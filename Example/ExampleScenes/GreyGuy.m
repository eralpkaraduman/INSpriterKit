// GreyGuy.m
//
// Copyright (c) 2014 Sven Korset
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "GreyGuy.h"
#import <INSPriteKit/INSpriteKit.h>


@interface GreyGuy () <INSKAMTextureLoader, INSKAnimationNodeDelegate>

/// The animation manager for the scene.
@property (nonatomic, strong) INSKAnimationManager *animationManager;
/// The visual representation for the test.
@property (nonatomic, strong) INSKAnimationNode *animationNode;
/// The list of animation names
@property (nonatomic, strong) NSArray *animationNames;
/// The index of the animation name in the entity currenlty playing.
@property (nonatomic, assign) NSInteger currentAnimationIndex;

/// A time label which shows the currently elapsed animation time.
@property (nonatomic, strong) SKLabelNode *animationTimeLabel;
/// A label which shows the currently playing animation name.
@property (nonatomic, strong) SKLabelNode *animationNameLabel;


@end


@implementation GreyGuy

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    // parse Spriter file and create a manager
    INSKScmlParser *scmlParser = [[INSKScmlParser alloc] init];
    NSAssert([scmlParser parseFilename:@"player"], @"Failed loading the scml file");
    NSLog(@"%@ loaded", scmlParser);
    self.animationManager = [[INSKAnimationManager alloc] initWithAnimationData:[scmlParser animationData] textureLoader:self];
    
    // create animation node and assign entity
    self.animationNode = [INSKAnimationNode node];
    if (![self.animationNode loadEntity:@"Player" fromManager:self.animationManager]) {
        NSLog(@"Can't load the Player entity");
    }
    [self addChild:self.animationNode];
    self.animationNode.animationNodeDelegate = self;
    
    // load list of animation names
    self.animationNames = [self.animationManager allAnimationNamesForEntity:@"Player"];
    NSAssert(self.animationNames.count > 0, @"At least one animation should be there to play");
    self.currentAnimationIndex = 0;

    // create animation time label
    self.animationTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    self.animationTimeLabel.fontSize = 15;
    self.animationTimeLabel.position = CGPointMake(10-size.width / 2, 10-size.height / 2);
    self.animationTimeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [self addChild:self.animationTimeLabel];
    
    // create animation name label
    self.animationNameLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    self.animationNameLabel.fontSize = 20;
    self.animationNameLabel.position = CGPointMake(0, size.height / 2 - 100);
    self.animationNameLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [self addChild:self.animationNameLabel];
    
    // create navigation button
    INSKButtonNode *button = [INSKButtonNode buttonNodeWithTitle:@"Next" fontSize:20];
    button.position = CGPointMake(-100, size.height / 2 - 100);
    [button setTouchUpInsideTarget:self selector:@selector(nextButtonPressed)];
    [self addChild:button];
    
    return self;
}

- (void)didMoveToView:(SKView *)view {
    // start playing the first animation
    [self startAnimation];
}

- (void)update:(NSTimeInterval)currentTime {
    // update the manager
    [self.animationManager update:currentTime];
    
    // update the label with the updated animation time
    self.animationTimeLabel.text = [NSString stringWithFormat:@"Animation Time (total %.1f sec): %.1f", self.animationNode.animationLength, self.animationNode.currentAnimationTime];
}

- (void)nextButtonPressed {
    ++self.currentAnimationIndex;
    if (self.currentAnimationIndex >= self.animationNames.count) {
        self.currentAnimationIndex = 0;
    }
    [self startAnimation];
}

- (void)startAnimation {
    NSString *animationName = self.animationNames[self.currentAnimationIndex];
    if (![self.animationNode playAnimation:animationName]) {
        NSLog(@"Can't play animation '%@'", animationName);
    }
    self.animationNode.loopAnimation = YES;
    self.animationNameLabel.text = animationName;
}


#pragma mark - Animation manager TextureLoader methods

- (SKTexture *)textureNamed:(NSString *)textureName path:(NSString *)path {
    // load and return a texture
    NSLog(@"TextureLoader loads %@/%@", path, textureName);
    return [SKTexture textureWithImageNamed:textureName];
}


#pragma mark - Animation node delegate methods

- (void)animationNodeDidFinishPlayback:(INSKAnimationNode *)animationNode looping:(BOOL)looping {
    NSLog(@"Animation did finish playback %@", (looping ? @"and is looping" : @"and stopped"));
}


@end
