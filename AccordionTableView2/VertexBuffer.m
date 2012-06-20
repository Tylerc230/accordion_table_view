//
//  VertexBuffer.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VertexBuffer.h"
@interface VertexBuffer ()
@property (nonatomic, strong) NSMutableData *vertexData;
@property (nonatomic, strong) NSMutableArray *objectData;
@end

@implementation VertexBuffer
@synthesize vertexData;
@synthesize objectData;
@synthesize vertexCount;

- (id)init
{
    self = [super init];
    if (self) {
        self.vertexData = [NSMutableData dataWithCapacity:10];
        self.objectData = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)objectCreationBegin
{
    VertexBufferIndex startIndex = self.vertexCount;
    [self objectCreationEnd];
    [self.objectData addObject:[NSValue valueWithRange:NSMakeRange(startIndex, 0)]];
}

- (void)objectCreationEnd
{
    VertexBufferIndex currentIndex = self.vertexCount;
    if (currentIndex > 0) {
        NSRange finishedObjectRange = [self.objectData.lastObject rangeValue];
        unsigned int length = currentIndex - finishedObjectRange.location;
        finishedObjectRange.length = length;
        [self.objectData replaceObjectAtIndex:self.objectData.count - 1 withObject:[NSValue valueWithRange:finishedObjectRange]];
    }
}

- (VertexBufferIndex)addVerticies:(Vertex *)vertexArray count:(unsigned int)numVertices{
    int indexCount = self.vertexCount;
    [self.vertexData appendBytes:vertexArray length:numVertices * sizeof(Vertex)];
    return indexCount + 1;
}

- (float *)vertexFloatArray
{
    return (float *)self.vertexData.bytes;
}

- (unsigned int)vertexBufferSize
{
    return self.vertexData.length;
}

- (unsigned int)vertexCount
{
    return self.vertexData.length /sizeof(Vertex);
}

@end
