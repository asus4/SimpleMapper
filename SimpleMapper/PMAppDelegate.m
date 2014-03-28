//
//  PMAppDelegate.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "PMAppDelegate.h"

@implementation PMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _projectinoWindow.fullscreen = YES;
    _projectinoWindow.fullscreen = NO;
    _projectinoWindow.fullscreen = YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
    [self.viewModel finalize];
}

- (IBAction)showEditor:(id)sender {
    [_window makeKeyAndOrderFront:nil];
}

@end
