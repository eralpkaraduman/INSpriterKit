// INSKScmlParser.m
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


#import "INSKScmlParser.h"
#import "SpriterModelHeaders.h"
#import <RXMLElement.h>


@implementation INSKScmlParser

#pragma mark - parser methods

- (NSString *)filenameExtension {
    return @"scml";
}

- (BOOL)parseFileContent:(NSData *)content {
    // load file
    RXMLElement *rootXML = [RXMLElement elementFromXMLData:content];
    if (!rootXML.isValid) {
        return NO;
    }
    
    // check for file version
    self.fileVersion = [rootXML attribute:@"scml_version"];
    if (![self parserForVersion:SCMLFileVersionSupported shouldBeCompatibleToFileVersion:self.fileVersion]) {
        NSLog(@"Warning: The scml file '%@' is of version %@, but the parser is designed for v%@!", self.filename, self.fileVersion, SCMLFileVersionSupported);
        return NO;
    }
    
    // parse some meta data
    self.generator = [rootXML attribute:@"generator"];
    self.generatorVersion = [rootXML attribute:@"generator_version"];
    
    // create the SpriterData and the tree
    self.spriterData = [[SpriterData alloc] init];
    self.spriterData.folders = [self parseFolders:[rootXML children:@"folder"]];
    self.spriterData.entities = [self parseEntities:[rootXML children:@"entity"]];
    
    return YES;
}


#pragma mark - parsing methods

- (NSArray *)parseFolders:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterFolder *element = [[SpriterFolder alloc] init];
        element.folderId = [xmlElement attribute:@"id"];
        element.name = [xmlElement attribute:@"name"];
        element.files = [self parseFiles:[xmlElement children:@"file"]];
        [array addObject:element];
    }
    return array;
}

- (NSArray *)parseFiles:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterFile *element = [[SpriterFile alloc] init];
        element.fileId = [xmlElement attribute:@"id"];
        element.name = [xmlElement attribute:@"name"];
        element.width = [[xmlElement attribute:@"width"] floatValue];
        element.height = [[xmlElement attribute:@"height"] floatValue];
        element.pivotX = [[xmlElement attribute:@"pivot_x"] floatValue];
        element.pivotY = [[xmlElement attribute:@"pivot_y"] floatValue];
        [array addObject:element];
    }
    return array;
}

- (NSArray *)parseEntities:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterEntity *element = [[SpriterEntity alloc] init];
        element.entityId = [xmlElement attribute:@"id"];
        element.name = [xmlElement attribute:@"name"];
        element.animations = [self parseAnimations:[xmlElement children:@"animation"]];
        [array addObject:element];
    }
    return array;
}

- (NSArray *)parseAnimations:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterAnimation *element = [[SpriterAnimation alloc] init];
        element.animationId = [xmlElement attribute:@"id"];
        element.name = [xmlElement attribute:@"name"];
        element.length = [[xmlElement attribute:@"length"] integerValue];
        NSString *looping = [xmlElement attribute:@"looping"];
        element.looping = looping ? [looping boolValue] : YES;
        element.mainline = [self parseMainline:[xmlElement child:@"mainline"]];
        element.timelines = [self parseTimelines:[xmlElement children:@"timeline"]];
        [array addObject:element];
    }
    return array;
}

- (SpriterMainline *)parseMainline:(RXMLElement *)xmlElement {
    SpriterMainline *element = [[SpriterMainline alloc] init];
    element.keys = [self parseMainlineKeys:[xmlElement children:@"key"]];
    return element;
}

- (NSArray *)parseMainlineKeys:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterMainlineKey *element = [[SpriterMainlineKey alloc] init];
        element.keyId = [xmlElement attribute:@"id"];
        element.time = [[xmlElement attribute:@"time"] integerValue];
        element.objectRefs = [self parseObjectRefs:[xmlElement children:@"object_ref"]];
        element.boneRefs = [self parseBoneRefs:[xmlElement children:@"bone_ref"]];
        [array addObject:element];
    }
    return array;
}

