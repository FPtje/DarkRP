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

hook.Add("DarkRPDBInitialized", "FPPInit", function()
	FPP.Init()

	-- Migrate database.
	-- Previous versions of the database don't store the default blocked.
	-- Store them now
	if not DarkRP.DBVersion or DarkRP.DBVersion < 20150725 then
		timer.Simple(6, function()
			-- Add all blocked things to default blocked. That way, FillDefaultBlocked will re-add everything
			for typ, v in pairs(FPP.Blocked) do
				for class, _ in pairs(v) do
					FPP.AddDefaultBlocked(typ, class)
				end
			end

			MySQLite.query("DELETE FROM FPP_BLOCKED1", FPP.FillDefaultBlocked)
		end)
	end
end)
