-- OspryOS Quickchat Plugins Module --

return function(OspryQC)
	return {
		Init = function(Plugins)
			--// Generate Folder
			local Plugins_Shared = Instance.new("Folder")
			Plugins_Shared.Name = "Plugins"
			Plugins_Shared.Parent = OspryQC.Shared
			
			--// Get Plugins
			for _, Plugin in pairs(Plugins:GetChildren()) do
				if Plugin:IsA("ModuleScript") then
					local PluginClone = Plugin:Clone()
					PluginClone.Parent = OspryQC.Shared.Plugins
					OspryQC:Debug("Plugin '"..PluginClone.Name.."' Cloned to Shared.")
				end
			end
			
			--// Complete
			OspryQC:Debug("Plugins Initialized, ready for Client.")
		end,
	}
end