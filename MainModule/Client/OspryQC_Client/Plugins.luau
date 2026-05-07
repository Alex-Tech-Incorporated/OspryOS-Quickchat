--// Client Framework
return function (Client)
	--// locals
	local Shared = Client.Shared
	local PluginsFolder = Shared:WaitForChild("Plugins", 60)
	
	-- Exports --
	return {
		--// Loads Plugins
		LoadPlugins = function()
			if not PluginsFolder then
				warn("[OspryQC Client]: Unable to find Plugins Folder within", Client.Shared:GetFullName()..".")
				return
			end
			print("[OspryQC Client]: Loading Plugins...")
			
			--// Get Plugins
			for _, Module in ipairs(PluginsFolder:GetChildren()) do
				if Module:IsA("ModuleScript") then
					--// Check if Module initializes
					local success, plugin = pcall(require, Module)
					
					--// Check repsonse
					if success and plugin.argName and plugin.Arguments then
						Client:RegisterArgument(plugin.argName, plugin.Arguments.Gui)
						
					else
						warn(`[OspryQC Client]: Plugin "{Module.Name}" has failed to initialize.`)
						continue
					end
				end
			end
			
			--// Complete
			print("[OspryQC Client]: Plugins loaded.")
		end,
	}
end