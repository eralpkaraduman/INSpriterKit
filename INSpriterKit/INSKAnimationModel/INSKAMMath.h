// INSKAMMath.h
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


#import <INSpriteKit/INSpriteKit.h>


/**
 Interpolates linearly between two scalars.
 
 Returns a if t = 0 and returns b if t = 1. Otherwise returns a linear interpolation between a and b.
 
 @param a The first value.
 @param b The second value.
 @param t The percentage (in the range of 0 to 1) to interpolate from a to b.
 @return The interpolated value.
 */
static inline CGFloat LinearInterpolation(CGFloat a, CGFloat b, CGFloat t) {
    return ((b - a) * t) + a;
}


/**
 Interpolates linearly between to angles in degree.
 
 The angles have to be degrees.
 
 @param angleA The first angle in degrees.
 @param angleB The second angle in degrees.
 @param spin The direction to rotate, 1 = clockwise, -1 = counterclockwise, 0 = no spin return angleA
 @param t The percentage (in the range of 0 to 1) to interpolate from agleA to angleB.
 @return The interpolated angle in degrees or angleA if spin is 0.
 */
static inline CGFloat LinearAngleInterpolationDegrees(CGFloat angleA, CGFloat angleB, NSInteger spin, CGFloat t) {
    if (spin > 0) {
        if (angleB < angleA) {
            angleB += 360;
        }
    } else if (spin < 0) {
        if (angleB > angleA) {
            angleB -= 360;
        }
    } else {
        return angleA;
    }
    return LinearInterpolation(angleA, angleB, t);
}


/**
 Interpolates linearly between to radian angles.
 
 The angles have to be radians.
 
 @param angleA The first radian angle.
 @param angleB The second radian angle.
 @param spin The direction to rotate, 1 = clockwise, -1 = counterclockwise, 0 = no spin return angleA
 @param t The percentage (in the range of 0 to 1) to interpolate from agleA to angleB.
 @return The interpolated radian angle or angleA if spin is 0.
 */
static inline CGFloat LinearAngleInterpolationRadian(CGFloat angleA, CGFloat angleB, NSInteger spin, CGFloat t) {
    if (spin > 0) {
        if (angleB < angleA) {
            angleB += M_PI_X_2;
        }
    } else if (spin < 0) {
        if (angleB > angleA) {
            angleB -= M_PI_X_2;
        }
    } else {
        return angleA;
    }
    return LinearInterpolation(angleA, angleB, t);
}

