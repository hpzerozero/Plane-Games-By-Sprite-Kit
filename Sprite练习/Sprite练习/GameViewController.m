//
//  GameViewController.m
//  Sprite练习
//
//  Created by hp on 2017/8/14.
//  Copyright © 2017年 hpone. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "MyScene.h"

@interface GameViewController ()
@property (nonatomic, weak) MyScene * scene;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load the SKScene from 'GameScene.sks'
//    GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];
//    
//    // Set the scale mode to scale to fit the window
//    scene.scaleMode = SKSceneScaleModeAspectFill;
//    
//    SKView *skView = (SKView *)self.view;
//    
//    // Present the scene
//    [skView presentScene:scene];
//    
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    MyScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    self.scene = scene;
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
