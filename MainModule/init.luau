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
OspryOS_Quickchat.functions = require(Modules.functions)(OspryOS_Quickchat)
OspryOS_Quickchat.Plugins = require(Modules.Plugins)(OspryOS_Quickchat)
OspryOS_Quickchat.Remote = require(Modules.Remote)(OspryOS_Quickchat)

--// Loading Order
local Loading_Order = {
	OspryOS_Quickchat.Remote,
	OspryOS_Quickchat.functions,
}

--// Prints
function OspryOS_Quickchat:print(...)
	print("[OspryOS QuickChat]:", ...)
end
function OspryOS_Quickchat:warn(...)
	warn("[OspryOS QuickChat]:", ...)
end
function OspryOS_Quickchat:debug(...)
	if not OspryOS_Quickchat.Config.DebugMode then return end
	warn("[OspryOS QuickChat] Debug:", ...)
end

-- LEGACY SUPPORT
function OspryOS_Quickchat:Debug(...)
	OspryOS_Quickchat:debug(...)
end



-- Internal functions --

--// Generates the RemoteFolder
local function GenerateRemotesFolder()
	local Folder = Instance.new("Folder")
	Folder.Name = "Remotes"
	Folder.Parent = OspryOS_Quickchat.Shared
	
	--// Set local
	OspryOS_Quickchat.Remotes = Folder
end



-- QC functions --

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

--// Sends a Notification to a Player or everyone if Player is nil
function OspryOS_Quickchat:Notify(Plr : Player, Message : string, Duration : number)
	--// Check if a Player was given
	if not Plr then
		OspryOS_Quickchat.Remote.SendAll("Notify", Message, Duration)
		
	else
		OspryOS_Quickchat.Remote.Send(Plr, "Notify", Message, Duration)
	end
end



--// Initiates the Quickchat Module
function OspryOS_Quickchat:Init(Plugins)
	--// Check for MUTEX
	if _G.OspryQC_MUTEX then
		return false, "OspryOS Quickchat Server is already running, active MUTEX detected."
	end
	
	--// Initialize
	_G.OspryQC_MUTEX = true
	OspryOS_Quickchat:print("Initializing Server...")
	
	--// Clone Shared
	local Client_Shared = SharedBase:Clone()
	Client_Shared.Name = "__OspryQC_Shared"
	Client_Shared.Parent = RS
	OspryOS_Quickchat.Shared = Client_Shared
	
	--// Debug Print
	OspryOS_Quickchat:debug("Shared has been cloned and placed in ReplicatedStorage.")
	
	--// Generate Remotes Folder
	GenerateRemotesFolder()
	
	--// Initiate Modules
	for _, module in pairs(Loading_Order) do
		module.Init()
	end
	
	--// Load Plugins
	OspryOS_Quickchat.Plugins.Init(Plugins)
	
	--// Loading Complete
	return true, `OspryOS Quickchat v{OspryOS_Quickchat.Config.Version}-Server initialized`
end

--// Export
return OspryOS_Quickchat