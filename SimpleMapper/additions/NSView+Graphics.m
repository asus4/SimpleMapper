//
//  NSView+Graphics.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "NSView+Graphics.h"

@implementation NSView (Graphics)



- (NSBezierPath*) makeCircle:(CGPoint)center radius:(CGFloat)radius
{
    return [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(center.x-radius, center.y-radius, radius*2, radius*2)];
}

@end
