//
//  AccordionModel.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccordionModel.h"
#import "Utils.h"
#import "BB3DCell.h"

#define kNumLattices 7
#define kVertsPerLattice 8
#define kLatticeWidth 120.f
#define kLatticeHeight 90.f
#define kLatticeLength 46.f

@interface AccordionModel ()
@property (nonatomic, strong) NSMutableArray *textures;
@end

@implementation AccordionModel
@synthesize contentOffset;
@synthesize latticeCount;
@synthesize textures;

- (id)init
{
    self = [super init];
    if (self) {
        self.latticeCount = kNumLattices;
    }
    return self;
}

- (void)setLatticeCount:(int)aLatticeCount
{
    latticeCount = aLatticeCount;
    [self clearWorldObjects];
    [self createLattices:latticeCount];
}

- (void)setContentOffset:(GLKVector3)aContentOffset
{
    contentOffset = aContentOffset;
    GLKVector3 yOffset = GLKVector3Make(0.f, -contentOffset.y, 0.f);
    for (SegmentedRect * rect in self.objects) {
        rect.offset = yOffset;
    }
}

- (GLfloat *)verticies
{
    return [self vertexData];
}

- (void)createLattices:(unsigned int)numLattices
{
    for (int i = 0; i < numLattices; i++) {
        BB3DCell *lattice = [[BB3DCell alloc] init];
        lattice.size = GLKVector3Make(kLatticeWidth, kLatticeHeight, 0.f);
        lattice.latticeLength = kLatticeLength;
        lattice.originalPosition = GLKVector3Make(0.f, i * kLatticeHeight, 0.f);
        [self addWorldObject:lattice];

    }
    [self generateBuffers];
}

@end

