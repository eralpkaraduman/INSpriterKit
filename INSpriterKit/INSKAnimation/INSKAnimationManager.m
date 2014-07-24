// INSKAnimationManager.m
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


#import "INSKAnimationManager.h"
#import "INSKAnimationNode.h"
#import "INSKAMHeaders.h"


@interface INSKAnimationManager ()

@property (nonatomic, weak, readwrite) id<INSKAMTextureLoader> textureLoader;

// A INSKAMData object.
@property (nonatomic, strong) INSKAMData *animationData;
// Weak references of all animation nodes.
@property (nonatomic, strong) NSHashTable *animationNodes;
// The last update's system time.
@property (nonatomic, assign) NSTimeInterval lastSystemTime;
// The currently used textures in a cache, each new accessed NSTexture objects will be put here
@property (nonatomic, strong) NSMapTable *textureCache;

@end


@implementation INSKAnimationManager

- (instancetype)initWithAnimationData:(INSKAMData *)animationData textureLoader:(id<INSKAMTextureLoader>)textureLoader {
    self = [super init];
    if (self == nil) return self;
    
    NSAssert(animationData != nil, @"animation data may not be nil");
    self.animationData = animationData;
    self.textureLoader = textureLoader;
    
    self.animationNodes = [NSHashTable weakObjectsHashTable];
    self.textureCache = [NSMapTable strongToWeakObjectsMapTable];
    self.lastSystemTime = 0;
    
    return self;
}

- (void)update:(NSTimeInterval)currentTime {
    NSTimeInterval deltaTime = 0;
    if (self.lastSystemTime > 0) {
        deltaTime = currentTime - self.lastSystemTime;
    }
    self.lastSystemTime = currentTime;

    for (INSKAnimationNode *node in self.animationNodes) {
        [node updateTime:deltaTime];
    }
}

- (NSArray *)allEntityNames {
    return self.animationData.entitiesByName.allKeys.copy;
}

- (NSArray *)allAnimationNamesForEntity:(NSString *)entityName {
    INSKAMEntity *entity = [self.animationData.entitiesByName objectForKey:entityName];
    return entity.animationsByName.allKeys.copy;
}

- (NSDictionary *)allTextureNames {
    NSMutableDictionary *paths = [NSMutableDictionary dictionary];
    for (INSKAMTexture *texture in self.animationData.texturesById.allValues) {
        NSMutableArray *fileNames = [paths objectForKey:texture.relativePath];
        if (fileNames == nil) {
            fileNames = [NSMutableArray array];
            [paths setObject:fileNames forKey:texture.relativePath];
        }
        [fileNames addObject:texture.fileName];
    }
    return paths;
}


#pragma mark - Engine privates

- (INSKAMEntity *)entityNamed:(NSString *)entityName {
    return [self.animationData.entitiesByName objectForKey:entityName];
}

- (void)addAnimationNode:(INSKAnimationNode *)animationNode {
    [self.animationNodes addObject:animationNode];
}

- (void)removeAnimationNode:(INSKAnimationNode *)animationNode {
    [self.animationNodes removeObject:animationNode];
}

- (SKTexture *)textureNamed:(NSString *)textureName path:(NSString *)path {
    // get texture from cache
    NSString *key = [path stringByAppendingString:textureName];
    id textureOrNull = [self.textureCache objectForKey:key];
    if (textureOrNull != nil) {
        // something cached found
        if ([textureOrNull isKindOfClass:[SKTexture class]]) {
            // cached texture found, return it
            return (SKTexture *)textureOrNull;
        } else {
            // null object, no texture from the texture loader to expect
            return nil;
        }
    }
    
    // no cached texture found, ask the delegate
    textureOrNull = [self.textureLoader textureNamed:textureName path:path];
    if (textureOrNull == nil) {
        // no texture, save the null object for not asking the delegate again for this resource
        [self.textureCache setObject:[NSNull null] forKey:key];
        return nil;
    }
    
    // save texture to cache and return it
    [self.textureCache setObject:textureOrNull forKey:key];
    return (SKTexture *)textureOrNull;
}


@end
