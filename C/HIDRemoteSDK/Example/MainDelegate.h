//
//  MainDelegate.h
//  HIDRemoteExample
//
//  Created by tsukino kantei on 2014/11/16.
//
//

#ifndef HIDRemoteExample_MainDelegate_h
#define HIDRemoteExample_MainDelegate_h

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "HIDRemote.h"

@interface MainDelegate : NSObject<HIDRemoteDelegate> {
    
    // -- HID Remote --
    HIDRemote			*hidRemote;
}

- (void)startOrStopRemoteWithExclusiveLock: (BOOL)toStart;


@end


#endif
