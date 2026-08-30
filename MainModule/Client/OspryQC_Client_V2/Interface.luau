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
			
			--// Create Interface
			Client.Interface.Create_Interface()
		end,
		
		--// Creates the Client Interface
		Create_Interface = function()
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
	}
end