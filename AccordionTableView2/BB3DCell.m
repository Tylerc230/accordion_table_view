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
        [self createSubObjects];
    }
    return self;
}

- (void)createSubObjects
{
    SegmentedRect * productView = [[SegmentedRect alloc] init];
    productView.size = GLKVector3Make(40.f, 20.f, 1.f);
    productView.latticeLength = 10.05f;
    productView.originalPosition = GLKVector3Make(30.f, 0.f, 0.f);
    [productView loadTexture:@"tile_sonyTV"];
    [self addSubObject:productView];
}

@end
