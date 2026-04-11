-- OspryQC VR Module --

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

--// VR System Table
local VR = {
	--// Essentials
	Fallback_Container = nil, -- Used for VRBottomBar Guis incase something goes wrong
	Interface = {
		Button = nil,
	},
	
	--// Behavior
	TopbarPlus_Availible = false,
}

-- Essentials --
function VR:Print(...)
	print("[QC-VR]:", ...)
end

function VR:Warn(...)
	warn("[QC-VR]:", ...)
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
			if not Client.Config.Enable_NexusVR_Compat then
				Client.UI.HookVRIcon(VR.TopbarPlus_Availible, VR_Button)
				
			else
				VR:Print("Waiting for NexusVRCore...")
				--// Wait for Core - Incase the Device is slow
				repeat task.wait(1) until VR.NexusVR_Core ~= nil
				
				--// Set Button
				VR.Interface.Button = VR_Button
				
				--// Initialize Interface
				Client.VR.Init_Interface()
				
			end
		end,
		
		--// Initiates the Interface for VR Users
		Init_Interface = function()
			if not Client.Config.Enable_NexusVR_Compat then return end
		end,
		
		
		
		--// Generates the VR-Side of Phrases
		CreatePhrases = function(Table)
			--// locals
			local Phrases = Table
		end,
		
		
		
		--// Initiates functionality for NexusVRCore.
		Init_NexusVRCore = function()
			if not Client.Config.Enable_NexusVR_Compat then return end
			
			--// Get Nexus VR Core
			local FoundCore = require(RS:WaitForChild("NexusVRCore"))
			NexusVRCore = FoundCore
			VR:Print("NexusVRCore found!")
		end,
	}
end