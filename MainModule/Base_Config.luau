return {
	
	Enable_TopbarPlus = false,
	Path_To_TopbarPlus = nil,
	
	VR_Compatibility = false,
	Use_NexusVR_Inbuild_Core = false,
	Path_To_NexusVRCore = nil,
	
	Enable_VRBottomBar = false,
	Path_To_VRBottomBar = nil,
	VRBottomBar_Position = 1,
	
	Adonis_Compat = false,
	Technified_Compat = false,
	
	Phrases = {
		["Default (Fallback)"] = {
			Fallback = {Text = "Fallback"},
		},
		
		-- All of these have been forcefully removed, due to Roblox changing there Policies regarding Quickchat Systems.
		--[[
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
		},]]
	},
	
	UI = {
		Stroke_Color = Color3.fromRGB(255, 0, 255),
		Stroke_Thickness = 2,
		Stroke_Transparency = 0,
		
		Background_Color = Color3.fromRGB(140, 0, 140),
		
		Style_Message = true,
		Message_punctuation = "*",
		PlayerNameColor = "#FFFFFF",
		PlayerMessageColor = "#FFFFFF",
		
		Welcome_Message = true,
	},
	
	Chat_Cooldown = 10,
	
	DebugMode = false,
	
	
	
	--// System Specific
	Version = "1.2.2",
}