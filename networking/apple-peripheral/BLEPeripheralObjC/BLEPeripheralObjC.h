#import "BLEPeripheralImpl.h"

#import <Foundation/Foundation.h>

@interface BLEPeripheral : NSObject // <CBPeripheralManagerDelegate>

//@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
//@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
//@property (strong, nonatomic) NSData *dataToSend;
//@property (nonatomic, readwrite) NSInteger sendDataIndex;

- (void) log:(const char *) str;

@end