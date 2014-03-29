//
//  BaseGLView.m
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import "BaseGLView.h"


// https://gitorious.org/projection-mapping/projection-mapping/
void gaussian_elimination(float *input, int n) {
    // ported to c from pseudocode in
    // http://en.wikipedia.org/wiki/Gaussian_elimination
    
    float * A = input;
    int i = 0;
    int j = 0;
    int m = n-1;
    while (i < m && j < n)
    {
        // Find pivot in column j, starting in row i:
        int maxi = i;
        for(int k = i+1; k<m; k++)
        {
            if(fabs(A[k*n+j]) > fabs(A[maxi*n+j]))
            {
                maxi = k;
            }
        }
        if (A[maxi*n+j] != 0)
        {
            //swap rows i and maxi, but do not change the value of i
            if(i!=maxi)
                for(int k=0; k<n; k++)
                {
                    float aux = A[i*n+k];
                    A[i*n+k]=A[maxi*n+k];
                    A[maxi*n+k]=aux;
                }
            //Now A[i,j] will contain the old value of A[maxi,j].
            //divide each entry in row i by A[i,j]
            float A_ij=A[i*n+j];
            for(int k=0; k<n; k++)
            {
                A[i*n+k]/=A_ij;
            }
            //Now A[i,j] will have the value 1.
            for(int u = i+1; u< m; u++)
            {
                //subtract A[u,j] * row i from row u
                float A_uj = A[u*n+j];
                for(int k=0; k<n; k++)
                {
                    A[u*n+k]-=A_uj*A[i*n+k];
                }
                //Now A[u,j] will be 0, since A[u,j] - A[i,j] * A[u,j] = A[u,j] - 1 * A[u,j] = 0.
            }
            
            i++;
        }
        j++;
    }
    
    //back substitution
    for(int i=m-2; i>=0; i--)
    {
        for(int j=i+1; j<n-1; j++)
        {
            A[i*n+m]-=A[i*n+j]*A[j*n+m];
            //A[i*n+j]=0;
        }
    }
}

void findHomography(NSPoint src[4], NSPoint dst[4], float homography[16])
{
    
    // create the equation system to be solved
    //
    // from: Multiple View Geometry in Computer Vision 2ed
    //       Hartley R. and Zisserman A.
    //
    // x' = xH
    // where H is the homography: a 3 by 3 matrix
    // that transformed to inhomogeneous coordinates for each point
    // gives the following equations for each point:
    //
    // x' * (h31*x + h32*y + h33) = h11*x + h12*y + h13
    // y' * (h31*x + h32*y + h33) = h21*x + h22*y + h23
    //
    // as the homography is scale independent we can let h33 be 1 (indeed any of the terms)
    // so for 4 points we have 8 equations for 8 terms to solve: h11 - h32
    // after ordering the terms it gives the following matrix
    // that can be solved with gaussian elimination:
    
    float P[8][9]=
    {
        {-src[0].x, -src[0].y, -1,   0,   0,  0, src[0].x*dst[0].x, src[0].y*dst[0].x, -dst[0].x }, // h11
        {  0,   0,  0, -src[0].x, -src[0].y, -1, src[0].x*dst[0].y, src[0].y*dst[0].y, -dst[0].y }, // h12
        
        {-src[1].x, -src[1].y, -1,   0,   0,  0, src[1].x*dst[1].x, src[1].y*dst[1].x, -dst[1].x }, // h13
        {  0,   0,  0, -src[1].x, -src[1].y, -1, src[1].x*dst[1].y, src[1].y*dst[1].y, -dst[1].y }, // h21
        
        {-src[2].x, -src[2].y, -1,   0,   0,  0, src[2].x*dst[2].x, src[2].y*dst[2].x, -dst[2].x }, // h22
        {  0,   0,  0, -src[2].x, -src[2].y, -1, src[2].x*dst[2].y, src[2].y*dst[2].y, -dst[2].y }, // h23
        
        {-src[3].x, -src[3].y, -1,   0,   0,  0, src[3].x*dst[3].x, src[3].y*dst[3].x, -dst[3].x }, // h31
        {  0,   0,  0, -src[3].x, -src[3].y, -1, src[3].x*dst[3].y, src[3].y*dst[3].y, -dst[3].y }, // h32
    };
    
    gaussian_elimination(&P[0][0],9);
    
    // gaussian elimination gives the results of the equation system
    // in the last column of the original matrix.
    // opengl needs the transposed 4x4 matrix:
    float aux_H[]= { P[0][8],P[3][8],0,P[6][8], // h11  h21 0 h31
        P[1][8],P[4][8],0,P[7][8], // h12  h22 0 h32
        0      ,      0,0,0,       // 0    0   0 0
        P[2][8],P[5][8],0,1
    };      // h13  h23 0 h33
    
    for(int i=0; i<16; i++) homography[i] = aux_H[i];
}


static inline NSPoint convertPoint(NSPoint *p) {
    NSPoint n;
    n.x = (p->x - 0.5) * 2;
    n.y = (p->y - 0.5) * 2;
    return n;
}



@interface BaseGLView () {
    GLfloat matrix[16];
    RatePoints normalVertex;
}
@property NSSize lastSize;

@property MeshRect rect;
@end


@implementation BaseGLView

- (void) awakeFromNib
{
    const GLint on = 1;
	[[self openGLContext] setValues:&on forParameter:NSOpenGLCPSwapInterval];
    [self setWantsBestResolutionOpenGLSurface:YES];
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
    
    glPushMatrix();
    
    findHomography(normalVertex.points, _vertex.points, matrix);
    glLoadMatrixf(matrix);
    
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glTexCoordPointer(2, GL_FLOAT, 0, _rect.tex_coords );
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, _rect.vertex );
    
    glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
    
    glPopMatrix();
    
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
    glOrtho(0.0, size.width, 0.0, size.height, -size.width, size.width);
    
//    glMatrixMode(GL_MODELVIEW);
//    glLoadIdentity();
//    glTranslated(size.width * 0.5, size.height * 0.5, 0.0);
    
    [[self openGLContext] update];
    
    _rect.vertex[0] = 0;
    _rect.vertex[1] = 0;
    _rect.vertex[2] = size.width;
    _rect.vertex[3] = 0;
    _rect.vertex[4] = size.width;
    _rect.vertex[5] = size.height;
    _rect.vertex[6] = 0;
    _rect.vertex[7] = size.height;
    
    normalVertex.points[0].x = 0;
    normalVertex.points[0].y = 0;
    normalVertex.points[1].x = size.width;
    normalVertex.points[1].y = 0;
    normalVertex.points[2].x = size.width;
    normalVertex.points[2].y = size.height;
    normalVertex.points[3].x = 0;
    normalVertex.points[3].y = size.height;
}

#pragma mark setter getter

- (void) setImage:(SyphonImage *)image
{
    _image = image;
}

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
    for(int i=0; i<4; ++i) {
        _vertex.points[i] = convertPoint(&vertex.points[i]);
    }
}
@end
