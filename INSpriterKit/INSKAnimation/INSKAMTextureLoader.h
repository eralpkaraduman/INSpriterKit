// INSKAMTextureLoader.h
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


@class INSKAnimationManager;
@class SKTexture;


/**
 The protocol for a texture loader which delivers SKTexture objects for an animation manager.
 */
@protocol INSKAMTextureLoader <NSObject>

/**
 Has to return a texture for the given name and path.
 
 This method is called by an animation manager or one of his nodes when it needs a texture.
 The delegate has to implement any texture loading routines.
 
 @param textureName The name of the texture to load.
 @param path The relative path of the texture as indicated by the Spriter file.
 @return A SKTexture or nil.
 */
- (SKTexture *)textureNamed:(NSString *)textureName path:(NSString *)path;

@end

