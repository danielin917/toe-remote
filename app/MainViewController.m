//
//  MainViewController.m
//  toe-remote
//
//  Copyright © 2016 eecs481. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) BLE *ble;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UIButton *connectButton;

@property (nonatomic, strong) UIButton *randomButton;
@property (nonatomic, strong) UIButton *redButton;
@property (nonatomic, strong) UIButton *yellowButton;
@property (nonatomic, strong) UIButton *greenButton;
@property (nonatomic, strong) UIButton *blueButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the BLE object
    self.ble = [[BLE alloc] init];
    [self.ble controlSetup];
    self.ble.delegate = self;
    
    {
        // Set up the title bar
        self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/10.0f)];
        [self.view addSubview:self.titleView];
        // Set up the title
        float width = 100.0f;
        UILabel *title = [[UILabel alloc]
                      initWithFrame:CGRectMake((self.titleView.bounds.size.width - width)/2.0f,
                                               0,
                                               width,
                                               self.titleView.bounds.size.height)
                      ];
        title.text = @"Toe Remote";
        [self.titleView addSubview:title];
    }
    {
        // Set up the connect button
        self.connectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        float width = 100.0f;
        self.connectButton.frame = CGRectMake(self.titleView.bounds.size.width - width, 0.0f, width, self.titleView.bounds.size.height);
        [self.connectButton addTarget:self action:@selector(connectButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        [self.titleView addSubview:self.connectButton];
    }
    
    {
        // Set up the main view
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height/10.0f, self.view.bounds.size.width, self.view.bounds.size.height - self.view.bounds.size.height/10.0f)];
        [self.view addSubview:self.mainView];
        
        // Set up the random button
        {
            UIButton *button = self.randomButton;
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(0.0f, 0.0f, 100.0f, 30.0f);
            [button addTarget:self
                              action:@selector(randomButtonPressed)
                    forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Random" forState:UIControlStateNormal];
            button.hidden = true;
            [self.mainView addSubview:button];
        }
        {
            UIButton *button = self.redButton;
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(0.0f, 50.0f, 100.0f, 30.0f);
            [button addTarget:self
                       action:@selector(redButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Red" forState:UIControlStateNormal];
            button.hidden = true;
            [self.mainView addSubview:button];
        }
        {
            UIButton *button = self.yellowButton;
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(0.0f, 100.0f, 100.0f, 30.0f);
            [button addTarget:self
                       action:@selector(yellowButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Yellow" forState:UIControlStateNormal];
            button.hidden = true;
            [self.mainView addSubview:button];
        }
        {
            UIButton *button = self.greenButton;
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(0.0f, 150.0f, 100.0f, 30.0f);
            [button addTarget:self
                       action:@selector(greenButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Green" forState:UIControlStateNormal];
            button.hidden = true;
            [self.mainView addSubview:button];
        }
        {
            UIButton *button = self.blueButton;
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(0.0f, 200.0f, 100.0f, 30.0f);
            [button addTarget:self
                       action:@selector(blueButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Blue" forState:UIControlStateNormal];
            button.hidden = true;
            [self.mainView addSubview:button];
        }
    }
}

#pragma mark - Button Actions

- (void)randomButtonPressed {
    UInt8 buf[1] = {0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [self.ble write:data];
}

- (void)redButtonPressed {
    UInt8 buf[1] = {0x01};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [self.ble write:data];
}

- (void)yellowButtonPressed {
    UInt8 buf[1] = {0x02};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [self.ble write:data];
}

- (void)greenButtonPressed {
    UInt8 buf[1] = {0x03};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [self.ble write:data];
}

- (void)blueButtonPressed {
    UInt8 buf[1] = {0x04};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [self.ble write:data];
}

- (void)connectButtonPressed {
    // If we are connected to a peripheral, then disconnect.
    if (self.ble.activePeripheral) {
        if (self.ble.activePeripheral.state == CBPeripheralStateConnected) {
            [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
            return;
        }
    }
    // Otherwise, clear the peripheral list.
    if (self.ble.peripherals) {
        self.ble.peripherals = nil;
    }
    
    // Search for peripherals with a 2 second timeout.
    [self.ble findBLEPeripherals:2];
    
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
    if (self.ble.peripherals.count == 0) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"No devices found"
                                              message:@""
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"Okay"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    // Present selection view controller.
    SelectionViewController *selectionController = [[SelectionViewController alloc] init];
    // Style
    selectionController.modalPresentationStyle = UIModalPresentationPageSheet;
    selectionController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    // Data
    selectionController.data = self.ble.peripherals;
    selectionController.delegate = self;
    [self showViewController:selectionController sender:self];
    
    // Connect to the first device on the list.  This behavior needs to be changed.
    // [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];
    
}

#pragma mark - BLEDelegate

- (void) bleDidDisconnect {
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    
    self.randomButton.hidden = true;
    self.redButton.hidden = true;
    self.yellowButton.hidden = true;
    self.greenButton.hidden = true;
    self.blueButton.hidden = true;

}

-(void) bleDidConnect {
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    self.randomButton.hidden = false;
    self.redButton.hidden = false;
    self.yellowButton.hidden = false;
    self.greenButton.hidden = false;
    self.blueButton.hidden = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SelectionViewControllerDelegate

- (void) didSelect:(NSInteger)selected {
    [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:selected]];
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
