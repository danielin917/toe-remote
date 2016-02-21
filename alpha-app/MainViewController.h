//
//  MainViewController.h
//  toe-remote
//
//  Created by Nick Terrell on 2/20/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "SelectionViewController.h"

@interface MainViewController : UIViewController <BLEDelegate, SelectionViewControllerDelegate>

@end
