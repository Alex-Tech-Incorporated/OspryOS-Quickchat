# VR-Bottom-Bar Integration
The Quickchat System is compatible with [VR-Bottom-Bar](https://github.com/IITPP-Roblox/VR-Bottom-Bar) by [TheNexusAvenger](https://github.com/TheNexusAvenger).
This part of the Documentation will cover on how you can set it up.
> [!TIP]
> VR-Bottom-Bar can be used without enabling `VR_Compatibility`. It works as a standalone feature.

## Setup
First, go into the Loader's Config and search for `Enable_VRBottomBar`, `Path_To_VRBottomBar` and `VRBottomBar_Position`.
```lua
--// VRBottomBar Integration
Enable_VRBottomBar = false, -- Enables Compatibility for "VRBottomBar"
Path_To_VRBottomBar = game.ReplicatedStorage.VRBottomBar, -- The Path to the "VRBottomBar" Module
VRBottomBar_Position = 1, -- The Position of the Button within the Bottom Bar
```
If you have set up VR-Bottom-Bar correctly, you should be able to see the Quickchat's Icon within the Bar.
> [!TIP]
> VR-Bottom-Bar has support with TopbarPlus, if `Enable_TopbarPlus` is `true`, it will create its Icons over TopbarPlus and then convert them via its "Context" Module.

> [!IMPORTANT]
> **Please put VR-Bottom-Bar into ReplicatedStorage, the Client needs to require it.**
