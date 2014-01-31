AddCSLuaFile("pp/sh_cppi.lua")
AddCSLuaFile("pp/sh_settings.lua")
AddCSLuaFile("pp/client/menu.lua")
AddCSLuaFile("pp/client/hud.lua")
AddCSLuaFile("pp/client/buddies.lua")

include("pp/sh_settings.lua")
include("pp/sh_cppi.lua")
include("pp/server/settings.lua")
include("pp/server/core.lua")
include("pp/server/antispam.lua")

hook.Add("DatabaseInitialized", "FPPInit", function()
	MySQLite.query("CREATE TABLE IF NOT EXISTS FPP_BLOCKEDMODELS1(model VARCHAR(140) NOT NULL PRIMARY KEY);", function()
		MySQLite.queryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS1;", function(modelCount)
			if modelCount and tonumber(modelCount) > 0 then return end

			include("darkrp/gamemode/modules/fpp/pp/sv_defaultblockedmodels.lua")
		end)
	end)

	FPP.Init()
end)

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
