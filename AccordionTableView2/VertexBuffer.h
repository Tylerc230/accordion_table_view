//
//  VertexBuffer.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
@interface VertexBuffer : NSObject
@property (nonatomic, readonly) unsigned int vertexCount;
@property (nonatomic, readonly) float *vertexFloatArray;
@property (nonatomic, readonly) unsigned int vertexBufferSize;

- (VertexBufferIndex)addVerticies:(Vertex *)vertexArray count:(unsigned int)numVertices;

@end
