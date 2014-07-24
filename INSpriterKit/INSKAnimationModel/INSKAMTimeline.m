// INSKAMTimeline.m
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


#import "INSKAMTimeline.h"
#import "INSKAMSpatial.h"
#import <INLib/INLib.h>


@implementation INSKAMTimeline

- (instancetype)copyWithZone:(NSZone *)zone {
    INSKAMTimeline *timelineCopy = [[[self class] allocWithZone:zone] init];
    timelineCopy.timelineId = self.timelineId;
    timelineCopy.spatialsByTime = self.spatialsByTime.mutableCopy;
    return timelineCopy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Timeline '%@': %@", self.timelineId, [self.spatialsByTime descriptionWithStart:@"[\n" elementFormatter:@"%@,\n" lastElementFormatter:@"%@\n" end:@"]"]];
}

- (INSKAMSpatial *)spatialForTime:(NSTimeInterval)time {
    // Return nil if there are no spatials in the timeline
    if (self.spatialsByTime.count == 0) {
        return nil;
    }
    
    // Do a binary search for the spatial which has the given time and the last one if there are multiple
    INSKAMSpatial *spatial = nil;
    NSInteger startIndex = 0;
    NSInteger endIndex = self.spatialsByTime.count - 1;
    while (startIndex <= endIndex) {
        NSInteger midIndex = (startIndex + endIndex) / 2;
        INSKAMSpatial *currentSpatial = self.spatialsByTime[midIndex];
        if ([currentSpatial equalsTime:time]) {
            spatial = currentSpatial;
            // spatial has same time, but may not be the last in the line
            while (midIndex < endIndex) {
                ++midIndex;
                currentSpatial = self.spatialsByTime[midIndex];
                if ([currentSpatial equalsTime:time]) {
                    spatial = currentSpatial;
                } else {
                    break;
                }
            }
            break;
        } else if (currentSpatial.time < time) {
            startIndex = midIndex + 1;
            if (startIndex > endIndex) {
                spatial = self.spatialsByTime[endIndex];
                break;
            }
        } else if (currentSpatial.time > time) {
            endIndex = midIndex - 1;
            if (startIndex > endIndex) {
                if (startIndex == 0) {
                    spatial = self.spatialsByTime[0];
                } else {
                    spatial = self.spatialsByTime[startIndex - 1];
                }
                break;
            }
        } else {
            NSAssert(false, @"impossible state");
        }
    }
    
    return spatial;
}


@end
