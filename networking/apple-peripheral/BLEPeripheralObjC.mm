#import "BLEPeripheral.h"

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define RBL_SERVICE_UUID                         "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID                         "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID                         "713D0003-503E-4C75-BA94-3148F18D941E"

static NSInteger MAX_CHUNK_SIZE = 64;

@interface BLEPeripheralImpl : NSObject <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *writeCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *readCharacteristic;
@property (strong, nonatomic) NSMutableData *dataToSend;
@property (strong, nonatomic) NSMutableData *readBuffer;
@property (strong, nonatomic) NSString *serviceName;

@property (nonatomic, readwrite) NSUInteger readBufferIndex;
@property (nonatomic, readwrite) NSUInteger sendDataIndex;
@property (nonatomic, readwrite) NSUInteger numReadSubscribers;
@property (nonatomic, readwrite) NSUInteger numWriteSubscribers;


- (void) send;
- (void) write:(NSData *)data;
- (bool) connected;

@end

@implementation BLEPeripheralImpl

BLEPeripheral::BLEPeripheral(const char *name) : impl((__bridge_retained void*)[[BLEPeripheralImpl alloc] init: name]) { }

BLEPeripheral::~BLEPeripheral() {
    NSLog(@"Destroyed");
    (__bridge_transfer BLEPeripheralImpl*)impl;
}

void BLEPeripheral::write_byte(unsigned char data) {
    write(&data, 1);
}

void BLEPeripheral::write(const unsigned char *data, unsigned char len) {
    [(__bridge BLEPeripheralImpl*)impl write: [NSData dataWithBytes:data length:len]];
}

void BLEPeripheral::process() {}

unsigned char BLEPeripheral::read_byte() {
    BLEPeripheralImpl *p = (__bridge BLEPeripheralImpl*)impl;
    assert(p.readBuffer.length > p.readBufferIndex);
    unsigned char byte = ((unsigned char*)p.readBuffer.mutableBytes)[p.readBufferIndex++];
    if (p.readBuffer.length == p.readBufferIndex) {
        [p.readBuffer setLength:0];
        p.readBufferIndex = 0;
    }
    return byte;
}

unsigned char BLEPeripheral::bytes_available() {
    BLEPeripheralImpl *p = (__bridge BLEPeripheralImpl*)impl;
    return p.readBuffer.length - p.readBufferIndex;
}

bool BLEPeripheral::connected() {
    return [((__bridge BLEPeripheralImpl*)impl) connected];
}

- (id) init:(const char *) name {
    self = [super init];
    if (self) {
        NSLog(@"Initializaing");
        self.numReadSubscribers = 0;
        self.numWriteSubscribers = 0;
        self.sendDataIndex = 0;
        self.readBufferIndex = 0;
        self.dataToSend = [[NSMutableData alloc] init];
        self.readBuffer = [[NSMutableData alloc] init];
        self.serviceName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"[DEBUG] Device is not powered on");
        return;
    }
    NSLog(@"Adding service");
    self.readCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@RBL_CHAR_RX_UUID] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    self.writeCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@RBL_CHAR_TX_UUID] properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@RBL_SERVICE_UUID] primary:YES];
    service.characteristics = @[self.readCharacteristic, self.writeCharacteristic];
    
    [self.peripheralManager addService:service];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"Service Added");
    [self.peripheralManager startAdvertising: @{
                                                CBAdvertisementDataServiceUUIDsKey:
                                                    @[[CBUUID UUIDWithString: @RBL_SERVICE_UUID]],
                                                CBAdvertisementDataLocalNameKey: self.serviceName
                                                }
     ];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"Started Advertising");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    if (characteristic == self.readCharacteristic) {
        NSLog(@"Got a read subscriber");
        self.numReadSubscribers += 1;
    } else if (characteristic == self.writeCharacteristic) {
        NSLog(@"Got a write subscriber");
        self.numWriteSubscribers += 1;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic == self.readCharacteristic) {
        self.numReadSubscribers -= 1;
    } else if (characteristic == self.writeCharacteristic) {
        self.numWriteSubscribers -= 1;
    }
}

- (void)write:(NSData *)data {
    if (self.numWriteSubscribers == 0) {
        return;
    }
    if (self.sendDataIndex < self.dataToSend.length) {
        [self.dataToSend appendData:data];
        return;
    }
    self.sendDataIndex = 0;
    [self.dataToSend setData:data];
    [self send];
}

- (void) peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    if (self.sendDataIndex < self.dataToSend.length) {
        [self send];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"[DEBUG] Recieved read requests");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"[DEBUG] Recieved write requests");
    if (requests.count == 0) {
        return;
    }
    for (CBATTRequest *request in requests) {
        [self.readBuffer appendData:request.value];
    }
    [peripheral respondToRequest:requests[0] withResult:CBATTErrorSuccess];
}

- (bool) connected {
    return self.numWriteSubscribers > 0;
}

- (void)send {
    while (self.sendDataIndex < self.dataToSend.length) {
        NSUInteger length = self.dataToSend.length - self.sendDataIndex;
        if (length > MAX_CHUNK_SIZE) {
            length = MAX_CHUNK_SIZE;
        }
        NSData *chunk = [self.dataToSend subdataWithRange:{self.sendDataIndex, self.sendDataIndex + length}];
        bool didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.writeCharacteristic onSubscribedCentrals:nil];
        if (!didSend) {
            return;
        }
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        self.sendDataIndex += length;
    }
}


@end