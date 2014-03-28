//
//  PMAppDelegate.h
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainViewModel.h"
#import "ProjectionWindow.h"

@interface PMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet MainViewModel *viewModel;
@property (unsafe_unretained) IBOutlet ProjectionWindow *projectinoWindow;


- (IBAction)showEditor:(id)sender;

@end
