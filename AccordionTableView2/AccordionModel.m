//
//  AccordionModel.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccordionModel.h"

#define kNumLattices 7
#define kVertsPerLattice 8
#define kLatticeWidth 100.f
#define kLatticeHeight 40.f
#define kLatticeCompressedHeight (kLatticeHeight * .25f)
#define kLatticeDepth 10.f
#define kLatticeLength 22.f
#define kLatticeZPos 0.f
#define kTrianglesPerLattice 4
float calcCompressedY(float trueY, float latticeHeight, float latticeCompressedHeight, float compressionPointY);
const GLubyte latticeIndices[] = {
    0,3,1,
    0,2,3,
    4,7,5,
    4,6,7
};

@interface AccordionModel ()
@property (nonatomic, strong) NSMutableData *vertexBuffer;
@property (nonatomic, strong) NSMutableData *indexBuffer;
@end

@implementation AccordionModel
@synthesize vertexBuffer;
@synthesize indexBuffer;
@synthesize contentOffset;
@synthesize latticeCount;

- (id)init
{
    self = [super init];
    if (self) {
        self.latticeCount = kNumLattices;
        [self updatedLattice];
    }
    return self;
}

- (GLfloat *)verticies
{
    return (GLfloat *)self.vertexBuffer.bytes;
}

- (unsigned int)vertexBufferSize
{
    return self.vertexBuffer.length;
}

- (GLushort *)indicies
{
    return (GLushort *)self.indexBuffer.bytes;
}

- (unsigned int)indexBufferSize
{
    return self.indexBuffer.length;
}

- (unsigned int)indexCount
{
    return self.indexBufferSize/sizeof(GLushort);
}

- (void)updatedLattice
{
    self.vertexBuffer = nil;
    self.indexBuffer = nil;
    int vBufferLength = self.latticeCount * kVertsPerLattice * 6 * sizeof(float);
    NSMutableData *vBuffer = [NSMutableData dataWithCapacity:vBufferLength];
    float latticeWidth = kLatticeWidth;
    float latticeHeight = kLatticeHeight;
    float yStart = (self.latticeCount * latticeHeight)/2 + self.contentOffset.y;
    
    for (int i = 0; i < self.latticeCount; i++) {
        float vrow0Y = 0;
        float latticeCompressedH = 0.f;
        for (int vrow = 0; vrow < 4; vrow++) {
            float trueY = vrow == 0 ? latticeHeight : ((vrow == 1 || vrow == 2) ? latticeHeight/2 : 0.f);
            trueY += i * latticeHeight - yStart;
            float compressedY = calcCompressedY(trueY, latticeHeight, kLatticeCompressedHeight, latticeHeight * .5f);
            if (vrow == 0) {
                vrow0Y = compressedY;
            }
            if (vrow == 1) {
                latticeCompressedH = vrow0Y - compressedY;
            }
            float latticeDepth = sqrtf((kLatticeLength * kLatticeLength) - (latticeCompressedH * latticeCompressedH));
            
            
            float z = kLatticeZPos + (vrow == 0 || vrow == 3 ? 0.f : -latticeDepth);
            GLKVector3 left = GLKVector3Make(-latticeWidth/2, compressedY, z);
            GLKVector3 right = GLKVector3Make(latticeWidth/2, compressedY, z);
            float yNorm = vrow > 1 ? 1 : -1;
            GLKVector3 normal = GLKVector3Normalize(GLKVector3Make(0, yNorm, 1));
            size_t vSize = sizeof(GLKVector3);
            [vBuffer appendBytes:&left length:vSize];
            [vBuffer appendBytes:&normal length:vSize];
            [vBuffer appendBytes:&right length:vSize];
            [vBuffer appendBytes:&normal length:vSize];
            
        }
    }
    
    int iBufferLength = self.latticeCount * kTrianglesPerLattice * 3;
    NSMutableData *iBuffer = [NSMutableData dataWithCapacity:iBufferLength];
    for (int i = 0; i < self.latticeCount; i++) {
        int offset = i * kVertsPerLattice;
        for (int index = 0; index < kTrianglesPerLattice * 3; index++) {
            GLushort indexValue = latticeIndices[index] + offset;
            [iBuffer appendBytes:&indexValue length:sizeof(indexValue)];            
        }
    }
    
    self.vertexBuffer = vBuffer;
    self.indexBuffer = iBuffer;

}

- (void)printVects
{
    float vectCount = self.vertexBuffer.length/sizeof(GLKVector3);
    for (int i = 0; i < vectCount; i += 2) {
        GLKVector3 position;
        GLKVector3 normal;
        [self.vertexBuffer getBytes:&position range:NSMakeRange(i * sizeof(GLKVector3), sizeof(GLKVector3))];
        [self.vertexBuffer getBytes:&normal range:NSMakeRange((i + 1) * sizeof(GLKVector3), sizeof(GLKVector3))];
        NSLog(@"vertex: x: %f y: %f z: %f normal x: %f y: %f z: %f", position.x, position.y, position.z, normal.x, normal.y, normal.z);
    }
    
}

@end

/* Calculates where something should be drawn on the y axis based on how far it has been scrolled up or down.
 * When we hit a certain y threshold in the positive or negative direction, we want the accordion to start folding
 * to its folded (compressed) height.
 * @param trueY the y offset before any folding occurs
 * @param latticeHeight the unfolded height
 * @param latticeCompressedHeight the height of a lattice after it has been compressed
 * @param compressionPointY the offset from 0 in the positive or negative direction at which the lattice begins to compress
 */
float calcCompressedY(float trueY, float latticeHeight, float latticeCompressedHeight, float compressionPointY)
{
    float compressionRatio = latticeCompressedHeight/latticeHeight;
    float compressedY = trueY;
    //If the vertex has crossed a certain y threshold, we scale its offset from 0 to make 
    //it look compressed like venitian blind or accordion.
    if (fabsf(trueY) >= compressionPointY) {
        //fabsf and signedCompressionPointY are to handle in the positive and negative directions. assumes offset from 0, 0, 0.
        float signedCompressionPointY = trueY > 0.f ? compressionPointY : -compressionPointY;
        compressedY = signedCompressionPointY + (trueY - signedCompressionPointY) * compressionRatio;
    }
    return compressedY;
}


