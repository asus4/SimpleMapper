//
//  BaseGLView.h
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Syphon/Syphon.h>
#import "MapperTypes.h"

@interface BaseGLView : NSOpenGLView

@property (nonatomic, strong) SyphonImage *image;

@property (nonatomic) RatePoints textureCord;
@property (nonatomic) RatePoints vertex;

- (void) resize:(NSSize) size;

@end
