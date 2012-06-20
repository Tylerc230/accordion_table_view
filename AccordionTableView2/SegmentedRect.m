//
//  SegmentedRect.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SegmentedRect.h"
#define kCompressionYCoff .5f

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

@interface SegmentedRect ()
{
    float _yScaleCoff;
}
@end

@implementation SegmentedRect
@synthesize originalPosition;
@synthesize latticeLength;
@synthesize offset;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (GLKVector3)scale
{
    GLKVector3 scaledSize = super.scale;
    scaledSize.y *= _yScaleCoff;
    
    float halfH = (self.size.y * scaledSize.y)/2;
    float scaledDepth = sqrtf(powf(self.latticeLength * 2, 2) - pow(halfH, 2));
    if (self.size.z > 0.f) {
        scaledSize.z = scaledDepth/self.size.z;
    } else {
        scaledSize.z = 0.f;
    }

    
    return scaledSize;
}

- (GLKVector3)position
{

    GLKVector3 position = [self truePosition];
//    float yCompressionPoint = super.scale.y * kCompressionYCoff;
//    if (fabsf(position.y) > yCompressionPoint) {
//        float sign = position.y != 0.f ? position.y/fabs(position.y) : 1.f;
//        float scaledY = (fabs(position.y) - yCompressionPoint) * _yScaleCoff;
//        position = GLKVector3Make(position.x, sign * (yCompressionPoint + scaledY), position.z);
//    }
    return position;
}

- (void)setLatticeLength:(float)aLatticeLength
{
    latticeLength = aLatticeLength;
    float z = sqrtf(pow(latticeLength, 2) - pow(self.size.y/2, 2));
    self.size = GLKVector3Make(self.size.x, self.size.y, z);
}

- (GLKVector3)truePosition
{
    return GLKVector3Add(self.offset, self.originalPosition);    
}

- (void)generateVertices:(NSMutableData *)vertexBuffer
{
    [super generateVertices:vertexBuffer];
    int currentVertexCount = vertexBuffer.length/sizeof(Vertex);
    GLKVector3 size = self.size;
    //front face of lattice is at 0 depth
    float leftSide = -.5f * size.x;
    float rightSide = .5f * size.x;
    float topY = .5f * size.y;
    float middleY = 0.f;
    float bottomY = -.5f * size.y;
    float front = 0.f;
    float back = -1.f * size.z;
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

- (void)setOffset:(GLKVector3)anOffset
{
    offset = anOffset;
    [self updateScaleCoeff];
}

- (void)setOriginalPosition:(GLKVector3)anOriginalPosition
{
    originalPosition = anOriginalPosition;
    [self updateScaleCoeff];
}

- (void)loadTexture:(NSString *)fileName
{
    GLKTextureInfo *texture = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
    NSError *error = nil;
    texture = [GLKTextureLoader textureWithContentsOfFile:filePath options:
               [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] 
                                           forKey:GLKTextureLoaderOriginBottomLeft]  error:&error];
    NSAssert(error == nil, @"Failed to load texture");
    self.texture = texture;
}

- (void)updateScaleCoeff
{
    GLKVector3 size = self.size;
    float yCompressionPoint = size.y * kCompressionYCoff;
    GLKVector3 truePosition = [self truePosition];
    _yScaleCoff = calcCompressedHeight(truePosition.y, size.y, .0f, yCompressionPoint);
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
    float yScale = 0.f;
    float yBottom = fabsf(trueY) - latticeHeight/2;
    float delta = compressionPointY - yBottom;
    if (delta > 0.f) {
        float variableCompressionRatio = 1.f - compressionRatio;
        yScale = compressionRatio + (delta/compressionPointY) * variableCompressionRatio;
    } else {
        yScale = compressionRatio;
    }
    return yScale;
}
