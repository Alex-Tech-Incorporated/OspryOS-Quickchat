-- OspryOS Quickchat Calls Module --

--// locals
--// Services
local Players = game:GetService("Players")

return function(OspryQC)
	--// locals
	local Client = OspryQC.Client
	
	return {
		Init = function()
			--// The Main Quickchat RemoteEvent, Parsing both Client and Server Requests
			local QuickChatEvent = Instance.new("RemoteEvent") :: RemoteEvent
			QuickChatEvent.Name = "QuickChat"
			QuickChatEvent.Parent = OspryQC.Remotes
			
			--// Notification RemoteEvent
			local NotifyEvent = Instance.new("RemoteEvent")
			NotifyEvent.Name = "Notify"
			NotifyEvent.Parent = OspryQC.Remotes
			
			--// RemoteFunction to return the Config to the Client
			local get_Config = Instance.new("RemoteFunction") :: RemoteFunction
			get_Config.Name = "get_Config"
			get_Config.Parent = OspryQC.Remotes
			
			--// RemoteFunction to return the Phrases to the Client
			local get_Phrases = Instance.new("RemoteFunction") :: RemoteFunction
			get_Phrases.Name = "get_Phrases"
			get_Phrases.Parent = OspryQC.Remotes
			
			
			
			--// Add get_Config Call
			get_Config.OnServerInvoke = function()
				return OspryQC.Config -- Export
			end
			
			--// Add get_Phrases Call
			get_Phrases.OnServerInvoke = function()
				--// Phrase Essentials
				local PhraseEssentials = {
					OspryQC.Config.Phrases
				}
				
				--// Export
				return PhraseEssentials
			end
			
			
			
			--// Player Added Connection
			Players.PlayerAdded:Connect(function(Plr : Player)
				OspryQC:Debug("Loading Player,", Plr.Name)
				
				--// Insert Client Script
				local OspryQC_Client = Client.OspryQC_Client:Clone()
				OspryQC_Client.Parent = Plr:WaitForChild("PlayerGui")
				OspryQC_Client.Enabled = true
			end)
			
			OspryQC:Debug("Calls Initialized!")
		end,
		
		--// Checks if a Player is Muted by a Support Admin System or the Inbuild Moderation Panel, returns true if Muted
		CheckMute = function(Plr : Player)
			--// Check if Adonis Compatability is enabled
			if OspryQC.Config.Adonis_Compat then
				OspryQC:Debug("Running Check via _G.Adonis...")
				
				--// locals
				local AdonisAPI = _G.Adonis
				
				--// Check for _G API
				if not AdonisAPI then
					warn("[OspryOS Quickchat]: Adonis _G API not availible, is G_API set to true?")
					return false
				end
				
				--// Check if Muted
				return AdonisAPI.IsMuted(Plr)
			end
			
			--// Check if Technified Compatability is enabled
			if OspryQC.Config.Technified_Compat then
				--// Check for _G.Technified
				if not _G.Technified then
					warn("[OspryOS Quickchat]: _G.Technified was not found, is Technified installed?")
					return false
				end	
				
				--// Technified Scripting API
				local IsMuted, Data = _G.Technified.IsMuted(Plr.UserId)
				
				--// Check if Muted
				if IsMuted then
					OspryQC:Debug(Plr.Name, "has been Muted for", Data)
					return true
				end
			end
			
			--// Return false if all other Checks did not return anything
			return false
		end,
	}
end