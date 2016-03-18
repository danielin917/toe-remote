#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEPeripheralImpl : NSObject <CBPeripheralManagerDelegate>

- (void) write:(NSData *)data;
- (bool) connected;

@end