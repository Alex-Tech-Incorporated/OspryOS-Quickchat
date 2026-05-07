--[[
		-- OspryOS Quickchat Loader --
	-- Loads the MainModule into the game --
	
	
	All releases of this System can be found on our Github!
	https://github.com/Alex-Tech-Incorporated/OspryOS-Quickchat
	
	Found a bug? You can report it to our Github.
	https://github.com/Alex-Tech-Incorporated/OspryOS-Quickchat/issues
	
	
	Only edit the Loader of you know what you are doing!
	OspryOS Quickchat is availible under the Terms of the MIT License.
--]]



--// locals
--// Services
local SSS = game:GetService("ServerScriptService")

--// Loader Components
local Container = script
local LoaderConfig = Container.Config

--// MainModule
local OspryQC

--// Loader Table
local Loader = {
	Config = require(LoaderConfig),
	Plugins = Container:WaitForChild("Plugins"),
}

function Loader:print(...)
	print("[OspryQC Loader]:", ...)
end
function Loader:warn(...)
	warn("[OspryQC Loader]:", ...)
end



-- Initialize --
Loader:print("Loading...")
Container.Parent = SSS -- Never leave Loaders in workspace, please...

--// Check if MainModule is availible
local success, module = pcall(function()
	return require(
		if Loader.Config.LoadLocally
			then Container:WaitForChild("MainModule", 30)
			else Loader.Config.MainModule
	)
end)

--// Result
if success then
	OspryQC = module
	
else
	Loader:warn("MainModule has failed to require.")
	return
end

--// Set up QuickChat Settings
OspryQC:OverwriteConfig(Loader.Config)



-- Initialize MainModule --
local loaded, response = OspryQC:Init(Loader.Plugins)

--// Check if MainModule loaded
if loaded then
	Loader:print(`{response}`)
	
else
	Loader:warn(`Failed to initialize MainModule.`)
	Loader:warn(`{response}`)
end