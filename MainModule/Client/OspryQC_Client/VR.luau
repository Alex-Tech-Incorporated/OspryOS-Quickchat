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

--// Player
local Plr = Players.LocalPlayer
local PlayerGui = Plr:WaitForChild("PlayerGui")

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
	--// Essentials
	Fallback_Container = nil, -- Used for VRBottomBar Guis incase something goes wrong
	Interface = {
		--// Essential elements
		Button = nil,
		Gui_Interface = nil,
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
	
	--// Behavior
	TopbarPlus_Availible = false,
	Menu_Shown = false,
	List_Shown = false,
}

-- Essentials --
function VR:Print(...)
	print("[QC-VR]:", ...)
end

function VR:Warn(...)
	warn("[QC-VR]:", ...)
end



-- Internal functions --

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

--// Loads all Dependencies of the Module
local function Load_Dependencies(Client)
	--// Get TopbarPlus
	if Client.Config.Enable_TopbarPlus then
		--// pcall for TopbarPlus Module
		local success, module = pcall(function()
			return require(
				Client.Config.Path_To_TopbarPlus
			)
		end)

		--// Check if TopbarPlus can be required
		if success then
			TopbarPlus = module
			VR.TopbarPlus_Availible = true
			VR:Print("TopbarPlus found!")

		else
			VR:Warn("Unable to require TopbarPlus, VRBottomBar will be used by default.")
		end
	end

	--// Get VRBottomBar
	if not Client.Config.Enable_VRBottomBar then
		VR:Warn("Please switch 'Enable_VRBottomBar' to true if you wish for VR Support.")
		return

	else
		--// pcall for VRBottomBar Module
		local success, module = pcall(function()
			return require(
				Client.Config.Path_To_VRBottomBar
			)
		end)

		--// Check if TopbarPlus can be required
		if success then
			VRBottomBar = module
			VR:Print("VRBottomBar found!")

		else
			VR:Warn("Failed to require VRBottomBar, aborting VR Systems.")
			return
		end
	end
end



