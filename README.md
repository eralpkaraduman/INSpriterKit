# INSpriterKit

[![CocoaDocs](http://cocoapod-badges.herokuapp.com/v/INSpriterKit/badge.png)](http://cocoadocs.org/docsets/INSpriterKit)

INSpriterKit adds Sprite Kit support for the animation tool "Spriter" by [Brashmonkey.com](http://www.brashmonkey.com).

**Warning: This library likely won't be updated!**


## Requirements

iOS 7+ or OS X 10.9+, ARC enabled

Needs the following Frameworks:
- SpriteKit
- GLKit

Needs the following Libraries (which are automatically installed when using CocoaPods):
- 'INLib' v2.1
- 'INSpriteKit' v1.1
- 'RaptureXML' v1.0

Tested with Files exported by Spriter b8_2 (v0.8.2 beta).


## Installation

INSpriterKit is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

    pod "INSpriterKit"

or clone the repo manually, add the INSpriterKit directory to your project and add the necessary frameworks and libraries mentioned in the requirements section to your project.

Include the INSpriterKit.h header file to get access to the engine.


## Usage

First parse a Spriter file with a concrete parser subclass like `INSKScmlParser`.

	INSKScmlParser *scmlParser = [[INSKScmlParser alloc] init];
    [scmlParser parseFilename:@"BasicTests"];

Then create a `INSKAnimationManager` in your game scene with the animation model returned by the parser.
The manager needs a texture loader which loads and returns the needed SKTexture objects for drawing the animation objects.
Implement the `INSKAMTextureLoader` protocol and register the delegate while creating the manager.

    self.animationManager = [[INSKAnimationManager alloc] initWithAnimationData:[scmlParser animationData] textureLoader:self];

The texture loader implements only a method like the following one, but maybe preloading or caching should also be implemented.

	- (SKTexture *)textureNamed:(NSString *)textureName path:(NSString *)path {
	    return [SKTexture textureWithImageNamed:textureName];
	}

Hold an instance of the manager and process its update method in each frame, normally by calling it in the scene's update method.

	- (void)update:(NSTimeInterval)currentTime {
	    [self.animationManager update:currentTime];
	}

With the manager set up animation nodes may be created which are SKNode instances to display an entity's animations.

    INSKAnimationNode *animationNode = [INSKAnimationNode node];
    [animationNode loadEntity:@"TestEntity" fromManager:animationManager];
    [scene addChild:animationNode];

Optionally implement some `INSKAnimationNodeDelegate` delegate methods and register on the animation node to get informed when an animation ends.

    animationNode.animationNodeDelegate = self;

Start playing animations for the registered entity.

	[animationNode playAnimation:@"AnimationName"];

That's all at the moment, have fun!


## Examples

There is a `INSpriterKitExample` project for testing.
Go to the project's folder and run `pod install` from there in Terminal first (CocoaPods installed required).
Then open the workspace file `INSpriterKitExample.xcworkspace` with Xcode and run the example app.

Most example scenes are loading the `BasicTests.scml` Spriter file and are using the `GreyGuy` assets in the `Assets` folder.
Open the scml file with Spriter and compare the animations with them within the app.


## Deficits

Currently the animation of simple sprites and non-scaling bones are supported, but there is a discrepance when scaling bones. The animation will break if the bones scale between keyframes.

The Z-order of Spriter is not used in this library and needs to be added.

Only linear interpolation is supported, no other easing. Character maps, bounding boxes, action points and other stuff supported by Spriter is also not implemented in this binding.

There should be a possibility where own SKNodes or other animation nodes can be added to an animation, for example having a Spriter animation as path for a spaceship, but the spaceship in this animation is only a place holder for the real spaceship, an enemy or something else represented by another entity and their animations.


## Version

[ChangeLog](./CHANGELOG.md)

Due to a lack of time and personal needing for this library it likely won't be updated, at least not in the near future.
With the buggy bone scaling and the missing Z-order this library as it is shouldn't be used in a productive environment.
So it is meant to be a open source base for extending, just clone the GitHub repository and get your hands dirty.
Sorry, but you are on your own to fix the bugs and implement the additional functionalities.
However, there is a little technical documentation in the project to get familiar with the code base.


## License

INSpriterKit is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

The 'GreyGuy' assets in the example project are bound to a specific usage right by BrashMonkey LLC, see the [copyright readme file](./Example/Assets/GreyGuy/Copyright_Information_Please_Read.txt) in the folder.
