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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    AccordionModel *model = [[AccordionModel alloc] init];
    for (int i = 0; i < 1; i++) {
        UIView * cell = [[[NSBundle mainBundle] loadNibNamed:@"ProductCell" owner:self options:nil] lastObject];
        [model addCell:cell];
    }

    self.scene = model;
    [model generateBuffers];
}

- (AccordionModel *)accordionModel
{
    return (AccordionModel*) super.scene;
}

#pragma mark - Private methods




@end
