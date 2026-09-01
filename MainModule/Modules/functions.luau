-- OspryOS Quickchat functions --

--// locals
--// Services
local Players = game:GetService("Players")

return function(OspryQC)
	--// locals
	local Client = OspryQC.Client
	
	return {
		Init = function()
			--// Clone Client
			local Cloned_Client = OspryQC.Client.OspryQC_Client_V2:Clone()
			Cloned_Client.Parent = game:GetService("ReplicatedStorage")
			
			--// Player Connections
			Players.PlayerRemoving:Connect(function(Plr : Player)
				OspryQC:debug(`Player leaving, {Plr.Name}`)
				
				--// Delete Client Status
				OspryQC.Remote.Client_Status[Plr.UserId] = nil
			end)
			
			OspryQC:debug("functions Initialized.")
		end,
		
		--// Checks the _G API of a supported Admin System to see if the Player is muted
		IsMuted = function(Plr : Player)
			--// Check if Adonis Compatability is enabled
			if OspryQC.Config.Adonis_Compat then
				OspryQC:debug("Running Check via _G.Adonis...")
				
				--// locals
				local AdonisAPI = _G.Adonis
				
				--// Check for _G API
				if not AdonisAPI then
					OspryQC:warn(`Adonis _G API is not availible.`)
					return false
				end
				
				--// Check if Playedr is Muted
				local success, result = pcall(function()
					return AdonisAPI.IsMuted(Plr)
				end)
				
				--// Check response
				if success then
					return result
					
				else
					--// Log
					OspryQC:warn(`Failed to reach _G.Adonis!`)
					OspryQC:warn(result)
					
					--// Return false if all other Checks did not return anything
					return false
				end
			end
		end,
	}
end