//
//  RectEditView.h
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MapperTypes.h"

// rect line
@interface RectLine : NSObject {
    @public
    NSPoint anchor[4];
}
- (id)initWithFrame:(NSRect)frame;
- (void)draw;
- (void)mouseDown:(NSPoint)point;
- (void)mouseDrag:(NSPoint)point;
- (void)mouseUp:(NSPoint)point;
@end


typedef void (^UpdateHandler)(RatePoints points);

// rect edit view
@interface RectEditView : NSView

@property (nonatomic, strong) RectLine *rect;

- (RatePoints) getNormalized;
- (void) setUpdateHandler:(UpdateHandler)func;
- (void) reset;
@end
