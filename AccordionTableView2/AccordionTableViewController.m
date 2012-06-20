//
//  AccordionTableViewViewController.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccordionTableViewController.h"
#import "AccordionModel.h"
#import "WorldScene.h"
#import "WorldObject.h"
@interface AccordionTableViewController ()
{
     GLKVector2 _currentScreenOffset;   
}
@end

@implementation AccordionTableViewController

- (id)init
{
    self = [super initWithNibName:@"AccordionTableViewController" bundle:nil];
    if (self) {
//        _rotation = 70.f;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.paused = !self.paused;
}

#pragma mark - UIPanGestureRecognizer delegate methods

- (IBAction)handleScrollGesture:(UIPanGestureRecognizer *)recognizer
{
    GLKVector2 currentOffset = GLKVector2Make([recognizer translationInView:self.view].x, [recognizer translationInView:self.view].y);
    
    GLKVector3 currentWorldOffset = [self worldPointFromScreenPoint:GLKVector2Add(_currentScreenOffset, currentOffset)];
    [self.accordionModel setContentOffset:currentWorldOffset];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _currentScreenOffset = GLKVector2Add(_currentScreenOffset, currentOffset);
    }
}

#pragma mark - public methods
- (void)setupModel
{
    self.scene = [[AccordionModel alloc] init];
}

- (AccordionModel *)accordionModel
{
    return (AccordionModel*) super.scene;
}



@end
