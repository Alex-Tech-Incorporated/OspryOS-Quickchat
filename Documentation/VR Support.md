# VR Support
This part of the Documentation covers VR Support.

## Dependencies
If you want to enable VR Compatibility, you need [VR-Bottom-Bar](https://github.com/IITPP-Roblox/VR-Bottom-Bar) and [Nexus VR Core](https://github.com/TheNexusAvenger/Nexus-VR-Core) by [TheNexusAvenger](https://github.com/TheNexusAvenger),
you can also us the bundled Nexus VR Core in [Nexus VR Character Module](https://github.com/TheNexusAvenger/Nexus-VR-Character-Model).
> [!WARNING]
> The bundled Version of Nexus VR Core within Nexus VR Character Module is deprecated!
> It is recommended to use a seperate Version of Nexus VR Core.

## Setting up VR-Bottom-Bar
VR-Bottom-Bar is essential for the Quickchat's VR Support, **without VR-Bottom-Bar, the VR System of the Client will refuse to Initialize.**
Please read the Documentation Page on how to [Setup VR-Bottom-Bar](https://github.com/Alex-Tech-Incorporated/OspryOS-Quickchat/blob/main/Documentation/VR-Bottom-Bar.md).

## Setting up VR Support
Go to the Loader's Config and enable `VR_Compatibility` and set `Path_To_NexusVRCore` to the Path to your version of Nexus VR Core.
If you want to use the bundled version of Nexus VR Core from Nexus VR Character Module set `Use_NexusVR_Inbuild_Core` to `true` **(NOT RECOMMENDED)**
```lua
--// VR Integration
VR_Compatibility = false, -- Uses NexusVRCore for VR Compatibility
Use_NexusVR_Inbuild_Core = false, -- Uses the inbuild NexusVRCore Module from Nexus VR Character Module (Deprecated)
Path_To_NexusVRCore = nil, -- The Path to NexusVRCore (Not required if Use_NexusVR_Inbuild_Core is set to true)
```
If set up correctly, VR Users should have a more VR Friendly Interface, you can use Studio's emulator to check.
> [!TIP]
> VR-Bottom-Bar will use TopbarPlus to create its Icons if availible.
