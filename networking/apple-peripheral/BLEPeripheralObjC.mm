#import "BLEPeripheral.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#define RBL_SERVICE_UUID "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID "713D0003-503E-4C75-BA94-3148F18D941E"

static NSInteger MAX_CHUNK_SIZE = 64;

@interface BLEPeripheralImpl : NSObject <CBPeripheralManagerDelegate>

@property(strong, nonatomic) CBPeripheralManager *peripheralManager;
@property(strong, nonatomic) CBMutableCharacteristic *writeCharacteristic;
@property(strong, nonatomic) CBMutableCharacteristic *readCharacteristic;
@property(strong, nonatomic) NSMutableData *dataToSend;
@property(strong, nonatomic) NSMutableData *readBuffer;
@property(strong, nonatomic) NSString *serviceName;

@property(nonatomic, readwrite) NSUInteger readBufferIndex;
@property(nonatomic, readwrite) NSUInteger sendDataIndex;
@property(nonatomic, readwrite) NSUInteger numSubscribers;

@property(nonatomic, readwrite) read_handler_t readHandler;
@property(nonatomic, readwrite) void *serverInterface;

- (void)send;
- (void)write:(NSData *)data;
- (void)advertise:(BOOL)shouldAdvertise;
- (void)cleanup;

@end

@implementation BLEPeripheralImpl

BLEPeripheral::BLEPeripheral(const char *name)
    : impl((__bridge_retained void *)[[BLEPeripheralImpl alloc]
          initWithServiceName:[NSString
                                  stringWithCString:name
                                           encoding:NSUTF8StringEncoding]]) {}

BLEPeripheral::~BLEPeripheral() {
    NSLog(@"Destroyed");
    BLEPeripheralImpl *_impl = (__bridge_transfer BLEPeripheralImpl *)impl;
    [_impl cleanup];
}

void BLEPeripheral::write_byte(unsigned char data) { write(&data, 1); }

void BLEPeripheral::write(const unsigned char *data, unsigned char len) {
    [(__bridge BLEPeripheralImpl *)impl
        write:[NSData dataWithBytes:data length:len]];
}

void BLEPeripheral::process() {}

bool BLEPeripheral::allows_async() { return true; }

void BLEPeripheral::register_read_handler(void *serverInterface,
                                          read_handler_t readHandler) {
    ((__bridge BLEPeripheralImpl *)impl).serverInterface = serverInterface;
    ((__bridge BLEPeripheralImpl *)impl).readHandler = readHandler;
}

unsigned char BLEPeripheral::read_byte() {
    NSLog(@"Not supported");
    exit(1);
}

unsigned char BLEPeripheral::bytes_available() {
    NSLog(@"Not supported");
    exit(1);
}

bool BLEPeripheral::connected() {
    return ((__bridge BLEPeripheralImpl *)impl).numSubscribers > 0;
}

