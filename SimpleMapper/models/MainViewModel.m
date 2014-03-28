//
//  MainViewModel.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "MainViewModel.h"

@implementation MainViewModel {
    
}

- (id) init
{
    if(self == [super init]) {
        
    }
    return self;
}

- (void) awakeFromNib
{
    [self.syphonServersController bind:@"contentArray" toObject:[SyphonServerDirectory sharedDirectory] withKeyPath:@"servers" options:nil];

    
    [self bind:@"selectedServerDescriptions" toObject:self.syphonServersController withKeyPath:@"selectedObjects" options:nil];
    
}


#pragma setter getter

- (void) setSelectedServerDescriptions:(NSArray *)selectedServerDescriptions
{
    if(selectedServerDescriptions.count == 0) {
        return;
    }
    if([selectedServerDescriptions isEqualToArray:_selectedServerDescriptions]) {
        return;
    }
    
    NSLog(@"selectedServerDescription : %@", selectedServerDescriptions);
    
    __block BOOL initialized = NO;
    
    // setup syphon
    [_syphonClient stop];
    _syphonClient = [[SyphonClient alloc] initWithServerDescription:selectedServerDescriptions.lastObject
                                                            options:nil
                                                    newFrameHandler:^(SyphonClient *client) {
        // This gets called whenever the client receives a new frame.
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            SyphonImage *frame = [_syphonClient newFrameImageForContext:[[_glView openGLContext] CGLContextObj]];
            
            _glView.image = frame;
            [_glView setNeedsDisplay:YES];
            
            if(!initialized) {
                [_glView resize:_glView.superview.frame.size];
                initialized = YES;
            }
        }];
    }];
    
    [self.inEditView setUpdateHandler:^(RatePoints points) {
        _glView.textureCord = points;
    }];
    
    [self.outEditView setUpdateHandler:^(RatePoints points) {
        _glView.vertex = points;
    }];
}

#pragma public methods

- (void) reset
{
    [self.inEditView reset];
    [self.outEditView reset];
}

- (void) finalize
{
    [self.syphonClient stop];
}


@end
