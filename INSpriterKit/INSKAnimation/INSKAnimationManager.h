// INSKAnimationManager.h
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


#import "INSKAMTextureLoader.h"


@class INSKAMData;
@class INSKAnimationNode;
@class INSKAMEntity;
@class INSKAMAnimation;



/**
 The INSKAnimationManager handles and updates all INSKAnimationNode instances which playes animation from the manager.
 
 Normally there is only one instance of INSKAnimationManager needed, initiated with the content of one Spriter file which contains all animations of all entities in the current scene.
 In fact if using multiple instances of INSKAnimationManager the INSKAnimationNode objects should be in different trees or there may occur naming conflicts when managing them.
 Pass the Spriter's data read from a file directly from a parser to a new manager instance.
 The texture loader is a delegate for asking for textures to display.
 
    INSKScmlParser *scmlParser = [[INSKScmlParser alloc] init];
    [scmlParser parseFilename:@"MySpriterFile"];
    INSKAnimationManager *animationManager = [[INSKAnimationManager alloc] initWithAnimationData:[scmlParser animationData] textureLoader:self];

 Therefore the scene should hold a reference to the manager and provide access to it for any game object with a INSKAnimationNode instances.
 The manager has to be updated each frame so the best place to update is in the scene's update method.

    - (void)update:(NSTimeInterval)currentTime {
        [self.animationManager update:currentTime];
    }
 
 For playing any animations from the manager use INSKAnimationNode instances as visual representations.
 
 @see INSKAnimationNode
 */
@interface INSKAnimationManager : NSObject

#pragma mark - Initializer
/// @name Initializer

/**
 Initializes an animation manager instance with Spriter data.
 
 The Spriter's data has to be the object tree parsed by a parser.
 The texture loader is asked each time the manager or an animation node needs a texture thus it should implement the loading handling and maybe cache the textures.
 
 @param animationData The Spriter's data tree.
 @param textureLoader A texture loader.
 */
- (instancetype)initWithAnimationData:(INSKAMData *)animationData textureLoader:(id<INSKAMTextureLoader>)textureLoader;


#pragma mark - Delegates
/// @name Delegates

/**
 The texture loader for querying any textures. Not retained.
 */
@property (nonatomic, weak, readonly) id<INSKAMTextureLoader> textureLoader;


#pragma mark - Public methods
/// @name Public methods

/**
 The update method which has to be called each frame with the current system time.
 
 This method is best placed in a scene's update method.
 
    @implementation MyScene
    - (void)update:(NSTimeInterval)currentTime {
        [self.animationManager update:currentTime];
    }
    @end
 
 @param currentTime The current system time in seconds.
 */
- (void)update:(NSTimeInterval)currentTime;


#pragma mark - Name gatherers
/// @name Name gatherers

/**
 Returns all Entity names available in the manager loaded from the file.
 
 @return An array of NSString objects or nil if there are no entites.
 */
- (NSArray *)allEntityNames;


/**
 Returns all Animation names available for the given animation name.
 
 @param entityName The name of the entity for which to get all animation names.
 @return An array of NSString objects or nil if there are no animations for the entity or there is no entity so called.
 */
- (NSArray *)allAnimationNamesForEntity:(NSString *)entityName;


/**
 Returns all used texture names by the parsed Spriter file.
 
 This method may come handy for preloading all textures before they will get accessed by the manager and their nodes.
 Each texture has a relative path as given by the Spriter file and a file name corresponding to a relative path.
 So multiple file names may have the same path.
 This method returns a dictionary of NSArray objects with the relative path as key. The array consists of the file names for this path.
 
 @return A dictionary with the texture's relative path as key and NSArray objects as values which have the file names for the corresponding path.
 */
- (NSDictionary *)allTextureNames;


// ------------------------------------------------------------
#pragma mark - Engine privates
// ------------------------------------------------------------
/// @name Engine privates

/**
 Returns the entity with the given name.
 
 This will be used by a INSKAnimationNode for retrieving the entity it represents.
 
 @param entityName The name of the entity.
 @return The entity.
 */
- (INSKAMEntity *)entityNamed:(NSString *)entityName;


/**
 Adds a INSKAnimationNode to the management queue so the updateTime: methods will be called automatically.
 
 A INSKAnimationNode normally adds itself as such a delegate object to the manager.
 The manager holds the node as a weak reference in a hash table.
 
 @param animationNode The animation node to add to the management queue.
 */
- (void)addAnimationNode:(INSKAnimationNode *)animationNode;


/**
 Removes a INSKAnimationNode from the management queue.
 
 A INSKAnimationNode can remove itself from the manager if it doesn't need to be called for updates anymore.
 A INSKAnimationNode normally does not need to remove itself from the manager,
 because the manager holds only weak references so destroying the animation node will
 automatically remove it from the manager.
 
 @param animationNode The animation node to remove from the management queue.
 */
- (void)removeAnimationNode:(INSKAnimationNode *)animationNode;


/**
 Returns a SKTexture to use for a Sprite.
 
 First the manager looks if there is a texture object in the cache and if so it returns it.
 If there is no texture in the cache the manager queries the delegate for a new texture object, puts it to the cache and returns it to the caller.
 The cache stores only weak references of the textures and are only for optimization not to ask the delegate too often.
 However, as long as a node uses a texture it will stay in the cache, but if no node uses the texture anymore it will be released and cleared from the cache.
 Then the TextureLoader has to be asked again if a new node needs this texture so the TextureLoader should cache such textures in a more persistent way if such a texture is more often used.
 
 @param textureName The name of the texture's file.
 @param path A relative path to the texture in Spriter's context.
 @return A SKTexture object for a sprite node to present.
 */
- (SKTexture *)textureNamed:(NSString *)textureName path:(NSString *)path;


@end
