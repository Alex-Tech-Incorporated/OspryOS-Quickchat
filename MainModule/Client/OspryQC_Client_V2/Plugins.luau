--// Client Framework
return function (Client)
	return {
		--// Loads Plugins
		Init = function()
			Client:print(`Initializing Plugins...`)
			
			--// locals
			local PluginsFolder = Client.Shared:WaitForChild("Plugins")

			--// Get Plugins
			for _, Module in ipairs(PluginsFolder:GetChildren()) do
				if Module:IsA("ModuleScript") then
					--// Check if Module initializes
					local success, plugin = pcall(require, Module)

					--// Check repsonse
					if success and plugin.argName and plugin.Arguments then
						-- Client:RegisterArgument(plugin.argName, plugin.Arguments.Gui)
						Client.Plugins.RegisterArgument(plugin.argName, plugin.Arguments.Gui)

					else
						Client:warn(`Plugin {Module.Name} has failed to load.`)
						continue
					end
				end
			end

			--// Complete
			Client:print(`Plugins initialized.`)
		end,
		
		--// Registers an Argument
		RegisterArgument = function(argName : string, guiData)
			Client.ArgumentTypes[argName] = guiData
			Client:debug(`Registered Argument: {argName}`)
		end,
	}
end