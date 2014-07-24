// INSKAnimationNode.h
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


#import <SpriteKit/SpriteKit.h>

@class INSKAnimationManager;
@class INSKAnimationNode;


/**
 A delegate protocol for INSKAnimationNode objects to inform the delegates about animation playback state changes.
 Each method is optional and informs about state changes.
 */
@protocol INSKAnimationNodeDelegate <NSObject>

/**
 Gets called if the animation playback reaches the end and is or is not looped.
 
 @param animationNode The animation node whiches animation reached the end.
 @param looping True if the animation will be looped, otherwise false.
 */
@optional
- (void)animationNodeDidFinishPlayback:(INSKAnimationNode *)animationNode looping:(BOOL)looping;

@end



/**
 An animation node which is meant to be a visual representation for a game object.
 
 Normally a game object is derived from NSObject and has a SKNode tree for it's visual representation.
 This game object's node now should be of the type INSKAnimationNode so it will be represented with animations.
 You also can add the INSKAnimationNode node as a subnode to any other nodes, perhapes for only having a part animated,
 but you shouldn't add subnodes to a INSKAnimationNode instance because thei may get removed automatically.

 A INSKAnimationNode node is created the same way as any SKNode with it's node class method.
 After creating it needs to be assigned to a INSKAnimationManager instance and an entity by calling loadEntity:fromManager:.
 If an entity is assigned each of the entity's animations can be played back anytime by calling playAnimation:.
 
    INSKAnimationManager *manager = ...
    self.animationNode = [INSKAnimationNode node];
    [self.animationNode loadEntity:@"MyEntity" fromManager:manager];
    [self.animationNode playAnimation:@"MyEntitysAnimation"];
 
 The node is copyable.
 
 @warning Never add subnodes to a INSKAnimationNode instance!
 */
@interface INSKAnimationNode : SKNode <NSCopying>

#pragma mark - Loading an Entity
/// @name Loading an Entity

/**
 Assigns an entity to this animation node which will be loaded from the given manager.
 
 This mehtod needs to be called to initialize the node for animation playback.
 Only animations for this entity may be played.
 
 @param entityName The entity's name in Spriter.
 @param animationManager The manager for this animation node on which the player will be assigned to.
 @return True if the entity could be loaded from the manager, otherwise false.
 */
- (BOOL)loadEntity:(NSString *)entityName fromManager:(INSKAnimationManager *)animationManager;


#pragma mark - Animation playback
/// @name Animation playback

/**
 A weak reference to a delegate which will be informed about animation state changes.
 */
@property (nonatomic, weak) id<INSKAnimationNodeDelegate> animationNodeDelegate;


/**
 Starts playing a new animation.
 
 The animation has to be for the assigned entity.
 Only one animation may play at any time, starting an animation with this method will stop any previous and reset any corresponding values.
 The property animationLength will be set to the appropriate time and currentAnimationTime resetted to 0.
 Assign an entity to the player first by calling loadEntity:fromManager: before starting an animation.
 The animation will replay from the beginning if looping is set to true in Spriter, otherwise it will be stopped automatically.
 Call stopAnimation if the playback should be stopped.
 For pausing an animation set the animationSpeed property to 0 instead.
 
 @param animationName The animation's name.
 @return True if the animation could be found and playback started, otherwise false.
 @see loadEntity:fromManager:
 @see stopAnimation
 @see animationSpeed
 */
- (BOOL)playAnimation:(NSString *)animationName;


/**
 Stops the playback of an animation.
 
 The playback of the current animation will be stopped immediately and the animation removed from the node.
 Does nothing if there is no animation currently playing.
 */
- (void)stopAnimation;


/**
 Returns the name of the current playing animation.
 
 Returns nil if no animation has been started or it has been stopped.
 
 @return The animation's name or nil.
 */
- (NSString *)currentAnimationName;


/**
 The speed of animation playback, defaults to 1.0.
 
 This is a time factor so a value of 1 is equal to the normal Spriter playback speed, while a value less than 1 will slow down the animation playback and a value higher than 1 will increase the speed.
 Therefore setting a value of 0 pauses the animation and a negative value will revert the playback.
 The animation speed is indepedet of the animation and will persist when starting another animation or assigning another entity.
 The animation speed will never be changed automatically.
 */
@property (nonatomic, assign) CGFloat animationSpeed;


/**
 The elapsed time in seconds of the current animation.
 
 Undefined if no animation is currently applyed and will be overwritten if a new animation is played.
 After starting an animation playback this property will be set to 0.0 and will be updated by the manager each frame.
 Assigning a new value will automatically instantly update the visual representation (node tree).
 The time will automatically clamped to the animation length respecting the looping flag.
 
 @see playAnimation:
 */
@property (nonatomic, assign) NSTimeInterval currentAnimationTime;


/**
 The total length in seconds of the current animation.
 
 Undefined if no animation is currently applyed and will be set if a new animation is started.

 @see playAnimation:
 */
@property (nonatomic, assign, readonly) NSTimeInterval animationLength;


/**
 Flag for looping the animation.
 
 This property is automatically set with the value in the Spriter's file when starting a new animation.
 A looping animation will restart from the beginning after reaching the end and call the delegate's animationNodeDidLoopPlayback: method.
 If set to false the animation will stop playback after reaching the end, stay in this time frame and call the delegate's animationNodeDidFinishPlayback: method instead.
 It is safe to change the looping behavior, because an end frame will be created for preventing different animation behaviors compared to Spriter.

 @see playAnimation:
 */
@property (nonatomic, assign) BOOL loopAnimation;


// ------------------------------------------------------------
#pragma mark - Engine privates
// ------------------------------------------------------------
/// @name Engine privates


/**
 Updates the current animation state.
 This method is automatically called each frame by the animation manager so it has never to be called manually.
 
 @param deltaTime The time difference in seconds from the last rendered frame.
 */
- (void)updateTime:(NSTimeInterval)deltaTime;


@end
