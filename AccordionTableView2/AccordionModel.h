//
//  AccordionModel.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"
#import "WorldScene.h"

@interface AccordionModel : WorldScene
@property (nonatomic, assign) GLKVector3 contentOffset;
- (void)addCell:(UIView *)cell;
@end
