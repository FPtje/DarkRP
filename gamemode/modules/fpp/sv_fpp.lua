AddCSLuaFile("pp/sh_cppi.lua")
AddCSLuaFile("pp/sh_settings.lua")
AddCSLuaFile("pp/client/menu.lua")
AddCSLuaFile("pp/client/hud.lua")
AddCSLuaFile("pp/client/buddies.lua")
AddCSLuaFile("pp/client/ownability.lua")

include("pp/sh_settings.lua")
include("pp/sh_cppi.lua")
include("pp/server/settings.lua")
include("pp/server/core.lua")
include("pp/server/antispam.lua")
include("pp/server/defaultblockedmodels.lua")
include("pp/server/ownability.lua")

hook.Add("DatabaseInitialized", "FPPInit", FPP.Init)

/*---------------------------------------------------------------------------
DarkRP blocked entities
---------------------------------------------------------------------------*/
local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

FPP.AddDefaultBlocked(blockTypes, "chatindicator")
FPP.AddDefaultBlocked(blockTypes, "darkrp_cheque")
FPP.AddDefaultBlocked(blockTypes, "drug")
FPP.AddDefaultBlocked(blockTypes, "drug_lab")
FPP.AddDefaultBlocked(blockTypes, "fadmin_jail")
FPP.AddDefaultBlocked(blockTypes, "food")
FPP.AddDefaultBlocked(blockTypes, "gunlab")
FPP.AddDefaultBlocked(blockTypes, "letter")
FPP.AddDefaultBlocked(blockTypes, "meteor")
FPP.AddDefaultBlocked(blockTypes, "microwave")
FPP.AddDefaultBlocked(blockTypes, "money_printer")
FPP.AddDefaultBlocked(blockTypes, "spawned_ammo")
FPP.AddDefaultBlocked(blockTypes, "spawned_food")
FPP.AddDefaultBlocked(blockTypes, "spawned_money")
FPP.AddDefaultBlocked(blockTypes, "spawned_shipment")
FPP.AddDefaultBlocked(blockTypes, "spawned_weapon")

FPP.AddDefaultBlocked("Spawning1", "darkrp_laws")
