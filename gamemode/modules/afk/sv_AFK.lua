-- How to use:
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed/vote demoted though!).
-- If a player does not use /afk, and they don't do anything for the demote time specified, they will be automatically demoted to hobo.

local function AFKDemote(ply)
	local rpname = ply:getDarkRPVar("rpname")

	if ply:Team() ~= GAMEMODE.DefaultTeam then
		ply:ChangeTeam(GAMEMODE.DefaultTeam, true)
		ply:SetSelfDarkRPVar("AFKDemoted", true)
		GAMEMODE:NotifyAll(0, 5, rpname .. " has been demoted for being AFK for too long.")
	end
	ply:SetDarkRPVar("job", "AFK")
end

local function SetAFK(ply)
	local rpname = ply:getDarkRPVar("rpname")
	ply:SetSelfDarkRPVar("AFK", not ply:getDarkRPVar("AFK"))

	SendUserMessage("blackScreen", ply, ply:getDarkRPVar("AFK"))

	if ply:getDarkRPVar("AFK") then
		DB.RetrieveSalary(ply, function(amount) ply.OldSalary = amount end)
		ply.OldJob = ply:getDarkRPVar("job")
		GAMEMODE:NotifyAll(0, 5, rpname .. " is now AFK.")

		ply:KillSilent()
		ply:Lock()
	else
		GAMEMODE:NotifyAll(1, 5, rpname .. " is no longer AFK.")
		GAMEMODE:Notify(ply, 0, 5, "Welcome back, your salary has now been restored.")
		ply:Spawn()
		ply:UnLock()
	end
	ply:SetDarkRPVar("job", ply:getDarkRPVar("AFK") and "AFK" or ply.OldJob)
	ply:SetDarkRPVar("salary", ply:getDarkRPVar("AFK") and 0 or ply.OldSalary or 0)
end
AddChatCommand("/afk", SetAFK)

local function StartAFKOnPlayer(ply)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
end
hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", StartAFKOnPlayer)

local function AFKTimer(ply, key)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
	if ply:getDarkRPVar("AFKDemoted") then
		ply:SetDarkRPVar("job", team.GetName(GAMEMODE.DefaultTeam))
		timer.Simple(3, function() ply:SetSelfDarkRPVar("AFKDemoted", false) end)
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
