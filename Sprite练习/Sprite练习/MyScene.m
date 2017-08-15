//
//  MyScene.m
//  Sprite练习
//
//  Created by hp on 2017/8/14.
//  Copyright © 2017年 hpone. All rights reserved.
//

#import "MyScene.h"
#import <AVFoundation/AVFoundation.h>
#import "ResultScene.h"
@interface MyScene()
@property(nonatomic, strong) NSMutableArray * monsters;
/** */
@property (strong, nonatomic) NSMutableArray *projectiles;
/** */
@property (strong, nonatomic) SKAction *projectileSoundEffect;
@property (nonatomic, strong) AVAudioPlayer *bgmPlayer;

/** 摧毁怪物的数量*/
@property (assign, nonatomic) int monstersDestroyed;
@end

@implementation MyScene
// 在为苹果开发游戏时，音效格式推荐使用CAF
- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        // 1 set background color for this scene
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode * bgNode = [SKSpriteNode spriteNodeWithImageNamed:@"result.jpg"];
        bgNode.position = CGPointMake(size.width/2,size.height/2);
        bgNode.size = size;
        
        [self addChild:bgNode];
        // 2 creat new sprite
        SKSpriteNode * player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        // 3 set it's position to the center right edge of screen
        player.position = CGPointMake(player.size.width/2, size.height/2);
        // 4 add it to current scene
        [self addChild:player];
        //
        self.monsters = [NSMutableArray array];
        self.projectiles = [NSMutableArray array];
        
        SKAction * actionAddMoster = [SKAction runBlock:^{
            
            [self addMonster];
        }];
        SKAction * waitAction = [SKAction waitForDuration:1];
        
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[actionAddMoster, waitAction]]]];
        
        // 添加发射音效
        self.projectileSoundEffect = [SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]; // 短声音格式caf
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"bgSound"  withExtension:@"wav"]; // 音频格式不能是caf，mp3
        NSError * error;
        self.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error==nil) {
            
            self.bgmPlayer.numberOfLoops = -1;
            [self.bgmPlayer play];
        } else {
            NSLog(@"%s,line=%d,%@",__FUNCTION__,__LINE__,error);
        }
        // 暂停和继续
        SKSpriteNode * pause = [SKSpriteNode spriteNodeWithImageNamed:@"暂停"];
        pause.size = CGSizeMake(40, 40);
        pause.position = CGPointMake(size.width-40, size.height-40);
        [self addChild:pause];
        pause.name = @"pause";
    }
    return self;
}

- (void)addMonster {
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    CGSize winSize = self.size;
    
    int minY = monster.size.height/2;
    int maxY = winSize.height - monster.size.height/2;
    int rangeY = maxY - minY;
    int actualY = arc4random_uniform(rangeY) + minY;
    
    monster.position = CGPointMake(winSize.width + monster.size.width/2, actualY);
    
    [self addChild:monster];
    [self.monsters addObject:monster];
    int minDuration = 2;
    int maxDuration = 4;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = arc4random_uniform(rangeDuration) + minDuration;
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionDone = [SKAction runBlock:^{
        [monster removeFromParent];
        [self.monsters removeObject:monster];
        //
        [self changeToResultSceneWithWon:NO];
    }];
    [monster runAction:[SKAction sequence:@[actionMove, actionDone]]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for ( UITouch * touch  in touches) {
        
        CGSize winSize = self.size;
        SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
        projectile.position = CGPointMake(projectile.size.width/2, winSize.height/2);
        
        CGPoint location = [touch locationInNode:self];
        // 判断点击的是否是暂停
        SKNode * node = [self nodeAtPoint:location];
        if ([node.name isEqualToString:@"pause"]) {
            self.paused = !self.paused;
            
            SKSpriteNode * pause = (SKSpriteNode * )node;
            // 改变背景图片
            if (self.paused) {
                [self.bgmPlayer pause];
                pause.texture = [SKTexture textureWithImageNamed:@"播放"];
            } else {
                [self.bgmPlayer play];
                pause.texture = [SKTexture textureWithImageNamed:@"暂停"];
            }
            return;
        }
        
        CGPoint offset = CGPointMake(location.x-projectile.position.x, location.y-projectile.position.y);
        if (offset.x<=0) {
            return;
        }
        
        [self addChild:projectile];
        [self.projectiles addObject:projectile];
        // 计算飞向的目的点
        float ratio = (float)offset.y / (float)offset.x;
        // 1 碰撞点在右侧屏幕边缘
        int realX = winSize.width + projectile.size.width/2;
        int realY = realX * ratio + projectile.position.y;
        // 2 碰撞点在屏幕上边或者下边
        if (fabsf(realX * ratio) > winSize.height/2) {
            if (offset.y>=0) { // 触碰到屏幕上方
                
                realY = winSize.height + projectile.size.height/2;
                realX = realY/ ratio;
            } else { // 触碰到屏幕下方
                realY = 0;
                realX = (int)fabs((float)winSize.height/2.0/ ratio);
            }
        }
        CGPoint destPoint = CGPointMake(realX, realY);
    
        // 计算飞行的距离，根据距离计算飞行速度
        int offRealX = realX - projectile.position.x;
        int offRealY = realY - projectile.position.y;
        
        float lenght = sqrtf(offRealX*offRealX + offRealY*offRealY);
        
        float velocity = winSize.width/1.0;
        
        float realMoveDuration = lenght/velocity;
        //
        SKAction * moveAction = [SKAction moveTo:destPoint duration:realMoveDuration];
        
        SKAction * playSoundAction = [SKAction group:@[moveAction, self.projectileSoundEffect]];
        [projectile runAction:playSoundAction completion:^{
            [projectile removeFromParent];
            [self.projectiles removeObject:projectile];

        }];
        
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    NSMutableArray * projectilesDelete = [NSMutableArray array];
    for (SKSpriteNode * projectile in self.projectiles) {
        
        NSMutableArray * monsterDelete = [[NSMutableArray alloc] init];
        for (SKSpriteNode * monster in self.monsters) {
            if (CGRectIntersectsRect(projectile.frame, monster.frame)) {
                [monsterDelete addObject:monster];
                [monster removeFromParent];
                [projectilesDelete addObject:projectile];
                // 碰撞效果
                SKSpriteNode * explodeEffect = [SKSpriteNode spriteNodeWithImageNamed:@"explodeEffect"];
                explodeEffect.size = CGSizeMake(40, 40);
                explodeEffect.position = monster.position;
                [self addChild:explodeEffect];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [explodeEffect removeFromParent];
                });
                // 播放碰撞音效
                SKAction * explodeAction = [SKAction playSoundFileNamed:@"explode-16bit.caf" waitForCompletion:NO];
                [self runAction:explodeAction];
                // 统计摧毁数量
                self.monstersDestroyed ++;
            }
        }
        
        for (SKSpriteNode * monster in monsterDelete) {
            
            [self.monsters removeObject:monster];
        }
        //
        if (self.monstersDestroyed>=30) {

            [self changeToResultSceneWithWon:YES];
        }
    }
    
    for (SKSpriteNode * projectile in projectilesDelete) {
        [self.projectiles removeObject:projectile];
        [projectile removeFromParent];
    }
}

- (void)changeToResultSceneWithWon:(BOOL)won
{
    [self.bgmPlayer stop];
    self.bgmPlayer = nil;
    ResultScene * resultScene = [[ResultScene alloc] initWithSize:self.size won:won];
    SKTransition * transition = [SKTransition revealWithDirection:SKTransitionDirectionUp duration:1.0];
    [self.view presentScene:resultScene transition:transition];
}
@end


