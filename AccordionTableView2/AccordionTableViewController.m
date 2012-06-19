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
#define kWhiteColor GLKVector4Make(1.f, 1.f, 1.f, 1.f)
#define kConstantAttenuaion 1.1f
//#define kCameraZ -150.f
#define kCameraZ -400.f

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
    GLKVector2 _currentScreenOffset;
    AccordionModel *_model;
    GLKBaseEffect *_baseEffect;
    
}
@property (nonatomic, readonly) GLKMatrix4 projectionMatrix;
@end

@implementation AccordionTableViewController

- (id)init
{
    self = [super initWithNibName:@"AccordionTableViewController" bundle:nil];
    if (self) {
//        _rotation = 90.f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [_model setContentOffset:currentWorldOffset];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _currentScreenOffset = GLKVector2Add(_currentScreenOffset, currentOffset);
    }
}

#pragma mark - private methods
- (void)setupGL
{
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    [EAGLContext setCurrentContext:_context];
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    

    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    self.preferredFramesPerSecond = 60;
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    view.contentScaleFactor = [UIScreen mainScreen].scale;

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
//    _rotation += 15.f * self.timeSinceLastUpdate;
//    [_model updatedLattice];
    glBufferData(GL_ARRAY_BUFFER, _model.vertexBufferSize, _model.verticies, GL_STATIC_DRAW);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;

    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.f, 0.f, kCameraZ);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.f, 1.f, 0.f);
    _baseEffect.transform.modelviewMatrix = modelViewMatrix;
    


    float stride = sizeof(Vertex);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, 0);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, (const GLvoid *)sizeof(GLKVector3));
            
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, stride, (const GLvoid *)(sizeof(GLKVector3) * 2));
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.f, 1.f, 1.f, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _model.indexBufferSize, _model.indicies, GL_STATIC_DRAW);
//    _baseEffect.texture2d0.enabled = NO;
//    [_baseEffect prepareToDraw];
//    glDrawElements(GL_TRIANGLES, _model.indexCount, GL_UNSIGNED_SHORT, 0);
//    _baseEffect.texture2d0.enabled = YES;
//    
//    
//    [_baseEffect prepareToDraw];
//    for (int i = 0; i < _model.latticeCount; i++) {
//        FoldingRectIndicies rectIndicies = [_model foldingRectIndiciesForIndex:i];
//        _baseEffect.texture2d0.name = rectIndicies.glTextName;
//        _baseEffect.texture2d0.envMode = GLKTextureEnvModeModulate;
//        _baseEffect.texture2d0.target = GLKTextureTarget2D;
//        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(rectIndicies.indices), rectIndicies.indices, GL_STATIC_DRAW);
//        glDrawElements(GL_TRIANGLES, rectIndicies.count, GL_UNSIGNED_SHORT, 0);
//    }
    GLKMatrix4 modelViewMatrix = _baseEffect.transform.modelviewMatrix;
    for (WorldObject *object in _model.scene.objects) {
        GLKMatrix4 objectMatrix = GLKMatrix4ScaleWithVector3(modelViewMatrix, object.scale);
        _baseEffect.transform.modelviewMatrix = objectMatrix;
        [_baseEffect prepareToDraw];
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, object.indexByteSize, object.indexData, GL_STATIC_DRAW);
        glDrawElements(GL_TRIANGLES, object.indexCount, GL_UNSIGNED_SHORT, 0);
        
    } 
}

- (GLKMatrix4)projectionMatrix
{
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.f), aspect, 1.0f, 1000.f);
    return projectionMatrix;
}

- (GLKVector3)worldPointFromScreenPoint:(GLKVector2)screenPoint
{
//    int viewport[] = {0, (int)self.view.bounds.size.height, (int)self.view.bounds.size.width, (int)self.view.bounds.size.height};
//    GLKVector3 windowPoint = GLKVector3Make(screenPoint.x, screenPoint.y, 0.f);
//    bool success = NO;
//    GLKVector3 worldPoint = GLKMathUnproject(windowPoint, GLKMatrix4Identity, self.projectionMatrix, viewport, &success);
//    return worldPoint;
    return GLKVector3Make(screenPoint.x, screenPoint.y, 0.f);
}

- (void)setupProjection
{
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.transform.projectionMatrix = self.projectionMatrix;
    _baseEffect.useConstantColor = YES;
    _baseEffect.constantColor = kWhiteColor;
    
    _baseEffect.lightModelTwoSided = YES;
    _baseEffect.lightingType = GLKLightingTypePerVertex;
    _baseEffect.light0.enabled = YES;
    _baseEffect.light0.position = GLKVector4Make(0.f, 100.f, 60.f, 1.f);
    _baseEffect.light0.diffuseColor = kWhiteColor;
    _baseEffect.light0.ambientColor = kWhiteColor;
    _baseEffect.light0.constantAttenuation = kConstantAttenuaion;
    
    
    [_baseEffect prepareToDraw];
}

- (void)setupBuffers
{
    glGenBuffers(1, &_indexVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);
    
    glGenBuffers(1, &_positionVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _positionVBO);
    glBufferData(GL_ARRAY_BUFFER, _model.vertexBufferSize, _model.verticies, GL_STATIC_DRAW);
        
}

@end
