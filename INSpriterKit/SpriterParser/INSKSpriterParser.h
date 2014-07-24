// INSKSpriterParser.h
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


@class SpriterData;
@class INSKAMData;


/**
 The Spriter file version supported by this binding, currently 1.0 and should be compatible up to the next major release excluding which is 2.0.
 */
static NSString * const SpriterFileVersionSupported = @"1.0";


/**
 An abstract class for parsing files created by the animation tool "Spriter" from BrashMonkey.

 To use a Spriter file in a Sprite Kit app choose a concrete parser subclass, call parseFilename: and deliver the returned value of animationData to a INSKAnimationManager instance.
 
    INSKScmlParser *scmlParser = [[INSKScmlParser alloc] init];
    [scmlParser parseFilename:@"MySpriterFile"];
    INSKAnimationManager *animationManager = [[INSKAnimationManager alloc] initWithAnimationData:[scmlParser animationData]];
 
 This class holds common properties and methods used by a parser for generating an animation model used by a INSKAnimationManager.
 Concrete subclasses have to implement the parsing process of a file by overriding the parseFileContent: method.
 A parser should parse a file's content in this method, check for compatiblity by calling parserForVersion:shouldBeCompatibleToFileVersion:, create a SpriterData object tree and save it to the spriterData property of this class.
 For loading files of the correct file extension a parser should override filenameExtension and return the supported extension name.
 A parser implementation will need to create the Spriter data model so a common include will be for SpriterModelHeaders.h.
 
 @see INSKScmlParser
 */
@interface INSKSpriterParser : NSObject

#pragma mark - Parsed output
/// @name Parsed output

/// The file's name currently loading or last loaded. Nil if no file has been tried to load, yet.
@property (nonatomic, copy, readonly) NSString *filename;
/// The file version of the parsed Spriter file.
@property (nonatomic, copy) NSString *fileVersion;
/// The name of the file's generator tool.
@property (nonatomic, copy) NSString *generator;
/// The version of the generator tool.
@property (nonatomic, copy) NSString *generatorVersion;
/// The data of the last parsed file or nil if no file could be successfully parsed.
@property (nonatomic, strong) SpriterData *spriterData;


#pragma mark - Start parsing a file
/// @name Start parsing a file

/**
 Loads and parses a Spriter file in the main bundle.
 
 The content of a given file in the main bundle will be parsed and a SpriterData object generated of it.
 After successfully parsing a INSKAnimationManager may be initialized with a INSKAMData object which can than be created with the animationData method.
 
 @param filename The name of a Spriter file without file extension to load.
 @return True if the file could be successfully parsed, otherwise false.
 */
- (BOOL)parseFilename:(NSString *)filename;


/**
 Parses a Spriter file's content passed as a data object.
 
 Load the Spriter's file manually and use this method for parsing if parseFilename: doen't suit.
 
 @param data The data object with a Spriter file's content.
 @return True if the data could be successfully parsed, otherwise false.
 */
- (BOOL)parseSpriterdata:(NSData *)data;


/**
 Convertes the parsed Spriter data into a INSKAMData object which can be used by a INSKAnimationManager instance.
 
 The Spriter's data has to be the object tree parsed by a parser and saved into the spriterData property.
 
 @return The animation data for an animation manager.
 */
- (INSKAMData *)animationData;


#pragma mark - Methods for subclasses
/// @name Methods for subclasses

/**
 A parser subclass should call this method to validate it is capable of parsing the file.
 
 A parser should be compatible to bugfix version changes, so a parser of version 1.0 should accept files of version 1.0.1, but reject 1.1.
 Directly after loading a file and parsing it's version number the parser should call this method with the parser's and the file's version as parameters so call this method within the implementation of parseFileContent:.
 If this method returns false the parser should quit parsing and return NO for the parseFileContent: method.
 
 @param parserVersion The version the parser is created for, i.e. "1.0".
 @param fileVersion The version number parsed from the file.
 @return True if the parser should be able to parse the file based on the version, otherwise false.
 */
- (BOOL)parserForVersion:(NSString *)parserVersion shouldBeCompatibleToFileVersion:(NSString *)fileVersion;


/**
 A parser subclass should override this method and return the extension of the file the parser is capable of parsing, i.e. "scml".
 
 At the moment each parser can only be tied to one single file extension, but multiple parsers may use the same extension.
 
 @return The file's extension support.
 */
- (NSString *)filenameExtension;


/**
 A parser subclass has to override this method and parse the content into a SpriterData object tree.
 The parser should save the created SpriterData object into the spriterData property and return true if parsing was successfull.
 The other properties should also be assigned with parsed values.
 
 @param content The file's content of a Spriter file.
 @return True if parsing was successfull, otherwise false.
 */
- (BOOL)parseFileContent:(NSData *)content;


@end
