// INSKSpriterParser.m
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


#import "INSKSpriterParser.h"
#import "SpriterModelHeaders.h"
#import "INSKAMHeaders.h"
#import <INLib/INLib.h>
#import <INSpriteKit/INSKMath.h>


@interface INSKSpriterParser ()

@property (nonatomic, copy, readwrite) NSString *filename;

@end


@implementation INSKSpriterParser

#pragma mark - methods to override

- (NSString *)filenameExtension {
    // has to be overridden by a subclass
    return nil;
}

- (BOOL)parseFileContent:(NSData *)content {
    // has to be overridden by a subclass
    return NO;
}


#pragma mark - private methods

- (void)resetProperties {
    self.fileVersion = nil;
    self.generator = nil;
    self.generatorVersion = nil;
    self.spriterData = nil;
    self.filename = nil;
}


#pragma mark - public methods

- (NSString *)description {
    if (self.spriterData) {
        return [NSString stringWithFormat:@"Spriter file '%@.%@' v%@", self.filename, [self filenameExtension], self.fileVersion];
    } else {
        return [NSString stringWithFormat:@"No Spriter data for file '%@.%@'", self.filename, [self filenameExtension]];
    }
}

- (BOOL)parserForVersion:(NSString *)parserVersion shouldBeCompatibleToFileVersion:(NSString *)fileVersion {
    if (parserVersion == nil || fileVersion == nil) {
        return NO;
    }
    
    NSString *notSupportedVersion = [parserVersion versionStringIncreasedAtIndex:1];
    return [fileVersion versionLowerThan:notSupportedVersion];
}

