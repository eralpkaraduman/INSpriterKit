// SpriterFileParser.m
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


#import "SpriterFileParser.h"

@implementation SpriterFileParser

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);

    // create log string
    NSMutableString *log = [NSMutableString string];
    
    // parse Spriter file and create a manager
    INSKScmlParser *scmlParser = [[INSKScmlParser alloc] init];
    NSAssert([scmlParser parseFilename:@"BasicTests"], @"Failed loading the scml file");
    [log appendFormat:@"%@ loaded", scmlParser];
    INSKAnimationManager *animationManager = [[INSKAnimationManager alloc] initWithAnimationData:[scmlParser animationData] textureLoader:nil];

    // log data model for debugging purposes
    [log appendFormat:@"\n\nAnimation manager data model\n\n%@\n", [(NSObject *)scmlParser.animationData description]];
    
    // log all entity names and their animations
    [log appendString:@"\n\nEntity & Animation names\n\n"];
    NSArray *entityNames = [animationManager allEntityNames];
    for (NSString *entityName in entityNames) {
        [log appendFormat:@"Entity: '%@'\n", entityName];
        NSArray *animationNames = [animationManager allAnimationNamesForEntity:entityName];
        for (NSString *animationName in animationNames) {
            [log appendFormat:@"  Animation: '%@'\n", animationName];
        }
    }
    
    // log all texture names
    [log appendString:@"\n\nTexture names\n\n"];
    NSDictionary *textureNames = [animationManager allTextureNames];
    for (NSString *pathName in textureNames.allKeys) {
        NSArray *fileNames = [textureNames objectForKey:pathName];
        for (NSString *fileName in fileNames) {
            [log appendFormat:@"%@/%@\n", pathName, fileName];
        }
    }
    
    // print log to console
    NSLog(@"\n\n%@\n", log);
    
    // create hint label
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.fontSize = 30;
    label.text = @"See console log output!";
    [self addChild:label];
    
    return self;
}


@end
