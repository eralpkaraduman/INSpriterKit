// INSKAnimationNode.m
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


#import "INSKAnimationNode.h"
#import "INSKAnimationManager.h"
#import "INSKAMHeaders.h"
#import <INSpriteKit/INSpriteKit.h>


@interface INSKAnimationNode ()

@property (nonatomic, assign, readwrite) NSTimeInterval animationLength;

// A weak reference to the animation manager which holds the data model and is queryed for all needed data.
@property (nonatomic, weak) INSKAnimationManager *animationManager;
// The entity this visual representation is bound to. This is retrieved from the spriter manager.
@property (nonatomic, weak) INSKAMEntity *entity;
// The animation currently to play back. Nil if no animation is currently applyed. The animation is retrieved from the animation manager.
@property (nonatomic, weak) INSKAMAnimation *animation;
// True if the update method should increase the animation's current time.
@property (nonatomic, assign) BOOL animationPlayback;

@end


@implementation INSKAnimationNode

- (instancetype)init {
    self = [super init];
    if (self == nil) return self;
    
    self.animationSpeed = 1.0;
    self.animationPlayback = NO;
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    INSKAnimationNode *copy = [super copyWithZone:zone];
    copy.animationSpeed = self.animationSpeed;
    copy.animationManager = self.animationManager;
    copy.entity = self.entity;
    copy.animation = self.animation;
    copy.currentAnimationTime = self.currentAnimationTime; // TODO test this
    copy.animationLength = self.animationLength;
    copy.animationPlayback = self.animationPlayback;
    copy.animationNodeDelegate = self.animationNodeDelegate;
    copy.loopAnimation = self.loopAnimation;
    return copy;
}


#pragma mark - public methods

- (BOOL)loadEntity:(NSString *)entityName fromManager:(INSKAnimationManager *)animationManager {
    // remove from an old manager if any
    [self.animationManager removeAnimationNode:self];
    
    // bind new spriter manager
    self.animationManager = animationManager;
    
    // load entity
    self.entity = [self.animationManager entityNamed:entityName];
    if (self.entity == nil) {
        return NO;
    }
    
    // add node to the manager
    [self.animationManager addAnimationNode:self];
    
    return YES;
}

- (BOOL)playAnimation:(NSString *)animationName {
    // first stop any old animation
    if (self.animation != nil) {
        [self stopAnimation];
    }
    
    // load animation data
    self.animation = [self.entity.animationsByName objectForKey:animationName];
    if (self.animation == nil) {
        return NO;
    }

    // reset animation time and show first frame
    self.animationLength = self.animation.length;
    self.loopAnimation = self.animation.looping;
    [self buildNodeTreeFromTimelines];
    self.currentAnimationTime = 0; // also updates nodes
    self.animationPlayback = YES;
    
    return YES;
}

- (void)stopAnimation {
    self.animation = nil;
    self.animationPlayback = NO;
    [self removeAllChildren];
}

- (NSString *)currentAnimationName {
    return self.animation.name;
}

- (void)setCurrentAnimationTime:(NSTimeInterval)currentAnimationTime {
    _currentAnimationTime = currentAnimationTime;
    self.animationPlayback = YES;
    BOOL animationEndReached = NO;
    BOOL animationLooped = NO;
    
    // make sure the time stays in bounds
    if (self.animationLength == 0.0) {
        _currentAnimationTime = 0.0;
        self.animationPlayback = NO;
        animationEndReached = YES;
    } else if (_currentAnimationTime >= self.animationLength) {
        // animation time exceeded
        animationEndReached = YES;
        if (self.loopAnimation) {
            // animation loops
            _currentAnimationTime -= self.animationLength * floor(_currentAnimationTime / self.animationLength);
            animationLooped = YES;
        } else {
            // stop at last keyframe
            _currentAnimationTime = self.animationLength;
            self.animationPlayback = NO;
        }
    } else if (_currentAnimationTime < 0.0) {
        // animation time below zero
        animationEndReached = YES;
        if (self.loopAnimation) {
            // animation loops
            _currentAnimationTime += self.animationLength * (1 + floor(-_currentAnimationTime / self.animationLength));
            animationLooped = YES;
        } else {
            // stop at first keyframe
            _currentAnimationTime = 0.0;
            self.animationPlayback = NO;
        }
    }
    
    // update nodes
    [self updateNodes];
    
    // inform delegate about reaching the end of the animation
    if (animationEndReached) {
        if ([self.animationNodeDelegate respondsToSelector:@selector(animationNodeDidFinishPlayback:looping:)]) {
            [self.animationNodeDelegate animationNodeDidFinishPlayback:self looping:animationLooped];
        }
    }
}


#pragma mark - engine privates

- (void)buildNodeTreeFromTimelines {
    NSAssert(self.animation != nil, @"Animation needed");
    for (INSKAMTimeline *timeline in self.animation.timelinesById.allValues) {
        INSKAMSpatial *spatial = timeline.spatialsByTime[0];
        SKNode *node = [spatial createNodeForManager:self.animationManager];
        [self addChild:node];
    }
}

- (void)updateTime:(NSTimeInterval)deltaTime {
    // only process if there is an animation at all
    if (!self.animationPlayback || self.animation == nil) {
        return;
    }
    
    // update time
    self.currentAnimationTime += deltaTime * self.animationSpeed;
}

- (void)updateNodes {
    // no updates if there is no animation
    if (self.animation == nil) {
        return;
    }
    
    // process the timelines
    NSArray *timelines = self.animation.timelinesById.allValues;
    for (INSKAMTimeline *timeline in timelines) {
        INSKAMSpatial *spatial = [timeline spatialForTime:self.currentAnimationTime];
        NSAssert(spatial != nil, @"A Spatial should be found");
        NSString *searchString = [NSString stringWithFormat:@"//%@", spatial.nodeName];
        SKNode *spatialNode = [self childNodeWithName:searchString];
        NSAssert(spatialNode != nil, @"There should be a node for each spatial");
        
        // update tree order
        if (spatial.parentNodeName == nil) {
            // no parent, move to root if needed
            if (spatialNode.parent != self) {
                [spatialNode removeFromParent];
                [self addChild:spatialNode];
            }
        } else {
            // change parent if needed
            if (![spatial.parentNodeName isEqualToString:spatialNode.parent.name]) {
                NSString *searchString = [NSString stringWithFormat:@"//%@", spatial.parentNodeName];
                SKNode *parentNode = [self childNodeWithName:searchString];
                NSAssert(parentNode != nil, @"There should be a parent node");
                [spatialNode removeFromParent];
                [parentNode addChild:spatialNode];
            }
        }
        
        // update values
        if ([spatial equalsTime:self.currentAnimationTime]) {
            // spatial for time, no interpolation needed
            [spatial updateNode:spatialNode interpolation:0.0 animationManager:self.animationManager];
        } else {
            // interpolate spatials
            CGFloat interpolationRatio = [spatial interpolationRatioForTime:self.currentAnimationTime];
            [spatial updateNode:spatialNode interpolation:interpolationRatio animationManager:self.animationManager];
        }
    }
}


@end
