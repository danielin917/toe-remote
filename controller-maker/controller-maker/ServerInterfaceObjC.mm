//
//  ServerInterfaceObjC.m
//  controller-maker
//
//  Created by Nick Terrell on 4/14/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

#import "../../networking/Main_sketch/ServerInterface.h"
#import "../../networking/apple-peripheral/SimulateKeypress.h"
#import "ServerInterfaceObjC.h"
#import <Foundation/Foundation.h>

@interface ServerInterfaceObjC ()

@property(readwrite, nonatomic) toe::ServerInterface<SimulateKeypress> *impl;

@end

@implementation ServerInterfaceObjC

- (id)init:(NSString *)name {
    const char *nameString = [name cStringUsingEncoding:NSUTF8StringEncoding];
    self.impl = new toe::ServerInterface<SimulateKeypress>();
    self.impl->set_device_name(nameString);
    self = [super init];
    return self;
}

- (void)dealloc {
    NSLog(@"Dealloc");
    delete self.impl;
}

- (void)start {
    self.impl->start_server();
}

- (void)addButton:(NSString *)label
         imageURL:(NSURL *)imageURL
                x:(uint8_t)x
                y:(uint8_t)y
            width:(uint8_t)width
           height:(uint8_t)height
           action:(uint16_t)action {
    const char *labelString = [label cStringUsingEncoding:NSUTF8StringEncoding];
    bool border = true;
    const char *imageString = nullptr;
    if (imageURL != NULL) {
        border = false;
        imageString = [[imageURL absoluteString]
            cStringUsingEncoding:NSUTF8StringEncoding];
    }

    self.impl->add_button(
        toe::Button{x, y, width, height, labelString, border, imageString},
        SimulateKeypress{action});
}

@end