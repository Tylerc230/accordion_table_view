//
//  Square.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Square.h"

@implementation Square

- (void)generateVertices:(NSMutableData *)vertexBuffer
{
    int vertexCount = vertexBuffer.length/sizeof(Vertex);
    GLKVector3 normal = GLKVector3Make(0.f, 0.f, 1.f);
    Vertex leftTop = createVert(GLKVector3Make(-self.size.x/2, self.size.y/2, 0.f),normal , GLKVector2Make(0.f, 1.f));
    Vertex rightTop = createVert(GLKVector3Make(self.size.x/2, self.size.y/2, 0.f),normal , GLKVector2Make(1.f, 1.f));
    Vertex leftBottom = createVert(GLKVector3Make(-self.size.x/2, -self.size.y/2, 0.f),normal , GLKVector2Make(0.f, 0.f));
    Vertex rightBottom = createVert(GLKVector3Make(self.size.x/2, -self.size.y/2, 0.f),normal , GLKVector2Make(1.f, 0.f));
    [vertexBuffer appendBytes:&leftTop length:sizeof(Vertex)];
    [vertexBuffer appendBytes:&rightTop length:sizeof(Vertex)];
    [vertexBuffer appendBytes:&leftBottom length:sizeof(Vertex)];
    [vertexBuffer appendBytes:&rightBottom length:sizeof(Vertex)];
    

    self.indicies = [NSMutableData dataWithLength:6];
    VertexBufferIndex indicies[] = {0, 1, 3, 0, 3, 2};
    for (int i = 0; i < sizeof(indicies)/sizeof(*indicies); i++) {
        VertexBufferIndex index = indicies[i] + vertexCount;
        [self.indicies appendBytes:&index length:sizeof(VertexBufferIndex)];
    }

}

@end
