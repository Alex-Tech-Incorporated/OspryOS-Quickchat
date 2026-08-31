--// locals
--// Services
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local Topbar

--// TweenService
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

--// Interface Table
local Interface = {
	--// Stores all Udim2 Positions of Guis
	Positions = {
		--// Quickchat Menu
		Menu = {
			Shown = UDim2.new(0.767, 0, 0.025, 0),
			Hidden = UDim2.new(1.01, 0, 0.025, 0)
		},
		
		--// Menu Button (ImageButton)
		Menu_Button = {
			Opened = UDim2.new(0.725, 0, 0.075, 0),
			Closed = UDim2.new(0.965, 0, 0.075, 0)
		},
		
		--// Menu Pages
		Pages = {
			Shown = UDim2.new(0, 0, 0, 0),
			Hidden = UDim2.new(1, 0, 0, 0)
		}
	}
}

--// Client Framework
return function (Client)
	--// Client
	local Plr = Client.Plr :: Player?
	local Config = Client.Config
	
	local PlayerGui = Plr:WaitForChild("PlayerGui")
	
	--// Shared
	local Shared = Client.Shared
	local Shared_UI = Shared:WaitForChild("UI")
	local Templates = Shared_UI:WaitForChild("Templates")
	
	
	
	-- Internal functions --

	--// Generates a Button... What do you expect exactly?
	local function GenerateCloseBtn(): TextButton
		--// Generate
		local CloseBtn = Instance.new("TextButton")
		CloseBtn.Size = UDim2.new(0.8, 0, 0, 40)
		CloseBtn.Text = "[CLOSE]"
		CloseBtn.Name = "Close_Button"

		CloseBtn.BackgroundTransparency = 1
		CloseBtn.TextStrokeTransparency = 0
		CloseBtn.TextColor3 = Color3.fromRGB(255, 55, 55)
		CloseBtn.FontFace = Font.new("rbxasset://fonts/families/Jura.json")
		CloseBtn.TextScaled = true

		--// Export
		return CloseBtn
	end
	
	--// Configures all the UI to the options set via the Config
	local function ConfigureUI(Elements : {any})
		Client:debug(Elements)
		
		--// Configure
		for i, Interface_Object in pairs(Elements) do
			if Interface_Object:IsA("ScreenGui") then
				
				--// locals
				local MainFrame = Interface_Object:FindFirstChildOfClass("Frame") :: Frame
				if not MainFrame then return end

				local UIStroke =  MainFrame:FindFirstChildOfClass("UIStroke")
				if not UIStroke then return end

				--// Modify Elements
				UIStroke.Color = Config.UI.Stroke_Color
				UIStroke.Thickness = Config.UI.Stroke_Thickness
				UIStroke.Transparency = Config.UI.Stroke_Transparency
				
				MainFrame.BackgroundColor3 = Config.UI.Background_Color
				
			elseif Interface_Object:IsA("TextButton") or Interface_Object:IsA("ImageButton") then
				--// locals
				local UIStroke = Interface_Object:FindFirstChildOfClass("UIStroke") :: UIStroke
				if not UIStroke then return end
				
				--// Modify Elements
				UIStroke.Color = Config.UI.Stroke_Color
				UIStroke.Thickness = Config.UI.Stroke_Thickness
				UIStroke.Transparency = Config.UI.Stroke_Transparency

				Interface_Object.BackgroundColor3 = Config.UI.Background_Color
			end
		end
	end
	
	--// Generates the Topbar Icon of the Quickchat
	local function GenerateButton()
		if UIS.VREnabled and Config.VR_Compatibility then Client.VR.Create_Icon() return end
		
		if Config.Enable_TopbarPlus then
			--// pcall
			local success, result = pcall(function()
				return require(Config.Path_To_TopbarPlus)
			end)

			--// Check response
			if not success then
				Client:warn(`Failed to require TopbarPlus Module.`)
				Client:warn(`{result}`)

				--// Restart
				Config.Enable_TopbarPlus = false
				Client.Topbar_Failed = true
				GenerateButton()
				return
			end

			--// localise
			Topbar = result

			--// Create Icon
			local Icon = Topbar.new()
				:setName("OspryQC")
				:setLabel("Quickchat")
				:setImage(125230976591996, "Deselected")
				:setImage(93549485815803, "Selected")
			if Config.Topbar_Icon_Keybind ~= nil then Icon:bindToggleKey(Config.Topbar_Icon_Keybind) end

			--// Complete
			Client:debug(`Topbar Icon generated.`)
			
		else
			--// locals
			local MenuButton = Templates:WaitForChild("MenuButton"):Clone() :: ImageButton
			MenuButton.Name = "QC_Button"
			MenuButton.Position = UDim2.new(0.965, 0, 0.075, 0)
			
			--// Parent to Gui
			task.spawn(function() MenuButton.Parent = PlayerGui:WaitForChild("OspryQC_Menu") end)
		end
	end
	
	--// functions
	return {
		--// Initiates the Interface
		Init = function()
			Client:debug(`Initializing Interface...`)
			
			--// Apply modifications
			Client:debug(`Applying modifcations...`)
			ConfigureUI({
				Shared_UI:WaitForChild("OspryQC_List"),
				Shared_UI:WaitForChild("OspryQC_Menu"),
				Shared_UI:WaitForChild("OspryQC_Notif"),
				
				Templates:WaitForChild("MenuButton"),
				Templates:WaitForChild("TemplateButton"),
				Templates:WaitForChild("PageTemplate"):WaitForChild("Selection"):WaitForChild("ReturnToOptions"),
			})
			
			--// Create Button
			GenerateButton()
			
			--// Create Interface and Pages
			Client.Interface.Create_Interface()
			Client.Interface.Create_Pages()
		end,
		
		--// Creates the Client Interface
		Create_Interface = function()
			if UIS.VREnabled and Config.VR_Compatibility then Client.VR.Create_Interface() return end
			Client:debug(`Generating Interface...`)
			
			--// Menu
			local QC_Menu = Shared_UI:WaitForChild("OspryQC_Menu"):Clone() :: ScreenGui
			QC_Menu:WaitForChild("Background").Position = Interface.Positions.Menu.Hidden
			QC_Menu.Parent = PlayerGui
			
			--// Connect Button or Icon
			local Icon = if Topbar then Topbar.getIcon("OspryQC") else nil
			if Icon then
				-- Connections --
				Icon.selected:Connect(function()
					TS:Create(
						QC_Menu.Background,
						MenuInfo,
						{Position = Interface.Positions.Menu.Shown}
					):Play()
				end)
				Icon.deselected:Connect(function()
					TS:Create(
						QC_Menu.Background,
						MenuInfo,
						{Position = Interface.Positions.Menu.Hidden}
					):Play()
				end)
				
			else
				--// locals
				local Button = QC_Menu:WaitForChild("QC_Button") :: ImageButton
				local MenuShown = false
				
				--// Connection
				Button.MouseButton1Click:Connect(function()
					if MenuShown then
						--// Button
						Button.Interactable = false
						Button.Image = "rbxassetid://108397435459242"
						TS:Create(Button,
							MenuInfo,
							{Position = Interface.Positions.Menu_Button.Closed}
						):Play()
						
						--// Move Menu
						TS:Create(
							QC_Menu.Background,
							MenuInfo,
							{Position = Interface.Positions.Menu.Hidden}
						):Play()
						
						--// Set State
						MenuShown = false
						
					else
						--// Button
						Button.Interactable = false
						Button.Image = "rbxassetid://140578581316954"
						TS:Create(Button,
							MenuInfo,
							{Position = Interface.Positions.Menu_Button.Opened}
						):Play()

						--// Move Menu
						TS:Create(
							QC_Menu.Background,
							MenuInfo,
							{Position = Interface.Positions.Menu.Shown}
						):Play()

						--// Set State
						MenuShown = true
					end
					
					--// Switch Interactibility
					task.delay(0.75, function()
						Button.Interactable = true
					end)
				end)
			end
		end,
		
		--// Creates all Pages
		Create_Pages = function()
			if UIS.VREnabled and Config.VR_Compatibility then Client.VR.Create_Pages() return end
			
			--// locals
			local Phrases = Client.Phrases
			local Root = Phrases[1]
			Client:debug(`Fetched Categories and Phrases. Expand to view results:`, Root)
			
			--// locals
			local Gui = Plr:WaitForChild("PlayerGui"):WaitForChild("OspryQC_Menu")
			local Pages = Gui:WaitForChild("Background"):WaitForChild("Pages")
			local CategoryOptions = Gui:WaitForChild("Background"):WaitForChild("Options")
			
			--// Generate Categorys
			for categoryName, phraseMap in pairs(Root) do
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

					--// Connection
					Button.MouseButton1Click:Connect(function()
						if Client.Debounce then
							--// Display Notification
							Client.Interface.Notify(
								"Please wait before sending another Message!",
								6
							)
							return
						end
						Client.Debounce = true

						--// locals
						local phraseText = data.Text
						local args = {}

						--// Find Arguments
						for argName in phraseText:gmatch("{(.-)}") do
							table.insert(args, argName)
						end

						--// Send if no Arguments were found
						if #args == 0 then
							Client.Remote.Send("Process_Message", phraseText, {})
							task.delay(Config.Chat_Cooldown, function()
								Client.Debounce = false
							end)
							return
						end

						--// Fill Tables
						Client.SelectedPhrase = phraseText
						Client.PendingArgs = {}
						Client.RequiredArgs = args

						Client.Plugins.ProcessArguments()
					end)
				end



				-- Connections --
				
				--// Connection for the Category Button
				catButton.MouseButton1Click:Connect(function()
					--// Hide all Pages
					for _, p in pairs(Pages:GetChildren()) do
						if p:IsA("Frame") then

							--// Generate Tween
							TS:Create(p, SlideInfo, {Position = Interface.Positions.Pages.Hidden}):Play()
						end
					end

					--// Tween Options Frame
					TS:Create(CategoryOptions, SlideInfo, {Position = Interface.Positions.Pages.Hidden}):Play()

					--// Tween Selected Frame
					TS:Create(catPage, SlideInfo, {Position = Interface.Positions.Pages.Shown}):Play()
					task.delay(1, function()
						catPage.Position = Interface.Positions.Pages.Shown
					end)
				end)

				--// Connection for all Category Return Buttons
				Selection.ReturnToOptions.MouseButton1Click:Connect(function()
					--// Hide all Pages
					for _, p in pairs(Pages:GetChildren()) do
						if p:IsA("Frame") then

							--// Generate Tween
							TS:Create(p, SlideInfo, {Position = Interface.Positions.Pages.Hidden}):Play()
							task.delay(1, function()
								p.Position = Interface.Positions.Pages.Hidden
							end)
						end
					end

					--// Tween Options Frame
					TS:Create(CategoryOptions, SlideInfo, {Position = Interface.Positions.Pages.Shown}):Play()
				end)
			end

			--// Complete?
			Client:debug("Generated Pages.")
		end,
		
		--// Creates a List of options given by the Argument's Name
		CreateList = function(argName : string)
			if UIS.VREnabled and Config.VR_Compatibility then Client.VR.CreateList(argName) return end
			
			--// Fetch Gui Data
			local guiData = Client.ArgumentTypes[argName]
			if not guiData then
				Client:warn(`{tostring(argName)} is not a valid Argument.`)
				return
			end
			Client:debug(guiData)

			--// Generate Gui
			local Gui = Shared_UI:FindFirstChild("OspryQC_List"):Clone()
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
			local CloseButton = GenerateCloseBtn()
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
					Client.PendingArgs[argName] = option
					CloseList()
					Client.Plugins.ProcessArguments()
				end)
			end

			--// CloseButton Connection
			CloseButton.MouseButton1Click:Connect(function()
				CloseList()

				--// Reset Debounce
				task.wait(Config.Chat_Cooldown)
				Client.Debounce = false
			end)
		end,
		
		--// Creates and Displays a Notification
		Notify = function(Message : string, Duration : number)
			if UIS.VREnabled and Config.VR_Compatibility then Client.VR.Notify(Message, Duration) return end
			
			--// locals
			local Notif_Duration = Duration or 4

			--// Find Notification Template
			local Template = Shared_UI:FindFirstChild("OspryQC_Notif")
			if not Template then Client:warn(`Failed to find Notification Template in {Shared_UI:GetFullName()}`) return end

			--// Clone Notification
			local Notif = Template:Clone()
			Notif.Background.Message.Text = Message
			Notif.Background.Position = UDim2.new(1.01, 0, 0.831, 0)
			Notif.Parent = PlayerGui

			--// Tween
			TS:Create(Notif.Background, MenuInfo, {BackgroundTransparency = 0.6}):Play()
			TS:Create(Notif.Background.UIStroke, MenuInfo, {Transparency = Config.UI.Stroke_Transparency}):Play()
			TS:Create(Notif.Background, MenuInfo, {Position = UDim2.new(0.744, 0, 0.831, 0)}):Play()

			task.wait(Notif_Duration)

			--// Tween
			TS:Create(Notif.Background, MenuInfo, {BackgroundTransparency = 1}):Play()
			TS:Create(Notif.Background.UIStroke, MenuInfo, {Transparency = 1}):Play()
			TS:Create(Notif.Background, MenuInfo, {Position = UDim2.new(1.01, 0, 0.831, 0)}):Play()
			
			--// Destroy UI
			task.delay(0.75, function()
				Notif:Destroy()
			end)
		end,
	}
end