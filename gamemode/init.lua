GM.Version = "2.5.0"
GM.Name = "DarkRP"
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion, Drakehawke"

DeriveGamemode("sandbox")

util.AddNetworkString("DarkRP_keypadData")

AddCSLuaFile("sh_interfaceloader.lua")
AddCSLuaFile("fn.lua")
include("fn.lua")

AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")
AddCSLuaFile("config/ammotypes.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("config/config.lua")

AddCSLuaFile("client/DRPDermaSkin.lua")
AddCSLuaFile("client/showteamtabs.lua")
AddCSLuaFile("client/vgui.lua")

AddCSLuaFile("shared/player_class.lua")
AddCSLuaFile("shared/animations.lua")
AddCSLuaFile("shared/commands.lua")
AddCSLuaFile("shared/entity.lua")
AddCSLuaFile("shared/MakeThings.lua")
AddCSLuaFile("shared/Workarounds.lua")

DB = DB or {}
GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

-- sv_alltalk must be 0
-- Note, everyone will STILL hear everyone UNLESS rp_voiceradius is 1!!!
-- This will fix the rp_voiceradius not working
game.ConsoleCommand("sv_alltalk 0\n")

include("config/_MySQL.lua")
include("config/config.lua")
include("config/licenseweapons.lua")

include("sh_interfaceloader.lua")

include("server/admincc.lua")

include("shared/player_class.lua")
include("shared/animations.lua")
include("shared/commands.lua")
include("shared/entity.lua")

include("shared/MakeThings.lua")
include("shared/Workarounds.lua")

include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")

include("server/database.lua")
MySQLite.initialize()
include("server/data.lua")
include("server/gamemode_functions.lua")
include("server/main.lua")
include("server/player.lua")
include("server/questions.lua")
include("server/util.lua")
include("server/votes.lua")

/*---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------*/
local fol = GM.FolderName.."/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
for k,v in pairs(files) do
	if GM.Config.DisabledModules[k] then continue end

	include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
	if folder ~= "." and folder ~= ".." and not GM.Config.DisabledModules[folder] then
		for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
			if File == "sh_interface.lua" then continue end

			AddCSLuaFile(fol..folder .. "/" ..File)

			if File == "sh_interface.lua" then continue end
			include(fol.. folder .. "/" ..File)
		end

		for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
			if File == "sv_interface.lua" then continue end
			include(fol.. folder .. "/" ..File)
		end

		for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
			if File == "cl_interface.lua" then continue end
			AddCSLuaFile(fol.. folder .. "/" ..File)
		end
	end
end

DarkRP.finish()
