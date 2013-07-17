GM.Version = "2.5.0"
GM.Name = "DarkRP"
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion, Drakehawke"

DeriveGamemode("sandbox")
local function LoadModules()
	local root = GM.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		if GM.Config.DisabledModules[folder] then continue end

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

include("fn.lua")

include("config/config.lua")
include("sh_interfaceloader.lua")

include("client/DRPDermaSkin.lua")
include("client/showteamtabs.lua")
include("client/vgui.lua")

include("shared/player_class.lua")
include("shared/animations.lua")
include("shared/commands.lua")
include("shared/entity.lua")
include("shared/MakeThings.lua")
include("shared/Workarounds.lua")

include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")

LoadModules()

DarkRP.finish()