- (id)initWithServiceName:(NSString *)name {
    self = [super init];
    if (self) {
        NSLog(@"Initializaing");
        self.numSubscribers = 0;
        self.sendDataIndex = 0;
        self.readBufferIndex = 0;
        self.dataToSend = [[NSMutableData alloc] init];
        self.readBuffer = [[NSMutableData alloc] init];
        self.serviceName = name;

        self.peripheralManager = [[CBPeripheralManager alloc]
            initWithDelegate:self
                       queue:dispatch_get_global_queue(
                                 DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

        self.readHandler = nullptr;
        self.serverInterface = nullptr;
    }
    return self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"[DEBUG] Device is not powered on");
        return;
    }
    NSLog(@"Adding service");
    self.readCharacteristic = [[CBMutableCharacteristic alloc]
        initWithType:[CBUUID UUIDWithString:@RBL_CHAR_RX_UUID]
          properties:CBCharacteristicPropertyWriteWithoutResponse
               value:nil
         permissions:CBAttributePermissionsWriteable];
    self.writeCharacteristic = [[CBMutableCharacteristic alloc]
        initWithType:[CBUUID UUIDWithString:@RBL_CHAR_TX_UUID]
          properties:CBCharacteristicPropertyRead |
                     CBCharacteristicPropertyNotify
               value:nil
         permissions:CBAttributePermissionsReadable];

    CBMutableService *service = [[CBMutableService alloc]
        initWithType:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]
             primary:YES];
    service.characteristics =
        @[ self.readCharacteristic, self.writeCharacteristic ];

    [self.peripheralManager addService:service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    NSLog(@"Service Added");
    [self advertise:true];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    NSLog(@"Started Advertising");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                         central:(CBCentral *)central
    didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {

    if (characteristic == self.writeCharacteristic) {
        NSLog(@"Got a subscriber");
        self.numSubscribers += 1;
        assert(self.numSubscribers == 1);
        [self advertise:false];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                             central:(CBCentral *)central
    didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic == self.writeCharacteristic) {
        NSLog(@"Lost a subscriber");
        self.numSubscribers -= 1;
        assert(self.numSubscribers == 0);
        [self advertise:true];
    }
}

- (void)write:(NSData *)data {
    NSLog(@"[DEBUG] Data to write: %@", [data description]);
    if (self.numSubscribers == 0) {
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

- (void)peripheralManagerIsReadyToUpdateSubscribers:
    (CBPeripheralManager *)peripheral {
    if (self.sendDataIndex < self.dataToSend.length) {
        [self send];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"[DEBUG] Recieved read requests");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
  didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"[DEBUG] Recieved write requests");
    if (requests.count == 0) {
        return;
    }
    for (CBATTRequest *request in requests) {
        NSLog(@"[DEBUG] Sent data: %@", [request.value description]);
        [self.readBuffer appendData:request.value];
    }
    if (self.readHandler != nullptr) {
        NSData *d = [[NSData alloc]
            initWithBytes:(void *)((unsigned char *)self.readBuffer.bytes +
                                   self.readBufferIndex)
                   length:self.readBuffer.length - self.readBufferIndex];
        NSLog(@"[DEBUG] Passing data to callback: %@", [d description]);
        self.readBufferIndex += self.readHandler(
            self.serverInterface,
            (unsigned char *)self.readBuffer.bytes + self.readBufferIndex,
            self.readBuffer.length - self.readBufferIndex);
        if (self.readBufferIndex == self.readBuffer.length) {
            [self.readBuffer setLength:0];
            self.readBufferIndex = 0;
        }
    }
    [peripheral respondToRequest:requests[0] withResult:CBATTErrorSuccess];
}

- (void)advertise:(BOOL)shouldAdvertise {
    if (shouldAdvertise) {
        [self.peripheralManager startAdvertising:@{
            CBAdvertisementDataServiceUUIDsKey :
                @[ [CBUUID UUIDWithString:@RBL_SERVICE_UUID] ],
            CBAdvertisementDataLocalNameKey : self.serviceName
        }];
        NSLog(@"Advertisement started");
    } else {
        [self.peripheralManager stopAdvertising];
        NSLog(@"Advertisement stopped");
    }
}

- (void)send {
    while (self.sendDataIndex < self.dataToSend.length) {
        NSUInteger length = self.dataToSend.length - self.sendDataIndex;
        if (length > MAX_CHUNK_SIZE) {
            length = MAX_CHUNK_SIZE;
        }
        NSData *chunk =
            [self.dataToSend subdataWithRange:{self.sendDataIndex, length}];
        bool didSend =
            [self.peripheralManager updateValue:chunk
                              forCharacteristic:self.writeCharacteristic
                           onSubscribedCentrals:nil];
        if (!didSend) {
            return;
        }
        NSLog(@"Sent: %@", [chunk description]);
        self.sendDataIndex += length;
    }
}

- (void)cleanup {
    [self advertise:false];
    [self.peripheralManager removeAllServices];
}

@end