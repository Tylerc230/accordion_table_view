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
#define kLatticeWidth 120.f
#define kLatticeHeight 120.f
#define kLatticeCompressedHeight (kLatticeHeight * .25f)
//If kLattice height is 2x kLatticeLength you will have no folding 
#define kLatticeLength (kLatticeHeight * .55f)
#define kCompressionPointY (kLatticeHeight * .5f)
#define kTrianglesPerLattice 4


typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 textureCoords;
}Vertex;

Vertex createVert(GLKVector3 position, GLKVector3 normal, GLKVector2 textureCoords)
{
    Vertex newVert = {position, normal, textureCoords};
    return newVert;
}

typedef struct {
    //top half
    Vertex topLeft1;
    Vertex topRight1;
    Vertex bottomLeft1;
    Vertex bottomRight1;
    
    //bottom half
    Vertex topLeft2;
    Vertex topRight2;
    Vertex bottomLeft2;
    Vertex bottomRight2;
}FoldingRect;



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
    //This line accounts for the scroll amount
    float yStart = (self.latticeCount - 1) * kLatticeHeight/2  - self.contentOffset.y;
    
    for (int i = 0; i < self.latticeCount; i++) {
        float latticeYOffset = i * kLatticeHeight;
        //trueY is the unfolded y offset from 
        float topTrueY = latticeHeight/2 + yStart - latticeYOffset;
        float middleTrueY = 0.f + yStart - latticeYOffset;
        float bottomTrueY = -latticeHeight/2 + yStart - latticeYOffset;
        
        float compressionYPoint = kCompressionPointY;
        float compressedTopY = calcCompressedY(topTrueY, latticeHeight, kLatticeCompressedHeight, compressionYPoint);
        float compressedMiddleY = calcCompressedY(middleTrueY, latticeHeight, kLatticeCompressedHeight, compressionYPoint);
        float compressedBottomY = calcCompressedY(bottomTrueY, latticeHeight, kLatticeCompressedHeight, compressionYPoint);
        
        //This code ensures the the length of the each half of the lattice stay the same before and after the folding animation
        float latticeCompressedH = (compressedTopY - compressedBottomY)/2;
        //Get the height of the folded or unfolded lattice and use pythag thrm depth = (latticeLeght^2 - height^2)^(.5) or x = (hypotenuse^2 - y^2)^(.5)
        float latticeDepth = sqrtf((kLatticeLength * kLatticeLength) - (latticeCompressedH * latticeCompressedH));
        
        //front face of lattice is at 0 depth
        float leftSide = -latticeWidth/2;
        float rightSide = latticeWidth/2;
        GLKVector3 topLeftVector = GLKVector3Make(leftSide, compressedTopY, 0.f);
        GLKVector3 topRightVector = GLKVector3Make(rightSide, compressedTopY, 0.f);
        GLKVector3 middleLeftVector = GLKVector3Make(leftSide, compressedMiddleY, -latticeDepth);
        GLKVector3 middleRightVector = GLKVector3Make(rightSide, compressedMiddleY, -latticeDepth);
        GLKVector3 bottomLeftVector = GLKVector3Make(leftSide, compressedBottomY, 0.f);
        GLKVector3 bottomRightVector = GLKVector3Make(rightSide, compressedBottomY, 0.f);
        
        GLKVector3 topNormal = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(topLeftVector, topRightVector), GLKVector3Subtract(middleRightVector, topRightVector)));
        GLKVector3 bottomNormal = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(middleRightVector, bottomRightVector), GLKVector3Subtract(bottomLeftVector, bottomRightVector)));
        
        GLKVector2 topLeftTextCoord = GLKVector2Make(0.f, 0.f);
        GLKVector2 topRightTextCoord = GLKVector2Make(0.f, 1.f);
        GLKVector2 bottomLeftTextCoord = GLKVector2Make(1.0f, 0.f);
        GLKVector2 bottomRightTextCoord = GLKVector2Make(1.f, 1.f);
        
        FoldingRect newLattice;
        newLattice.topLeft1 = createVert(topLeftVector, topNormal, topLeftTextCoord);
        newLattice.topRight1 = createVert(topRightVector, topNormal, topRightTextCoord);
        newLattice.bottomLeft1 = createVert(middleLeftVector, topNormal, bottomLeftTextCoord);
        newLattice.bottomRight1 = createVert(middleRightVector, topNormal, bottomRightTextCoord);
        
        newLattice.topLeft2 = createVert(middleLeftVector, bottomNormal, topLeftTextCoord);
        newLattice.topRight2 = createVert(middleRightVector, bottomNormal, topRightTextCoord);
        newLattice.bottomLeft2 = createVert(bottomLeftVector, bottomNormal, bottomLeftTextCoord);
        newLattice.bottomRight2 = createVert(bottomRightVector, bottomNormal, bottomRightTextCoord);
        
        [vBuffer appendBytes:&newLattice length:sizeof(FoldingRect)];
        
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
//    [self printVects];
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