- (BOOL)parseFilename:(NSString *)filename {
    // reset values
    [self resetProperties];
    self.filename = filename;

    // load file's content
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:[self filenameExtension]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data == nil) {
        return NO;
    }
    
    // parse the file's content
    BOOL success = [self parseFileContent:data];
    if (!success) {
        return NO;
    }
    
    // validate model version
    if (self.fileVersion != nil) {
        NSString *notSupportedVersion = [SpriterFileVersionSupported versionStringIncreasedAtIndex:0];
        if (self.fileVersion == nil || ![self.fileVersion versionLowerThan:notSupportedVersion]) {
            NSLog(@"Warning: The file '%@' is of version %@, but currently only a model of v%@ is supported!", self.filename, self.fileVersion, SpriterFileVersionSupported);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)parseSpriterdata:(NSData *)data {
    // reset values
    [self resetProperties];

    // data object needed
    if (data == nil) {
        return NO;
    }
    
    // parse the file's content
    BOOL success = [self parseFileContent:data];
    if (!success) {
        return NO;
    }
    
    // validate model version
    if (self.fileVersion != nil) {
        NSString *notSupportedVersion = [SpriterFileVersionSupported versionStringIncreasedAtIndex:0];
        if (self.fileVersion == nil || ![self.fileVersion versionLowerThan:notSupportedVersion]) {
            NSLog(@"Warning: The given Spriter data is of version %@, but currently only a model of v%@ is supported!", self.fileVersion, SpriterFileVersionSupported);
            return NO;
        }
    }

    return YES;
}

- (INSKAMData *)animationData {
    if (self.spriterData == nil) {
        return nil;
    }
    
    // create animation data
    INSKAMData *data = [[INSKAMData alloc] init];
    
    // create textures
    data.texturesById = [NSMutableDictionary dictionary];
    for (SpriterFolder *spriterFolder in self.spriterData.folders) {
        for (SpriterFile *spriterFile in spriterFolder.files) {
            INSKAMTexture *texture = [[INSKAMTexture alloc] init];
            texture.textureId = [NSString stringWithFormat:@"%@_%@", spriterFolder.folderId, spriterFile.fileId];
            [data.texturesById setObject:texture forKey:texture.textureId];
            texture.width = spriterFile.width;
            texture.height = spriterFile.height;
            texture.relativePath = spriterFolder.name;
            NSAssert(spriterFolder.name.length < spriterFile.name.length, @"The file name normally includes the folder");
            texture.fileName = [spriterFile.name substringFromIndex:spriterFolder.name.length + 1];
        }
    }
    
    // create entities
    data.entitiesByName = [NSMutableDictionary dictionary];
    for (SpriterEntity *spriterEntity in self.spriterData.entities) {
        // create entity
        INSKAMEntity *entity = [[INSKAMEntity alloc] init];
        entity.name = spriterEntity.name;
        [data.entitiesByName setObject:entity forKey:entity.name];
        
        // create animations
        entity.animationsByName = [NSMutableDictionary dictionary];
        for (SpriterAnimation *spriterAnimation in spriterEntity.animations) {
            INSKAMAnimation *animation = [[INSKAMAnimation alloc] init];
            animation.name = spriterAnimation.name;
            [entity.animationsByName setObject:animation forKey:animation.name];
            
            animation.length = spriterAnimation.length / 1000.0; // convert from milliseconds to seconds
            animation.looping = spriterAnimation.looping;
            
            // create timelines
            animation.timelinesById = [NSMutableDictionary dictionary];
            for (SpriterTimeline *spriterTimeline in spriterAnimation.timelines) {
                INSKAMTimeline *timeline = [[INSKAMTimeline alloc] init];
                timeline.timelineId = spriterTimeline.timelineId;
                [animation.timelinesById setObject:timeline forKey:timeline.timelineId];
                
                // create spatial name for this timeline
                NSString *spatialName = [INSKAMSpatial composeNameWithTimelineId:spriterTimeline.timelineId animationId:spriterAnimation.animationId entityId:spriterEntity.entityId];
                
                // create spatials
                NSMutableArray *spatialsByTime = [NSMutableArray array];
                // spatials in the timeline
                for (SpriterTimelineKey *spriterTimelineKey in spriterTimeline.keys) {
                    // create spatial of key
                    INSKAMSpatial *spatial = [[INSKAMSpatial alloc] init];
                    [spatialsByTime addObject:spatial];
                    spatial.spatialId = spriterTimelineKey.keyId;
                    spatial.nodeName = spatialName;
                    spatial.time = spriterTimelineKey.time / 1000.0; // convert from milliseconds to seconds
                    spatial.hidden = NO;
                    if (spriterTimelineKey.object != nil) {
                        spatial.spatialType = INSKAMSpatialTypeSprite;
                        SpriterObject *object = spriterTimelineKey.object;
                        // node data
                        spatial.positionX = object.positionX;
                        spatial.positionY = object.positionY;
                        spatial.scaleX = object.scaleX;
                        spatial.scaleY = object.scaleY;
                        spatial.alpha = object.alpha;
                        spatial.angle = DegreesToRadians(object.angle);
                        spatial.spin = spriterTimelineKey.spin;
                        // sprite data
                        spatial.texture = [data.texturesById objectForKey:[NSString stringWithFormat:@"%@_%@", object.folderId, object.fileId]];
                        SpriterFile *spriterFile = [self spriterFileWithId:object.fileId folderId:object.folderId];
                        NSAssert(spriterFile != nil, @"spriterFile should exist");
                        spatial.pivotX = object.pivotX;
                        if (object.pivotX == SpriterObjectNoPivotValue) {
                            spatial.pivotX = spriterFile.pivotX;
                        }
                        spatial.pivotY = object.pivotY;
                        if (object.pivotY == SpriterObjectNoPivotValue) {
                            spatial.pivotY = spriterFile.pivotY;
                        }
                    } else if (spriterTimelineKey.bone != nil) {
                        spatial.spatialType = INSKAMSpatialTypeNode;
                        SpriterBone *object = spriterTimelineKey.bone;
                        spatial.positionX = object.positionX;
                        spatial.positionY = object.positionY;
                        spatial.scaleX = object.scaleX;
                        spatial.scaleY = object.scaleY;
                        spatial.alpha = object.alpha;
                        spatial.angle = DegreesToRadians(object.angle);
                        spatial.spin = spriterTimelineKey.spin;
                    } else {
                        NSAssert(false, @"Unsupported Spatial type?");
                        return nil;
                    }
                }
                NSAssert(spatialsByTime.count > 0, @"There should be at least one spatial in each timeline");
                timeline.spatialsByTime = spatialsByTime;
            }
            NSAssert(animation.timelinesById.count > 0, @"no timelines");
            
            // update the parent names of all timeline's spatials
            for (SpriterMainlineKey *spriterMainlineKey in spriterAnimation.mainline.keys) {
                for (SpriterObjectRef *spriterObjectRef in spriterMainlineKey.objectRefs) {
                    [self updateSpatialForMainlineKey:spriterMainlineKey spriterTimelineId:spriterObjectRef.timelineId spriterParentId:spriterObjectRef.parentId timelinesById:animation.timelinesById];
                }
                for (SpriterBoneRef *spriterBoneRef in spriterMainlineKey.boneRefs) {
                    [self updateSpatialForMainlineKey:spriterMainlineKey spriterTimelineId:spriterBoneRef.timelineId spriterParentId:spriterBoneRef.parentId timelinesById:animation.timelinesById];
                }
            }

            // add any missing spatials for all timelines and create shortcut links
            for (INSKAMTimeline *timeline in animation.timelinesById.allValues) {
                // make sure there is a spatial for time 0 and on the end frame
                INSKAMSpatial *firstSpatial = timeline.spatialsByTime[0];
                if (![firstSpatial equalsTime:0.0]) {
                    // insert a hidden spatial for time 0
                    INSKAMSpatial *zeroSpatial = firstSpatial.copy;
                    zeroSpatial.time = 0.0;
                    zeroSpatial.hidden = YES;
                    [timeline.spatialsByTime insertObject:zeroSpatial atIndex:0];
                    firstSpatial = zeroSpatial;
                }
                INSKAMSpatial *endSpatial = [timeline.spatialsByTime lastObject];
                if (![endSpatial equalsTime:animation.length]) {
                    if (animation.looping) {
                        // insert a copy of the first as the last frame
                        INSKAMSpatial *spatial = firstSpatial.copy;
                        spatial.time = animation.length;
                        [timeline.spatialsByTime addObject:spatial];
                        
                        // if pivot changes the pivot of the first keyframe is not correct
                        spatial.pivotX = endSpatial.pivotX;
                        spatial.pivotY = endSpatial.pivotY;
                    } else {
                        // insert a copy of the last frame as a new frame
                        INSKAMSpatial *spatial = endSpatial.copy;
                        spatial.time = animation.length;
                        [timeline.spatialsByTime addObject:spatial];
                    }
                }
                
                // create shortcut links between spatials
                for (NSUInteger index = 0; index < timeline.spatialsByTime.count - 1; ++index) {
                    INSKAMSpatial *spatial = timeline.spatialsByTime[index];
                    spatial.nextSpatial = timeline.spatialsByTime[index + 1];
                }
                // always connect the last with the first spatial regardless of the current looping state
                INSKAMSpatial *lastSpatial = timeline.spatialsByTime.lastObject;
                lastSpatial.nextSpatial = timeline.spatialsByTime[0];
            }

            // add any hiding spatials.
            NSArray *timelineIds = animation.timelinesById.allKeys;
            for (SpriterMainlineKey *spriterMainlineKey in spriterAnimation.mainline.keys) {
                // collect timeline IDs which are not in the mainline
                NSMutableArray *unusedTimelineIds = timelineIds.mutableCopy;
                for (SpriterObjectRef *spriterObjectRef in spriterMainlineKey.objectRefs) {
                    [unusedTimelineIds removeObject:spriterObjectRef.timelineId];
                }
                for (SpriterBoneRef *spriterBoneRef in spriterMainlineKey.boneRefs) {
                    [unusedTimelineIds removeObject:spriterBoneRef.timelineId];
                }
                
                // add hiding spatials for the unused IDs
                for (NSString *timelineId in unusedTimelineIds) {
                    [self addHiddenSpatialToTimeline:[animation.timelinesById objectForKey:timelineId] atSpriterTime:spriterMainlineKey.time];
                }
            }

            // update position and scale values
            // TODO optimize cycle
            NSMutableSet *updatedSpatials = [NSMutableSet set];
            BOOL cycle = YES; // cycle while there are any spatials updated
            while (cycle) {
                cycle = NO;
                for (INSKAMTimeline *timeline in animation.timelinesById.allValues) {
                    for (INSKAMSpatial *spatial in timeline.spatialsByTime) {
                        if ([updatedSpatials containsObject:spatial]) {
                            // already updated
                        } else if (spatial.parentNodeName == nil) {
                            // no parent, no update needed
                            [updatedSpatials addObject:spatial];
                            cycle = YES;
                        } else {
                            INSKAMTimeline *parentTimeline = [animation.timelinesById objectForKey:spatial.parentTimelineId];
                            INSKAMSpatial *parentSpatial = [parentTimeline spatialForTime:spatial.time];
                            NSAssert(parentSpatial != nil, @"There should always be a parent spatial");
                            if (![updatedSpatials containsObject:parentSpatial]) {
                                // parent not yet updated
                                continue;
                            }
                            
                            // parent updated, so update this spatial
                            spatial.positionX *= parentSpatial.scaleX;
                            spatial.positionY *= parentSpatial.scaleY;
                            spatial.scaleX *= parentSpatial.scaleX;
                            spatial.scaleY *= parentSpatial.scaleY;
                            [updatedSpatials addObject:spatial];
                            cycle = YES;
                        }
                    }
                }
            }
        }
        NSAssert(entity.animationsByName.count > 0, @"no animations");
    }
    NSAssert(data.entitiesByName.count > 0, @"no entities");
    
    return data;
}

// Returns a spriter file for the file and folder id.
- (SpriterFile *)spriterFileWithId:(NSString *)fileId folderId:(NSString *)folderId {
    SpriterFolder *folder = [self.spriterData.folders firstObjectPassingTest:^BOOL(SpriterFolder *folder) {
        return [folder.folderId isEqualToString:folderId];
    }];
    SpriterFile *file = [folder.files firstObjectPassingTest:^BOOL(SpriterFile *file) {
        return [file.fileId isEqualToString:fileId];
    }];
    return file;
}

// Add spatials which hides the nodes when there is no key in the mainline.
- (void)addHiddenSpatialToTimeline:(INSKAMTimeline *)timeline atSpriterTime:(NSInteger)spriterTime {
    NSTimeInterval time = spriterTime / 1000.0;
    INSKAMSpatial *spatial = [timeline spatialForTime:time];
    NSAssert(spatial != nil, @"a spatial expected");
    if ([spatial equalsTime:time]) {
        return;
    }
    
    NSUInteger spatialIndex = [timeline.spatialsByTime indexOfObject:spatial];
    NSAssert(spatialIndex != NSNotFound, @"spatial should have an index");
    INSKAMSpatial *newSpatial = spatial.copy;
    newSpatial.time = time;
    newSpatial.hidden = YES;
    spatial.nextSpatial = newSpatial;
    [timeline.spatialsByTime insertObject:newSpatial atIndex:spatialIndex + 1];
    spatial = newSpatial;
}

// Updates the parent links.
- (void)updateSpatialForMainlineKey:(SpriterMainlineKey *)spriterMainlineKey spriterTimelineId:(NSString *)spriterTimelineId spriterParentId:(NSString *)spriterParentId timelinesById:(NSDictionary *)timelinesById {
    // find corresponding spatial
    INSKAMTimeline *timeline = [timelinesById objectForKey:spriterTimelineId];
    NSAssert(timeline != nil, @"available timeline expected");
    NSTimeInterval time = spriterMainlineKey.time / 1000.0; // convert Spriter's time in milliseconds to seconds
    INSKAMSpatial *spatial = [timeline spatialForTime:time];
    NSAssert(spatial != nil, @"spatial expected");
    
    // update parent
    if ([spriterParentId isEqualToString:SpriterRefNoParentValue]) {
        // no parent
        spatial.parentNodeName = nil;
        spatial.parentTimelineId = nil;
    } else {
        // has parent
        SpriterBoneRef *parentRef = [spriterMainlineKey.boneRefs firstObjectPassingTest:^BOOL(SpriterBoneRef *ref) {
            return [ref.refId isEqualToString:spriterParentId];
        }];
        NSAssert(parentRef != nil, @"the reference should point to a bone");
        INSKAMTimeline *parentTimeline = [timelinesById objectForKey:parentRef.timelineId];
        INSKAMSpatial *parentSpatial = [parentTimeline spatialForTime:time];
        NSAssert(parentSpatial != nil, @"no parent spatial found");
        spatial.parentNodeName = parentSpatial.nodeName;
        spatial.parentTimelineId = parentTimeline.timelineId;
    }
}


@end
