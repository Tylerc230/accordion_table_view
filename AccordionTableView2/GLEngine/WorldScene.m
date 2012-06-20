//
//  WorldScene.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorldScene.h"
#import "VertexBuffer.h"
@interface WorldScene ()
@property (nonatomic, strong) VertexBuffer *vertexBuffer;
@end

@implementation WorldScene
@synthesize vertexBuffer;
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

- (void)clearWorldObjects
{
    [self.objects removeAllObjects];
}

- (void)updateWorld
{
    
    for (WorldObject *object in self.objects) {
        [object updateVerticies:self.vertexBuffer];
    }
    [self.vertexBuffer resetUpdateCount];
}

- (void)generateBuffers
{
    self.vertexBuffer = [[VertexBuffer alloc] init];
    for (WorldObject *object in self.objects) {
        [object generateVertices:self.vertexBuffer];
    }
}

- (unsigned int)vertexBufferSize
{
    return self.vertexBuffer.vertexBufferSize;
}

- (float *)vertexData
{
    return self.vertexBuffer.vertexFloatArray;
}


@end
