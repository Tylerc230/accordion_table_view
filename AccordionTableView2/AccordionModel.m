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
#import "QuartzCore/CALayer.h"
#import "Square.h"

#define kVertsPerLattice 8
#define kLatticeWidth 1024.f
#define kLatticeHeight 764.f
#define kMaxScaleCoeff .75f
#define kMinScaleCoeff .25f

@interface AccordionModel ()
{
    float yBeginOffset;
}
@end

@implementation AccordionModel
@synthesize contentOffset;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setContentOffset:(GLKVector3)aContentOffset
{
    contentOffset = aContentOffset;
    GLKVector3 yOffset = GLKVector3Make(0.f, -contentOffset.y, 0.f);
    for (SegmentedRect * rect in self.objects) {
        rect.offset = yOffset;
    }
}

- (void)addCell:(UIView *)cell
{
//    Square * square = [[Square alloc] init];
//    square.size = GLKVector3Make(100.f, 100.f, 0.f);
//    [self addWorldObject:square];
    
    UIImage *cellImage = [self imageForView:cell];
    BB3DCell *lattice = [[BB3DCell alloc] init];
    lattice.uncompressedScale = kMaxScaleCoeff;
    lattice.compressedScale = kMinScaleCoeff;
    lattice.size = GLKVector3Make(kLatticeWidth, kLatticeHeight, 0.f);
    lattice.originalPosition = GLKVector3Make(0.f, yBeginOffset, 0.f);
    [lattice createProductView:cellImage atLocation:GLKVector3Make(lattice.size.x/4, 0.f, 10.f)];
    [self addWorldObject:lattice];
    yBeginOffset += kLatticeHeight;
}

- (UIImage *)imageForView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  screenShot;
}


@end

