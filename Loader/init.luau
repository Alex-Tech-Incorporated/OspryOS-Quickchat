-- OspryOS Quickchat Loader --

--// locals
--// Services
local SSS = game:GetService("ServerScriptService")

--// Loader Components
local Container = script
local Plugins = Container:WaitForChild("Plugins")
local LoaderConfig = Container.Config



-- Initialize --
Container.Parent = SSS -- Never leave Loaders in workspace, please...
local Config = require(LoaderConfig)
local OspryQC

--// Check if MainModule is availible
local success, module = pcall(function()
	return require(
		if Config.LoadLocally
			then Container:WaitForChild("MainModule", 60)
			else Config.MainModule
	)
end)

--// Result
if success then
	OspryQC = module
	
else
	warn("[OspryQC Loader]: MainModule is not availible at this time.")
	return
end

--// Set up QuickChat Settings
OspryQC:OverwriteConfig(Config)



--// Bootup MainModule
local loaded, response = OspryQC:Init(Plugins)

if loaded then
	print(`[OspryQC Loader]: {response}`)
	
else
	warn("[OspryQC Loader]: Failed to Initialize MainModule:")
	warn(`[OspryQC Loader]: {response}`)
end