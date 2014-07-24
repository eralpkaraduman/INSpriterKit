// SpriterObject.h
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


@interface SpriterObject : NSObject

/// The folder ID.
@property (nonatomic, copy) NSString *folderId;
/// The file ID.
@property (nonatomic, copy) NSString *fileId;
/// The X position.
@property (nonatomic, assign) CGFloat positionX;
/// The Y position.
@property (nonatomic, assign) CGFloat positionY;
/// The angle in degrees.
@property (nonatomic, assign) CGFloat angle;
/// The X scale factor.
@property (nonatomic, assign) CGFloat scaleX;
/// The Y scale factor.
@property (nonatomic, assign) CGFloat scaleY;
/// The X pivot or SpriterObjectNoPivotValue for a reference to the default from the SpriterFile.
@property (nonatomic, assign) CGFloat pivotX;
/// The Y pivot or SpriterObjectNoPivotValue for a reference to the default from the SpriterFile.
@property (nonatomic, assign) CGFloat pivotY;
/// The alpha value.
@property (nonatomic, assign) CGFloat alpha;

@end
