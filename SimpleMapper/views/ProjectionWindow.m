//
//  ProjectionWindow.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/25.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "ProjectionWindow.h"

@interface ProjectionWindow() {
    NSPoint initialPosition;
}

@end

@implementation ProjectionWindow

- (void) awakeFromNib
{
    [self setLevel:kCGScreenSaverWindowLevel];
}

- (void) mouseDown:(NSEvent *)theEvent
{
    initialPosition = theEvent.locationInWindow;
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    NSPoint p = self.mouseLocationOutsideOfEventStream;
    NSRect current = [self convertRectToScreen:NSMakeRect(p.x, p.y, 0, 0)];
    NSPoint next;
    next.x = current.origin.x - initialPosition.x;
    next.y = current.origin.y - initialPosition.y;
    [self setFrameOrigin:next];
}

#pragma mark setter getter

- (void) setFullscreen:(BOOL)fullscreen {
    _fullscreen = fullscreen;
    
    NSRect rect;
    if(fullscreen) {
        rect = [[NSScreen screens].lastObject frame];
        [self setFrame:rect display:YES];
    }
    else {
        [self setFrame:NSMakeRect(30, 30, 640, 480) display:YES];
    }
    
}

@end
