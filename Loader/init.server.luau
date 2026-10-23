--[[
	OspryOS Quickchat Loader
	Loads and/or initializes the MainModule
	
	Found a bug? Report it to our Github Repo!
	https://github.com/Alex-Tech-Incorporated/OspryOS-Quickchat/issues
	
	Need help? Take a look at our Wiki Page!
	https://github.com/Alex-Tech-Incorporated/OspryOS-Quickchat/wiki
	
	This Loader is distributed under the terms of the MIT license.
	Please, do not redistribute without proper credits.
]]

--// locals
--// Services
local SSS = game:GetService("ServerScriptService")

--// Loader
local Container = script
local ArgModules = Container.Args
local ConfigModule = Container.Config

--// MainModule
local OspryQC

--// Loader Data
local Loader = {
	--// Essential
	Config = require(ConfigModule),
	
	--// Boot options
	DebugMode = false, -- Enables various features for debugging
	LoadLocally = false, -- Loads a local MainModule parented to the Loader
	
	--// Internal
	Version = "2.0.0",
}

--// Prints
function Loader:print(...)
	print("[OspryQC Loader]:", ...)
end
function Loader:warn(...)
	warn("[OspryQC Loader]:", ...)
end



-- Begin Loading process --

--// Parent Loader to ServerScriptService
Container.Parent = SSS

--// Check MainModule availibility
local availible, module = pcall(function()
	return require(
		if Loader.LoadLocally 
			then Container:WaitForChild("MainModule", 60)
			else Loader.Config.MainModule
	)
end)

--// Check results
if availible then
	OspryQC = module
	
else
	Loader:warn(`Failed to require MainModule.`)
	Loader:warn(module)
	return
end



-- Load MainModule --
--// Overwrite Settings
OspryQC:Overwrite(Loader.Config)

--// Initialize
local loaded, response = OspryQC:Init(Loader)

--// Check results
if loaded then
	Loader:print(`{response}, required by Loader v{Loader.Version}`)
	
else
	Loader:warn(`Failed to initialize MainModule!`)
	Loader:warn(response)
end