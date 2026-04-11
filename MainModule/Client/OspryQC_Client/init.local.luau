-- OspryOS Quickchat Client --

--// locals
--// Services
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

--// Player
local Plr = Players.LocalPlayer
local PlayerGui = Plr:WaitForChild("PlayerGui")

--// Client Table
local Client = {
	--// Configuration
	Config = {
		--// TopbarPlus
		Enable_TopbarPlus = false,
		Path_To_TopbarPlus = nil,
		
		--// Nexus VR
		VR_Compatibility = false,
		Use_NexusVR_Inbuild_Core = false,
		Path_To_NexusVRCore = nil,
		
		--// VRBottomBar
		Enable_VRBottomBar = false,
		Path_To_VRBottomBar = nil,
		VRBottomBar_Position = 1,
		
		--// Client Interface
		UI = {
			Stroke_Color = Color3.fromRGB(0, 120, 255),
			Stroke_Thickness = 2,
			Stroke_Transparency = 0,
			
			Background_Color = Color3.fromRGB(0, 0, 0),
			
			Use_Formatting = true,
			PlayerNameColor = "#FFFFFF",
			PlayerMessageColor = "#FFFFFF",
			
			Welcome_Message = true,
		},
		
		Chat_Cooldown = 2,

		DebugMode = false,
		
		-- System Specific --
		Version = nil, -- Gets synced via get_Config.
	},
	
	--// Plugin Support
	ArgumentTypes = {},
	PendingArgs = {},
	RequiredArgs = {},
	
	--// Client Shared
	Shared = RS:FindFirstChild("__OspryQC_Shared"),
	
	Remotes = RS:WaitForChild("__OspryQC_Shared"):FindFirstChild("Remotes"),
	Plugins = RS:WaitForChild("__OspryQC_Shared"):FindFirstChild("Plugins"),
	Phrases = RS:WaitForChild("__OspryQC_Shared"):FindFirstChild("Remotes"):FindFirstChild("get_Phrases"):InvokeServer(),
	
	--// Misc
	SelectedPhrase = nil,
	
	Debounce = false,
	Topbar_Failed = false,
}

--// Client Modules
Client.UI = require(script.Interface)(Client)
Client.VR = require(script.VR)(Client)

--// Misc
local SlideInfo = TweenInfo.new(
	0.75,
	Enum.EasingStyle.Exponential
)



-- Internal functions --

--// Overwrites the Client Config Table with Information recieved by the Server.
local function OverwriteConfig(serverConfig)
	for key, value in pairs(serverConfig) do
		Client.Config[key] = value
	end
end

--// Formats Text
local function format(Sender : Player, QCMessage : string)
	if Client.Config.UI.Use_Formatting then
		if not Client.Config.UI.Use_Formatting then return end

		--// Format Sender
		local namePart = string.format(
			"<font color='%s'>%s:</font>",
			Client.Config.UI.PlayerNameColor,
			Sender.Name
		)

		--// Format Message
		local messagePart = string.format(
			"<font color='%s'> %s</font>",
			Client.Config.UI.PlayerMessageColor,
			QCMessage
		)

		--// Export
		return namePart .. messagePart
		
	else
		--// Generate Regular Template
		local Message = string.format(
			"%s: %s",
			Sender.Name,
			QCMessage
		)
		
		return Message
	end
end




-- Client functions --

-- Essentials --

--// Debug Prints :P
function Client:Debug(...)
	if not Client.Config.DebugMode then return end

	warn("[OspryQC Client]:", ...)
end

--// Initiates the Client's Systems
function Client:Init()
	-- Initialize VR Core --
	if UIS.VREnabled then Client.VR.Init() end

	-- Initialize Interface --
	Client.UI.CreateButton()
	Client.UI.CreateGui()

	-- Initialize Phrases --
	Client.UI.CreatePhrases()

	-- Initialize Plugins --
	Client:LoadPLugins()
end

--// Sets up the Client
function Client:Configure()
	--// Config
	local ConfigRemote = Client.Remotes:WaitForChild("get_Config") :: RemoteFunction
	local Config = ConfigRemote:InvokeServer()
	
	OverwriteConfig(Config)
	
	Client:Debug("Configured")
end

--// Sends the QuickChat Message to the Server
function Client.Send(Phrase : string, Args)
	--// Send to Server
	Client.Remotes.QuickChat:FireServer(Phrase, Args)
	Client:Debug("A request has been sent to the Server:", Phrase, tostring(Args))

	--// Debounce
	task.delay(Client.Config.Chat_Cooldown, function()
		Client.Debounce = false
	end)
end



-- Plugin Support --

--// Loads Plugins
function Client:LoadPLugins()
	local Plugins = Client.Shared:FindFirstChild("Plugins")
	if not Plugins then
		warn("[OspryQC Client]: Unable to find Plugins Folder within"..Client.Shared:GetFullName()..", skipped!")
		return
	end
	print("[OspryQC Client]: Loading Plugins...")
	
	--// Load Plugins
	for _, module in ipairs(Plugins:GetChildren()) do
		if module:IsA("ModuleScript") then
			local success, plugin = pcall(require, module)
			if success and plugin.argName and plugin.Arguments then
				Client:RegisterArgument(plugin.argName, plugin.Arguments.Gui)
				
			else
				warn("[OspryQC Client]: "..module.Name.." Plugin failed to Initialize!")
			end
		end
	end
end

--// Registers an Argument Tpye via Plugins
function Client:RegisterArgument(argName : string, guiData)
	Client.ArgumentTypes[argName] = guiData
	Client:Debug("Registered Argument, '"..argName.."'")
end

--// Processes all Arguments
function Client:ProcessArguments()
	--// locals
	local nextArg = table.remove(Client.RequiredArgs, 1)
	Client:Debug("Processing Arguments...")
	
	--// Check if there are no Arguments remaining within Client.RequiredArgs.
	if not nextArg then
		Client.Send(Client.SelectedPhrase, Client.PendingArgs)
		return
	end

	Client.UI.CreateList(nextArg)
end



-- Client Interface --
-- Moved to Interface Module, please use Client.UI for Interface related topics.



-- On Startup --

-- Prepare Client --
script.Parent = Plr:WaitForChild("PlayerScripts")
Client:Configure()

-- Initialize --
Client:Init()



-- Connections --

--// Client Connection
Client.Remotes.QuickChat.OnClientEvent:Connect(function(Sender : Player, QCMessage : string)
	--// ChatMessage Template
	local QC_Template = format(Sender, QCMessage)
	
	--// Send Chat Message
	TextChatService.TextChannels.RBXSystem:DisplaySystemMessage(
		QC_Template
	)
	
	--// Chat Bubble
	TextChatService:DisplayBubble(Sender.Character, QCMessage)
	Client:Debug("Chat Message recieved from", Sender.Name)
end)

--// Notifiction Connection
Client.Remotes.Notify.OnClientEvent:Connect(function(Message : string)
	--// Display Message
	Client.UI.DisplayNotif(Message)
end)



--// Initialized Prints
print("[OspryQC Client]: Quickchat Client running.")
print("[OspryQC Client]: OspryOS Quickchat running on Version", Client.Config.Version)

--// Welcome Message
if Client.Config.UI.Welcome_Message then
	Client.UI.DisplayNotif(
		"Hello "..Plr.DisplayName.."! OspryOS Quickchat version "..Client.Config.Version.." is running!"
	)
end