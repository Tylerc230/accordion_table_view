//
//  BB3DCell.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BB3DCell.h"

@implementation BB3DCell

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)createProductView:(UIImage *)productThumbnail atLocation:(GLKVector3)offset
{
    SegmentedRect * productView = [[SegmentedRect alloc] init];
    productView.size = GLKVector3Make(productThumbnail.size.width, productThumbnail.size.height, 0.f);
    productView.originalPosition = offset;
    productView.compressedScale = .25;
    productView.uncompressedScale = 1.f;
    [productView loadTextureFromImage:productThumbnail];
    [self addSubObject:productView];
}

@end
