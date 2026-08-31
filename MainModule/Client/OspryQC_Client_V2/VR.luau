-- OspryQC VR Module --

--[[
	Most of this Script relies heavily on Nexus VR Core.
	Please check out the Documention of Nexus VR Core to learn more.
	
	https://github.com/TheNexusAvenger/Nexus-VR-Core/tree/master/docs
]]

--// locals
--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

--// Module Essentials
local NexusVRCore
local TopbarPlus
local VRBottomBar

--// TweenService
local SlideInfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Exponential
)
local MenuInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Exponential
)

--// VR System Table
local VR = {
	Fallback_Container = nil,
	Interface = {
		Button = nil,
		
		Container = nil,
		UIScale = nil,
		
		--// List layout elements
		List = {
			Title = nil,
			Options = nil,
			UIScale = nil,
		},

		--// Notification layout elements
		Notification = {
			Title = nil,
			Message = nil,
			UIScale = nil,
		},
	},
	
	--// Interface booleans
	-- This is used to indicate which Menu is current shown
	Menu = false,
	List = false,
}



--// Client Framework
return function (Client)
	--// Client
	local Plr = Client.Plr :: Player?
	local Config = Client.Config

	local PlayerGui = Plr:WaitForChild("PlayerGui")
	
	--// Shared
	local Shared = Client.Shared
	local Shared_VR = Shared:WaitForChild("VR")
	local Templates = Shared_VR:WaitForChild("Templates")
	
	
	
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
		CloseBtn.Font = Enum.Font.Jura
		CloseBtn.TextScaled = true

		--// Export
		return CloseBtn
	end
	
	--// Configures all the UI to the options set via the Config
	local function ConfigureUI(Elements : {any})
		Client:debug(Elements)

		--// Configure
		for i, Interface_Object in pairs(Elements) do
			if Interface_Object:IsA("Frame") then

				--// locals
				local UIStroke =  Interface_Object:FindFirstChildWhichIsA("UIStroke", true)
				if not UIStroke then return end

				--// Modify Elements
				UIStroke.Color = Config.UI.Stroke_Color
				UIStroke.Thickness = Config.UI.Stroke_Thickness
				UIStroke.Transparency = Config.UI.Stroke_Transparency

				Interface_Object.BackgroundColor3 = Config.UI.Background_Color

			elseif Interface_Object:IsA("TextButton") or Interface_Object:IsA("ImageButton") then
				--// locals
				local UIStroke = Interface_Object:FindFirstChildWhichIsA("UIStroke") :: UIStroke
				if not UIStroke then return end

				--// Modify Elements
				UIStroke.Color = Config.UI.Stroke_Color
				UIStroke.Thickness = Config.UI.Stroke_Thickness
				UIStroke.Transparency = Config.UI.Stroke_Transparency

				Interface_Object.BackgroundColor3 = Config.UI.Background_Color
			end
		end
	end
	
	--// Tweens a UIScale's Scale Value
	local function TweenScale(UIScale : UIScale, Info : TweenInfo, NewScale : number)
		TS:Create(
			UIScale,
			Info,
			{Scale = NewScale}
		):Play()
	end
	
	--// Toggles the Visibility of the HomePage
	local function ToggleHomePage(Shown : boolean)
		--// locals
		local Interface = VR.Interface.Gui_Interface:GetContainer()
		local Frame = Interface:WaitForChild("Container")
		local HomePage = Frame:WaitForChild("Home")

		if Shown then
			--// Tween
			TS:Create(
				HomePage,
				SlideInfo,
				{Position = UDim2.new(0.025, 0, 0.025, 0)}
			):Play()

		else
			--// Tween
			TS:Create(
				HomePage,
				SlideInfo,
				{Position = UDim2.new(1, 0, 0.025, 0)}
			):Play()
		end
	end

	--// Hides all Pages from the UI
	local function HideAllPages(Pages : Folder, IgnoredPage : string)
		--// Get and Hide Pages
		for _, Page in ipairs(Pages:GetChildren()) do
			if Page:IsA("Frame") and Page.Name ~= IgnoredPage then
				--// Generate Tween
				TS:Create(Page, SlideInfo, {Position = UDim2.new(1, 0, 0.025, 0)}):Play()
			end
		end
	end

	--// Switches the UI's Page
	local function SwitchPage(Page : Frame)
		--// Hide all Pages
		HideAllPages(Page.Parent, Page.Name)
		ToggleHomePage(false)

		--// Tween Page
		TS:Create(
			Page,
			SlideInfo,
			{Position = UDim2.new(0.025, 0, 0.025, 0)}
		):Play()
	end
	
	--// functions
	return {
		--// Initiates the VR Sub-System
		Init = function()
			if not UIS.VREnabled or not Config.VR_Compatibility then return end
			Client:print(`Initializing VR Systems...`)
			
			--// Load Nexus VR Core
			Client.VR.Load_NexusVRCore()
			if not NexusVRCore then
				Client:warn(`Something wen't wrong while trying to require Nexus VR Core!`)
				Config.VR_Compatibility = false
				return
			end
			
			--// Load VR Bottom Bar
			Client.VR.Load_VRBottomBar()
			if not VRBottomBar then
				Client:warn(`Something wen't wrong while trying to require VR Bottom Bar!`)
				Config.VR_Compatibility = false
				return
			end
			
			--// require TopbarPlus
			if Config.Use_TopbarPlus then
				--// pcall
				local success, result = pcall(function()
					return require(Config.Path_To_TopbarPlus)
				end)
				
				--// Check Response
				if not success then
					Client:warn(`Failed to require TopbarPlus Module via the set Config path.`)
					Client:warn(`{result}`)
				end
				
				--// Set local
				TopbarPlus = result
				Client:print(`Found TopbarPlus`)
			end
			
			--// Configure Interface
			ConfigureUI({
				Shared_VR:WaitForChild("Container"),
				Shared_VR:WaitForChild("List_Container"),
				Shared_VR:WaitForChild("Notif_Container"),
				
				Templates:WaitForChild("PageTemplate"),
				Templates:WaitForChild("TemplateButton")
			})
		end,
		
		--// Creates an Icon for VR Users
		Create_Icon = function()
			if TopbarPlus then
				--// locals
				local VR_Icon = TopbarPlus.new()
					:setName("OspryQC_VR")
					:setImage(125230976591996)
				
				--// Add to VRBottomBar
				local Context = VRBottomBar:WithTopbarPlus(TopbarPlus)
				Context:Add(VR_Icon, Config.VRBottomBar_Position)

				--// Set Button
				VR.Interface.Button = VR_Icon
				
			else
				--// Generate Fallback Container
				local Container = Instance.new("Folder")
				Container.Name = "Fallbacks"
				Container.Parent = Shared

				VR.Fallback_Container = Container
				
				--// Generate Button
				local Button = Instance.new("ImageButton")
				Button.Name = "OspryQC_VR"
				Button.SizeConstraint = Enum.SizeConstraint.RelativeYY
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.Image = "rbxassetid://108397435459242"
				Button.Parent = VR.Fallback_Container

				--// Customize
				Button.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
				Button.BackgroundTransparency = 0.08

				--// UI Corner
				local UICorner = Instance.new("UICorner")
				UICorner.CornerRadius = UDim.new(1, 0)
				UICorner.Parent = Button

				--// Add to VRBottomBar
				VRBottomBar:Add(Button, Config.VRBottomBar_Position)

				--// Set Button
				VR.Interface.Button = Button
			end
			
			--// Complete
			Client:print(`Icon generated.`)
		end,
		
		--// Creates the VR Interface
		Create_Interface = function()
			if not UIS.VREnabled or not Config.VR_Compatibility then return end
			Client:print(`Creating VR Interface...`)
			
			--// Client resources
			local ButtonTemplate = Templates:WaitForChild("TemplateButton")
			local ScreenGui = NexusVRCore:GetResource("Container.ScreenGui")
			
			
			
			-- Generate Interface --
			
			local VR_Interface = ScreenGui.new()
			VR_Interface.Name = "OspryQC_VR"
			VR_Interface.Easing = 0.2
			VR_Interface.Parent = PlayerGui
			VR.Interface.Container = VR_Interface
			
			local Interface_Container = Shared_VR:WaitForChild("Container"):Clone()
			VR.Interface.UIScale = Interface_Container:WaitForChild("UIScale")
			VR.Interface.UIScale.Scale = 0
			Interface_Container.Parent = VR.Interface.Container:GetContainer()

			--// Setup List
			local List_Container = Shared_VR:WaitForChild("List_Container"):Clone()
			VR.Interface.List.Title = List_Container:WaitForChild("Title")
			VR.Interface.List.Options = List_Container:WaitForChild("Options")
			VR.Interface.List.UIScale = List_Container:WaitForChild("UIScale")
			List_Container.Parent = VR.Interface.Container:GetContainer()

			--// Setup Notifications
			local Notif_Container = Shared_VR:WaitForChild("Notif_Container"):Clone()
			VR.Interface.Notification.Title = Notif_Container:WaitForChild("Title")
			VR.Interface.Notification.Message = Notif_Container:WaitForChild("Message")
			VR.Interface.Notification.UIScale = Notif_Container:WaitForChild("UIScale")
			Notif_Container.Parent = VR.Interface.Container:GetContainer()
			
			
			
			-- Connections --
			
			--// Check if TopbarPlus is availible
			if TopbarPlus then
				VR.Interface.Button.toggled:Connect(function()
					if VR.List then return end
					
					--// Check Menu State
					if VR.Menu then
						TweenScale(VR.Interface.UIScale, MenuInfo, 0)
						VR.Menu = false
						
					else
						TweenScale(VR.Interface.UIScale, MenuInfo, 1)
						VR.Menu = true
					end
				end)
				
			else
				VR.Interface.Button.MouseButton1Click:Connect(function()
					if VR.List then return end

					--// Check Menu State
					if VR.Menu then
						TweenScale(VR.Interface.UIScale, MenuInfo, 0)
						VR.Menu = false

					else
						TweenScale(VR.Interface.UIScale, MenuInfo, 1)
						VR.Menu = true
					end
				end)
			end
			
			Client:print(`Interface generated.`)
		end,
		
		--// Creates all Pages for the VR Interface
		Create_Pages = function()
			if not UIS.VREnabled or not Config.VR_Compatibility then return end
			
			--// locals
			local Phrases = Client.Phrases
			local Root = Phrases[1]
			Client:debug(`Fetched Categories and Phrases. Expand to view results:`, Root)
			
			--// Client resources
			local ButtonTemplate = Templates:WaitForChild("TemplateButton")
			local PageTemplate = Templates:WaitForChild("PageTemplate")
			local Container = VR.Interface.Container:GetContainer()
			
			--// Interface
			local MainFrame = Container:WaitForChild("Container")
			local Pages = MainFrame:WaitForChild("Pages")
			local Home = MainFrame:WaitForChild("Home")
			
			
			
			--// Create Categories
			for catName, phraseMap in pairs(Root) do
				--// Create Button
				local CategoryButton = ButtonTemplate:Clone()
				CategoryButton.Name = catName
				CategoryButton.Text = catName
				CategoryButton.Parent = Home:WaitForChild("Options")

				--// Category Page
				local CategoryPage = PageTemplate:Clone()
				CategoryPage.Name = catName
				CategoryPage.CatName.Text = catName
				CategoryPage.Parent = Pages
				
				--// Elements
				local BottomBar = CategoryPage:WaitForChild("BottomBar")
				local ReturnButton = BottomBar:WaitForChild("ReturnButton")
				local PhraseSelection = CategoryPage:WaitForChild("Phrases")
				
				--// Generate Phrases
				for phraseId, data in pairs(phraseMap) do
					--// Create a new Button
					local Button = ButtonTemplate:Clone()
					Button.Text = data.Text
					Button.Parent = PhraseSelection

					--// Connect
					Button.MouseButton1Click:Connect(function()
						if Client.Debounce then
							--// Display Notification
							Client.VR.Notify(
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

				--// Connects the Category Button to its Category
				CategoryButton.MouseButton1Click:Connect(function()
					--// Switch to Category
					SwitchPage(CategoryPage)
				end)

				--// Connects the Return Button to the Home Page
				ReturnButton.MouseButton1Click:Connect(function()
					HideAllPages(Pages, "N/A")
					ToggleHomePage(true)
				end)
			end
		end,
		
		--// Creates a List :P
		CreateList = function(argName : string)
			if not Config.VR_Compatibility then return end
			if VR.List then return end
			VR.List = true

			--// Fetch Gui Data
			local guiData = Client.ArgumentTypes[argName]
			if not guiData then
				VR:Warn(`"{tostring(argName)}" is not a valid Argument.`)
				return
			end

			--// locals
			local UIScale = VR.Interface.List.UIScale
			local Title = VR.Interface.List.Title
			local List = VR.Interface.List.Options

			--// Set Elements
			Title.Text = guiData.Title

			--// Closes the List
			local function CloseList()
				TweenScale(UIScale, MenuInfo, 0)
				TweenScale(VR.Interface.UIScale, MenuInfo, 1)
				VR.List = false

				--// Clear list
				task.delay(0.5, function()
					for _, Text in ipairs(List:GetChildren()) do
						if Text:IsA("TextButton") then
							Text:Destroy()
						end
					end
				end)
			end

			--// Generate Close Button
			local CloseButton = GenerateCloseBtn()
			CloseButton.Parent = List

			--// Open List
			TweenScale(VR.Interface.UIScale, MenuInfo, 0)
			TweenScale(UIScale, MenuInfo, 1)



			-- Connections --

			--// Get Data
			local options = guiData.Populate(Plr)
			for _, option in pairs(options) do
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
					Client:ProcessArguments()
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
			if not Config.VR_Compatibility then return end

			--// locals
			local UIScale = VR.Interface.Notification.UIScale
			local Notif_Text = VR.Interface.Notification.Message
			local Notif_Duration = Duration or 4

			--// Tween and set Text
			Notif_Text.Text = Message
			TweenScale(UIScale, MenuInfo, 1)
			task.wait(Notif_Duration)
			
			TweenScale(UIScale, MenuInfo, 0)
		end,
		
		
		
		-- Misc functions --
		
		--// Attempts to load Nexus VR Core
		Load_NexusVRCore = function()
			if not UIS.VREnabled or not Config.VR_Compatibility then return end
			if NexusVRCore then return end
			
			--// Check if Nexus VR Character Module's Core should be used
			if Config.Use_NexusVR_Inbuild_Core then
				Client:warn(
					`Using the inbuild Core of Nexus VR Character Module is deprecated!`
					..`\nPlease switch to a seperate version of Nexus VR Core.`
				)
				
				--// Load NexusVRCore
				local VRCore = require(RS:WaitForChild("NexusVRCore"))
				NexusVRCore = VRCore
				Client:print(`Found inbuild Nexus VR Core`)
				
			else
				--// pcall
				local success, result = pcall(function()
					return require(Config.Path_To_NexusVRCore)
				end)
				
				--// Check repsonse
				if not success then
					Client:warn(`Failed to require Nexus VR Core via the set Config path.`)
					Client:warn(`{result}`)
					return
				end
				
				--// Set Core
				NexusVRCore = result
				Client:print(`Found Nexus VR Core`)
			end
		end,
		
		--// Attempts to load VR Bottom Bar
		Load_VRBottomBar = function()
			if not UIS.VREnabled or not Config.VR_Compatibility then return end
			
			--// Check if Path is nil
			if Config.Path_To_VRBottomBar == nil then
				Client:warn(`Path_To_VRBottomBar is set to nil, VR initialization aborted.`)
				Config.VR_Compatibility = false
				return
			end
			
			--// pcall
			local success, result = pcall(function()
				return require(Config.Path_To_VRBottomBar)
			end)
			
			--// Check Response
			if not success then
				Client:warn(`Failed to require VR Bottom Bar via the set Config path.`)
				Client:warn(`{result}`)
				return
			end
			
			--// Set local
			VRBottomBar = result
			Client:print(`Found VR Bottom Bar`)
		end,
	}
end