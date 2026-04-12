--[[
	                                       ..                                       
                                   ::::::::::                                   
                                ::::::::::::::::                                
                            ::::::::::::::::::::::::                            
                         ::::::::::::::::::::::::::::::                         
                      ::::::::::::::::::::::::::::::::::::                      
                  :::::::::::::::::::-    :::::::::::::::::::                   
               ::::::::::::::::::::          ::::::::::::::                     
           ::::::::::::::::::::                  ::::::    ::::::               
          ::::::::::::::::::                             ::::::::               
          .::::::::::::                              ::::::::::::               
          :::::::::::                            :::::::::::::::::              
          .:::::::::                              ::::::::::::::::::::.         
          ::::::::::       :::::::::::::::::         ---::-::::::::::::::       
          ::::::::::    .::::::::::::::::::::::           :-:::-:::::::::::.    
         :::::::::::   ::::::              ::-:::           :-::::::::::::::    
       :::::::::::::   ::::                 -:---              -:-----::::::    
    .:::::::::::::::   ::::       ::::::--:-::--------             :-:::::::    
       :::::::::::::   ::::     ::::::-:::--:::::-------           --:--:-::    
    :::     ::::::::   ::::    ::::.                 ----          -------::    
    :::::     ::::::   ::::    ::::                  ----          --------:    
    :::::::::     ::   :::: -::-:::                  ----          --------:    
    .::::::::          ::::::::::::                  ----          --------:    
    .::::::::          ::::::: ::::.                 ----          --------:    
    :::::::::          :::::   ::--:                 ----          --------:    
    .::::::::          :::      :------------------------          --------:    
    .::::::::                       ---------------------          --------:    
    :::::::::                                      ------          --------:    
    :::::::::                                        --            --------:    
    :::::::::::::                                 --           ------------:    
    :::::::::::::::::                         ------       ----------------:    
    :::::::::::::::::::.                   ---------    -------------------:    
        .::::::::::::::::::-           :------------  -----------------:        
           ::::::::::::::::::--     ----------------  ---------------           
               ::::::::::::------:------------------  -----------               
                  ::::::::::------------------------  --------                  
                     ::::-:-------------------------  -----                     
                         ::---------------      ----                            
                            -----------                                         
                                ---          

	Distributed under the MIT license.
	Please do not redistribute without proper credits.
]]

--// locals
--// Services
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

--// Dependencies
local Server = script
local SharedBase = Server.Shared
local Client = Server.Client
local Modules = Server.Modules

--// OspryOS Quickchat
local OspryOS_Quickchat = {
	--// Folders
	Modules = Modules,
	Client = Client,
	
	--// Essentials
	Config = require(Server.Base_Config),
	Shared = nil,
	
	Remotes = nil,
}

--// Essential Modules
OspryOS_Quickchat.Plugins = require(Modules.Plugins)(OspryOS_Quickchat)
OspryOS_Quickchat.Calls = require(Modules.Calls)(OspryOS_Quickchat)



-- Internal functions --

--// Generates the RemoteFolder
local function GenerateRemoteStorage()
	local Folder = Instance.new("Folder")
	Folder.Name = "Remotes"
	Folder.Parent = OspryOS_Quickchat.Shared
	
	--// Set local
	OspryOS_Quickchat.Remotes = Folder
end



-- QC functions --

--// Debug Prints :P
function OspryOS_Quickchat:Debug(...)
	if not OspryOS_Quickchat.Config.DebugMode then return end
	
	warn("[OspryOS QuickChat]:", ...)
end

--// Transfers all Settings from the Loader to the MainModule
function OspryOS_Quickchat:OverwriteConfig(config: typeof(OspryOS_Quickchat.Config))
	for index, value in config do
		OspryOS_Quickchat.Config[index] = value
	end
end

--// Searches through the saved Phrases within the Config
function OspryOS_Quickchat:FindPhraseData(Text : string)
	for _, category in pairs(OspryOS_Quickchat.Config.Phrases) do
		for _, data in pairs(category) do
			if data.Text == Text then
				return data
			end
		end
	end
	
	return nil
end



--// Initiates the Quickchat Module
function OspryOS_Quickchat:Init(Plugins)
	--// Check for MUTEX
	if _G.OspryQC_MUTEX then
		return false, "OspryOS Quickchat Server is already running, active MUTEX detected."
	end
	
	--// Initialize
	_G.OspryQC_MUTEX = true
	print("[OspryOS QuickChat]: Initializing Server...")
	
	--// Clone Shared
	local Client_Shared = SharedBase:Clone()
	Client_Shared.Name = "__OspryQC_Shared"
	Client_Shared.Parent = RS
	OspryOS_Quickchat.Shared = Client_Shared
	
	--// Debug Print
	OspryOS_Quickchat:Debug("Shared has been cloned and placed in ReplicatedStorage.")
	
	--// Generate Remotes Folder
	GenerateRemoteStorage()
	
	--// Initiate Modules
	task.spawn(function()
		OspryOS_Quickchat.Calls.Init()
	end)
	
	--// Load Plugins
	OspryOS_Quickchat.Plugins.Init(Plugins)
	
	
	
	-- Server Calls --
	
	--// Server Call for QuickChat RemoteEvent
	OspryOS_Quickchat.Remotes.QuickChat.OnServerEvent:Connect(function(Plr : Player, Phrase : string, ArgTable : string)
		--// Debug Print
		OspryOS_Quickchat:Debug("Server request recieved by", Plr.Name)
		
		--// Check if Player is muted
		if OspryOS_Quickchat.Calls.CheckMute(Plr) then
			OspryOS_Quickchat:Debug(Plr.Name, "is Muted, request cancelled.")
			OspryOS_Quickchat.Remotes.Notify:FireClient(Plr, "You are currently Muted and unable to use Quickchat.")
			return
		end
		
		--// Check if Phrase is Valid
		local data = OspryOS_Quickchat:FindPhraseData(Phrase)
		if not data then
			warn("[OspryOS Quickchat]: "..Plr.Name.." attempted to send an Invalid Phrase to the Server.")
			Plr:Kick("[OspryOS Quickchat]\n\nAn Invalid Phrase has been sent to the Server via Quickchat RemoteEvent.")
			return
		end
		
		--// Convert Arguments or leave Phrase as is
		local FinalMessage = Phrase
		for argName, argValue in pairs(ArgTable) do
			FinalMessage = FinalMessage:gsub("{"..argName.."}", argValue)
		end
		
		--// Filter
		-- TODO: Add Filtering via TextService

		--// Send to Clients
		OspryOS_Quickchat.Remotes.QuickChat:FireAllClients(Plr, FinalMessage)
	end)
	
	--// Export Result
	return true, "OspryOS Quickchat "..OspryOS_Quickchat.Config.Version.."-Server running."
end

--// Export
return OspryOS_Quickchat