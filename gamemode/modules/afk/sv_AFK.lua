-- How to use:
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed/vote demoted though!).
-- If a player does not use /afk, and they don't do anything for the demote time specified, they will be automatically demoted to hobo.

local function AFKDemote(ply)
	local rpname = ply:getDarkRPVar("rpname")

	if ply:Team() ~= GAMEMODE.DefaultTeam then
		ply:ChangeTeam(GAMEMODE.DefaultTeam, true)
		ply:setSelfDarkRPVar("AFKDemoted", true)
		GAMEMODE:NotifyAll(0, 5, rpname .. " has been demoted for being AFK for too long.")
	end
	ply:setDarkRPVar("job", "AFK")
end

local function SetAFK(ply)
	local rpname = ply:getDarkRPVar("rpname")
	ply:setSelfDarkRPVar("AFK", not ply.DarkRPVars.AFK)

	SendUserMessage("blackScreen", ply, ply:getDarkRPVar("AFK"))

	if ply:getDarkRPVar("AFK") then
		DB.RetrieveSalary(ply, function(amount) ply.OldSalary = amount end)
		ply.OldJob = ply:getDarkRPVar("job")
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
		npc:CPPISetOwner(ply)
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
	ply:SetDarkRPVar("job", ply:getDarkRPVar("AFK") and "AFK" or ply.OldJob)
	ply:SetDarkRPVar("salary", ply:getDarkRPVar("AFK") and 0 or ply.OldSalary or 0)
end
DarkRP.addChatCommand("/afk", SetAFK)

local function StartAFKOnPlayer(ply)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
end
hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", StartAFKOnPlayer)

local function AFKTimer(ply, key)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
	if ply:getDarkRPVar("AFKDemoted") then
		ply:SetDarkRPVar("job", team.GetName(GAMEMODE.DefaultTeam))
		timer.Simple(3, function() ply:setSelfDarkRPVar("AFKDemoted", false) end)
	end
end
hook.Add("KeyPress", "DarkRPKeyReleasedCheck", AFKTimer)

local function KillAFKTimer()
	for id, ply in pairs(player.GetAll()) do
		if ply.AFKDemote and CurTime() > ply.AFKDemote and not ply:getDarkRPVar("AFK") then
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
