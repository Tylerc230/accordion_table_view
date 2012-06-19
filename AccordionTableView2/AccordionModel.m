//
//  AccordionModel.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccordionModel.h"
#import "Utils.h"
#import "SegmentedRect.h"

#define kNumLattices 3
#define kVertsPerLattice 8
#define kLatticeWidth 120.f
#define kLatticeHeight 120.f
#define kLatticeCompressedHeight (kLatticeHeight * .25f)
#define kLatticeCompressionRation .25f
//If kLattice height is 2x kLatticeLength you will have no folding 
#define kLatticeLength (kLatticeHeight * .55f)
#define kCompressionPointY (kLatticeHeight * .5f)

@interface AccordionModel ()
@property (nonatomic, strong) NSMutableArray *textures;
@end

@implementation AccordionModel
@synthesize scene;
@synthesize contentOffset;
@synthesize latticeCount;
@synthesize textures;

- (id)init
{
    self = [super init];
    if (self) {
        self.scene = [[WorldScene alloc] init];
        self.latticeCount = kNumLattices;
    }
    return self;
}

- (void)setLatticeCount:(int)aLatticeCount
{
    latticeCount = aLatticeCount;
    [self.scene clearWorldObjects];
    [self createLattices:latticeCount];
}

- (void)setContentOffset:(GLKVector3)aContentOffset
{
    contentOffset = aContentOffset;
    GLKVector3 yOffset = GLKVector3Make(0.f, -contentOffset.y, 0.f);
    for (SegmentedRect * rect in self.scene.objects) {
        rect.position = GLKVector3Add(rect.originalOffset, yOffset);
    }
}

- (GLfloat *)verticies
{
    return [self.scene vertexData];
}

- (unsigned int)vertexBufferSize
{
    return [self.scene vertexBufferSize];
}


- (void)createLattices:(unsigned int)numLattices
{
    for (int i = 0; i < numLattices; i++) {
        SegmentedRect *lattice = [[SegmentedRect alloc] init];
        lattice.scale = GLKVector3Make(kLatticeWidth, kLatticeHeight, 50.f);
        lattice.originalOffset = GLKVector3Make(0.f, i * kLatticeHeight, 0.f);
        [self.scene addWorldObject:lattice];

    }
    [self.scene generateBuffers];
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

@end

