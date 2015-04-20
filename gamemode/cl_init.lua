hook.Run("DarkRPStartedLoading")

GM.Version = "2.6.1"
GM.Name = "DarkRP"
GM.Author = "By FPtje Falco et al."

DeriveGamemode("sandbox")
local function LoadModules()
	local root = GM.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		if DarkRP.disabledDefaults["modules"][folder] then continue end

		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			if File == "sh_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			if File == "cl_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
	end
end

GM.Config = {} -- config table
GM.NoLicense = GM.NoLicense or {}

include("config/config.lua")
include("libraries/simplerr/simplerr.lua")
include("libraries/gmodfunctional/fn.lua")
include("libraries/interfaceloader.lua")
include("libraries/disjointset.lua")

include("libraries/modificationloader.lua")
LoadModules()

DarkRP.DARKRP_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
DarkRP.DARKRP_LOADING = nil

DarkRP.finish()

hook.Call("DarkRPFinishedLoading", GM)
