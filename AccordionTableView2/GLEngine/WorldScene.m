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
@end

@implementation WorldScene
@synthesize vertextBuffer;
@synthesize objects;

- (id)init
{
    self = [super init];
    if (self) {
        self.objects = [NSMutableArray arrayWithCapacity:15];
    }
    return self;
}

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

- (unsigned int)vertexBufferSize
{
    return self.vertextBuffer.length;
}

- (float *)vertexData
{
    return (float*)self.vertextBuffer.bytes;
}


@end
