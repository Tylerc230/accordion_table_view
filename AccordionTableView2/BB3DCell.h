//
//  BB3DCell.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SegmentedRect.h"

@interface BB3DCell : SegmentedRect
- (void)createProductView:(UIImage *)productThumbnail atLocation:(GLKVector3)offset;
@end
