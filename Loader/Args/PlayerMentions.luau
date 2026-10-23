-- This Plugin serves as a Example and functionality for the Player Mentions feature of the QC System.
-- You can remove this anytime, without anything breaking or keep it.

return {
	--// The Arguments Name
	argName = "player",
	
	--// Arguments Table
	Arguments = {
		--// Gui Creator
		Gui = {
			Title = "Select a Player", -- The Title of the list
			
			--// The "Populate" function is the base for every List to be filled, changing this to Anything will break the Plugin.
			Populate = function(Plr : Player)
				local list = {}
				for _, FoundPlr in ipairs(game:GetService("Players"):GetPlayers()) do
					if FoundPlr ~= Plr then
						table.insert(list, FoundPlr.DisplayName)
					end
				end
				
				--// Export
				return list
			end,
		}
	}
}