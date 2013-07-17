GM.Version = "2.5.0"
GM.Name = "DarkRP"
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion, Drakehawke"

DeriveGamemode("sandbox")

AddCSLuaFile("libraries/interfaceloader.lua")
AddCSLuaFile("libraries/fn.lua")

AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")
AddCSLuaFile("config/ammotypes.lua")

AddCSLuaFile("cl_init.lua")

AddCSLuaFile("shared/player_class.lua")
AddCSLuaFile("shared/animations.lua")
AddCSLuaFile("shared/commands.lua")
AddCSLuaFile("shared/entity.lua")
AddCSLuaFile("shared/MakeThings.lua")
AddCSLuaFile("shared/Workarounds.lua")

DB = DB or {}
GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

include("libraries/interfaceloader.lua")

include("shared/MakeThings.lua")
include("shared/Workarounds.lua")

include("config/_MySQL.lua")
include("config/config.lua")
include("config/licenseweapons.lua")
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")

include("libraries/fn.lua")
include("libraries/database.lua")

include("shared/player_class.lua")
include("shared/animations.lua")
include("shared/commands.lua")
include("shared/entity.lua")

include("server/gamemode_functions.lua")
include("server/main.lua")
include("server/player.lua")
include("server/util.lua")

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

MySQLite.initialize()

DarkRP.finish()
