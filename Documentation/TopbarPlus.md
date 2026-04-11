# TopbarPlus Integration
The Quickchat System is compatible with TopbarPlus by @ForeverHD. This part of the Documentation will cover how you can set it up. You can get TopbarPlus [here](https://create.roblox.com/store/asset/92368439343389/TopbarPlus?keyword=TopbarPLus&pageNumber=1&pagePosition=0).
## Setup
First, go into the Loader's Config and search for `Enable_TopbarPlus` and `Path_To_TopbarPlus`.
```lua
--// TopbarPlus Integration
Enable_TopbarPlus = false, -- Set this to true
Path_To_TopbarPlus = game.ReplicatedStorage.Icon, -- Set this to the path to where you have stored TopbarPlus. (This is the Default path)
```
If you have set up TopbarPlus correct, you should be able to see the Quickchat's Icon nex to the Chat.
> [!IMPORTANT]
> **Please put TopbarPlus into ReplicatedStorage, the Client needs to require it.**

## Developers
The Icon can be editted and accessed via the API of TopbarPlus, for that you can use the Code below. This can be used to hide to Icon during cutscenes as an example.
```lua
--// locals
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TopbarPlus = require(ReplicatedStorage.Icon)

--// Get Icon
TopbarPlus.getIcon("OspryQC")
```
