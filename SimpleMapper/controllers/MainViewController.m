//
//  MainViewController.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) awakeFromNib
{
    _projectionWindow.fullscreen = YES;
}

- (IBAction)reset:(id)sender {
    [self.viewModel reset];
}

- (IBAction)toggleFullscreen:(id)sender {
    // TODO : hide cursor
    _projectionWindow.fullscreen = !_projectionWindow.fullscreen;
    if(_projectionWindow.fullscreen) {
//        [NSCursor hide];
    }
    else {
//        [NSCursor unhide];
    }
    
}
@end
