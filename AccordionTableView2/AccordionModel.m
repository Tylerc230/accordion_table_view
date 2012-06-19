//
//  AccordionModel.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccordionModel.h"

#define kNumLattices 1
#define kVertsPerLattice 8
#define kLatticeWidth 120.f
#define kLatticeHeight 120.f
#define kLatticeCompressedHeight (kLatticeHeight * .25f)
#define kLatticeCompressionRation .25f
//If kLattice height is 2x kLatticeLength you will have no folding 
#define kLatticeLength (kLatticeHeight * .55f)
#define kCompressionPointY (kLatticeHeight * .5f)


typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 textureCoords;
}Vertex;

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


float calcCompressedY(float trueY, float latticeHeight, float latticeCompressionRatio, float compressionPointY);
FoldingRect createFoldingRect(float compressionPointY, float latticeWidth, float latticeHeight, float latticeLength, float latticeX, float latticeY, float latticeZ);
Vertex createVert(GLKVector3 position, GLKVector3 normal, GLKVector2 textureCoords);
const GLubyte latticeIndices[] = {
    0,3,1,
    0,2,3,
    4,7,5,
    4,6,7
};

@interface AccordionModel ()
{
    FoldingRectIndicies * _rectIndicies;
}
@property (nonatomic, strong) NSMutableData *vertexBuffer;
@property (nonatomic, strong) NSMutableData *indexBuffer;
@property (nonatomic, strong) NSMutableArray *textures;
@end

@implementation AccordionModel
@synthesize vertexBuffer;
@synthesize indexBuffer;
@synthesize contentOffset;
@synthesize latticeCount;
@synthesize textures;

- (id)init
{
    self = [super init];
    if (self) {
        _rectIndicies = NULL;
        self.latticeCount = kNumLattices;
        [self updatedLattice];
    }
    return self;
}

- (void)setLatticeCount:(int)aLatticeCount
{
    latticeCount = aLatticeCount;
    [self createViewRects];
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

- (FoldingRectIndicies) foldingRectIndiciesForIndex:(int)index
{
    return *(_rectIndicies + index);
}

- (void)updatedLattice
{
    self.vertexBuffer = nil;
    int vBufferLength = self.latticeCount * kVertsPerLattice * 6 * sizeof(float);
    NSMutableData *vBuffer = [NSMutableData dataWithCapacity:vBufferLength];

    //This line accounts for the scroll amount
    float yStart = (self.latticeCount - 1) * kLatticeHeight/2  - self.contentOffset.y;
    
    for (int i = 0; i < self.latticeCount; i++) {
        float latticeYOffset = i * kLatticeHeight;
        float yOffset =  yStart - latticeYOffset;
        FoldingRect newLattice = createFoldingRect(kLatticeHeight * .5f, kLatticeWidth,   kLatticeHeight,       kLatticeLength,        0.f, yOffset, 0.f);
        float rectH = kLatticeHeight * .5f;
        FoldingRect uiViewRect = createFoldingRect(rectH * .5,           kLatticeWidth/2, rectH,                rectH * .5,            0.f, yOffset, 2.f);
        
        [vBuffer appendBytes:&newLattice length:sizeof(FoldingRect)];
        [vBuffer appendBytes:&uiViewRect length:sizeof(FoldingRect)];
        
        
    }
    
    self.vertexBuffer = vBuffer;
//    [self printVects];
}

- (void)createViewRects
{
    int iBufferLength = self.latticeCount * kTrianglesPerLattice * 3;
    NSMutableData *latticeIBuffer = [NSMutableData dataWithCapacity:iBufferLength];

    if (_rectIndicies) {
        free(_rectIndicies);
    }
    _rectIndicies = malloc(self.latticeCount * sizeof(FoldingRectIndicies));
    for (int i = 0; i < self.latticeCount; i++) {
        int offset = i * kVertsPerLattice * 2;
        for (int index = 0; index < kTrianglesPerLattice * 3; index++) {
            GLushort indexValue = latticeIndices[index] + offset;
            [latticeIBuffer appendBytes:&indexValue length:sizeof(indexValue)];
            _rectIndicies[i].indices[index] = latticeIndices[index] + offset + kVertsPerLattice;
        }
        _rectIndicies[i].count = kTrianglesPerLattice * 3;
        _rectIndicies[i].glTextName = [self loadTexture:@"tile_sonyTV"];
    }
    self.indexBuffer = latticeIBuffer;
}

- (int)loadTexture:(NSString *)fileName
{
    GLKTextureInfo *texture = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
    NSError *error = nil;
    texture = [GLKTextureLoader textureWithContentsOfFile:filePath options:
               [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] 
                                           forKey:GLKTextureLoaderOriginBottomLeft]  error:&error];
    [self.textures addObject:textures];
    NSAssert(error == nil, @"Failed to load texture");
    return texture.name;
}

