# Overview
Tools/scripts that I made a long time ago for Maya, 3ds Max, and Photoshop.

## Maya
### CacheToBlendshapeAnim
**CacheToBlendshapeAnim:** Copies simulated mesh frames (or other blendshapes) to a single blendshape node as intermediate blendshapes so that simulation can be played in the game engine at runtime.\
**VtxAOtoRGBTool:** Tool for inverting each RGBA channel of vertex colors or removing data. Was mostly used to move baked vertex AO to a single channel.\
**CryEngineMat:** Tool for setting up materials and collison settings for export to CryEngine.\
**ObjectRenamer:** Tool for renaming objects and/or adding prefix & suffix.\
**RandRotScale:** Tool for randomizing the rotation and scale of the selected objects.

## 3ds Max
**CryEngineAutoMat:** Tool for setting up materials and collison settings for export to CryEngine.\
**ObjectRenamer:** Tool for renaming objects and/or adding prefix & suffix.\
**RandRotScale:** Tool for randomizing the rotation and scale of the selected objects.

## Photoshop
**LightmapMergingTool:** Used for merging many .exr files into a single file including the alpha channel. Was mostly used for merging multiple lightmaps into one for use in Unity.


# How to use
## Maya
**A)** Open script in the script editor and run\
**B)** Open script in the script editor, then select all text and drag and drop to the shelf to create a button to run the script\

## 3ds Max
* Run script either via the *Scripting* menu or the *Utilities*->*MAXScript* panel (this will register script in 3ds Max)\
* Add a menu or button that runs the script via the *Customize*->*Customize User Interface* menu\
* Click newly added button/menu to run the script\

## Photoshop
**A)** Run script via *File*->*Scripts*->*Browse* menu\
**B)** Copy and paste .jsx file to the *Presets/Scripts* folder in the Photoshop's directory, then run via *File*->*Scripts* menu\