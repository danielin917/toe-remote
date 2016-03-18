#import "BLEPeripheralObjC.h"

@implementation BLEPeripheral

BLEPeripheralImpl::BLEPeripheralImpl() : self(NULL) {
    
}

BLEPeripheralImpl::~BLEPeripheralImpl() {
    //[(__bridge id)self dealloc];
}

void BLEPeripheralImpl::init() {
    self = (__bridge void*)[[BLEPeripheral alloc] init];
}

void BLEPeripheralImpl::log(const char *str) {
    [(__bridge id)self log:str];
}

- (void) log:(const char *) str {
    NSLog(@"%@",[NSString stringWithCString:str encoding:NSUTF8StringEncoding]);
}

@end