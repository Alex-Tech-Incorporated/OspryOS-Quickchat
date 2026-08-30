return function (OspryQC)
	return {
		--// locals
		QuickChatEvent = Instance.new("RemoteEvent"),
		
		--// Tables
		Client_Status = {}, -- Stores the Status of all Clients -- Format: [Plr.UserId] = "Loading" | "Loaded"
		
		--// Initiates the Module
		Init = function()
			-- Setup Remotes --
			
			--// This is the "Main" Event for the entire Client.
			OspryQC.Remote.QuickChatEvent.Name = "QuickChat"
			OspryQC.Remote.QuickChatEvent.Parent = OspryQC.Remotes

			--// RemoteFunction to return the Config to the Client
			local get_Config = Instance.new("RemoteFunction") :: RemoteFunction
			get_Config.Name = "get_Config"
			get_Config.Parent = OspryQC.Remotes

			--// RemoteFunction to return the Phrases to the Client
			local get_Phrases = Instance.new("RemoteFunction") :: RemoteFunction
			get_Phrases.Name = "get_Phrases"
			get_Phrases.Parent = OspryQC.Remotes
			
			
			-- Connections --
			
			--// get_Config
			get_Config.OnServerInvoke = function()
				return OspryQC.Config -- Export
			end

			--// get_Phrases
			get_Phrases.OnServerInvoke = function()
				--// Phrase Essentials
				local PhraseEssentials = {
					OspryQC.Config.Phrases
				}

				--// Export
				return PhraseEssentials
			end
			
			--// QuickChat Event
			OspryQC.Remote.QuickChatEvent.OnServerEvent:Connect(function(Plr : Player, Command : string, ...)
				if Command == "Load_Client" then
					if OspryQC.Remote.Client_Status[Plr.UserId] then
						return
					end
					
					--// Start Loading process
					OspryQC.Remote.Client_Status[Plr.UserId] = "Loading"
					OspryQC.Remote.Send(Plr, "Load_Client")
					OspryQC:debug(`Loading the Client of {Plr.Name}`)
					
				else
					--// locals
					local func = OspryQC.Remote.Commands[Command]
					if not func then return end
					
					--// Execute
					func(Plr, ...)
				end
			end)
			
			--// Complete
			OspryQC:debug(`Remote Module initialized.`)
		end,
		
		--// Sends a Command to a Client
		Send = function(Plr : Player, Command : string, ...)
			OspryQC.Remote.QuickChatEvent:FireClient(Plr, Command, ...)
		end,
		
		--// Sends a Command to all Clients
		SendAll = function(Command : string, ...)
			OspryQC.Remote.QuickChatEvent:FireAllClients(Command, ...)
		end,
		
		--// Commands that the Client can use
		Commands = {
			--// Signals the Server that the Client has loaded
			Client_Loaded = function(Plr : Player)
				if OspryQC.Remote.Client_Status[Plr.UserId] ~= "Loading" then
					--// Log
					OspryQC:warn(
						`The Server has gotten an invalid signal from {Plr.Name}.`
						..`\nThe Client has finished loading, but loading was never started.`
					)
					
					--// Ignore
					return
				end
				
				--// Add to loaded
				OspryQC.Remote.Client_Status[Plr.UserId] = "Loaded"
				OspryQC:debug(`The Client of {Plr.Name} has finished loading.`)
			end,
			
			--// Sends a Quickchat Message to the Server for processing
			Process_Message = function(Plr : Player, Phrase : string, ArgTable : string)
				--// locals
				local TextService = game:GetService("TextService")
				
				--// Debug Print
				OspryQC:debug("Server request recieved by", Plr.Name)

				--// Check if Player is muted
				if OspryQC.functions.IsMuted(Plr) then
					OspryQC:debug(Plr.Name, "is Muted, request cancelled.")
					OspryQC:Notify(Plr, "You are currently Muted and unable to use the Quickchat.", 6)
					return
				end

				--// Check if Phrase is Valid
				local data = OspryQC:FindPhraseData(Phrase)
				if not data then
					OspryQC:warn(`{Plr.Name} has sent an invalid Phrase to the Server`)
					
					--// Kick
					Plr:Kick(
						"[OspryOS Quickchat]"
						.."\nAn Invalid Phrase has been sent to the Server from your Client, please rejoin."
					)
					
					--// Cancel Request
					return
				end

				--// Convert Arguments or leave Phrase as is
				local ProcessedMessage = Phrase
				for argName, argValue in pairs(ArgTable) do
					ProcessedMessage = ProcessedMessage:gsub("{"..argName.."}", argValue)
				end

				--// Filter
				local success, result = pcall(function()
					return TextService:FilterStringAsync(
						ProcessedMessage,
						Plr.UserId,
						Enum.TextFilterContext.PublicChat
					)
				end)

				--// Check Response
				if not success then
					--// Notify Player
					OspryQC:Notify(
						Plr,
						"Something wen't wrong during filtering, please try again later!",
						4
					)

					--// Cancel Request
					OspryQC:warn(
						`TextService has failed to filter a Message.`
						..`\nResult: {result}`
					)
					return
				end

				--// Get Filter result
				local FilteredMessage = result:GetNonChatStringForBroadcastAsync()
				
				--// Send to Clients
				OspryQC.Remote.SendAll("NewMessage", FilteredMessage)
			end,
		}
	}
end