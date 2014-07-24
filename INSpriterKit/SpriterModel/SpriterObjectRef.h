// SpriterObjectRef.h
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


@interface SpriterObjectRef : NSObject

/// The spriter object reference ID.
@property (nonatomic, copy) NSString *refId;

// TODO
//name
//folder
//file
//abs_x
//abs_y
//abs_pivot_x
//abs_pivot_y
//abs_angle
//abs_scale_x
//abs_scale_y
//abs_a

/// The reference to a bone_ref's ID or "-1" (SpriterRefNoParentValue) if there is no parent.
/// @see SpriterRefNoParentValue
@property (nonatomic, copy) NSString *parentId;

/// The referenced timeline ID.
@property (nonatomic, copy) NSString *timelineId;
/// The referenced timeline key ID.
@property (nonatomic, copy) NSString *keyId;
/// The z-Index
@property (nonatomic, assign) NSInteger zIndex;


@end
