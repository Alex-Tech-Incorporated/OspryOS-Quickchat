-- OspryOS Quickchat Client V2 --

--// locals
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Player
local Plr = Players.LocalPlayer
local PlayerGui = Plr:WaitForChild("PlayerGui")

--// ReplicatedStorage
local Shared = RS:WaitForChild("__OspryQC_Shared")
local Remotes = Shared:WaitForChild("Remotes")

--// Client Table
local Client = {
	--// Player
	Plr = Plr,
	
	--// Configuration
	Config = {
		--// TopbarPlus
		Enable_TopbarPlus = false,
		Topbar_Icon_Keybind = nil,
		Path_To_TopbarPlus = nil,

		--// Nexus VR
		VR_Compatibility = false,
		Use_NexusVR_Inbuild_Core = false,
		Path_To_NexusVRCore = nil,

		--// VRBottomBar
		Path_To_VRBottomBar = nil,
		VRBottomBar_Position = 1,

		--// Client Interface
		UI = {
			Stroke_Color = Color3.fromRGB(0, 120, 255),
			Stroke_Thickness = 2,
			Stroke_Transparency = 0,

			Background_Color = Color3.fromRGB(0, 0, 0),

			Style_Message = true,
			Message_punctuation = "*",
			PlayerNameColor = "#FFFFFF",
			PlayerMessageColor = "#FFFFFF",
			
			Sent_To_Chat = true,
			Welcome_Message = true,
		},

		Chat_Cooldown = 10,

		DebugMode = false,

		-- System Specific --
		Version = nil, -- Gets synced via get_Config.
	},
	
	--// Plugin Support
	ArgumentTypes = {},
	PendingArgs = {},
	RequiredArgs = {},
	
	--// Client Shared
	Shared = Shared,
	
	Remotes = Remotes,
	Phrases = Remotes:WaitForChild("get_Phrases"):InvokeServer(),
	
	--// Misc
	SelectedPhrase = nil,

	Debounce = false,
	Topbar_Failed = false,
}

--// Client Modules
Client.Remote = require(script:WaitForChild("Remote"))(Client)
Client.Plugins = require(script:WaitForChild("Plugins"))(Client)
Client.Interface = require(script:WaitForChild("Interface"))(Client)
Client.VR = require(script:WaitForChild("VR"))(Client)

--// Client Load Order
Client.Module_LoadingOrder = {
	Client.Plugins,
	Client.VR,
	Client.Interface,
}

--// Prints
function Client:print(...)
	print("[OspryQC Client]:", ...)
end
function Client:warn(...)
	warn("[OspryQC Client]:", ...)
end
function Client:debug(...)
	if not Client.Config.DebugMode then return end
	warn("[OspryQC Client] Debug:", ...)
end



-- Client functions --

--// Formats Text to look a bit better
function Client:format(Sender : Player, Message : string)
	if Client.Config.UI.Style_Message then
		--// Sender
		local namePart = string.format(
			"<font color='%s'>%s%s:</font>",
			Client.Config.UI.PlayerNameColor,
			Client.Config.UI.Message_punctuation,
			Sender.Name
		)

		--// Message
		local messagePart = string.format(
			"<font color='%s'> %s</font>",
			Client.Config.UI.PlayerMessageColor,
			Message
		)

		--// Export
		return namePart .. messagePart

	else
		--// Generate Regular Template
		local ChatMessage = string.format(
			"%s%s: %s",
			Client.Config.UI.Message_punctuation,
			Sender.Name,
			Message
		)

		--// Export
		return ChatMessage
	end
end



-- Initialize --
Client.Remote.Init()
Client:print(`Sending Load Request to Server...`)
Client.Remote.Send("Load_Client")