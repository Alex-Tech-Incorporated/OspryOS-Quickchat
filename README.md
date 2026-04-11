# OspryOS Quickchat
A simple and lightweight Quickchat System made for Roblox, with Plugin Support and Nexus VR Core compatibility.

## Setup
Download the newest Version of the Loader and MainModule and place the Loader in ServerScriptService (Recommended)
### Requiring the Module (Recommended)
Download the newest Version of the MainModule and upload it to your Roblox Profile or the Group, then go to Loader > `Config` and replace `MainModule` with the ID if your uploaded MainModule.
> [!IMPORTANT]
> Make sure that `LoadLocally` is set to `false` when requiring the MainModule!
### Load locally
You can load a Local version of the MainModule by inserting the MainModule into the Loader, then go to Loader > `Config` and set `LoadLocally` to `true`.
> [!TIP]
> If `LoadLocally` is enabled, the require process will be skipped by the Loader.

### Adding Phrases
You can add Phrases to the Quickchat by going to Loader > `Config` > `Phrases`, there you will see some already existing Categories and Phrases within them.
```lua
-- EXAMPLE:
Phrases = {
		["Test"] = { -- This is a Category, you can create multiple
			Hello = {Text = "Hello!"}, -- This is a Phrase within the Category, you can add multiple Phrases within one Category.
		},
	},
  ```

## TopbarPlus, VRBottomBar and VR Support
It is recommended to take a look at our Documentation for topics related to TopbarPlus, VRBottomBar or VR support.

## License
This Project is availible under an MIT License.
