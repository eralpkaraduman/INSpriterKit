# INSpriterKit

Document version 2014-07-24


## Overview

INSpriterKit adds Sprite Kit support for the animation tool "Spriter" by [Brashmonkey.com](http://www.brashmonkey.com).

With Spriter you can create 2D bone animations and with INSpriterKit you load these created spriter files into an iOS game. This way you can have complex animations easily added to your Sprite Kit scene.

For information about installation and usage of INSpriterKit have a look at the project's page on GitHub: [https://github.com/indieSoftware/INSpriterKit](https://github.com/indieSoftware/INSpriterKit)

This documentation is a technical which describes the library's structure for extending or educational purposes. This document is not necessary for using the library in a project.

INSpriterKit is tested with files created with Spriter b8_2 a.k.a. v0.8.2 which is a beta version.


## The structure

INSpriteKit is divided into 4 parts:
- SpriterParser
- SpriterModel
- INSKAnimationModel
- INSKAnimation

Each part encloses a specific task in the process of reading a Spriter file and playing the animation in a Sprite Kit scene.

### SpriterParser

Classes have a "INSK" prefix.

This submodule is for parsing Spriter files and loading them into a Spriter model.

Spriter files have either the "scml" extension and are of XML or they are JSON files with the "scon" extension. More may come with later versions of Spriter so INSpriterKit needs to be expandable. 

Therefore SpriterParser has a basic parser class called `INSKSpriterParser`. This is an abstract class and thus can't parse any files itself, but contains a basic structure for concrete parser implementations.

A concrete parser implementation is `INSKScmlParser` which parses "scml" files.

A "scon" parser is missing, but may be implemented just the same way, just like the "scml" parser. That should be straightforward.

The abstract parser `INSKSpriterParser` has some methods which a parser subclass should override. There are also some properties the subclass has to fill.

A concrete parser implementation is meant for a specific file extension so the subclass has to override `- (NSString *)filenameExtension` and return the extensions' string. When loading a file from the main bundle with the concrete parser subclass the corresponding file's extension will be used and the correct file will be loaded. Multiple file extensions are not supported, but the file can be loaded manually and the data passed directly to the parser instead.

In a project the parser subclass will be instantiated and a file will be loaded with the abstract classes' method `parseFilename:` or `parseSpriterdata:`. The file will be loaded and delivered to the parser subclass via `parseFileContent:`. Therefore the parser has to override the method `- (BOOL)parseFileContent:(NSData *)content`. There the file's content should be parsed. Return True if everything could be parsed successfully, otherwise return False to cancel the loading process.

A parser is normally only compatible with a certain Spriter file version. A parser should be compatible to bugfix version changes, so a parser of version 1.0 should accept files of version 1.0.1, but reject 1.1. The parser should first read the meta data from the Spriter file and compares the file version with the supported version. This can be done by calling `parserForVersion:shouldBeCompatibleToFileVersion:` of the abstract parser class. If the version is supported continue with the parsing process.

While parsing the Spriter file the abstract classes' properties should be filled. At least the `spriterData` property has to be filled with the spriter model. The spriter model is the rare data of the Spriter file parsed into a model tree. The classes to model the tree are available in the `SpriterModel` submodule.

The Spriter data model is transformed into another model by calling `animationData` on the abstract parser which can be used by the animation manager in the game scene. The transformation is a huge part and necessary to make the Spriter's file content available in useful and optimized form for Sprite Kit. This is done by the abstract parser and should be compatible to a Spriter file version up to the next major release excluding which should be 2.0. With this abstraction only a parser has to be updated for a new Spriter version, because the model shouldn't change. However, to support new features the Spriter model needs to be updated, of course.


### SpriterModel

Classes have a "Spriter" prefix and can all be included with the header file `SpriterModelHeaders.h`.

This submodule is for representing the Spriter data parsed from a Spriter file in a modelled tree. The tree can be directly mapped to the file and vice versa, because it contains the rare, unmodified Spriter data.

The root object for the Spriter model is an instance of the class called `SpriterData`. This class consists of the folders and entities. Such an object has to be created by a concrete parser subclass and saved into the abstract parser's property `spriterData`.

A Spriter model created this way should be compatible with a Spriter file version 1.0 and above up to version 2.0 excluding, but may lack in some functionalities. So to support more functionalities this model has to be updated and the parsers, too.


### INSKAnimationModel

Classes have a "INSKAM" prefix which is a shorthand for "indie-Software Spriter Kit Animation Model". All classes of this submodule can be included with the header file `INSKAMHeaders.h`. The model is needed by the `INSKAnimation` submodule and by the abstract spriter parser in the `SpriterParser` submodule.

The Spriter data itself cannot be used by the animation manager and therefore has to be converted into a usable and more optimized structure. This is what this model classes are good for, they form the new model tree. So this submodule is for representing the Spriter data model usable by the animation manager.

The animation model tree is created by the abstract parser `INSKSpriterParser` when calling the `animationData` method.

The animation model's root object is an instance of the class called `INSKAMData`. This class has the entities accessible by their names and the texture meta data.

The texture meta data `INSKAMTexture` contains the name of the real texture to load and its width and height for representing via a SKSpriteNode. Instances of this texture class are used when asking a texture loader delegate for SKTexture instances. They combine the folder and file classes of a Spriter file.

A `INSKAMEntity` is a named entity class in the scene. For example in a space game with two spaceships there may be an entity called 'Spaceship' in Spriter to use for both spaceship instances in the scene. All animations are created for a spaceship and in the game two spaceship objects are created with both having a visual representation bound to this and the same entity. To assign an entity will be done by its name therefore the entities are accessible in the model via their name.

Each entity has all animations available for itself. A `INSKAMAnimation` object can be retrieved by its name from the entity. The concrete animation can be played back by the animation node and will be managed by the animation manager. As an example the spaceship entity may have the two animations called 'Fire' and 'Explode' which will be played when a spaceship fires or explodes. Each animation has an animation length and the timelines. Entities and animations can be mapped directly to the Spriter counterparts.

Timelines are objects of the type `INSKAMTimeline`. Timelines are meant to be the representation nodes themself, i.e. the spaceships' gun which will move back and forth when the animation 'Fire' is played. The gun is a simple sprite represented by a texture and a SKSpriteNode in the Sprite Kit scene. So it has its timeline, while the spaceship's hull is another sprite node and has its own timeline for this animation. Each visible node needs its own timeline in an animation otherwise it won't be part of the animation and therefore not visible. Non-visible nodes like bones needs also their own timelines, because they are represented by SKNode objects which may be animated over time.

The INSKAMTimeline class consists of a Spriter timeline plus some additional keyframes and a part of the Spriter mainline. The additional keyframes are inserted at the end of an animation so there is an end keyframe to interpolate to when looping. It's mainly an optimization otherwise there should be more searching and computing necessary during playback. The additional information in the mainline are merged to the single timelines for the same purpose. This way the parent information is stored in each timeline and the mainline is not needed anymore. So a timeline has a keyframe at the start and at the end of an animation and may have multiple keyframes between them.

Each object has therefore a keyframe at the animation's start even if it is not visible. In Spriter an object may be placed later in the animation and doesn't exist before. In this library the node tree will be created on animation start and not altered afterwards so all nodes have to be there, but may be invisible at the beginning. So hidden keyframes are inserted from the mainline to the timeline only to have the nodes still there, but hidden.

Each timeline has keyframes which are represented by spatials of the type `INSKAMSpatial`. A spatial represents its visual or non-visual representation node at a specific time during the animation. The spatial contains all data needed to update a SKNode object in the scene and also has appropriate methods for updating its node. They manage a big part for the visual representation and the node tree update process during an animation.

A spatial combines the information from the Spriter timeline keys, their bone and object tags and some bits from the mainline. Think of them to be SKNode instances in the Sprite Kit scene for specific time keys in the animation. Each SKNode at a specific time has to be mapped fully to a spatial. For time positions between two keyframes the both spatials wrapping this time position are interpolated to represent the SKNode's properties.

A spatial creates a SKNode depending of the spatial's data. For a visual representation SKSpriteNode objects are used and for bones simple SKNode objects are used. Only bones may have subnodes. Most of a node's properties are directly mapped from the spatial. The alpha value for instance is directly assigned. With scaling it is different, because scaled nodes will deform subnodes. Therefore sprite nodes which shouldn't have any subnodes are scaled directly, but nodes created from bones aren't. They carry the scale factor to the subnodes in a computed form, so the position of a subnode will be adapted according to a parent's bone scale, same with the scale, but without assigning the scale property of the bone's node. However, currently this approach breaks some animations created with Spriter, because Spriter interpolates the scale of subnodes between their keyframes and this library doesn't. So the animation looks different compared with Spriter. This should be fixed.

The header file `INSKAMMath.h` contains some math methods for interpolating the spatial's and their nodes between two keyframes. Currently only linear interpolation is supported by the model, but when extending the library the additional methods have to be put into this file.


### INSKAnimation

Classes have a "INSK" prefix and are apart from a concrete parser implementation the only files needed by a game project. All needed headers by a game scene can be included with `INSpriterKit.h`.

For playing Spriter animations a manager of the type `INSKAnimationManager` is needed. The manager holds the animation data, the parsed and transformed content of a Spriter file. The manager is needed for accessing the entities and animations by animation nodes and to update the animation nodes periodically.

A `INSKAMTextureLoader` has to be registered to the animation manager because it will be asked by the manager for concrete textures to display. The texture loader should load the asked textures and maybe cache them in a preloading process. With this delegate the game is responsible for loading and managing the assets used by the animations.

The animation itself is represented by a `INSKAnimationNode`. This is a SKNode and has to be added to the scene. An entity and the animation manager has to be assigned by calling `loadEntity:fromManager:` and then any animation for that entity can be played by calling `playAnimation:`. The nodes for the animation will be added to this animation node and updated by the animation manager. At plus any registered delegate to the node can be informed about the animation playback state.

The key part is surely the animation node, because it has to create the Sprite Kit node tree and update it according to the played animation. The update process is initiated by the manager, so only one instance has to be updated each frame which in return updates all animation nodes. In this update process the passed time for the animation is calculated and the node tree updated. In a MVC pattern the animation node is the view and the animation manager the controller, which holds the animation model.


## Starting point to extend

The simplest starting point will be to implement another parser. Have a look what `INSKScmlParser` does and transcribe it.

To fix the animations with the scaled bones have a deeper look into `INSKAMSpatial` and how the node tree is created and updated.

Adding new callbacks and manipulation possibilites for the game should be done by extending `INSKAnimationNode`. For instance it may be handy to queue animations via the node or to tween two animations.

When adding new functionality support for Spriter the model has surely to be updated. First starting point should be the `SprtierModel` classes and then they have to be filled by a concrete parser class. To have the new information available to the engine the `INSKAnimationModel` especially the `INSKAMSpatial` has to be updated and of corse the mapping in `INSKSpriterParser`.


## Deficits

Currently the animation of simple sprites and bones are supported, but there is a discrepance when scaling bones. In the Spriter tool a scaled bone will also scale the sub-nodes between keyframes, but this library won't. When scaling applies all SKNode instances even as bones will result in massive deformations of the sub-sprites when using SKNode scale properties (same when using Cocos2d by the way). Therefore the node's scale properties aren't set, but the translation calculated. This will include the sub-node's scales, but not in their interpolation. Compare the `BoneScale` test scene and the same named animation in the `BasicTests.scml` for differences. Or see the `jump_start` animation in the 'GreyGuy' assets.

The Z-order of Spriter is not used in this library, see the animation test `ZOrderChanges`. The Z-order may change on keyframes and even differ beyond the parent bone. INSpriterKit uses the bare node order in a scene so the Z-ordering couldn't be mapped to this. For this the Sprite Kit zPosition has to be used and mapped, but that is not implemented, because that may break other parts in a game, i.e. having parts of an animation over the GUI because the GUI has a lower zPosition than the animation. It should be wise to use the Z-order values from Spriter as a relative position to the zPosition of the animation node, but even that may result in some trouble in game scenes.

Only linear interpolation is supported and no other easing. Character maps, bounding boxes, action points and other stuff supported by Spriter is also not implemented in this library.

There should be a possibility where own SKNodes or other animation nodes can be added to an animation, for example having a Spriter animation as path for a spaceship, but the spaceship in this animation is only a place holder for the real spaceship, an enemy or something else represented by another entity and their animations so the animation can be reused by other animation nodes.

