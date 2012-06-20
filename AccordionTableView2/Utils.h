//
//  Utils.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "GLKit/GLKit.h"
#define CLAMP(number, min, max) (number > max ? max : (number < min ? min : number))

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 textureCoords;
}Vertex;
typedef GLushort VertexBufferIndex;

Vertex createVert(GLKVector3 position, GLKVector3 normal, GLKVector2 textureCoords);
void printVertex(Vertex vertex);
