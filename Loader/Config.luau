return {
	
	--// TopbarPlus Integration
	Enable_TopbarPlus = false, -- Enables TopbarPlus Integration for the Quickchat Menu, replacing the Gui Toggle Button.
	Path_To_TopbarPlus = game.ReplicatedStorage.Icon, -- The Path to the "Icon" Module of TopbarPlus
	
	--// VR Integration (Requires Nexus VR Character Module, https://github.com/TheNexusAvenger/Nexus-VR-Character-Model)
	Enable_NexusVR_Compat = false, -- Allows better VR Compatiblity by using Nexus VR Character Module (HIGHLY EXPERIMENTAL)
	
	--// VRBottomBar Integration, can be used with TopbarPlus (Recomended) or without
	Enable_VRBottomBar = false, -- Enables Compatibility for "VRBottomBar", made by TheNexusAvenger. (https://github.com/IITPP-Roblox/VR-Bottom-Bar)
	Path_To_VRBottomBar = game.ReplicatedStorage.VRBottomBar, -- The Path to the "VRBottomBar" Module
	VRBottomBar_Position = 1, -- The Position of the Button for Bottom Bar
	
	--// Admin System Compatability
	Adonis_Compat = false, -- Enables Integration with the Adonis ;mute command via Adonis's _G API, make sure G_API is set to true!
	Technified_Compat = false, -- Enables Integration with Technified's In-game Admin Client to allow Mutes to work with Quickchat
	
	--// Phrases
	Phrases = {
		["Formalities"] = {
			Hello = {Text = "Hello!"},
			HelloPlayer = {Text = "Hello {player}!"},
			Hi = {Text = "Hi"},

			Bye = {Text = "Bye!"},
			ByePlayer = {Text = "Bye, {player}!"},
		},
		
		["Requests"] = {
			CanYouFollowMe = {Text = "Can you follow me {player}?"},
		},
		
		["Answers"] = {
			Yes = {Text = "Yes"},
			No = {Text = "No"},
			What = {Text = "What?"},
			Sure = {Text = "Sure"},
		},
	},
	
	--// User Interface
	UI = {
		Stroke_Color = Color3.fromRGB(0, 120, 255), -- The Color of the Border of the UI
		Stroke_Thickness = 2, -- The Thickness of the Border of the UI
		Stroke_Transparency = 0, -- The Transparency of the Border of the UI

		Background_Color = Color3.fromRGB(0, 0, 0), -- The Color of the Background of the UI

		Use_Formatting = true, -- Makes Quickchat sent Player Messages look allot better
		PlayerNameColor = "#0078FF", -- The HEX Code of the Player's Name Color in Chat
		PlayerMessageColor = "#FFFFFF", -- The HEX Code of the Message Color when using Quickchat
		
		Welcome_Message = true, -- Displays the Client Welcome Message for the Player if the Client loaded.
	},
	
	--// Misc
	Chat_Cooldown = 2, -- The Chat Cooldown before a Player can send a Quickchat Message again
	
	--// Development
	LoadLocally = true, -- Loads a local version of the MainModule within the Loader
	DebugMode = true, -- Used for Debugging and toggles Debug Prints
	
	--// Modules
	MainModule = 94534925883801, -- The MainModule itself, you can replace this with your own uploaded Module.
}