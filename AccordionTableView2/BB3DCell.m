//
//  BB3DCell.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BB3DCell.h"
@interface BB3DCell ()
@property (nonatomic, strong) SegmentedRect *productView;
@end
@implementation BB3DCell
@synthesize productView;
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setOffset:(GLKVector3)anOffset
{
    [super setOffset:anOffset];
    [self updateScaleCoeff];
}

- (void)setOriginalPosition:(GLKVector3)originalPosition
{
    [super setOriginalPosition:originalPosition];
    [self updateScaleCoeff];
}

- (void)updateScaleCoeff
{
    self.yScaleCoeff = calcCompressionCoeff([self truePosition].y, self.compressedScale, self.uncompressedScale, self.size.y);
    self.productView.yScaleCoeff = self.yScaleCoeff;    
}

- (void)createProductView:(UIImage *)productThumbnail atLocation:(GLKVector3)offset
{
//    self.productView = [[SegmentedRect alloc] init];
//    self.productView.size = GLKVector3Make(productThumbnail.size.width, productThumbnail.size.height, 0.f);
//    self.productView.originalPosition = offset;
//    self.productView.compressedScale = .25;
//    self.productView.uncompressedScale = 1.f;
//    [self.productView loadTextureFromImage:productThumbnail];
//    [self addSubObject:self.productView];
//    [self updateScaleCoeff];
}

/* Calculates where something should be drawn on the y axis based on how far it has been scrolled up or down.
 * When we hit a certain y threshold in the positive or negative direction, we want the accordion to start folding
 * to its folded (compressed) height.
 */
float calcCompressionCoeff(float trueY, float compressedScale, float uncompressedScale, float uncompressedHeight)
{
//    float compressedH = ((uncompressedScale - compressedScale) + (compressedScale/2)) * uncompressedHeight/2;
    float compressedBoundry = uncompressedHeight;
    float compressionScale = 1.f - fabsf(trueY)/compressedBoundry;
    return CLAMP(compressionScale, 0.f, 1.f);
}


@end
