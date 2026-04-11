# Modifications and Development
The System is availible under an MIT license, you can fork and redistribute any changes to the MainModule and Loader. Please remember to give Credits!

## Development Settings
These settings are intended for Development use, they include an option to load a local MainModule and a Debug Mode.
```lua
--// Development
LoadLocally = true, -- Loads a local version of the MainModule within the Loader
DebugMode = true, -- Toggles debug prints
```

## LoadLocally
`LoadLocally` allows the Loader to load a local version of the MainModule that has been parented to the Loader, this is intended to test any modifications to the MainModule and/or Loader.

## Debug Mode
`DebugMode` enables special Debug Prints for the Client and Server, which can be called over `OspryQC:Debug()` on the Server and `Client:Debug()` on the Client.
Debug Mode is intended for finding bugs with the System.
