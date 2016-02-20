//
//  RootViewController.h
//  toe-remote
//
//  Created by Nick Terrell on 2/4/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

