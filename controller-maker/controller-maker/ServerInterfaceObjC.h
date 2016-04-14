//
//  ServerInterfaceObjC.h
//  controller-maker
//
//  Created by Nick Terrell on 4/14/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

#ifndef ServerInterfaceObjC_h
#define ServerInterfaceObjC_h

#import <Carbon/Carbon.h>
#import <Foundation/Foundation.h>

@interface ServerInterfaceObjC : NSObject

- (id)init:(NSString *)name;

- (void)start;

- (void)dealloc;

- (void)addButton:(NSString *)label
         imageURL:(NSURL *)imageURL
                x:(uint8_t)x
                y:(uint8_t)y
            width:(uint8_t)width
           height:(uint8_t)height
           action:(uint16_t)action;
@end

#endif /* ServerInterfaceObjC_h */
