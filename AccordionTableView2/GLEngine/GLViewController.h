//
//  GLViewController.h
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLKit/GLKit.h"
#import "WorldScene.h"

@interface GLViewController : GLKViewController
@property (nonatomic, strong) WorldScene *scene;
- (GLKVector3)worldPointFromScreenPoint:(GLKVector2)screenPoint;
@end
