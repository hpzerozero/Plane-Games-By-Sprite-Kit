//
//  ResultScene.m
//  Sprite练习
//
//  Created by hp on 2017/8/15.
//  Copyright © 2017年 hpone. All rights reserved.
//

#import "ResultScene.h"
#import "MyScene.h"
@implementation ResultScene
- (instancetype)initWithSize:(CGSize)size won:(BOOL)won
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode * bgNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg.jpg"];
        bgNode.position = CGPointMake(size.width/2,size.height/2);
        bgNode.size = size;
        [self addChild:bgNode];
        
        SKLabelNode * resultLable = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        resultLable.text = won ? @"YOU WIN!" : @"YOU LOSE";
        resultLable.fontSize = 20;
        if (won) {
            resultLable.fontColor = [SKColor redColor];
        } else {
            resultLable.fontColor = [SKColor magentaColor];
        }
        resultLable.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:resultLable];
        //
        SKLabelNode * retryLable = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryLable.text = @"try again";
        retryLable.fontSize = 20;
        retryLable.fontColor = SKColor.blueColor;
        retryLable.position = CGPointMake(resultLable.position.x, resultLable.position.y*0.6);
        retryLable.name = @"retryLable";
        
        [self addChild:retryLable];
        
    }
    return  self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch * touch in touches) {
        CGPoint point = [touch locationInNode:self];
        SKNode * node = [self nodeAtPoint:point];
        if ([node.name isEqualToString:@"retryLable"]) {
            [self retryGame];
        }
    }
}

- (void)retryGame{
    MyScene * gameScene = [MyScene sceneWithSize:self.size];
    SKTransition * transition = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    [self.view presentScene:gameScene transition:transition];
}
@end
