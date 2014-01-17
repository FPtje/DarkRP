-- How to use:
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed/vote demoted though!).
-- If a player does not use /afk, and they don't do anything for the demote time specified, they will be automatically demoted to hobo.

function AFKDemote(ply)
	local shouldDemote, demoteTeam, suppressMsg, msg = hook.Call("playerAFKDemoted", nil, ply)
	demoteTeam = demoteTeam or GAMEMODE.DefaultTeam

	if ply:Team() ~= demoteTeam and shouldDemote ~= false then
		local rpname = ply:getDarkRPVar("rpname")
		ply:changeTeam(demoteTeam, true)
		if not suppressMsg then DarkRP.notifyAll(0, 5, msg or DarkRP.getPhrase("hes_afk_demoted", rpname)) end
	end
	ply:setSelfDarkRPVar("AFKDemoted", true)
	ply:setDarkRPVar("job", "AFK")
end

local function SetAFK(ply)
	local rpname = ply:getDarkRPVar("rpname")
	ply:setSelfDarkRPVar("AFK", not ply:getDarkRPVar("AFK"))

	SendUserMessage("blackScreen", ply, ply:getDarkRPVar("AFK"))

	if ply:getDarkRPVar("AFK") then
		DarkRP.retrieveSalary(ply, function(amount) ply.OldSalary = amount end)
		ply.OldJob = ply:getDarkRPVar("job")
		DarkRP.notifyAll(0, 5, DarkRP.getPhrase("player_now_afk", rpname))

		ply.AFKDemote = math.huge

		ply:KillSilent()
		ply:Lock()
	else
		ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
		DarkRP.notifyAll(1, 5, DarkRP.getPhrase("player_no_longer_afk", rpname))
		DarkRP.notify(ply, 0, 5, DarkRP.getPhrase("salary_restored", rpname))
		ply:Spawn()
		ply:UnLock()
	end
	ply:setDarkRPVar("job", ply:getDarkRPVar("AFK") and "AFK" or ply:getDarkRPVar("AFKDemoted") and team.GetName(ply:Team()) or ply.OldJob)
	ply:setDarkRPVar("salary", ply:getDarkRPVar("AFK") and 0 or ply.OldSalary or 0)
end
DarkRP.defineChatCommand("afk", SetAFK)

local function StartAFKOnPlayer(ply)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
end
hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", StartAFKOnPlayer)

local function AFKTimer(ply, key)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
	if ply:getDarkRPVar("AFKDemoted") then
		ply:setDarkRPVar("job", team.GetName(ply:Team()))
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

local function BlockAFKTeamChange(ply, t, force)
	if ply:getDarkRPVar("AFK") and (not force or t ~= GAMEMODE.DefaultTeam) then
		local TEAM = RPExtraTeams[t]
		if TEAM then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", GAMEMODE.Config.chatCommandPrefix .. TEAM.command, DarkRP.getPhrase("afk_mode"))) end
		return false
	end
end
hook.Add("playerCanChangeTeam", "AFKCanChangeTeam", BlockAFKTeamChange)
