// BasicTestScene.m
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


#import "BasicTestScene.h"


@interface BasicTestScene ()

@property (nonatomic, strong) SKLabelNode *animationTimeLabel;

@end


@implementation BasicTestScene

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    // parse Spriter file and create a manager
    INSKScmlParser *scmlParser = [[INSKScmlParser alloc] init];
    NSAssert([scmlParser parseFilename:@"BasicTests"], @"Failed loading the scml file");
    NSLog(@"%@ loaded", scmlParser);
    self.animationManager = [[INSKAnimationManager alloc] initWithAnimationData:[scmlParser animationData] textureLoader:self];
    
    // create animation node and assign entity
    self.animationNode = [INSKAnimationNode node];
    if (![self.animationNode loadEntity:@"TestEntity" fromManager:self.animationManager]) {
        NSLog(@"Can't load TestEntity");
    }
    [self addChild:self.animationNode];
    self.animationNode.animationNodeDelegate = self;
    
    // create animation time label
    self.animationTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    self.animationTimeLabel.fontSize = 15;
    self.animationTimeLabel.position = CGPointMake(10-size.width / 2, 10-size.height / 2);
    self.animationTimeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [self addChild:self.animationTimeLabel];
    
    return self;
}

- (void)didMoveToView:(SKView *)view {
    // start playing an animation
    NSString *animationName = NSStringFromClass([self class]);
    if (![self.animationNode playAnimation:animationName]) {
        NSLog(@"Can't play animation '%@'", animationName);
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // update the manager
    [self.animationManager update:currentTime];
    
    // update the label with the updated animation time
    self.animationTimeLabel.text = [NSString stringWithFormat:@"Animation Time (total %.1f sec): %.1f", self.animationNode.animationLength, self.animationNode.currentAnimationTime];
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