- (void)printVects
{
    float vectCount = self.vertexBuffer.length/sizeof(Vertex);
    for (int i = 0; i < vectCount; i++) {
        Vertex vertex;
        [self.vertexBuffer getBytes:&vertex range:NSMakeRange(i * sizeof(Vertex), sizeof(Vertex))];
        NSLog(@"index: %d vertex: x: %f y: %f z: %f normal x: %f y: %f z: %f",i, vertex.position.x, vertex.position.y, vertex.position.z, vertex.normal.x, vertex.normal.y, vertex.normal.z);
    }
    NSLog(@"*********************************");
    
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
float calcCompressedY(float trueY, float latticeHeight, float compressionRatio, float compressionPointY)
{
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

Vertex createVert(GLKVector3 position, GLKVector3 normal, GLKVector2 textureCoords)
{
    Vertex newVert = {position, normal, textureCoords};
    return newVert;
}

FoldingRect createFoldingRect(float compressionPointY, float latticeWidth, float latticeHeight, float latticeLength, float latticeX, float latticeY, float latticeZ)
{
    //trueY is the unfolded y offset from 
    float topTrueY = latticeHeight/2 + latticeY;
    float bottomTrueY = -latticeHeight/2 + latticeY;
    
    
    float compressedTopY = calcCompressedY(topTrueY, latticeHeight, kLatticeCompressionRation, compressionPointY);
    float compressedBottomY = calcCompressedY(bottomTrueY, latticeHeight, kLatticeCompressionRation, compressionPointY);
    float compressedMiddleY =     compressedBottomY + (compressedTopY - compressedBottomY)/2;
    //This code ensures the the length of the each half of the lattice stay the same before and after the folding animation
    float latticeCompressedH = (compressedTopY - compressedBottomY)/2;
    //Get the height of the folded or unfolded lattice and use pythag thrm depth = (latticeLeght^2 - height^2)^(.5) or x = (hypotenuse^2 - y^2)^(.5)
    float latticeDepth = sqrtf((latticeLength * latticeLength) - (latticeCompressedH * latticeCompressedH));
    
    //front face of lattice is at 0 depth
    float leftSide = -latticeWidth/2 + latticeX;
    float rightSide = latticeWidth/2 + latticeX;
    GLKVector3 topLeftVector = GLKVector3Make(leftSide, compressedTopY, latticeZ);
    GLKVector3 topRightVector = GLKVector3Make(rightSide, compressedTopY, latticeZ);
    GLKVector3 middleLeftVector = GLKVector3Make(leftSide, compressedMiddleY, -latticeDepth + latticeZ);
    GLKVector3 middleRightVector = GLKVector3Make(rightSide, compressedMiddleY, -latticeDepth + latticeZ);
    GLKVector3 bottomLeftVector = GLKVector3Make(leftSide, compressedBottomY, latticeZ);
    GLKVector3 bottomRightVector = GLKVector3Make(rightSide, compressedBottomY, latticeZ);
    
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
    return newRect;

}


