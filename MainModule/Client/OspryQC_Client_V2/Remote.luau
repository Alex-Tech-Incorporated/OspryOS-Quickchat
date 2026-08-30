--// locals
--// Services
local TextChatService = game:GetService("TextChatService")

--// Client Framework
return function (Client)
	return {
		--// Remotes
		QuickChat = Client.Remotes:WaitForChild("QuickChat"),
		get_Config = Client.Remotes:WaitForChild("get_Config"),
		
		--// Initiates the Module
		Init = function()
			Client:print(`Connecting ClientEvent...`)
			
			--// OnClientEvent Connection
			Client.Remote.QuickChat.OnClientEvent:Connect(function(Command : string, ...)
				Client.Remote.Commands[Command](...)
			end)
		end,
		
		--// Sends a Command to the Server
		Send = function(Command : string, ...)
			Client.Remote.QuickChat:FireServer(Command, ...)
		end,
		
		--// Client Commands
		Commands = {
			--// Loads the Client
			Load_Client = function()
				Client:print(`Loading Client...`)
				
				--// Configure Client
				local Config = Client.Remote.get_Config:InvokeServer()

				--// Configure
				for key, value in pairs(Config) do
					Client.Config[key] = value
				end
				Client:debug("Configured")
				
				--// Load Modules
				Client:debug(`Loading Modules...`)
				for _, Module in pairs(Client.Module_LoadingOrder) do
					Module.Init()
				end
				Client:debug(`Module loading complete.`)
				
				--// Complete
				Client:print(`OspryOS Quickchat Client v{Client.Config.Version} loaded.`)
				Client.Remote.Send("Client_Loaded")
			end,
			
			--// Displays a Quickchat Message
			NewMessage = function(Sender : Player, Message : string)
				--// ChatMessage Template
				local QC_Template = Client:format(Sender, Message)

				--// Send Chat Message
				TextChatService.TextChannels.RBXSystem:DisplaySystemMessage(
					QC_Template
				)

				--// Chat Bubble
				TextChatService:DisplayBubble(
					Sender.Character,
					string.format("%s%s",
						Client.Config.UI.Message_punctuation,
						Message
					)
				)
				Client:debug("Chat Message recieved from", Sender.Name)
			end,
			
			--// Displays a Notification
			Notify = function(Message : string, Duration : number)
				
			end,
		},
	}
end