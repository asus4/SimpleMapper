//
//  PMAppDelegate.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "PMAppDelegate.h"
#import <Syphon/Syphon.h>

@implementation PMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (void) applicationWillTerminate:(NSNotification *)notification
{
    [self.viewModel finalize];
}

@end