- (NSArray *)parseObjectRefs:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterObjectRef *element = [[SpriterObjectRef alloc] init];
        element.refId = [xmlElement attribute:@"id"];
        element.timelineId = [xmlElement attribute:@"timeline"];
        element.keyId = [xmlElement attribute:@"key"];
        element.zIndex = [[xmlElement attribute:@"z_index"] integerValue];
        element.parentId = [xmlElement attribute:@"parent"];
        if (element.parentId == nil) {
            element.parentId = SpriterRefNoParentValue;
        }
        [array addObject:element];
    }
    return array;
}

- (NSArray *)parseBoneRefs:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterBoneRef *element = [[SpriterBoneRef alloc] init];
        element.refId = [xmlElement attribute:@"id"];
        element.timelineId = [xmlElement attribute:@"timeline"];
        element.keyId = [xmlElement attribute:@"key"];
        element.parentId = [xmlElement attribute:@"parent"];
        if (element.parentId == nil) {
            element.parentId = SpriterRefNoParentValue;
        }
        [array addObject:element];
    }
    return array;
}

- (NSArray *)parseTimelines:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterTimeline *element = [[SpriterTimeline alloc] init];
        element.timelineId = [xmlElement attribute:@"id"];
        element.name = [xmlElement attribute:@"name"];
        element.keys = [self parseTimelineKeys:[xmlElement children:@"key"]];
        [array addObject:element];
    }
    return array;
}

- (NSArray *)parseTimelineKeys:(NSArray *)xmlRoot {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:xmlRoot.count];
    for (RXMLElement *xmlElement in xmlRoot) {
        SpriterTimelineKey *element = [[SpriterTimelineKey alloc] init];
        element.keyId = [xmlElement attribute:@"id"];
        element.time = [[xmlElement attribute:@"time"] integerValue];
        NSString *spin = [xmlElement attribute:@"spin"];
        element.spin = spin ? [spin integerValue] : 1;
        element.object = [self parseObject:[xmlElement child:@"object"]];
        element.bone = [self parseBone:[xmlElement child:@"bone"]];
        [array addObject:element];
    }
    return array;
}

- (SpriterObject *)parseObject:(RXMLElement *)xmlElement {
    if (xmlElement == nil) {
        return nil;
    }
    
    SpriterObject *element = [[SpriterObject alloc] init];
    element.folderId = [xmlElement attribute:@"folder"];
    element.fileId = [xmlElement attribute:@"file"];
    element.positionX = [[xmlElement attribute:@"x"] floatValue];
    element.positionY = [[xmlElement attribute:@"y"] floatValue];
    element.angle = [[xmlElement attribute:@"angle"] floatValue];
    NSString *scaleX = [xmlElement attribute:@"scale_x"];
    element.scaleX = scaleX ? [scaleX floatValue] : 1.0;
    NSString *scaleY = [xmlElement attribute:@"scale_y"];
    element.scaleY = scaleY ? [scaleY floatValue] : 1.0;
    NSString *pivotX = [xmlElement attribute:@"pivot_x"];
    element.pivotX = pivotX ? [pivotX floatValue] : SpriterObjectNoPivotValue;
    NSString *pivotY = [xmlElement attribute:@"pivot_y"];
    element.pivotY = pivotY ? [pivotY floatValue] : SpriterObjectNoPivotValue;
    NSString *alpha = [xmlElement attribute:@"a"];
    element.alpha = alpha ? [alpha floatValue] : 1.0;
    return element;
}

- (SpriterBone *)parseBone:(RXMLElement *)xmlElement {
    if (xmlElement == nil) {
        return nil;
    }
    
    SpriterBone *element = [[SpriterBone alloc] init];
    element.positionX = [[xmlElement attribute:@"x"] floatValue];
    element.positionY = [[xmlElement attribute:@"y"] floatValue];
    element.angle = [[xmlElement attribute:@"angle"] floatValue];
    NSString *scaleX = [xmlElement attribute:@"scale_x"];
    element.scaleX = scaleX ? [scaleX floatValue] : 1.0;
    NSString *scaleY = [xmlElement attribute:@"scale_y"];
    element.scaleY = scaleY ? [scaleY floatValue] : 1.0;
    NSString *alpha = [xmlElement attribute:@"a"];
    element.alpha = alpha ? [alpha floatValue] : 1.0;
    return element;
}


@end
