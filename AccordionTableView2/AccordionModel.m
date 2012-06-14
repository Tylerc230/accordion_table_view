//
//  AccordionModel.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccordionModel.h"
#import "GLKit/GLKit.h"

#define kNumLattices 6
#define kVertsPerLattice 8
#define kLatticeWidth 7.f
#define kLatticeHeight 6.f
#define kLatticeDepth 25.f
#define kLatticeZPos -2.f
#define kTrianglesPerLattice 4

const GLubyte latticeIndices[] = {
    0,3,1,
    0,2,3,
    4,7,5,
    4,6,7
};

@interface AccordionModel ()
@property (nonatomic, strong) NSMutableData *verticeBuffer;
@property (nonatomic, strong) NSMutableData *indexBuffer;
@end

@implementation AccordionModel
@synthesize verticeBuffer;
@synthesize indexBuffer;

- (id)init
{
    self = [super init];
    if (self) {
        [self createModel:kNumLattices];
    }
    return self;
}

- (GLfloat *)verticies
{
    return (GLfloat *)self.verticeBuffer.bytes;
}

- (unsigned int)vertexBufferSize
{
    return self.verticeBuffer.length;
}

- (GLushort *)indicies
{
    return (GLushort *)self.indexBuffer.bytes;
}

- (unsigned int)indexBufferSize
{
    return self.indexBuffer.length;
}

- (void)createModel:(int)latticeCount
{
    int vBufferLength = latticeCount * kVertsPerLattice * 6 * sizeof(float);
    NSMutableData *vBuffer = [NSMutableData dataWithCapacity:vBufferLength];
    float latticeWidth = kLatticeWidth;
    float latticeHeight = kLatticeHeight;
    float latticeDepth = kLatticeDepth;
    float yStart = (latticeCount * latticeHeight)/2;
    
    for (int i = 0; i < latticeCount; i++) {
        
        for (int vrow = 0; vrow < 4; vrow++) {
            float y = vrow == 0 ? latticeHeight : ((vrow == 1 || vrow == 2) ? latticeHeight/2 : 0.f);
            y -= yStart;
            y += i * latticeHeight;
            float z = kLatticeZPos + (vrow == 0 || vrow == 3 ? latticeDepth/2 : -latticeDepth/2);
            GLKVector3 left = {-latticeWidth/2, y, z};
            GLKVector3 right = {latticeWidth/2, y, z};
            float yNorm = vrow > 1 ? 1 : -1;
            GLKVector3 normal = GLKVector3Normalize(GLKVector3Make(0, yNorm, 1));
            size_t vSize = sizeof(GLKVector3);
            [vBuffer appendBytes:&left length:vSize];
            [vBuffer appendBytes:&normal length:vSize];
            [vBuffer appendBytes:&right length:vSize];
            [vBuffer appendBytes:&normal length:vSize];
            
        }
    }
    
    int iBufferLength = latticeCount * kTrianglesPerLattice * 3;
    NSMutableData *iBuffer = [NSMutableData dataWithCapacity:iBufferLength];
    for (int i = 0; i < latticeCount; i++) {
        int offset = i * kVertsPerLattice;
        for (int index = 0; index < kTrianglesPerLattice * 3; index++) {
            GLubyte indexValue = latticeIndices[index] + offset;
            [iBuffer appendBytes:&indexValue length:sizeof(indexValue)];            
        }
    }
    
    self.verticeBuffer = vBuffer;
    self.indexBuffer = iBuffer;

}


@end
