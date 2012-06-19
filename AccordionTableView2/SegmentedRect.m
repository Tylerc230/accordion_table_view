//
//  SegmentedRect.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SegmentedRect.h"

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

const VertexBufferIndex rectIndicies[] = {
    0,3,1,
    0,2,3,
    4,7,5,
    4,6,7
};

float calcCompressedHeight(float trueY, float latticeHeight, float compressionRatio, float compressionPointY);

@implementation SegmentedRect
@synthesize originalOffset;
- (GLKVector3)scale
{

    GLKVector3 scale = [super scale];
    float yCompressionPoint = scale.y/2.f;
    float scaleCoff = calcCompressedHeight(self.position.y, scale.y, .25f, yCompressionPoint);
    
    return GLKVector3Make(scale.x, scaleCoff * scale.y , scale.z);
}

- (void)generateVertices:(NSMutableData *)vertexBuffer
{
    int currentVertexCount = vertexBuffer.length/sizeof(Vertex);
    //front face of lattice is at 0 depth
    float leftSide = -.5f;
    float rightSide = .5f;
    float topY = .5f;
    float middleY = 0.f;
    float bottomY = -.5f;
    float front = 0.f;
    float back = -1.f;
    GLKVector3 topLeftVector = GLKVector3Make(leftSide, topY, front);
    GLKVector3 topRightVector = GLKVector3Make(rightSide, topY, front);
    GLKVector3 middleLeftVector = GLKVector3Make(leftSide, middleY, back);
    GLKVector3 middleRightVector = GLKVector3Make(rightSide, middleY, back);
    GLKVector3 bottomLeftVector = GLKVector3Make(leftSide, bottomY, front);
    GLKVector3 bottomRightVector = GLKVector3Make(rightSide, bottomY, front);
    
    GLKVector3 topNormal = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(topLeftVector, topRightVector), GLKVector3Subtract(middleRightVector, topRightVector)));
    GLKVector3 bottomNormal = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(middleRightVector, bottomRightVector), GLKVector3Subtract(bottomLeftVector, bottomRightVector)));
    
    GLKVector2 topLeftTextCoord = GLKVector2Make(0.f, 1.f);
    GLKVector2 topRightTextCoord = GLKVector2Make(1.f, 1.f);
    GLKVector2 middleLeftTextCoord = GLKVector2Make(0.f, .5f);
    GLKVector2 middleRightTextCoord = GLKVector2Make(1.f, .5f);
    
    GLKVector2 bottomLeftTextCoord = GLKVector2Make(0.0f, 0.f);
    GLKVector2 bottomRightTextCoord = GLKVector2Make(1.f, 0.f);
    
    FoldingRect newRect;
    newRect.topLeft1 = createVert(topLeftVector, topNormal, topLeftTextCoord);
    newRect.topRight1 = createVert(topRightVector, topNormal, topRightTextCoord);
    newRect.bottomLeft1 = createVert(middleLeftVector, topNormal, middleLeftTextCoord);
    newRect.bottomRight1 = createVert(middleRightVector, topNormal, middleRightTextCoord);
    
    newRect.topLeft2 = createVert(middleLeftVector, bottomNormal, middleLeftTextCoord);
    newRect.topRight2 = createVert(middleRightVector, bottomNormal, middleRightTextCoord);
    newRect.bottomLeft2 = createVert(bottomLeftVector, bottomNormal, bottomLeftTextCoord);
    newRect.bottomRight2 = createVert(bottomRightVector, bottomNormal, bottomRightTextCoord);
    
    int numIndices = sizeof(rectIndicies)/sizeof(*rectIndicies);
    [vertexBuffer appendBytes:&newRect length:sizeof(FoldingRect)];
    
    self.indicies = [NSMutableData dataWithCapacity:numIndices * sizeof(GLushort)];
    for (int i = 0; i < numIndices; i++) {
        VertexBufferIndex index = rectIndicies[i] + currentVertexCount;
        [self.indicies appendBytes:&index length:sizeof(VertexBufferIndex)];
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
float calcCompressedHeight(float trueY, float latticeHeight, float compressionRatio, float compressionPointY)
{
    float yScale = 1.f;
    float bottomY = fabs(trueY) - latticeHeight/2;
    float delta = compressionPointY - bottomY;
    if (delta < latticeHeight) {
        yScale = delta/latticeHeight;
        if (yScale < compressionRatio) {
            yScale = compressionRatio;
        }
    }
    return yScale;
}
