-- How to use:
-- Use rp_afk_demote 1 to enable AFK mode.
-- Use rp_afk_demotetime to set the time someone has to be AFK before they are demoted.
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed/vote demoted though!).
-- If a player does not use /afk, and they don't do anything for the demote time specified, they will be automatically demoted to hobo.

AddCSLuaFile(GM.FolderName.."/gamemode/modules/afk/cl_afk.lua")
GM.Config.afkdemote = false
GM.Config.afkdemotetime = 600

local function AFKDemote(ply)
	local rpname = ply.DarkRPVars.rpname

	if ply:Team() ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN, true)
		ply:SetSelfDarkRPVar("AFKDemoted", true)
		GAMEMODE:NotifyAll(0, 5, rpname .. " has been demoted for being AFK for too long.")
	end
	ply:SetDarkRPVar("job", "AFK")
end

local function SetAFK(ply)
	local rpname = ply.DarkRPVars.rpname
	ply:SetSelfDarkRPVar("AFK", not ply.DarkRPVars.AFK)

	umsg.Start("DarkRPEffects", ply)
		umsg.String("colormod")
		umsg.String(ply.DarkRPVars.AFK and "1" or "0")
	umsg.End()

	if ply.DarkRPVars.AFK then
		DB.RetrieveSalary(ply, function(amount) ply.OldSalary = amount end)
		ply.OldJob = ply.DarkRPVars.job
		GAMEMODE:NotifyAll(0, 5, rpname .. " is now AFK.")

		-- NPC code partially by _Undefined
		local npc = ents.Create("npc_citizen")
		npc:SetPos(ply:GetPos())
		npc:SetAngles(ply:GetAngles())
		npc:SetModel(ply:GetModel())
		npc:Spawn()
		npc:Activate()
		npc:SetNPCState(NPC_STATE_ALERT)
		npc:IdleSound()
		npc:CapabilitiesAdd(bit.bor(CAP_USE, CAP_OPEN_DOORS))
		for _,v in pairs(ents.FindByClass("prop_physics")) do npc:AddEntityRelationship(v, D_LI, 99) end
		for _,v in pairs(player.GetAll()) do if v == ply then npc:AddEntityRelationship(v, D_FR, 99) npc:SetEnemy(v) end end
		ply.AFKNpc = npc
		npc.Owner = ply
		npc.OwnerID = ply:SteamID()
		npc.AFKPly = ply
		if IsValid(ply:GetActiveWeapon()) then npc:Give(ply:GetActiveWeapon():GetClass()) end
		npc:SetHealth(ply:Health())
		npc:SetNoDraw(false)
		ply:SetNoDraw(true)
		ply:SetPos(Vector(0,0,-5000))
		hook.Add("PlayerDeath", ply:EntIndex().."DRPNPCDeath", function(ply)
			if not IsValid( ply.AFKNpc ) then hook.Remove("PlayerDeath", ply:EntIndex().."DRPNPCDeath") return end
			ply:SetEyeAngles(ply.AFKNpc:EyeAngles())
			ply.AFKNpc:Remove()
			hook.Remove("PlayerDeath", ply:EntIndex().."DRPNPCDeath")
		end)
		hook.Add("PlayerDisconnected", ply:EntIndex().."DRPNPCDisconnect", function(ply)
			SafeRemoveEntity(ply.AFKNpc)
			hook.Remove("PlayerDisconnected", ply:EntIndex().."DRPNPCDisconnect")
		end)
	else
		GAMEMODE:NotifyAll(1, 5, rpname .. " is no longer AFK.")
		GAMEMODE:Notify(ply, 0, 5, "Welcome back, your salary has now been restored.")
		if IsValid(ply.AFKNpc) then
			ply:SetEyeAngles(ply.AFKNpc:EyeAngles())
			ply:SetPos(ply.AFKNpc:GetPos() + ply.AFKNpc:GetAimVector() * 10)
			ply.AFKNpc:Remove()
		end
		ply:SetNoDraw(false)

		hook.Remove("PlayerDisconnected", ply:EntIndex().."DRPNPCDisconnect")
		hook.Remove("PlayerDeath", ply:EntIndex().."DRPNPCDeath")
	end
	ply:SetDarkRPVar("job", ply.DarkRPVars.AFK and "AFK" or ply.OldJob)
	ply.DarkRPVars.salary = ply.DarkRPVars.AFK and 0 or ply.OldSalary or 0
end

local function StartAFKOnPlayer(ply)
	local demotetime
	if not GAMEMODE.Config.afkdemote then
		demotetime = math.huge
	else
		demotetime = GAMEMODE.Config.afkdemotetime
	end
	ply.AFKDemote = CurTime() + demotetime
end
hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", StartAFKOnPlayer)

local function ToggleAFK(ply)
	if not GAMEMODE.Config.afkdemote then
		GAMEMODE:Notify( ply, 1, 5, "AFK mode is disabled.")
		return ""
	end

	SetAFK(ply)
	return ""
end
AddChatCommand("/afk", ToggleAFK)

local function AFKTimer(ply, key)
	if not GAMEMODE.Config.afkdemote then return end
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
	if ply.DarkRPVars.AFKDemoted then
		ply:SetDarkRPVar("job", "Citizen")
		timer.Simple(3, function() ply:SetSelfDarkRPVar("AFKDemoted", false) end)
	end
end
hook.Add("KeyPress", "DarkRPKeyReleasedCheck", AFKTimer)

local function KillAFKTimer()
	for id, ply in pairs(player.GetAll()) do
		if ply.AFKDemote and CurTime() > ply.AFKDemote and not ply.DarkRPVars.AFK then
			SetAFK(ply)
			AFKDemote(ply)
			ply.AFKDemote = math.huge
		end
	end
end
hook.Add("Think", "DarkRPKeyPressedCheck", KillAFKTimer)

local function DamagePlayer(target, DmgInfo)
	if target:IsNPC() and IsValid(target.AFKPly) then
		target.AFKPly:TakeDamageInfo(DmgInfo)
	end
end
hook.Add("EntityTakeDamage", "AFKDamage", DamagePlayer)