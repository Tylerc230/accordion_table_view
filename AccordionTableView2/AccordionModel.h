//
//  AccordionModel.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccordionModel : NSObject
@property (nonatomic, readonly) GLfloat *verticies;
@property (nonatomic, readonly) unsigned int vertexBufferSize;
@property (nonatomic, readonly) GLushort *indicies;
@property (nonatomic, readonly) unsigned int indexBufferSize;
@end
