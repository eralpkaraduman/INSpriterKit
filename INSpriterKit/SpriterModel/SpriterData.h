// SpriterData.h
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


/**
 A Spriter object graph which holds all data for managing the animations and represents the content of a Spriter file.

 Normally a SpriterData object will be created by a parser which parses a Spriter file.
 The data model should be able to create directly from the content of a Spriter file.
 After creating the SpriterData a SpriterManager processes it for SpriterPlayer objects.
 
 When implementing another parser it should parse the data into a SpriterData object.
 For a parser all ParsedModel classes are needed so include the SpriterParsedModelHeaders.h.
 Just create all graph node objects and fill their properties, then create a SpriterData with the graph.
 */
@interface SpriterData : NSObject

/// An array with SpriterFolder objects.
@property (nonatomic, strong) NSArray *folders;
/// An array with SpriterEntity objects.
@property (nonatomic, strong) NSArray *entities;


@end
