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
@property (nonatomic, strong) NSMutableArray *objects;
- (void)clearWorldObjects;
- (void)updateWorld;
- (void)addWorldObject:(WorldObject *)object;
- (void)generateBuffers;
- (unsigned int)vertexBufferSize;
- (float *)vertexData;
@end
