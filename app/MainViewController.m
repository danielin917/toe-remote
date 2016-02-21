//
//  MainViewController.m
//  toe-remote
//
//  Copyright © 2016 eecs481. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) BLE *bleShield;

@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, strong) UIButton *onButton;
@property (nonatomic, strong) UIButton *offButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup];
    self.bleShield.delegate = self;
    
    // Set up the connect button
    self.connectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.connectButton.frame = CGRectMake(110.0f, 50.0f, 100.0f, 30.0f);
    [self.connectButton addTarget:self
                action:@selector(connectButtonPressed)
      forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.view addSubview:self.connectButton];
    
    // Set up the on button
    self.onButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.onButton.frame = CGRectMake(110.0f, 150.0f, 100.0f, 30.0f);
    [self.onButton addTarget:self
            action:@selector(onButtonPressed)
            forControlEvents:UIControlEventTouchUpInside];
    [self.onButton setTitle:@"On" forState:UIControlStateNormal];
    self.onButton.hidden = true;
    [self.view addSubview:self.onButton];
    
    // Set up the off button
    self.offButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.offButton.frame = CGRectMake(55.0f, 250.0f, 100.0f, 30.0f);
    [self.offButton addTarget:self
               action:@selector(offButtonPressed)
     forControlEvents:UIControlEventTouchUpInside];
    [self.offButton setTitle:@"Off" forState:UIControlStateNormal];
    self.offButton.hidden = true;
    [self.view addSubview:self.offButton];
}

#pragma mark - Button Actions

- (void)onButtonPressed {
    UInt8 buf[1] = {0x01};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [self.bleShield write:data];
}

- (void)offButtonPressed {
    UInt8 buf[1] = {0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [self.bleShield write:data];
}

- (void)connectButtonPressed {
    // If we are connected to a peripheral, then disconnect.
    if (self.bleShield.activePeripheral) {
        if (self.bleShield.activePeripheral.state == CBPeripheralStateConnected) {
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
            return;
        }
    }
    // Otherwise, clear the peripheral list.
    if (self.bleShield.peripherals) {
        self.bleShield.peripherals = nil;
    }
    
    // Search for peripherals with a 2 second timeout.
    [self.bleShield findBLEPeripherals:2];
    
    // Call a handler when the interval has elapsed.
    [NSTimer
     scheduledTimerWithTimeInterval:(float)2.0
     target:self
     selector:@selector(connectionTimer:)
     userInfo:nil
     repeats:NO];

}

- (void)connectionTimer:(NSTimer *)timer {
    // Handle failure to find a device.
    if (self.bleShield.peripherals.count == 0) {
        return;
    }
    
    // Connect to the first device on the list.  This behavior needs to be changed.
    [self.bleShield connectPeripheral:[self.bleShield.peripherals objectAtIndex:0]];
    
}

#pragma mark - BLEDelegate

- (void) bleDidDisconnect {
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    self.onButton.hidden = true;
    self.offButton.hidden = true;
}

-(void) bleDidConnect {
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    self.onButton.hidden = false;
    self.offButton.hidden = false;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
