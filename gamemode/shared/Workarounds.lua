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

-- Clientside part
if CLIENT then
	/*---------------------------------------------------------------------------
	Vehicle fix for datastream from Tobba
	---------------------------------------------------------------------------*/
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
	Generic InitPostEntity workarounds
	---------------------------------------------------------------------------*/
	hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
		if hook.GetTable().HUDPaint then hook.Remove("HUDPaint","drawHudVital") end -- Removes the white flashes when the server lags and the server has flashbang. Workaround because it's been there for fucking years
	end)

	return
end

-- Serverside part
/*---------------------------------------------------------------------------
Fix the gmod cleanup
---------------------------------------------------------------------------*/

local function IsValidCleanup(class)
	return table.HasValue(cleanup.GetTable(), class)
end

concommand.Add("gmod_admin_cleanup", function(pl, command, args)
	if not pl:IsAdmin() then return end
	if not args[1] then
		for k,v in pairs(ents.GetAll()) do
			if v.Owner and not v:IsWeapon() then -- DarkRP entities have the Owner part of their table as nil.
				v:Remove()
			end
		end
		if GAMEMODE.NotifyAll then GAMEMODE:NotifyAll(0, 4, pl:Nick() .. " cleaned up everything.") end
	end

	if not IsValidCleanup(args[1]) then return end

	for k, v in pairs(ents.FindByClass(args[1])) do
		v:Remove()
	end
	if GAMEMODE.NotifyAll then GAMEMODE:NotifyAll(0, 4, pl:Nick() .. " cleaned up all " .. args[1]) end
end)

/*---------------------------------------------------------------------------
Assmod makes previously banned people able to noclip. I say fuck you.
---------------------------------------------------------------------------*/
hook.Add("PlayerNoClip", "DarkRP_FuckAss", function(ply)
	if LevelToString and string.lower(LevelToString(ply:GetNWInt("ASS_isAdmin"))) == "banned" then -- Assmod's bullshit
		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				GAMEMODE:TalkToPerson(v, Color(255,0,0,255), "WARNING", Color(0,0,255,255), "If DarkRP didn't intervene, assmod would have given a banned user noclip access.\nGet rid of assmod, it's a piece of shit.", ply)
			end
		end
		return false
	end
end)

/*---------------------------------------------------------------------------
Generic InitPostEntity workarounds
---------------------------------------------------------------------------*/
hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
	game.ConsoleCommand("durgz_witty_sayings 0\n") -- Deals with the cigarettes exploit. I'm fucking tired of them. I hate having to fix other people's mods, but this mod maker is retarded and refuses to update his mod.
end)

/*---------------------------------------------------------------------------
Anti map spawn kill (like in rp_downtown_v4c)
this is the only way I could find.
---------------------------------------------------------------------------*/
hook.Add("PlayerSpawn", "AntiMapKill", function(ply)
	timer.Simple(0, function()
		if not ply:Alive() then
			ply:Spawn()
			ply:AddDeaths(-1)
		end
	end)
end)

/*---------------------------------------------------------------------------
Wire field generator exploit
---------------------------------------------------------------------------*/
hook.Add("OnEntityCreated", "DRP_WireFieldGenerator", function(ent)
	timer.Simple(0, function(ent)
		if ValidEntity(ent) and ent:GetClass() == "gmod_wire_field_device" then
			local TriggerInput = ent.TriggerInput
			function ent:TriggerInput(iname, value)
				if value ~= nil and iname == "Distance" then
					value = math.Min(value, 400);
				end
				pcall(TriggerInput(self, iname, value)) -- Don't let wiremod errors ruin my beautiful hook.
			end
		end
	end, ent)
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
	if ValidEntity(ent) then
		constraint.RemoveAll(ent)
	end
end)