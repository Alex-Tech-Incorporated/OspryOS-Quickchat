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
				local start = os.clock()
				
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
				Client:debug(`Loading took: {os.clock() - start} seconds.`)
				Client.Remote.Send("Client_Loaded")
				
				--// Welcome Notification
				if Config.UI.Welcome_Message then
					Client.Interface.Notify(
						`Hello {Client.Plr.DisplayName}! Client v{Config.Version} has successfully initialized.`,
						6
					)
				end
			end,
			
			--// Displays a Quickchat Message
			NewMessage = function(Sender : Player, Message : string)
				--// ChatMessage Template
				local QC_Template = Client:format(Sender, Message)

				--// Send Chat Message
				if Client.Config.UI.Sent_To_Chat then
					TextChatService.TextChannels.RBXSystem:DisplaySystemMessage(QC_Template)
				end

				--// Chat Bubble
				TextChatService:DisplayBubble(
					Sender.Character,
					string.format("%s%s",
						Client.Config.UI.Message_punctuation,
						Message
					)
				)
				Client:debug("Got Message from Server by", Sender.Name)
			end,
			
			--// Displays a Notification
			Notify = function(Message : string, Duration : number)
				Client.Interface.Notify(Message, Duration)
			end,
		},
	}
end