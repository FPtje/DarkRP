-- How to use:
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed/vote demoted though!).
-- If a player does not use /afk, and they don't do anything for the demote time specified, they will be automatically demoted to hobo.

local function AFKDemote(ply)
	local rpname = ply:getDarkRPVar("rpname")

	if ply:Team() ~= GAMEMODE.DefaultTeam then
		ply:changeTeam(GAMEMODE.DefaultTeam, true)
		ply:setSelfDarkRPVar("AFKDemoted", true)
		DarkRP.notifyAll(0, 5, DarkRP.getPhrase("hes_afk_demoted", rpname))
	end
	ply:setDarkRPVar("job", "AFK")
end

local function SetAFK(ply)
	local rpname = ply:getDarkRPVar("rpname")
	ply:setSelfDarkRPVar("AFK", not ply.DarkRPVars.AFK)

	SendUserMessage("blackScreen", ply, ply:getDarkRPVar("AFK"))

	if ply:getDarkRPVar("AFK") then
		DarkRP.retrieveSalary(ply, function(amount) ply.OldSalary = amount end)
		ply.OldJob = ply:getDarkRPVar("job")
		DarkRP.notifyAll(0, 5, DarkRP.getPhrase("player_now_afk", rpname))

		ply:KillSilent()
	else
		DarkRP.notifyAll(1, 5, rpname .. " is no longer AFK.")
		DarkRP.notify(ply, 0, 5, "Welcome back, your salary has now been restored.")
		ply:Spawn()
	end
	ply:setDarkRPVar("job", ply:getDarkRPVar("AFK") and "AFK" or ply.OldJob)
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
		ply:setDarkRPVar("job", team.GetName(GAMEMODE.DefaultTeam))
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
