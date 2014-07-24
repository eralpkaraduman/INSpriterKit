// INSKAMSpatial.h
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


#import "INSKAMTypes.h"
#import <SpriteKit/SpriteKit.h>


@class INSKAMTexture;
@class INSKAnimationManager;


@interface INSKAMSpatial : NSObject <NSCopying>

#pragma mark - Keyframe properties
/// @name Keyframe properties

/// The spatial's ID for the timeline
@property (nonatomic, copy) NSString *spatialId;
/// The time of the spatial's key frame in seconds.
@property (nonatomic, assign) NSTimeInterval time;


#pragma mark - SKNode
/// @name SKNode

/// The type of object this spatial represents.
@property (nonatomic, assign) INSKAMSpatialType spatialType;
/// The next spatial in the timeline.
@property (nonatomic, weak) INSKAMSpatial *nextSpatial;
/// The SKNode's name composed with composeNameWithTimelineId:animationId:entityId:.
@property (nonatomic, copy) NSString *nodeName;
/// The SKNode's parent name or nil if this spatial has no parent.
@property (nonatomic, copy) NSString *parentNodeName;
/// The parent timeline ID for updating bone rotation values. Together with the spatial's time it is possible to retrieve the spatial's parent spatial.
@property (nonatomic, copy) NSString *parentTimelineId;
/// Whether this spatial's node is hidden or not.
@property (nonatomic, assign) BOOL hidden;

/// The X postion.
@property (nonatomic, assign) CGFloat positionX;
/// The Y postion.
@property (nonatomic, assign) CGFloat positionY;
/// The X scale factor.
@property (nonatomic, assign) CGFloat scaleX;
/// The Y scale factor.
@property (nonatomic, assign) CGFloat scaleY;
/// The alpha value.
@property (nonatomic, assign) CGFloat alpha;
/// The angle in radians.
@property (nonatomic, assign) CGFloat angle;
/// The rotation direction.
@property (nonatomic, assign) INSKAMSpinType spin;


#pragma mark - SKSpriteNode
/// @name SKSpriteNode

/// The texture for a visual representation or nil if there is none.
@property (nonatomic, strong) INSKAMTexture *texture;
/// The X pivot from 0 to 1.
@property (nonatomic, assign) CGFloat pivotX;
/// The Y pivot from 0 to 1.
@property (nonatomic, assign) CGFloat pivotY;


#pragma mark - Engine methods
/// @name Engine methods

/**
 Creates a name for a Spatial and the corresponding SKNode.
 
 The name will be of the type "INSKAM__entityId_animationId_timelineId" so it is unique for an animation manager and their managed nodes.
 
 @param timelineId The Spriter's timeline ID.
 @param animationId The Spriter's animation ID.
 @param entityId The Spriter's entity ID.
 @return A unique name for the Spatial's node representation.
 */
+ (NSString *)composeNameWithTimelineId:(NSString *)timelineId animationId:(NSString *)animationId entityId:(NSString *)entityId;


/**
 Compares the spatial's time with another time.
 
 The spatial's time is equal if both time values vary at most of 0.0001.
 @param time The time to compare the spatial's with.
 @return True if both times are approximately equal.
 */
- (BOOL)equalsTime:(NSTimeInterval)time;


/**
 Creates a new SKNode out of this spatial.
 
 This method creates the node depending of the spatial type, i.e. a SKNode for a bone or a SKSpriteNode if the spatial has a texture assigned.
 All stats of the SKNode are set depending on the spatial's values.
 The animation manager is asked for a texture if one is needed.
 
 @param animationManager The animation manager to ask for resources.
 @return A initialized SKNode.
 */
- (SKNode *)createNodeForManager:(INSKAnimationManager *)animationManager;


/**
 Updates a SKNode with the values of this spatial interpolated with the spatial's next spatial object in chain.
 
 The node's properties like position, scale, rotation, alpha, etc will be updated according to the current time.
 
 @param node The SKNode which properties to update.
 @param interpolationRatio The ratio to use for interpolating, range from 0 = only this spatial's properties to 1 = only the next spatial's properties. Any value between 0 and 1 will interpolate with this ratio.
 @param animationManager The animation manager to ask for texture resources.
 */
- (void)updateNode:(SKNode *)node interpolation:(CGFloat)interpolationRatio animationManager:(INSKAnimationManager *)animationManager;


/**
 Calculates an interpolation ratio for a spatial depending on the current animation time.
 
 The current animation time has to be the spatial's time or lay between this spatial and the next spatial.
 Because the first keyframe follows right after the last keyframe in a looped animation no interpolation between both are needed and thus is not supported.
 
 @param time The current animation time.
 @return A ratio for interpolating this and the next spatial.
 */
- (CGFloat)interpolationRatioForTime:(NSTimeInterval)time;


@end
