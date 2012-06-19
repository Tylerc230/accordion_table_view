//
//  WorldScene.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorldScene.h"
@interface WorldScene ()
@property (nonatomic, strong) NSData *vertextBuffer;
@property (nonatomic, strong) NSMutableArray *objects;
@end

@implementation WorldScene
@synthesize vertextBuffer;
@synthesize objects;

- (void)addWorldObject:(WorldObject *)object
{
    [self.objects addObject:object];
}

- (void)generateBuffers
{
    NSMutableData * vBuff = [NSMutableData dataWithCapacity:1000.f];
    for (WorldObject *object in self.objects) {
        [object generateVertices:vBuff];
    }
    self.vertextBuffer = vBuff;
}

@end
