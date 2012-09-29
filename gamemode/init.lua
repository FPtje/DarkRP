GM.Version = "2.4.2"
GM.Name = "DarkRP "..GM.Version
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion, Drakehawke"

CUR = "$"

-- Checking if counterstrike is installed correctly
local foundCSS = false
for k,v in pairs(GetMountedContent()) do
	if v == "cstrike" then
		foundCSS = true
		break
	end
end

if not foundCSS then
	timer.Create("TheresNoCSS", 10, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("Counter Strike: Source is incorrectly installed!")
			v:ChatPrint("You need it for DarkRP to work!")
			print("Counter Strike: Source is incorrectly installed!\nYou need it for DarkRP to work!")
		end
	end)
end

-- RP Name Overrides

local meta = FindMetaTable("Player")
meta.SteamName = meta.Name
meta.Name = function(self)
	if not ValidEntity(self) then return "" end
	if GetConVarNumber("allowrpnames") == 1 then
		self.DarkRPVars = self.DarkRPVars or {}
		return self.DarkRPVars.rpname and tostring(self.DarkRPVars.rpname) or self:SteamName()
	else
		return self:SteamName()
	end
end
meta.Nick = meta.Name
meta.GetName = meta.Name
-- End

DeriveGamemode("sandbox")

AddCSLuaFile("addentities.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("ammotypes.lua")
AddCSLuaFile("cl_init.lua")

AddCSLuaFile("client/DRPDermaSkin.lua")
AddCSLuaFile("client/help.lua")
AddCSLuaFile("client/helpvgui.lua")
AddCSLuaFile("client/hud.lua")
AddCSLuaFile("client/showteamtabs.lua")
AddCSLuaFile("client/vgui.lua")

AddCSLuaFile("shared/animations.lua")
AddCSLuaFile("shared/commands.lua")
AddCSLuaFile("shared/entity.lua")
AddCSLuaFile("shared/language.lua")
AddCSLuaFile("shared/MakeThings.lua")
AddCSLuaFile("shared/Workarounds.lua")

-- Earthquake Mod addon
resource.AddFile("sound/earthquake.mp3")
util.PrecacheSound("earthquake.mp3")


DB = {}

-- sv_alltalk must be 0
-- Note, everyone will STILL hear everyone UNLESS rp_voiceradius is 1!!!
-- This will fix the rp_voiceradius not working
game.ConsoleCommand("sv_alltalk 0\n")

include("_MySQL.lua")

include("server/chat.lua")
include("server/admincc.lua")

include("shared/animations.lua")
include("shared/commands.lua")
include("shared/entity.lua")

include("shared/language.lua")
include("shared/MakeThings.lua")
include("shared/Workarounds.lua")

include("shared.lua")
include("addentities.lua")
include("ammotypes.lua")

include("server/data.lua")
include("server/gamemode_functions.lua")
include("server/main.lua")
include("server/player.lua")
include("server/questions.lua")
include("server/util.lua")
include("server/votes.lua")


-- Falco's prop protection
local BlockedModelsExist = sql.QueryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS;") ~= false
if not BlockedModelsExist then
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_BLOCKEDMODELS('model' TEXT NOT NULL PRIMARY KEY);")
	include("FPP/FPP_DefaultBlockedModels.lua") -- Load the default blocked models
end
AddCSLuaFile("FPP/sh_CPPI.lua")
AddCSLuaFile("FPP/sh_settings.lua")
AddCSLuaFile("FPP/client/FPP_Menu.lua")
AddCSLuaFile("FPP/client/FPP_HUD.lua")
AddCSLuaFile("FPP/client/FPP_Buddies.lua")
AddCSLuaFile("shared/FAdmin_DarkRP.lua")

include("FPP/sh_settings.lua")
include("FPP/sh_CPPI.lua")
include("FPP/server/FPP_Settings.lua")
include("FPP/server/FPP_Core.lua")
include("FPP/server/FPP_Antispam.lua")
include("shared/FAdmin_DarkRP.lua")

local files = file.Find("gamemodes/"..GM.FolderName.."/gamemode/modules/*.lua", true)
for k, v in pairs(files) do
	include("modules/" .. v)
end

local function GetAvailableVehicles(ply)
	if not ply:IsAdmin() then return end
	ServerLog("Available vehicles for custom vehicles:")
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(list.Get("Vehicles")) do
		ServerLog("\""..k.."\"")
		print("\""..k.."\"")
	end
end
concommand.Add("rp_getvehicles_sv", GetAvailableVehicles)

-- Vehicle fix from tobba!
function debug.getupvalues(f)
	local t, i, k, v = {}, 1, debug.getupvalue(f, 1)
	while k do
		t[k] = v
		i = i+1
		k,v = debug.getupvalue(f, i)
	end
	return t
end

glon.encode_types = debug.getupvalues(glon.Write).encode_types
glon.encode_types["Vehicle"] = glon.encode_types["Vehicle"] or {10, function(o)
		return (ValidEntity(o) and o:EntIndex() or -1).."\1"
	end}

/*---------------------------------------------------------------------------
Registering numpad data
---------------------------------------------------------------------------*/
local oldNumpadUp = numpad.OnUp
local oldNumpadDown = numpad.OnDown

function numpad.OnUp(ply, key, name, ent, ...)
	numpad.OnUpItems = numpad.OnUpItems or {}
	table.insert(numpad.OnUpItems, {ply = ply, key = key, name = name, ent = ent, arg = {...}})

	return oldNumpadUp(ply, key, name, ent, ...)
end

function numpad.OnDown(ply, key, name, ent, ...)
	numpad.OnDownItems = numpad.OnDownItems or {}
	table.insert(numpad.OnDownItems, {ply = ply, key = key, name = name, ent = ent, arg = {...}})

	return oldNumpadDown(ply, key, name, ent, ...)
end