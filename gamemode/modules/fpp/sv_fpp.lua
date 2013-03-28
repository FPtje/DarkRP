local BlockedModelsExist = sql.QueryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS;") ~= false
if not BlockedModelsExist then
	sql.Query("CREATE TABLE IF NOT EXISTS FPP_BLOCKEDMODELS('model' TEXT NOT NULL PRIMARY KEY);")
	include("pp/FPP_DefaultBlockedModels.lua") -- Load the default blocked models
end

AddCSLuaFile("pp/sh_CPPI.lua")
AddCSLuaFile("pp/sh_settings.lua")
AddCSLuaFile("pp/client/FPP_Menu.lua")
AddCSLuaFile("pp/client/FPP_HUD.lua")
AddCSLuaFile("pp/client/FPP_Buddies.lua")

include("pp/sh_settings.lua")
include("pp/sh_CPPI.lua")
include("pp/server/FPP_Settings.lua")
include("pp/server/FPP_Core.lua")
include("pp/server/FPP_Antispam.lua")


if not RP_MySQLConfig or not RP_MySQLConfig.EnableMySQL then
	FPP.Init()
end

/*---------------------------------------------------------------------------
DarkRP blocked entities
---------------------------------------------------------------------------*/
local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}
FPP.AddDefaultBlocked(blockTypes, "chatindicator")
FPP.AddDefaultBlocked(blockTypes, "darkrp_cheque")
FPP.AddDefaultBlocked(blockTypes, "darkp_console")
FPP.AddDefaultBlocked(blockTypes, "drug")
FPP.AddDefaultBlocked(blockTypes, "drug_lab")
FPP.AddDefaultBlocked(blockTypes, "fadmin_jail")
FPP.AddDefaultBlocked(blockTypes, "food")
FPP.AddDefaultBlocked(blockTypes, "gunlab")
FPP.AddDefaultBlocked(blockTypes, "letter")
FPP.AddDefaultBlocked(blockTypes, "meteor")
FPP.AddDefaultBlocked(blockTypes, "spawned_food")
FPP.AddDefaultBlocked(blockTypes, "spawned_money")
FPP.AddDefaultBlocked(blockTypes, "spawned_shipment")
FPP.AddDefaultBlocked(blockTypes, "spawned_weapon")

FPP.AddDefaultBlocked("Spawning1", "darkrp_laws")