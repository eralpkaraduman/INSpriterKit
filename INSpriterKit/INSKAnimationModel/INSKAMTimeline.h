// INSKAMTimeline.h
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


@class INSKAMSpatial;


@interface INSKAMTimeline : NSObject <NSCopying>

/// The timeline's ID.
@property (nonatomic, copy) NSString *timelineId;
/// An array of INSKAMSpatial objects in order of their time for this timeline.
@property (nonatomic, strong) NSMutableArray *spatialsByTime;


/**
 Returns the spatial for a given time or the nearest with less time.
 
 The spatial's time is equal to the given if they vary at most of 0.0001.
 If there is no spatial with the given time or less the first spatial in the timeline will be returned.
 If there are no spatials in the timeline nil will be returned.
 
 @param time The keyframe's time.
 @return The corresponding spatial for the time stamp.
 */
- (INSKAMSpatial *)spatialForTime:(NSTimeInterval)time;


@end
