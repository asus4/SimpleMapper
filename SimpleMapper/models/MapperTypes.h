//
//  MapperTypes.h
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/24.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#ifndef SimpleMapper_MapperTypes_h
#define SimpleMapper_MapperTypes_h


typedef struct {
    GLfloat vertex[8];
    GLfloat tex_coords[8];
} MeshRect;

typedef struct {
    CGPoint points[4];
} RatePoints;

#endif
