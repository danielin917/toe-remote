//
//  DataViewController.h
//  toe-remote
//
//  Created by Nick Terrell on 2/4/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end

