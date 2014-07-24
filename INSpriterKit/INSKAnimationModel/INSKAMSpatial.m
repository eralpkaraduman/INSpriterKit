// INSKAMSpatial.m
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


#import "INSKAMSpatial.h"
#import "INSKAMTexture.h"
#import "INSKAnimationManager.h"
#import "INSKAMMath.h"
#import <INSpriteKit/INSKMath.h>


@implementation INSKAMSpatial

- (instancetype)copyWithZone:(NSZone *)zone {
    INSKAMSpatial *spatialCopy = [[[self class] allocWithZone:zone] init];
    spatialCopy.spatialId = [self.spatialId stringByAppendingString:@"+"];
    spatialCopy.time = self.time;
    spatialCopy.spatialType = self.spatialType;
    spatialCopy.nextSpatial = self.nextSpatial;
    spatialCopy.nodeName = self.nodeName;
    spatialCopy.parentNodeName = self.parentNodeName;
    spatialCopy.parentTimelineId = self.parentTimelineId;
    spatialCopy.hidden = self.hidden;
    spatialCopy.positionX = self.positionX;
    spatialCopy.positionY = self.positionY;
    spatialCopy.scaleX = self.scaleX;
    spatialCopy.scaleY = self.scaleY;
    spatialCopy.alpha = self.alpha;
    spatialCopy.angle = self.angle;
    spatialCopy.spin = self.spin;
    spatialCopy.texture = self.texture;
    spatialCopy.pivotX = self.pivotX;
    spatialCopy.pivotY = self.pivotY;
    return spatialCopy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Spatial:'%@' Next:'%@' Type:%d Name:'%@' Parent:'%@' Time:%.2f Pos:%.0f,%.0f Scale:%.1f,%.1f Alpha:%.2f %@ Angle:%.2f Spin:%d Pivot:%.1f,%.1f", self.spatialId, self.nextSpatial.spatialId, self.spatialType, self.nodeName, self.parentNodeName, self.time, self.positionX, self.positionY, self.scaleX, self.scaleY, self.alpha, (self.hidden ? @"hidden" : @"opaque"), self.angle, self.spin, self.pivotX, self.pivotY];
}

- (SKNode *)createNodeForManager:(INSKAnimationManager *)animationManager {
    SKNode *node = nil;
    if (self.spatialType == INSKAMSpatialTypeSprite) {
        SKTexture *texture = [animationManager textureNamed:self.texture.fileName path:self.texture.relativePath];
        CGSize size = CGSizeMake(self.texture.width, self.texture.height);
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture size:size];
        node = sprite;
        sprite.anchorPoint = CGPointMake(self.pivotX, self.pivotY);
    } else if (self.spatialType == INSKAMSpatialTypeNode) {
        node = [SKNode node];
    } else {
        NSAssert(false, @"unknown spatial type");
    }

    // the nodes should only be created, no properties yet to assign
    node.name = self.nodeName;
    node.hidden = YES;
    
    return node;
}

- (BOOL)equalsTime:(NSTimeInterval)time {
    return ScalarNearOtherWithVariance(self.time, time, 0.0001);
}

+ (NSString *)composeNameWithTimelineId:(NSString *)timelineId animationId:(NSString *)animationId entityId:(NSString *)entityId {
    return [NSString stringWithFormat:@"INSKAM_%@_%@_%@", entityId, animationId, timelineId];
}

- (void)updateNode:(SKNode *)node interpolation:(CGFloat)interpolationRatio animationManager:(INSKAnimationManager *)animationManager {
    NSAssert(self.nextSpatial != nil, @"a next spatial is always expected");
    NSAssert(interpolationRatio >= 0.0 && interpolationRatio <= 1.0, @"interpolation ratio range from 0 to 1 expected");
    NSAssert(self.time < self.nextSpatial.time || interpolationRatio == 0.0, @"There should be never an interpolation between the last and the first spatial");
    
    // node hidden?
    node.hidden = self.hidden;
    if (node.hidden) {
        return;
    }
    
    // interpolation needed?
    if (interpolationRatio == 0.0) {
        // no interpolation
        node.position = CGPointMake(self.positionX, self.positionY);
        node.alpha = self.alpha;
        node.zRotation = self.angle;
    } else {
        // interpolate
        node.position = CGPointMake(LinearInterpolation(self.positionX, self.nextSpatial.positionX, interpolationRatio), LinearInterpolation(self.positionY, self.nextSpatial.positionY, interpolationRatio));
        node.alpha = LinearInterpolation(self.alpha, self.nextSpatial.alpha, interpolationRatio);
        node.zRotation = LinearAngleInterpolationRadian(self.angle, self.nextSpatial.angle, self.spin, interpolationRatio);
    }
    
    // update node depending values
    if (self.spatialType == INSKAMSpatialTypeSprite) {
        NSAssert([node isKindOfClass:[SKSpriteNode class]], @"node expected to be a sprite node");
        SKSpriteNode *spriteNode = (SKSpriteNode *)node;

        if (interpolationRatio == 0.0) {
            // no interpolation
            spriteNode.anchorPoint = CGPointMake(self.pivotX, self.pivotY);
            spriteNode.xScale = self.scaleX;
            spriteNode.yScale = self.scaleY;
        } else {
            // interpolate
            spriteNode.anchorPoint = CGPointMake(LinearInterpolation(self.pivotX, self.nextSpatial.pivotX, interpolationRatio), LinearInterpolation(self.pivotY, self.nextSpatial.pivotY, interpolationRatio));
            spriteNode.xScale = LinearInterpolation(self.scaleX, self.nextSpatial.scaleX, interpolationRatio);
            spriteNode.yScale = LinearInterpolation(self.scaleY, self.nextSpatial.scaleY, interpolationRatio);
        }

        // get texture from the animation manager who caches it
        SKTexture *texture = [animationManager textureNamed:self.texture.fileName path:self.texture.relativePath];
        spriteNode.texture = texture;
    } else if (self.spatialType == INSKAMSpatialTypeNode) {
        // nothing to do
    } else {
        NSAssert(false, @"unknown spatial type");
    }

}

- (CGFloat)interpolationRatioForTime:(NSTimeInterval)time {
    // make some assumptions
    NSAssert(self.nextSpatial != nil, @"a next spatial is always expected");
    NSAssert(self.time < self.nextSpatial.time || [self equalsTime:time], @"There should be never an interpolation between the last and the first spatial");
    NSAssert(time >= self.time && time <= self.nextSpatial.time, @"the time should lay between this and the next spatial");
    
    // calculate the ratio
    return (time - self.time) / (self.nextSpatial.time - self.time);
}


@end
