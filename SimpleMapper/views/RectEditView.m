//
//  RectEditView.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "RectEditView.h"
#import "NSView+Graphics.h"


static inline BOOL isSamePoint(NSPoint* a, NSPoint*b, double torrerance) {
    return fabs(a->x - b->x) < torrerance && fabs(a->y - b->y) < torrerance;
}

const int kAnchorLength = 4;
const int kAnchorRadius = 5;

@interface RectLine() {
    int hit;
}
@end


@implementation RectLine

- (id)initWithFrame:(NSRect)frame
{
    if(self == [super init]) {
        hit = -1;
        
        double x,y,w,h;
        x = frame.origin.x;
        y = frame.origin.y;
        w = frame.size.width;
        h = frame.size.height;
        
        anchor[0] = NSMakePoint(x, y);
        anchor[1] = NSMakePoint(x+w, y);
        anchor[2] = NSMakePoint(x+w, y+h);
        anchor[3] = NSMakePoint(x, y+h);
    }
    return self;
}

- (void)draw
{
    for(int i=0; i<kAnchorLength; ++i) {
        // draw circle
        NSBezierPath *p = [self makeCircle:anchor[i] radius:kAnchorRadius];
        if(hit == i) {
            [p fill];
        }
        else {
            [p stroke];
        }
        
        // draw line
        if(i < kAnchorLength-1) {
            [NSBezierPath strokeLineFromPoint:anchor[i] toPoint:anchor[i+1]];
        }
    }
    
    // close line
    [NSBezierPath strokeLineFromPoint:anchor[kAnchorLength-1] toPoint:anchor[0]];
}

- (void)mouseDown:(NSPoint)point
{
    hit = [self getHitAnchor:point];
}

- (void)mouseDrag:(NSPoint)point
{
    if(hit>=0) {
        anchor[hit] = point;
        if(!_allowQuad) {
            if(hit == 0) {
                anchor[1].y = point.y;
                anchor[3].x = point.x;
            }
            else if(hit == 1) {
                anchor[0].y = point.y;
                anchor[2].x = point.x;
            }
            else if(hit == 2) {
                anchor[1].x = point.x;
                anchor[3].y = point.y;
            }
            else if(hit == 3) {
                anchor[0].x = point.x;
                anchor[2].y = point.y;
            }
        }
        
    }
}

- (void)mouseUp:(NSPoint)point
{
    hit = -1;
}

// privates
- (NSBezierPath*) makeCircle:(CGPoint)center radius:(CGFloat)radius
{
    return [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(center.x-radius, center.y-radius, radius*2, radius*2)];
}

- (int) getHitAnchor:(NSPoint)point
{
    int hit_ = -1;
    for(int i=0; i<kAnchorLength; ++i) {
        if(isSamePoint(&anchor[i], &point, kAnchorRadius)) {
            hit_ = i;
        }
    }
    return hit_;
}
@end


#pragma mark class RectEditView

@interface RectEditView() {
    NSColor *lineColor;
    UpdateHandler updateHandler;
}
@end

@implementation RectEditView


- (id)initWithFrame:(NSRect)frame
{
    if (self == [super initWithFrame:frame]) {
        lineColor = [NSColor colorWithCalibratedRed:0.943 green:0.229 blue:0.238 alpha:0.7];
        self.rect = [[RectLine alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // fill brack
    [[NSColor colorWithCalibratedWhite:0 alpha:1] setFill];
    NSRectFill(dirtyRect);
    
    //
    [lineColor set];
    [_rect draw];
}

- (void) mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [_rect mouseDown:point];
    [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    [_rect mouseDrag:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent *)theEvent
{
    [_rect mouseUp:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    [self setNeedsDisplay:YES];
}

- (void) setNeedsDisplay:(BOOL)flag
{
    [super setNeedsDisplay:flag];
    if(updateHandler) {
        updateHandler([self getNormalized]);
    }
}

#pragma mark public methods

- (void) setAllowQuad:(BOOL)allowQuad
{
    _allowQuad = allowQuad;
    self.rect.allowQuad = allowQuad;
}

- (RatePoints) getNormalized
{
    RatePoints p;
    NSSize size = self.frame.size;
    
    for (int i=0; i<4; ++i) {
        p.points[i].x = _rect->anchor[i].x / size.width;
        p.points[i].y = _rect->anchor[i].y / size.height;
    }
    
    return p;
}

- (void) setUpdateHandler:(UpdateHandler)func
{
    updateHandler = func;
}

- (void) reset
{
    NSSize size = self.frame.size;
    
    _rect->anchor[0] = NSMakePoint(0, 0);
    _rect->anchor[1] = NSMakePoint(size.width, 0);
    _rect->anchor[2] = NSMakePoint(size.width, size.height);
    _rect->anchor[3] = NSMakePoint(0, size.height);
    [self setNeedsDisplay:YES];
}


@end
