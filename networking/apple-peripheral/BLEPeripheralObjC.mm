#import "BLEPeripheralObjC.h"
#import "BLEPeripheral.h"

#define RBL_SERVICE_UUID                         "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID                         "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID                         "713D0003-503E-4C75-BA94-3148F18D941E"

static NSInteger MAX_CHUNK_SIZE = 64;

@interface BLEPeripheralImpl()

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *writeCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *readCharacteristic;
@property (strong, nonatomic) NSMutableData *dataToSend;
@property (strong, nonatomic) NSString *serviceName;

@property (nonatomic, readwrite) NSUInteger sendDataIndex;
@property (nonatomic, readwrite) NSUInteger numReadSubscribers;
@property (nonatomic, readwrite) NSUInteger numWriteSubscribers;


- (void) send;

@end

@implementation BLEPeripheralImpl

BLEPeripheral::BLEPeripheral(const char *name) : impl((__bridge_retained void*)[[BLEPeripheralImpl alloc] init: name]) { }

BLEPeripheral::~BLEPeripheral() {
    NSLog(@"Destroyed");
    (__bridge_transfer id)impl;
}

void BLEPeripheral::write_byte(unsigned char data) {
    write(&data, 1);
}

void BLEPeripheral::write(const unsigned char *data, unsigned char len) {
    [(__bridge id)impl write: [NSData dataWithBytes:data length:len]];
}

void BLEPeripheral::process() {}

unsigned char BLEPeripheral::read_byte() {
    return 0;
}

unsigned char BLEPeripheral::bytes_available() {
    return 0;
}

bool BLEPeripheral::connected() {
    return [((__bridge id)impl) connected];
}

- (id) init:(const char *) name {
    self = [super init];
    if (self) {
        NSLog(@"Initializaing");
        self.numReadSubscribers = 0;
        self.numWriteSubscribers = 0;
        self.sendDataIndex = 0;
        self.dataToSend = [[NSMutableData alloc] init];
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
    self.readCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@RBL_CHAR_RX_UUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsWriteable];
    self.writeCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@RBL_CHAR_TX_UUID] properties:CBCharacteristicPropertyWriteWithoutResponse|CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
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

- (bool) connected {
    // return true;
    return self.numWriteSubscribers > 0 && self.numReadSubscribers > 0;
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

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    if (self.sendDataIndex < self.dataToSend.length) {
        [self send];
    }
}


@end