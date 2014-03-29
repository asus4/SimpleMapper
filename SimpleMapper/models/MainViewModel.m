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
    self.inEditView.allowQuad = NO;
    self.outEditView.allowQuad = YES;
    
    [self.syphonServersController bind:@"contentArray" toObject:[SyphonServerDirectory sharedDirectory] withKeyPath:@"servers" options:nil];
    
    [self bind:@"selectedServerDescriptions" toObject:self.syphonServersController withKeyPath:@"selectedObjects" options:nil];
    
    [self load];
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
                _glView.textureCord = [self.inEditView getNormalized];
                _glView.vertex = [self.outEditView getNormalized];
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
    [self save];
}

- (void) load
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *inData = [ud dataForKey:@"GL_IN_DATA"];
    NSData *outData = [ud dataForKey:@"GL_OUT_DATA"];
    
    if(!inData || !outData) {
        return;
    }
    
    NSPoint *inPoint = (NSPoint*) inData.bytes;
    NSPoint *outPoint = (NSPoint*) outData.bytes;
    
    for(int i=0; i<4; ++i) {
        _inEditView.rect->anchor[i] = inPoint[i];
        _outEditView.rect->anchor[i] = outPoint[i];
    }
}

- (void) save
{
    int dataLength = sizeof(NSPoint)*4;
    NSData * inData = [NSData dataWithBytes:_inEditView.rect->anchor length:dataLength];
    NSData * outData = [NSData dataWithBytes:_outEditView.rect->anchor length:dataLength];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:inData forKey:@"GL_IN_DATA"];
    [ud setObject:outData forKey:@"GL_OUT_DATA"];
    [ud synchronize];
}


@end
