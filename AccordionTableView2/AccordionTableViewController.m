//
//  AccordionTableViewViewController.m
//  AccordionTableView2
//
//  Created by Tyler Casselman on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccordionTableViewController.h"
#import "AccordionModel.h"
#define kWhiteColor GLKVector4Make(1.f, 1.f, 1.f, 1.f)

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};


@interface AccordionTableViewController ()
{
    EAGLContext *_context;
    GLuint _program;
    GLuint _positionVBO;
    GLuint _indexVBO;
    

    float _screenWidth;
    float _screenHeight;
    float _rotation;
    AccordionModel *_model;
    GLKBaseEffect *_baseEffect;
}
@end

@implementation AccordionTableViewController

- (id)init
{
    self = [super initWithNibName:@"AccordionTableViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    self.preferredFramesPerSecond = 60;
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    view.contentScaleFactor = [UIScreen mainScreen].scale;
    
    [self setupGL];
    [self setupModel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.paused = !self.paused;
}

#pragma mark - private methods
- (void)setupGL
{
    [EAGLContext setCurrentContext:_context];
    [self setupProjection];
    
    glUseProgram(_program);
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:_context];
    
    glDeleteBuffers(1, &_positionVBO);
    glDeleteBuffers(1, &_indexVBO);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

- (void)setupModel
{
    _model = [[AccordionModel alloc] init];
    [self setupBuffers];
}

- (void)update
{
//    _rotation += 45.f * self.timeSinceLastUpdate;
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;

    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.f, 0.f, -150.f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.f, 1.f, 0.f);
    _baseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [_baseEffect prepareToDraw];

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3) + sizeof(GLKVector3), 0);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3) + sizeof(GLKVector3), (const GLvoid *)sizeof(GLKVector3));
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.f, 1.f, 1.f, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glDrawElements(GL_TRIANGLES, _model.indexCount, GL_UNSIGNED_SHORT, 0);
}



#pragma mark - gl stuff

- (void)setupProjection
{
    _baseEffect = [[GLKBaseEffect alloc] init];
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.f), aspect, 1.0f, 200.f);
    _baseEffect.transform.projectionMatrix = projectionMatrix;
    _baseEffect.useConstantColor = YES;
    _baseEffect.constantColor = kWhiteColor;
    
    _baseEffect.lightModelTwoSided = YES;
    _baseEffect.lightingType = GLKLightingTypePerVertex;
    _baseEffect.light0.enabled = YES;
    _baseEffect.light0.position = GLKVector4Make(0.f, 200.f, 1000.f, 1.f);
    _baseEffect.light0.diffuseColor = kWhiteColor;
    _baseEffect.light0.ambientColor = kWhiteColor;
    _baseEffect.light0.constantAttenuation = .95f;
    
    
    [_baseEffect prepareToDraw];
}

- (void)setupBuffers
{
    glGenBuffers(1, &_indexVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _model.indexBufferSize, _model.indicies, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_positionVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _positionVBO);
    glBufferData(GL_ARRAY_BUFFER, _model.vertexBufferSize, _model.verticies, GL_STATIC_DRAW);
        
}

@end
