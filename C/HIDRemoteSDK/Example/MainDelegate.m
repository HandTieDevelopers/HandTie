//
//  MainDelegate.m
//  HIDRemoteExample
//
//  Created by tsukino kantei on 2014/11/16.
//
//
#import <stdio.h>
#import "HIDRemote.h"
#import "MainDelegate.h"

@implementation MainDelegate

#pragma mark -- initialization --
- (id)init
{
    if((self = [super init]) != nil) {
        if ([HIDRemote isCandelairInstallationRequiredForRemoteMode:kHIDRemoteModeExclusiveAuto]) {
            // Candelair needs to be installed. Inform the user about it.
            printf("you need to install \"Candelair\" driver for using this application,please google and install it\n");
            exit(-1);
        }
        
        hidRemote = nil;
        [self setupRemote];
    }
    
    return self;
}

#pragma mark -- Deallocation --
- (void)dealloc
{
    [self cleanupRemote];
}

- (void)setupRemote
{
    if (!hidRemote)
    {
        if ((hidRemote = [[HIDRemote alloc] init]) != nil)
        {
            [hidRemote setDelegate:self];
            [self setUnusedButtonCodes];
        }
    }
}

//prevent user from activating unintendedly.
- (void)setUnusedButtonCodes
{
    [hidRemote setUnusedButtonCodes:[NSArray arrayWithObjects:
                                                      /* [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeMenuHold],
                                                    [NSNumber numberWithInt:(int)kHIDRemoteButtonCodePlayHold],
                                                       */
                                                    [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeCenterHold],
                                     [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeUpHold],
                                     [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeDownHold],
                                     [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeLeftHold],
                                     [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeRightHold],
                                                       nil]
     ];
    return;
}

- (void)cleanupRemote
{
    if ([hidRemote isStarted])
    {
        [hidRemote stopRemoteControl];
    }
    [hidRemote setDelegate:nil];
    hidRemote = nil;
    return;
}

- (void)startOrStopRemoteWithExclusiveLock: (BOOL)toStart
{
    // Has the HID Remote already been started?
    if ([hidRemote isStarted])
    {
        // HID Remote already started. Stop it.
        [hidRemote stopRemoteControl];
    }
    
    if(!toStart) { //toStop
        return;
    }
    
    [hidRemote startRemoteControl:kHIDRemoteModeExclusiveAuto];
    return;
}

#pragma mark -- Handle remote control events --
- (void)hidRemote:(HIDRemote *)hidRemote eventWithButton:(HIDRemoteButtonCode)buttonCode isPressed:(BOOL)isPressed fromHardwareWithAttributes:(NSMutableDictionary *)attributes
{
    const char* buttonName = NULL;
    
    if (!isPressed) //currently we only need pressed event
    {
        return;
    }
    
    switch (buttonCode)
    {
        case kHIDRemoteButtonCodeUp:
            buttonName = "U";
            break;
        case kHIDRemoteButtonCodeDown:
            buttonName = "D";
            break;
        case kHIDRemoteButtonCodeLeft:
            buttonName = "L";
            break;
        case kHIDRemoteButtonCodeRight:
            buttonName = "R";
            break;
        case kHIDRemoteButtonCodeCenter:
            buttonName = "C";
            break;
        case kHIDRemoteButtonCodeMenu:
            buttonName = "M";
            break;
        case kHIDRemoteButtonCodePlay:
            buttonName = "P";
            break;
        /*
        case kHIDRemoteButtonCodeUpHold:
            buttonName = @"Up (hold)";
            break;
        case kHIDRemoteButtonCodeDownHold:
            buttonName = @"Down (hold)";
            break;
        case kHIDRemoteButtonCodeLeftHold:
            buttonName = @"Left (hold)";
            break;
        case kHIDRemoteButtonCodeRightHold:
            buttonName = @"Right (hold)";
            break;
        case kHIDRemoteButtonCodeCenterHold:
            buttonName = @"Center (hold)";
            break;
        */
        case kHIDRemoteButtonCodeMenuHold:
            buttonName = "N";
            break;
        case kHIDRemoteButtonCodePlayHold:
            buttonName = "O";
            break;
        default:
            buttonName = "O";
            break;
    }
    
    fprintf(stderr,"%s\n",buttonName);
    
    return;
}

@end