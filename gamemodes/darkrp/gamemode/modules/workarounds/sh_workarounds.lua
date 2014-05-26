-- Shared part
/*---------------------------------------------------------------------------
Sound crash glitch
---------------------------------------------------------------------------*/

local entity = FindMetaTable("Entity")
local EmitSound = entity.EmitSound
function entity:EmitSound(sound, ...)
	if string.find(sound, "??", 0, true) then return end
	return EmitSound(self, sound, ...)
end


function DarkRP.getAvailableVehicles()
	local vehicles = list.Get("Vehicles")
	for k, v in pairs(list.Get("SCarsList") or {}) do
		vehicles[v.PrintName] = {
			Name = v.PrintName,
			Class = v.ClassName,
			Model = v.CarModel
		}
	end

	return vehicles
end

-- Clientside part
if CLIENT then
	/*---------------------------------------------------------------------------
	Generic InitPostEntity workarounds
	---------------------------------------------------------------------------*/
	hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
		if hook.GetTable().HUDPaint then hook.Remove("HUDPaint","drawHudVital") end -- Removes the white flashes when the server lags and the server has flashbang. Workaround because it's been there for fucking years
	end)

	return
end

/*---------------------------------------------------------------------------
SetPos crash
---------------------------------------------------------------------------*/
local oldSetPos = entity.SetPos
function entity:SetPos(vec)
	vec.x = math.Clamp(vec.x, -99999997952, 99999997952)
	vec.y = math.Clamp(vec.y, -99999997952, 99999997952)
	vec.z = math.Clamp(vec.z, -99999997952, 99999997952)

	return oldSetPos(self, vec)
end

/*---------------------------------------------------------------------------
Generic InitPostEntity workarounds
---------------------------------------------------------------------------*/
hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
	game.ConsoleCommand("durgz_witty_sayings 0\n") -- Deals with the cigarettes exploit. I'm fucking tired of them. I hate having to fix other people's mods, but this mod maker is retarded and refuses to update his mod.

	-- Remove ULX /me command. (the /me command is the only thing this hook does)
	hook.Remove("PlayerSay", "ULXMeCheck")
end)

/*---------------------------------------------------------------------------
Anti map spawn kill (like in rp_downtown_v4c)
this is the only way I could find.
---------------------------------------------------------------------------*/
hook.Add("PlayerSpawn", "AntiMapKill", function(ply)
	timer.Simple(0, function()
		if IsValid(ply) and not ply:Alive() then
			ply:Spawn()
			ply:AddDeaths(-1)
		end
	end)
end)

/*---------------------------------------------------------------------------
Wire field generator exploit
---------------------------------------------------------------------------*/
hook.Add("OnEntityCreated", "DRP_WireFieldGenerator", function(ent)
	timer.Simple(0, function()
		if IsValid(ent) and ent:GetClass() == "gmod_wire_field_device" then
			local TriggerInput = ent.TriggerInput
			function ent:TriggerInput(iname, value)
				if value ~= nil and iname == "Distance" then
					value=math.Min(value, 400);
				end
				TriggerInput(self, iname, value)
			end
		end
	end)
end)

/*---------------------------------------------------------------------------
Door tool is shitty
Let's fix that huge class exploit
---------------------------------------------------------------------------*/
hook.Add("InitPostEntity", "FixDoorTool", function()
	local oldFunc = makedoor
	if oldFunc then
		function makedoor(ply,trace,ang,model,open,close,autoclose,closetime,class,hardware, ...)
			if class ~= "prop_dynamic" and class ~= "prop_door_rotating" then return end

			oldFunc(ply,trace,ang,model,open,close,autoclose,closetime,class,hardware, ...)
		end
	end
end)

/*---------------------------------------------------------------------------
Anti crash exploit
---------------------------------------------------------------------------*/
hook.Add("PropBreak", "drp_AntiExploit", function(attacker, ent)
	if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
		constraint.RemoveAll(ent)
	end
end)

local allowedDoors = {
	["prop_dynamic"] = true,
	["prop_door_rotating"] = true,
	[""] = true
}

hook.Add("CanTool", "DoorExploit", function(ply, trace, tool)
	if not IsValid(ply:GetActiveWeapon()) or not ply:GetActiveWeapon().GetToolObject or not ply:GetActiveWeapon():GetToolObject() then return end

	local tool = ply:GetActiveWeapon():GetToolObject()
	if not allowedDoors[string.lower(tool:GetClientInfo("door_class") or "")] then
		return false
	end
end)

/*---------------------------------------------------------------------------
ply:UniqueID calculates the CRC of "gm_"..ply:SteamID().."_gm"
That calculation is slow
---------------------------------------------------------------------------*/
local plyMeta = FindMetaTable("Player")
local oldUID = plyMeta.UniqueID
function plyMeta:UniqueID()
	self.UIDCache = self.UIDCache or oldUID(self)

	return self.UIDCache
end
