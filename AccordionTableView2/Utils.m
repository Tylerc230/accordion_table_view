//
//  Utils.c
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Utils.h"
Vertex createVert(GLKVector3 position, GLKVector3 normal, GLKVector2 textureCoords)
{
    Vertex newVert = {position, normal, textureCoords};
    return newVert;
}


