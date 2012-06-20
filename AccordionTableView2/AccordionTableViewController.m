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
#define kConstantAttenuaion 1.03f
#define kCameraZ -150.f
//#define kCameraZ -400.f
@interface AccordionTableViewController ()
{
    EAGLContext *_context;
    GLuint _program;
    GLuint _positionVBO;
    GLuint _indexVBO;
    GLKMatrixStackRef _matrixStack;
    
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
//        _rotation = 70.f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupGL];
    [self setupModel];
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

    float stride = sizeof(Vertex);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, (GLvoid *)offsetof(Vertex, position));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, (GLvoid *)offsetof(Vertex, normal));
            
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, stride, (GLvoid *)offsetof(Vertex, textureCoords));
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.f, 1.f, 1.f, 1.0);
//    glClearColor(.5f, .5f, .5f, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    _rotation += 15.f * self.timeSinceLastUpdate;
    

    GLKMatrixStackPush(_matrixStack);
    GLKMatrixStackRotate(_matrixStack, GLKMathDegreesToRadians(_rotation), 0.f, 1.f, 0.f);
    for (WorldObject *object in _model.scene.objects) {
        [self drawObject:object];
    }
    GLKMatrixStackPop(_matrixStack);
    
}

- (void)drawObject:(WorldObject *)object
{
    GLKMatrixStackPush(_matrixStack);
    GLKMatrixStackTranslateWithVector3(_matrixStack, object.position);
    GLKMatrixStackScaleWithVector3(_matrixStack, object.scale);
    _baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(_matrixStack);

    if (object.texture != nil) {
        _baseEffect.texture2d0.enabled = YES;
        _baseEffect.texture2d0.name = object.texture.name;
    } else {
        _baseEffect.texture2d0.enabled = NO;
    }
    
    [_baseEffect prepareToDraw];
    
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, object.indexByteSize, object.indexData, GL_STATIC_DRAW);
    glDrawElements(GL_TRIANGLES, object.indexCount, GL_UNSIGNED_SHORT, 0);
    

    for (WorldObject *subObject in object.subObjects) {
        [self drawObject:subObject];
    }
    GLKMatrixStackPop(_matrixStack);

}

- (GLKMatrix4)projectionMatrix
{
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.f), aspect, 1.0f, 1000.f);
    return projectionMatrix;
//    float hWidth = self.view.bounds.size.width/2;
//    float hHeight =self.view.bounds.size.height/2;
//    return GLKMatrix4MakeOrtho(-hWidth, hWidth, -hHeight, hHeight, 1.0, 1000.f);
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
    
    _matrixStack = GLKMatrixStackCreate(NULL);
    GLKMatrixStackTranslate(_matrixStack, 0.f, 0.f, kCameraZ);
    GLKMatrixStackPush(_matrixStack);
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
