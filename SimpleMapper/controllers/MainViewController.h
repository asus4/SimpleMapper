//
//  MainViewController.h
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainViewModel.h"
#import "ProjectionWindow.h"

@interface MainViewController : NSViewController

@property (unsafe_unretained) IBOutlet ProjectionWindow *projectionWindow;
@property (weak) IBOutlet MainViewModel *viewModel;

- (IBAction)reset:(id)sender;
- (IBAction)toggleFullscreen:(id)sender;

@end
