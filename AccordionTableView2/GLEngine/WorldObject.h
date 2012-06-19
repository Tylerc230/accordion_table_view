//
//  WorldObject.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLKit/GLKit.h"
#import "Utils.h"
@interface WorldObject : NSObject
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector3 scale;
@property (nonatomic, strong) GLKEffectPropertyTexture *texture;
- (void)generateVertices:(NSMutableData *)vertexBuffer;
@end
