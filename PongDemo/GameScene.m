//
//  GameScene.m
//  PongDemo
//
//  Created by Mircea Popescu on 10/9/18.
//  Copyright © 2018 Mircea Popescu. All rights reserved.
//

#import "GameScene.h"


@interface GameScene()

@property (strong, nonatomic) UITouch *leftPaddleMotivatingTouch;
@property (strong, nonatomic) UITouch *rightPaddleMotivatingTouch;

@end

@implementation GameScene

static const CGFloat kTrackPixelsPerSecond = 500;

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    SKNode *ball = [self childNodeWithName:@"ball"];
    ball.physicsBody.angularVelocity = 1.0;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint p = [t locationInNode:self];
        NSLog(@"\n%f %f %f %f", p.x, p.y, self.frame.size.width, self.frame.size.height);

        if(p.x < self.frame.size.width * 0.01){
            self.leftPaddleMotivatingTouch = t;
            NSLog(@"left");
        } else if(p.x > self.frame.size.width * 0.1){
            self.rightPaddleMotivatingTouch = t;
            NSLog(@"right");
        }
        else {
            // if ball gets stuck, we increase the velocity by clicking in the middle where norither left or right touch is registered and double it's velocity
            SKNode *ball = [ self childNodeWithName:@"ball"];
            ball.physicsBody.velocity = CGVectorMake(ball.physicsBody.velocity.dx*2.0, ball.physicsBody.velocity.dy);
        }
    }
    [self trackPaddlesToMotivatingTouches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
   
    [self trackPaddlesToMotivatingTouches];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   
    if([touches containsObject:self.leftPaddleMotivatingTouch])
        self.leftPaddleMotivatingTouch = nil;
    
    if([touches containsObject:self.rightPaddleMotivatingTouch])
        self.rightPaddleMotivatingTouch = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   
    if([touches containsObject:self.leftPaddleMotivatingTouch])
        self.leftPaddleMotivatingTouch = nil;
    
    if([touches containsObject:self.rightPaddleMotivatingTouch])
        self.rightPaddleMotivatingTouch = nil;
    
}


-(void) trackPaddlesToMotivatingTouches {
    
    id a = @[@{@"node": [self childNodeWithName:@"left_paddle"],
               @"touch": self.leftPaddleMotivatingTouch ?: [NSNull null]},
             @{@"node": [self childNodeWithName:@"right_paddle"],
               @"touch": self.rightPaddleMotivatingTouch ?: [NSNull null]}];
    
    for(NSDictionary *o in a){
        SKNode *node = o[@"node"];
        UITouch *touch = o[@"touch"];
        if([[NSNull null] isEqual:touch])
            continue;
        CGFloat yPos = [touch locationInNode:self].y;
        NSTimeInterval duration = ABS(yPos -node.position.y) / kTrackPixelsPerSecond;
        
        SKAction *moveAction = [SKAction moveToY:yPos duration:duration];
        [node runAction:moveAction withKey:@"moving!"];
    }
}

@end
