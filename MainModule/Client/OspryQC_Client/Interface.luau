-- OspryQC Interface Module --

--// locals
--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

--// Player
local Plr = Players.LocalPlayer
local PlayerGui = Plr:WaitForChild("PlayerGui")

--// TopbarPlus
local TopbarPlus

--// TweenService
local Positions = {
	Background = {
		Shown = UDim2.new(0.767, 0, 0.025, 0),
		Hidden = UDim2.new(1.01, 0, 0.025, 0)
	},
	
	MenuButton = {
		MenuOpen = UDim2.new(0.725, 0, 0.075, 0),
		MenuClosed = UDim2.new(0.965, 0, 0.075, 0)
	},
	
	Pages = {
		Shown = UDim2.new(0, 0, 0, 0),
		Hidden = UDim2.new(1, 0, 0, 0)
	},
}

--// TweenInfo
local MenuInfo = TweenInfo.new(
	0.75,
	Enum.EasingStyle.Exponential
)
local SlideInfo = TweenInfo.new(
	0.75,
	Enum.EasingStyle.Exponential
)
local ListInfo = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Exponential
)

--// System Table
local Sys = {
	MenuShown = false,
}


--// Export
return function (QCClient)
	--// locals
	local Shared = QCClient.Shared
	
	--// Export functions
	return {
		--// Generates the Menu Button or Topbar Icon
		CreateButton = function()
			
			--// Check if Player is in VR
			if UIS.VREnabled and QCClient.Config.Enable_VRBottomBar or QCClient.Config.Enable_NexusVR_Compat then
				--// Notice
				print("[QC Interface]: VR User detected, loading VR Interface...")
				
				--// Init
				QCClient.VR.Init_Icon()
				return
				
			else
				--// Check if TopbarPlus should be used
				if QCClient.Config.Enable_TopbarPlus then
					--// Debug Print
					QCClient:Debug("Path_To_TopbarPlus is set to", QCClient.Config.Path_To_TopbarPlus:GetFullName())
					QCClient:Debug("Generating Topbar...")
					
					--// pcall for TopbarPlus Module
					local success, module = pcall(function()
						return require(
							QCClient.Config.Path_To_TopbarPlus
						)
					end)

					--// Check if TopbarPlus can be required
					if success then
						TopbarPlus = module

					else
						warn("[QC Interface]: TopbarPlus could not be required or found, switching to Default.")

						--// Restart
						QCClient.Topbar_Failed = true
						QCClient.Config.Enable_TopbarPlus = false
						QCClient.UI.CreateButton()
						return
					end
					
					--// Create Topbar Button
					TopbarPlus.new()
						:setName("OspryQC")
						:setLabel("Quickchat")
						:setImage(125230976591996, "Deselected")
						:setImage(93549485815803, "Selected")

					QCClient:Debug("TopbarPlus Icon generated.")
					
				else
					--// Search for Template
					local Template = Shared.UI.Templates:WaitForChild("MenuButton", 180)
					if Template then
						--// Generate Button
						local QCButton = Template:Clone() :: ImageButton
						QCButton.Name = "QCButton"
						QCButton.Position = UDim2.new(0.965, 0, 0.075, 0)
						QCButton.BackgroundColor3 = QCClient.Config.UI.Background_Color
						QCButton.UIStroke.Color = QCClient.Config.UI.Stroke_Color
						QCButton.UIStroke.Thickness = QCClient.Config.UI.Stroke_Thickness
						QCButton.UIStroke.Transparency = QCClient.Config.UI.Stroke_Transparency

						--// Prevents the Script from freezing due to the Infinite Yield
						task.spawn(function() QCButton.Parent = PlayerGui:WaitForChild("OspryQC_Menu") end)
						QCClient:Debug("MenuButton generated.")
					else
						Plr:Kick("[OspryOS Quickchat Interface]\n\nQuickchat MenuButton failed to load after 3 Minutes, please rejoin.")
						return
					end
				end
			end
		end,
		
		--// Hooks the VR Icon to the regular Interface
		HookVRIcon = function(Used_Topbar, Icon)
			--// locals
			local Menu = nil
			local Info = TweenInfo.new(
				0.75,
				Enum.EasingStyle.Exponential
			)
			
			--// Connect Button
			if Used_Topbar then
				Icon.toggled:Connect(function()
					if Sys.MenuShown then
						--// Menu
						TS:Create(Menu.Background, Info, {Position = Positions.Background.Hidden}):Play()
						Sys.MenuShown = false

					else
						--// Menu
						TS:Create(Menu.Background, Info, {Position = Positions.Background.Shown}):Play()
						Sys.MenuShown = true
					end
				end)
				
			else
				Icon.MouseButton1Click:Connect(function()
					if Sys.MenuShown then
						--// Menu
						TS:Create(Menu.Background, Info, {Position = Positions.Background.Hidden}):Play()
						Sys.MenuShown = false

					else
						--// Menu
						TS:Create(Menu.Background, Info, {Position = Positions.Background.Shown}):Play()
						Sys.MenuShown = true
					end
				end)
			end

			--// Set local
			task.spawn(function()
				Menu = PlayerGui:WaitForChild("OspryQC_Menu")
				print("[QC Interface]: VR Icon hooked!")
			end)
		end,
		
		
		
		--// Generates the Quickchat Interface
		CreateGui = function()
			QCClient:Debug("Generating Client Interface...")

			--// Check if Shared exists
			if QCClient.Shared then
				if UIS.VREnabled and QCClient.Config.Enable_NexusVR_Compat then return end
				
				--// locals
				local UI = Shared:WaitForChild("UI")
				local QCMenu = UI:WaitForChild("OspryQC_Menu")
				local QCList = UI:WaitForChild("OspryQC_List")
				local QCNotif = UI:WaitForChild("OspryQC_Notif")


				--// Clone Menu
				local MenuClone = QCMenu:Clone()
				MenuClone.Background.BackgroundColor3 = QCClient.Config.UI.Background_Color
				MenuClone.Background.UIStroke.Color = QCClient.Config.UI.Stroke_Color
				MenuClone.Background.UIStroke.Thickness = QCClient.Config.UI.Stroke_Thickness
				MenuClone.Background.UIStroke.Transparency = QCClient.Config.UI.Stroke_Transparency
				MenuClone.Background.Position = UDim2.new(1.02, 0, 0.025, 0)
				MenuClone.Parent = PlayerGui

				--// Modify Template Button
				UI.Templates.TemplateButton.BackgroundColor3 = QCClient.Config.UI.Background_Color
				UI.Templates.TemplateButton.UIStroke.Color = QCClient.Config.UI.Stroke_Color
				UI.Templates.TemplateButton.UIStroke.Thickness = QCClient.Config.UI.Stroke_Thickness
				UI.Templates.TemplateButton.UIStroke.Transparency = QCClient.Config.UI.Stroke_Transparency

				--// Modify Page Template Return Button
				UI.Templates.PageTemplate.Selection.ReturnToOptions.TextColor3 = QCClient.Config.UI.Stroke_Color
				

				--// Modify OspryQC List
				QCList.Background.UIStroke.Color = QCClient.Config.UI.Stroke_Color
				QCList.Background.UIStroke.Thickness = QCClient.Config.UI.Stroke_Thickness
				QCList.Background.UIStroke.Transparency = QCClient.Config.UI.Stroke_Transparency
				QCList.Background.BackgroundColor3 = QCClient.Config.UI.Background_Color
				
				--// Modify OspryQC Notification
				QCNotif.Background.UIStroke.Color = QCClient.Config.UI.Stroke_Color
				QCNotif.Background.UIStroke.Thickness = QCClient.Config.UI.Stroke_Thickness
				QCNotif.Background.UIStroke.Transparency = 1
				QCNotif.Background.BackgroundColor3 = QCClient.Config.UI.Background_Color
				QCNotif.Background.BackgroundTransparency = 1

				--// Generate Menu Info
				local Info = TweenInfo.new(
					0.75,
					Enum.EasingStyle.Exponential
				)

				--// Connect TopbarPlus
				if QCClient.Config.Enable_TopbarPlus then
					--// Check if User is in VR and if VRBottomBar is enabled
					if UIS.VREnabled and QCClient.Config.Enable_VRBottomBar then
						print("[QC Interface]: Skipped Connection with TopbarPlus due to VR Overrides.")
						
					else
						--// locals and connections
						local Icon = TopbarPlus.getIcon("OspryQC")

						Icon.selected:Connect(function()
							TS:Create(MenuClone.Background, Info, {Position = Positions.Background.Shown}):Play()
						end)
						Icon.deselected:Connect(function()
							TS:Create(MenuClone.Background, Info, {Position = Positions.Background.Hidden}):Play()
						end)

						--// Debug
						QCClient:Debug("TopbarPlus Icon connected to functions.")
					end

				else
					--// Check if User is in VR and if VRBottomBar is enabled
					if UIS.VREnabled and QCClient.Shared:FindFirstChild("VR_Fallbacks") then
						print("[QC Interface]: Skipped Connection with MenuButton due to VR Overrides.")
						
					else
						--// locals
						local MenuButton = MenuClone:WaitForChild("QCButton") :: ImageButton

						--// Connections
						MenuButton.MouseButton1Click:Connect(function()
							if Sys.MenuShown then
								--// Menu
								TS:Create(MenuClone.Background, Info, {Position = Positions.Background.Hidden}):Play()
								Sys.MenuShown = false

								--// Button
								TS:Create(MenuButton, Info, {Position = Positions.MenuButton.MenuClosed}):Play()
								MenuButton.Interactable = false
								MenuButton.Image = "rbxassetid://108397435459242"

							else
								--// Menu
								TS:Create(MenuClone.Background, Info, {Position = Positions.Background.Shown}):Play()
								Sys.MenuShown = true

								--// Button
								TS:Create(MenuButton, Info, {Position = Positions.MenuButton.MenuOpen}):Play()
								MenuButton.Interactable = false
								MenuButton.Image = "rbxassetid://140578581316954"
							end

							--// Delay to prevent Spam
							task.delay(0.75, function()
								MenuButton.Interactable = true
							end)
						end)
						
						--// Debug
						QCClient:Debug("MenuButton connected to function.")
					end
				end

				QCClient:Debug("Client Interface generated.")
			else
				QCClient.UI.DisplayNotif("Client Shared could not be found, the Client will not be functional.")
				error("[QC Interface]: Unable to find '__OspryQC_Shared' in ReplicatedStorage, the Client will not be functional.")
			end
		end,
		
		CreatePhrases = function()
			--// locals
			local Gui = Plr:WaitForChild("PlayerGui"):WaitForChild("OspryQC_Menu")
			local Pages = Gui:WaitForChild("Background"):WaitForChild("Pages")
			local CategoryOptions = Gui:WaitForChild("Background"):WaitForChild("Options")
			local Templates = QCClient.Shared:WaitForChild("UI"):WaitForChild("Templates")

			local root = QCClient.Phrases[1] -- Skips the entire Table shenanigans with it starting with 1.

			--// Debug Prints
			QCClient:Debug("Creating Categorys and Phrases...")
			
			--// Found Phrases and Categorys
			QCClient:Debug("Found Categorys and Phrases,")
			QCClient:Debug(QCClient.Phrases)
			
			
			
			--// Check UserInputService
			if UIS.VREnabled and QCClient.Config.Enable_NexusVR_Compat then
				--// Initate Phrases for VR Interface
				QCClient.VR.CreatePhrases(root)
				
			else
				--// Generate Categorys
				for categoryName, phraseMap in pairs(root) do
					--// Generate Category Button
					local catButton = Templates.TemplateButton:Clone() :: TextButton
					catButton.Name = categoryName
					catButton.Text = categoryName
					catButton.Parent = CategoryOptions

					--// Generate Category
					local catPage = Templates.PageTemplate:Clone() :: Frame
					catPage.Name = categoryName
					catPage.catName.Text = categoryName
					catPage.Parent = Pages

					--// Category Selection Frame
					local Selection = catPage:WaitForChild("Selection")

					--// Generate Buttons for each Category
					for phraseId, data in pairs(phraseMap) do
						--// Phrase Buttons
						local Button = Templates.TemplateButton:Clone() :: TextButton
						Button.Text = data.Text
						Button.Parent = Selection

						Button.MouseButton1Click:Connect(function()
							if QCClient.Debounce then return end
							QCClient.Debounce = true

							--// locals
							local phraseText = data.Text
							local args = {}

							--// Find Arguments
							for argName in phraseText:gmatch("{(.-)}") do
								table.insert(args, argName)
							end

							--// Send if no Arguments were found
							if #args == 0 then
								QCClient.Send(phraseText, {})
								return
							end

							--// Fill Tables
							QCClient.SelectedPhrase = phraseText
							QCClient.PendingArgs = {}
							QCClient.RequiredArgs = args

							QCClient:ProcessArguments()
						end)
					end



					--// Connection for all Category Buttons
					catButton.MouseButton1Click:Connect(function()
						--// Hide all Pages
						for _, p in pairs(Pages:GetChildren()) do
							if p:IsA("Frame") then

								--// Generate Tween
								TS:Create(p, SlideInfo, {Position = UDim2.new(1, 0, 0, 0)}):Play()
							end
						end

						--// Tween Options Frame
						TS:Create(CategoryOptions, SlideInfo, {Position = UDim2.new(1, 0, 0, 0)}):Play()

						--// Tween Selected Frame
						TS:Create(catPage, SlideInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
						task.delay(1, function()
							catPage.Position = UDim2.new(0, 0, 0, 0)
						end)
					end)

					--// Connection for all Category Return Buttons
					Selection.ReturnToOptions.MouseButton1Click:Connect(function()
						--// Hide all Pages
						for _, p in pairs(Pages:GetChildren()) do
							if p:IsA("Frame") then

								--// Generate Tween
								TS:Create(p, SlideInfo, {Position = UDim2.new(1, 0, 0, 0)}):Play()
								task.delay(1, function()
									p.Position = UDim2.new(1, 0, 0, 0)
								end)
							end
						end

						--// Tween Options Frame
						TS:Create(CategoryOptions, SlideInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
					end)
				end
			end
			
			--// Complete?
			QCClient:Debug("Categorys and Phrases generated?")
		end,
		
		--// Displays a Notification for the Player
		DisplayNotif = function(Message : string)
			--// Find Notification Template
			local Template = QCClient.Shared.UI:FindFirstChild("OspryQC_Notif")
			if not Template then warn("[QC Interface]: Unable to find 'OspryQC_Notif' in", QCClient.Shared.UI:GetFullName()) return end
			
			--// Clone Notif
			local Notif = Template:Clone()
			Notif.Background.Message.Text = Message
			Notif.Background.Position = UDim2.new(1.01, 0, 0.831, 0)
			Notif.Parent = PlayerGui
			
			--// Tween
			TS:Create(Notif.Background, MenuInfo, {BackgroundTransparency = 0.6}):Play()
			TS:Create(Notif.Background.UIStroke, MenuInfo, {Transparency = QCClient.Config.UI.Stroke_Transparency}):Play()
			TS:Create(Notif.Background, MenuInfo, {Position = UDim2.new(0.744, 0, 0.831, 0)}):Play()
			
			task.wait(8)
			
			--// Tween
			TS:Create(Notif.Background, MenuInfo, {BackgroundTransparency = 1}):Play()
			TS:Create(Notif.Background.UIStroke, MenuInfo, {Transparency = 1}):Play()
			TS:Create(Notif.Background, MenuInfo, {Position = UDim2.new(1.01, 0, 0.831, 0)}):Play()
			task.delay(0.75, function()
				Notif:Destroy()
			end)
		end,
		
		
		
		--// Creates a List based on the Argument found.
		CreateList = function(argName : string)
			local guiData = QCClient.ArgumentTypes[argName]
			if not guiData then
				warn("[QC Interface]: '"..tostring(argName).."' is not a valid Argument.")
				return
			end
			QCClient:Debug(guiData)
			
			--// Generate Gui
			local Gui = Shared.UI:FindFirstChild("OspryQC_List"):Clone()
			local Background = Gui.Background
			local List = Background.Options
			
			--// Set Gui Parent
			Background.Title.Text = guiData.Title
			Gui.Parent = PlayerGui
			TS:Create(Background.UIScale, ListInfo, {Scale = 1}):Play()
			
			--// Closes the Gui
			local function CloseList()
				--// Close Menu
				TS:Create(Background.UIScale, ListInfo, {Scale = 0}):Play()
				task.delay(0.2, function()
					Gui:Destroy()
				end)
			end
			
			--// Generate Close Button
			local CloseButton = Instance.new("TextButton")
			CloseButton.Size = UDim2.new(0.8, 0, 0, 40)
			CloseButton.Text = "[CLOSE]"
			CloseButton.Name = "Close_Button"

			CloseButton.BackgroundTransparency = 1
			CloseButton.TextStrokeTransparency = 0
			CloseButton.TextColor3 = Color3.fromRGB(255, 55, 55)
			CloseButton.Font = Enum.Font.Jura
			CloseButton.TextScaled = true
			CloseButton.Parent = List
			
			--// Populate List
			local options = guiData.Populate(Plr)
			for _, option in ipairs(options) do
				local Button = Instance.new("TextButton")
				Button.Size = UDim2.new(0.8, 0, 0, 40)
				Button.Text = tostring(option)
				Button.Name = "Option_Button"
				
				--// Edit
				Button.BackgroundTransparency = 1
				Button.TextStrokeTransparency = 0
				Button.TextColor3 = Color3.fromRGB(255, 255, 255)
				Button.Font = Enum.Font.Jura
				Button.TextScaled = true
				Button.Parent = List
				
				--// Connect
				Button.MouseButton1Click:Connect(function()
					QCClient.PendingArgs[argName] = option
					CloseList()
					QCClient:ProcessArguments()
				end)
			end

			--// CloseButton Connection
			CloseButton.MouseButton1Click:Connect(function()
				CloseList()

				--// Reset Debounce
				task.wait(QCClient.Config.Chat_Cooldown)
				QCClient.Debounce = false
			end)
		end,
	}
end