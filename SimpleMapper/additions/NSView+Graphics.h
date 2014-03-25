//
//  NSView+Graphics.h
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Graphics)
- (NSBezierPath*) makeCircle:(CGPoint) center radius:(CGFloat) radius;
@end