--// Export
return function(Client)
	return {
		
		--// Initiates the Core of the VR System
		Init = function()
			if not UIS.VREnabled then return end
			VR:Print("Initializing VR System Core...")
			
			--// Get Nexus VR Core
			Client.VR.Init_NexusVRCore()
			
			--// Initiate Dependencies
			Load_Dependencies(Client)
			
			--// Prepared
			VR:Print("Core Systems prepared.")
		end,
		
		--// Initiates the Icon for VR Users
		Init_Icon = function()
			--// locals
			local VR_Button = nil
			
			--// Create Button
			if VR.TopbarPlus_Availible then
				--// Icon
				local VRIcon = TopbarPlus.new()
					:setName("OspryQC_VR")
					:setImage(125230976591996)
				
				--// Add to VRBottomBar
				local Context = VRBottomBar:WithTopbarPlus(TopbarPlus)
				Context:Add(VRIcon, Client.Config.VRBottomBar_Position)
				
				--// Set Button
				VR_Button = VRIcon
				VR:Print("Generated Icon via TopbarPlus.")
				
			else
				--// Generate Fallback Folder
				local Folder = Instance.new("Folder")
				Folder.Name = "VR_Fallbacks"
				Folder.Parent = Client.Shared
				VR.Fallback_Container = Folder
				
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
				VRBottomBar:Add(Button, Client.Config.VRBottomBar_Position)
				
				--// Set Button
				VR_Button = Button
				VR:Print("Generated Icon via VRBottomBar.")
			end
			
			--// Check if the Normal Interface should be used
			if not Client.Config.VR_Compatibility then
				Client.UI.HookVRIcon(VR.TopbarPlus_Availible, VR_Button)
				
			else
				VR:Print("Waiting for NexusVRCore...")
				--// Wait for Core - Incase the Device is slow
				repeat task.wait(1) until NexusVRCore ~= nil
				
				--// Set Button
				VR.Interface.Button = VR_Button
				
				--// Initialize Interface
				Client.VR.Init_Interface()
				
			end
		end,
		
		--// Initiates the Interface for VR Users
		Init_Interface = function()
			if not Client.Config.VR_Compatibility then return end
			VR:Print("Initialiting Interface...")
			
			--// locals
			--// Client Resources
			local Shared = Client.Shared
			local VRShared = Shared:WaitForChild("VR")
			local Templates = VRShared:WaitForChild("Templates")
			
			--// Templates
			local ButtonTemplate = Templates:WaitForChild("TemplateButton") :: TextButton
			local PageTemplate = Templates:WaitForChild("PageTemplate") :: Frame
			
			--// NexusVRCore Resources
			local ScreenGui = NexusVRCore:GetResource("Container.ScreenGui")
			
			
			
			-- Generate SurfaceGui --
			
			--// Generate ScreenGui
			local VRInterface = ScreenGui.new()
			VRInterface.Name = "OspryQC_VR"
			VRInterface.Easing = 0.2
			VRInterface.Parent = PlayerGui
			VR.Interface.Gui_Interface = VRInterface
			
			--// Get UI and Setup
			local Interface_Container = VRShared:WaitForChild("Container"):Clone()
			VR.Interface.UIScale = Interface_Container:WaitForChild("UIScale")
			VR.Interface.UIScale.Scale = 0
			Interface_Container.Parent = VR.Interface.Gui_Interface:GetContainer()
			
			--// Setup List
			local List_Container = VRShared:WaitForChild("List_Container"):Clone()
			VR.Interface.List.Title = List_Container:WaitForChild("Title")
			VR.Interface.List.Options = List_Container:WaitForChild("Options")
			VR.Interface.List.UIScale = List_Container:WaitForChild("UIScale")
			List_Container.Parent = VR.Interface.Gui_Interface:GetContainer()
			
			--// Setup Notifications
			local Notif_Container = VRShared:WaitForChild("Notif_Container"):Clone()
			VR.Interface.Notification.Title = Notif_Container:WaitForChild("Title")
			VR.Interface.Notification.Message = Notif_Container:WaitForChild("Message")
			VR.Interface.Notification.UIScale = Notif_Container:WaitForChild("UIScale")
			Notif_Container.Parent = VR.Interface.Gui_Interface:GetContainer()
			
			
			
			-- Connections --
			
			--// Connect Icon
			if VR.TopbarPlus_Availible then
				VR.Interface.Button.toggled:Connect(function()
					if VR.List_Shown then return end
					
					--// Check Menu State
					if VR.Menu_Shown then
						TS:Create(VR.Interface.UIScale, MenuInfo, {Scale = 0}):Play()
						VR.Menu_Shown = false

					else
						TS:Create(VR.Interface.UIScale, MenuInfo, {Scale = 1}):Play()
						VR.Menu_Shown = true
					end
				end)
				
			else
				VR.Interface.Button.MouseButton1Click:Connect(function()
					if VR.List_Shown then return end
					
					--// Check Menu State
					if VR.Menu_Shown then
						TS:Create(VR.Interface.UIScale, MenuInfo, {Scale = 0}):Play()
						VR.Menu_Shown = false

					else
						TS:Create(VR.Interface.UIScale, MenuInfo, {Scale = 1}):Play()
						VR.Menu_Shown = true
					end
				end)
			end
			
			--// Complete
			VR:Print("Interface initialized.")
		end,
		
		
		
		--// Generates the VR-Side of Phrases
		CreatePhrases = function(Table)
			VR:Print("Generating Categorys and Phrases...")
			
			--// locals
			--// Client Resources
			local Shared = Client.Shared
			local VRShared = Shared:WaitForChild("VR")
			local Templates = VRShared:WaitForChild("Templates")
			local Phrases = Table
			
			--// Templates
			local ButtonTemplate = Templates:WaitForChild("TemplateButton") :: TextButton
			local PageTemplate = Templates:WaitForChild("PageTemplate") :: Frame
			
			--// Interface
			local Container = VR.Interface.Gui_Interface:GetContainer()
			local Frame = Container:WaitForChild("Container")
			local Pages = Frame:WaitForChild("Pages")
			local Home = Frame:WaitForChild("Home")
			
			
			
			--// Create Categories
			for catName, phraseMap in pairs(Phrases) do
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
				
				--// Get Phrases
				for phraseId, data in pairs(phraseMap) do
					--// Create a new Button
					local Button = ButtonTemplate:Clone()
					Button.Text = data.Text
					Button.Parent = PhraseSelection
					
					--// Connect
					Button.MouseButton1Click:Connect(function()
						if Client.Debounce then return end
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
							Client.Send(phraseText, {})
							return
						end

						--// Fill Tables
						Client.SelectedPhrase = phraseText
						Client.PendingArgs = {}
						Client.RequiredArgs = args

						Client:ProcessArguments()
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
			
			--// Complete
			VR:Print("Phrases and Categorys generated?")
		end,
		
		--// Displays a Notification
		Notify = function(Message : string, Duration : number)
			if not Client.Config.VR_Compatibility then return end
			
			--// locals
			local UIScale = VR.Interface.Notification.UIScale
			local Notif_Text = VR.Interface.Notification.Message
			local Notif_Duration = Duration or 4
			
			--// Tween and set Text
			Notif_Text.Text = Message
			TS:Create(UIScale, MenuInfo, {Scale = 1}):Play()
			task.wait(8)
			
			TS:Create(UIScale, MenuInfo, {Scale = 0}):Play()
		end,
		
		
		
		--// Generates a List for VR Compatibility
		GenerateList = function(argName : string)
			if not Client.Config.VR_Compatibility then return end
			if VR.List_Shown then return end
			VR.List_Shown = true
			
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
				TS:Create(UIScale, MenuInfo, {Scale = 0}):Play()
				TS:Create(VR.Interface.UIScale, MenuInfo, {Scale = 1}):Play()
				VR.List_Shown = false
				
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
			
			--// Open List
			TS:Create(VR.Interface.UIScale, MenuInfo, {Scale = 0}):Play()
			TS:Create(UIScale, MenuInfo, {Scale = 1}):Play()
			
			
			
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
				task.wait(Client.Config.Chat_Cooldown)
				Client.Debounce = false
			end)
		end,
		
		
		
		--// Initiates functionality for NexusVRCore.
		Init_NexusVRCore = function()
			if not Client.Config.VR_Compatibility then return end
			
			--// Check what Core should be used
			if Client.Config.Use_NexusVR_Inbuild_Core then
				VR:Warn("Warning! Using the bundled Nexus VR Core in Nexus VR Character Module is deprecated!")
				
				--// Get Nexus VR Core
				local FoundCore = require(RS:WaitForChild("NexusVRCore"))
				NexusVRCore = FoundCore
				VR:Print("Found bundled NexusVRCore!")
				
			else
				--// Get Nexus VR Core
				local success, module = pcall(function()
					return require(
						Client.Config.Path_To_NexusVRCore
					)
				end)
				
				if success then
					--// Set VR Table
					NexusVRCore = module
					
					VR:Print("Found NexusVRCore!")
					
				else
					VR:Warn("Unable to find NexusVRCore! VR Systems will not be functional!")
					return
				end
			end
		end,
	}
end