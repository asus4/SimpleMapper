//
//  BaseGLView.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "BaseGLView.h"

@interface BaseGLView ()
@property NSSize lastSize;

@property MeshRect rect;
@end


@implementation BaseGLView

- (void) awakeFromNib
{
    const GLint on = 1;
	[[self openGLContext] setValues:&on forParameter:NSOpenGLCPSwapInterval];
    [self setWantsBestResolutionOpenGLSurface:YES];
    
    [self resize:self.superview.frame.size];
}

- (void) dealloc
{
    
}

- (void)drawRect:(NSRect)dirtyRect
{
//    [super drawRect:dirtyRect];
//    CGLContextObj cgl_ctx = [[self openGLContext] CGLContextObj];
    
    NSSize size = self.superview.frame.size;
    if(size.width != _lastSize.width || size.height != _lastSize.height) {
        [self reshape];
        _lastSize = size;
        [self resize:size];
    }
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    SyphonImage *image = self.image;
    if (image)
    {
        [self drawSyphon:image size:size];
    }
    [[self openGLContext] flushBuffer];
    
}

- (void) drawSyphon:(SyphonImage*) image size:(NSSize) size;
{
    glEnable(GL_TEXTURE_RECTANGLE_EXT);
    
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, image.textureName);
    
    glColor4f(1.0, 1.0, 1.0, 1.0);
    
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glTexCoordPointer(2, GL_FLOAT, 0, _rect.tex_coords );
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, _rect.vertex );
    
//    glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
//    glDrawArrays( GL_QUADS, 0, 4 );
//    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    glDrawArrays( GL_POLYGON, 0, 4 );
    
    
//    static int nf = sizeof face / sizeof face[0];
    
//    glEnable(GL_TEXTURE_2D);
//    glDrawElements(GL_TRIANGLES, nf * 3, GL_UNSIGNED_INT, face);
    
    glDisableClientState( GL_TEXTURE_COORD_ARRAY );
    glDisableClientState(GL_VERTEX_ARRAY);
    
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, 0);
    glDisable(GL_TEXTURE_RECTANGLE_EXT);
}

- (void) resize:(NSSize) size
{
    self.frame = NSMakeRect(0, 0, size.width, size.height);
    
    // Setup OpenGL states
    glViewport(0, 0, size.width, size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0.0, size.width, 0.0, size.height, -1, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
//    glTranslated(size.width * 0.5, size.height * 0.5, 0.0);
    
    [[self openGLContext] update];
    
    
    // rezie mesh
    NSSize textureSize = self.image.textureSize;
    NSSize scaled;
    float wr = textureSize.width / size.width;
    float hr = textureSize.height / size.height;
    float ratio;
    ratio = (hr < wr ? wr : hr);
    scaled = NSMakeSize((textureSize.width / ratio), (textureSize.height / ratio));
    
    _rect.tex_coords[0] = 0;
    _rect.tex_coords[1] = 0;
    _rect.tex_coords[2] = textureSize.width;
    _rect.tex_coords[3] = 0.0;
    _rect.tex_coords[4] = textureSize.width;
    _rect.tex_coords[5] = textureSize.height;
    _rect.tex_coords[6] = 0.0;
    _rect.tex_coords[7] = textureSize.height;
    
    
    _rect.vertex[0] = 0;
    _rect.vertex[1] = 0;
    _rect.vertex[2] = scaled.width;
    _rect.vertex[3] = 0;
    _rect.vertex[4] = scaled.width;
    _rect.vertex[5] = scaled.height;
    _rect.vertex[6] = 0;
    _rect.vertex[7] = scaled.height;
    
//    NSLog(@"sss : %f %f", halfw, halfh);
}

#pragma mark setter getter

- (void) setTextureCord:(RatePoints)textureCord
{
    _textureCord = textureCord;
    
    NSSize size = self.image.textureSize;
    int j = 0;
    for(int i=0; i<4; ++i) {
        _rect.tex_coords[j++] = textureCord.points[i].x * size.width;
        _rect.tex_coords[j++] = textureCord.points[i].y * size.height;
    }
}


- (void) setVertex:(RatePoints)vertex
{
    _vertex = vertex;
    
    NSSize size = self.frame.size;
    
    int j = 0;
    for(int i=0; i<4; ++i) {
        _rect.vertex[j++] = vertex.points[i].x * size.width;
        _rect.vertex[j++] = vertex.points[i].y * size.height;
    }
}
@end
