// NSString+INSpriterKit.h
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


@interface NSString (INSpriterKit)

/**
 Increases the version number at a specific index.
 
 The version hast to be separated by periods, i.e. "1.2.3".
 The index points to the number which will be increased by one.
 Each number after the index will be truncated.
 
    [INSKSpriterParser increaseVersionString:@"1.2.3" atIndex:2]; // returns @"1.2.4"
    [INSKSpriterParser increaseVersionString:@"1.2.3" atIndex:1]; // returns @"1.3"
    [INSKSpriterParser increaseVersionString:@"1.2.3" atIndex:0]; // returns @"2"
    [INSKSpriterParser increaseVersionString:@"1" atIndex:2]; // returns @"1.0.1"
 
 @param version The original version string.
 @param index The index of the number in the version to increase, beginning with 0 for the first number.
 @return A new increased version string.
 */
- (NSString *)increaseVersionAtIndex:(NSUInteger)index;


/**
 Compares version number strings with each other, i.e. "3.2" > "3.1.2".

 @param versionNumber A string with a version number to compare with.
 @return True if this version number is lower than the given version, otherwise false.
 */
- (BOOL)versionLowerThan:(NSString *)versionNumber;


@end
