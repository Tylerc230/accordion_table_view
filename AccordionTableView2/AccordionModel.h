//
//  AccordionModel.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"
#import "WorldScene.h"
#define kTrianglesPerLattice 4
typedef struct {
    unsigned short indices[kTrianglesPerLattice * 3];
    int count;
    int glTextName;
}FoldingRectIndicies;


@interface AccordionModel : NSObject
@property (nonatomic, readonly) GLfloat *verticies;
@property (nonatomic, readonly) unsigned int vertexBufferSize;
@property (nonatomic, assign) GLKVector3 contentOffset;
@property (nonatomic, assign) int latticeCount;

@property (nonatomic, strong) WorldScene *scene;
@end
