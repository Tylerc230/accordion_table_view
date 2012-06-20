//
//  WorldObject.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorldObject.h"
@interface WorldObject ()

@end


@implementation WorldObject
@synthesize position;
@synthesize size;
@synthesize scale;
@synthesize texture;
@synthesize subObjects;
@synthesize indicies;

- (id)init
{
    self = [super init];
    if (self) {
        self.subObjects = [NSMutableArray arrayWithCapacity:5];
        self.scale = GLKVector3Make(1.f, 1.f, 1.f);
    }
    return self;
}

- (void)generateVertices:(NSMutableData *)vertexBuffer
{
    for (WorldObject *subObject in self.subObjects) {
        [subObject generateVertices:vertexBuffer];
    }
}

- (unsigned int)indexCount
{
    return self.indicies.length/sizeof(VertexBufferIndex); 
}

- (unsigned int)indexByteSize
{
    return self.indicies.length;
}

- (VertexBufferIndex *)indexData
{
    return (VertexBufferIndex *) self.indicies.bytes;
}

- (void)addSubObject:(WorldObject *)object
{
    [self.subObjects addObject:object];
}

@end
