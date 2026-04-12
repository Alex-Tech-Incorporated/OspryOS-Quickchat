# Plugins
This part of the Documentation will cover how Plugins work.
> [!IMPORTANT]
> Plugins are still in development! Things may change in the future.

## Creating a Plugin
Within the Loader, there should be a Folder called "Plugins", in there you should be able to find a Plugin called "PlayerMentions",
this Plugin serves as an Example on how to make Plugins and the Mention functionality of the Quickchat System.
```lua
-- Code Example for a simple Plugin:
return {
	--// The Arguments Name
	argName = "test",
	
	--// Arguments Table
	Arguments = {
		--// Gui Creator
		Gui = {
			Title = "Select a Test", -- The Title of the list
			
			--// The "Populate" function is the base for every List to be filled, changing this to Anything will break the Plugin.
			Populate = function()
				return { -- Anything within this return will be a selectable option.
					"Test 1",
					"Test 2",
				}
			end,
		}
	}
}
```
### Integrating Plugins to Phrases
Within all Plugins, you need to set an `argName`, once you have set an Argument Name, you can go to the Phrases Table within the Config and add the Argument as seen below.
```lua
["Debugging"] = {
  Test = {Text = "Test, {test}"},
},
```
Once a Player selects this Phrase, the Client will check for brackets. If a bracket is found, it will look what Plugin uses that Argument, and then Create a List with the options from the `return`.
After all Arguments are processed, the Client will send the results to the Server.

## How do Plugins work?
Most of the Plugins functionality is a part of the Client. All the Server does is clone them over to the Shared Folder within `ReplicatedStorage`.
The Client loads Plugins one by one and Registers the Arguments by storing them in the Client Table with the Gui data. This is done by `Client:LoadPlugins()` and `Client:RegisterArgument()`.
Once the Client detects an Argument within a Phrase, the Client will run `Client:ProcessArguments()`, which will the process all Arguments within the Phrase,
the Arguments that need to be processed are also stored in a Table that are a part of the Client Table.
These are `Client.RequiredArgs` for any Args that still need to be processed and `Client.PendingArgs` for any that will be sent to the Server and have already been processed.
`Client.ArgumentTypes` is only used to Store the Arguments of Plugins.
