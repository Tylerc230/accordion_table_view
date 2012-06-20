//
//  SegmentedRect.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorldObject.h"

@interface SegmentedRect : WorldObject
@property (nonatomic, assign) GLKVector3 originalPosition;
@property (nonatomic, assign) GLKVector3 offset;
@property (nonatomic, assign) float uncompressedScale;
@property (nonatomic, assign) float compressedScale;
- (void)loadTexture:(NSString *)fileName;
- (void)loadTextureFromImage:(UIImage *)image;
@end
