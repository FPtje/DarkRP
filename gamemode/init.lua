hook.Run("DarkRPStartedLoading")

GM.Version = "2.7.0"
GM.Name = "DarkRP"
GM.Author = "By FPtje Falco et al."

DeriveGamemode("sandbox")
DEFINE_BASECLASS("gamemode_sandbox")

GM.Sandbox = BaseClass


AddCSLuaFile("libraries/sh_cami.lua")
AddCSLuaFile("libraries/simplerr.lua")
AddCSLuaFile("libraries/interfaceloader.lua")
AddCSLuaFile("libraries/modificationloader.lua")
AddCSLuaFile("libraries/disjointset.lua")
AddCSLuaFile("libraries/fn.lua")
AddCSLuaFile("libraries/tablecheck.lua")

AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")
AddCSLuaFile("config/ammotypes.lua")
AddCSLuaFile("config/licenseweapons.lua")

AddCSLuaFile("cl_init.lua")

GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

include("libraries/interfaceloader.lua")

include("config/_MySQL.lua")
include("config/config.lua")
include("config/licenseweapons.lua")

include("libraries/fn.lua")
include("libraries/tablecheck.lua")
include("libraries/sh_cami.lua")
include("libraries/simplerr.lua")
include("libraries/modificationloader.lua")
include("libraries/mysqlite/mysqlite.lua")
include("libraries/disjointset.lua")

resource.AddFile("materials/vgui/entities/arrest_stick.vmt")
resource.AddFile("materials/vgui/entities/door_ram.vmt")
resource.AddFile("materials/vgui/entities/keys.vmt")
resource.AddFile("materials/vgui/entities/lockpick.vmt")
resource.AddFile("materials/vgui/entities/ls_sniper.vmt")
resource.AddFile("materials/vgui/entities/med_kit.vmt")
resource.AddFile("materials/vgui/entities/pocket.vmt")
resource.AddFile("materials/vgui/entities/stunstick.vmt")
resource.AddFile("materials/vgui/entities/unarrest_stick.vmt")
resource.AddFile("materials/vgui/entities/weapon_ak472.vmt")
resource.AddFile("materials/vgui/entities/weapon_deagle2.vmt")
resource.AddFile("materials/vgui/entities/weapon_fiveseven2.vmt")
resource.AddFile("materials/vgui/entities/weapon_glock2.vmt")
resource.AddFile("materials/vgui/entities/weapon_keypadchecker.vmt")
resource.AddFile("materials/vgui/entities/weapon_m42.vmt")
resource.AddFile("materials/vgui/entities/weapon_mac102.vmt")
resource.AddFile("materials/vgui/entities/weapon_mp52.vmt")
resource.AddFile("materials/vgui/entities/weapon_p2282.vmt")
resource.AddFile("materials/vgui/entities/weapon_pumpshotgun2.vmt")
resource.AddFile("materials/vgui/entities/weaponchecker.vmt")


hook.Call("DarkRPPreLoadModules", GM)


--[[---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------]]
local fol = GM.FolderName .. "/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
local SortedPairs = SortedPairs

for _, v in ipairs(files) do
    if DarkRP.disabledDefaults["modules"][v:Left(-5)] then continue end
    if string.GetExtensionFromFilename(v) ~= "lua" then continue end
    include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
    if folder == "." or folder == ".." or DarkRP.disabledDefaults["modules"][folder] then continue end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
        if File == "sh_interface.lua" then continue end
        AddCSLuaFile(fol .. folder .. "/" .. File)
        include(fol .. folder .. "/" .. File)
    end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
        if File == "sv_interface.lua" then continue end
        include(fol .. folder .. "/" .. File)
    end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
        if File == "cl_interface.lua" then continue end
        AddCSLuaFile(fol .. folder .. "/" .. File)
    end
end


DarkRP.DARKRP_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
DarkRP.DARKRP_LOADING = nil

DarkRP.finish()

hook.Call("DarkRPFinishedLoading", GM)
MySQLite.initialize()
