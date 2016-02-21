//
//  SelectionViewController.h
//  toe-remote
//
//  Created by Nick Terrell on 2/21/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectionViewControllerDelegate <NSObject>

- (void) didSelect:(NSInteger)selected;

@end

@interface SelectionViewController : UITableViewController

@property (nonatomic, strong) NSArray *data;

@property (nonatomic, weak) id <SelectionViewControllerDelegate> delegate;

@end
