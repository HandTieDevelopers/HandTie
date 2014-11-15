//
//  main.m
//  irRemoteDaemon
//
//  Created by tsukino kantei on 2014/11/16.
//
//

#import <Foundation/Foundation.h>
#import "MainDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MainDelegate *delegate = [[MainDelegate alloc] init];
        [delegate startOrStopRemoteWithExclusiveLock:YES];CFRunLoopRun();
    }
    return 0;
}
