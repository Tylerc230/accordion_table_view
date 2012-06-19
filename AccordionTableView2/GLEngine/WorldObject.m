//
//  WorldObject.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorldObject.h"
@interface WorldObject ()
@property (nonatomic, strong) NSMutableArray *subObjects;
@end


@implementation WorldObject
@synthesize position;
@synthesize scale;
@synthesize texture;
@synthesize subObjects;
@synthesize indicies;

- (void)generateVertices:(NSMutableData *)vertexBuffer
{
    
}
@end
