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

float calcCompressionCoeff(float trueY, float compressedScale, float uncompressedScale, float uncompressedHeight);

@interface SegmentedRect ()
@property (nonatomic, readonly) float currentCompressionAmount;
@end

@implementation SegmentedRect
@synthesize originalPosition;
@synthesize offset;
@synthesize compressedScale;
@synthesize uncompressedScale;
@synthesize yScaleCoeff;
@synthesize currentCompressionAmount;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (GLKVector3)position
{

    GLKVector3 position = [self truePosition];
    float realSpacing = self.size.y;
    float avgInterpolation = (self.uncompressedScale - self.compressedScale)/2;
    float yOffset = position.y * self.compressedScale;

    float cca = self.yScaleCoeff;
    yOffset += realSpacing * avgInterpolation * cca;
    position = GLKVector3Make(position.x, yOffset, position.z);
    return position;
}

- (GLKVector3)truePosition
{
    return GLKVector3Add(self.offset, self.originalPosition);    
}

- (void)generateVertices:(VertexBuffer *)vertexBuffer
{
    [super generateVertices:vertexBuffer];
    [vertexBuffer objectCreationBegin];
    int currentVertexCount = vertexBuffer.vertexCount;
    FoldingRect newRect;
    [self updateFoldingRect:&newRect];
    int numIndices = sizeof(rectIndicies)/sizeof(*rectIndicies);
    [vertexBuffer addVerticies:(Vertex*)&newRect count:sizeof(FoldingRect)/sizeof(Vertex)];
    
    self.indicies = [NSMutableData dataWithCapacity:numIndices * sizeof(VertexBufferIndex)];
    for (int i = 0; i < numIndices; i++) {
        VertexBufferIndex index = rectIndicies[i] + currentVertexCount;
        [self.indicies appendBytes:&index length:sizeof(VertexBufferIndex)];
    }
    [vertexBuffer objectCreationEnd];
}

- (void)updateFoldingRect:(FoldingRect *)foldingRect
{
    float compressionScale = self.currentCompressionAmount;
    
    GLKVector3 size = self.size;
    //front face of lattice is at 0 depth
    float leftSide = -.5f * size.x;
    float rightSide = .5f * size.x;
    float topY = .5f * size.y * compressionScale;
    float middleY = 0.f;
    float bottomY = -.5f * size.y * compressionScale;
    
    float compressedHHeight = (topY - bottomY)/2;
    float uncompressedHHeight = size.y/2;
    float depth = sqrtf(powf(uncompressedHHeight, 2) - powf(compressedHHeight, 2));
    
    float front = 0.f;
    float back = -depth;
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
    

    foldingRect->topLeft1 = createVert(topLeftVector, topNormal, topLeftTextCoord);
    foldingRect->topRight1 = createVert(topRightVector, topNormal, topRightTextCoord);
    foldingRect->bottomLeft1 = createVert(middleLeftVector, topNormal, middleLeftTextCoord);
    foldingRect->bottomRight1 = createVert(middleRightVector, topNormal, middleRightTextCoord);
    
    foldingRect->topLeft2 = createVert(middleLeftVector, bottomNormal, middleLeftTextCoord);
    foldingRect->topRight2 = createVert(middleRightVector, bottomNormal, middleRightTextCoord);
    foldingRect->bottomLeft2 = createVert(bottomLeftVector, bottomNormal, bottomLeftTextCoord);
    foldingRect->bottomRight2 = createVert(bottomRightVector, bottomNormal, bottomRightTextCoord);
    
    
}

- (float)currentCompressionAmount
{
    float compressionCoeff = 1 - fabsf(self.yScaleCoeff);
    return self.compressedScale + (self.uncompressedScale - self.compressedScale) * compressionCoeff;
}

- (void)updateVerticies:(VertexBuffer *)vertexBuffer
{
    [super updateVerticies:vertexBuffer];
    [vertexBuffer objectUpdateBegin];
    FoldingRect *objectVertices = (FoldingRect *)[vertexBuffer vertexDataForCurrentObject];
    [self updateFoldingRect:objectVertices];
    [vertexBuffer objectUpdateEnd];
    
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

- (void)loadTextureFromImage:(UIImage *)image
{
    NSError *error = nil;
    GLKTextureInfo *texture = [GLKTextureLoader textureWithCGImage:image.CGImage options:
                               [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]  forKey:GLKTextureLoaderOriginBottomLeft] 
                                                             error:&error];
    NSAssert(error == nil, @"Failed to load image");
    self.texture = texture;
}

@end

