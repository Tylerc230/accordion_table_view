//
//  WorldScene.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorldObject.h"
@interface WorldScene : NSObject
- (void)addWorldObject:(WorldObject *)object;
- (void)generateBuffers;
@end
