-- How to use:
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed/vote demoted though!).
-- If a player does not use /afk, and they don't do anything for the demote time specified, they will be automatically demoted to hobo.

local function AFKDemote(ply)
	local shouldDemote, demoteTeam, suppressMsg, msg = hook.Call("playerAFKDemoted", nil, ply);
	demoteTeam = demoteTeam or GAMEMODE.DefaultTeam

	if ply:Team() ~= demoteTeam and shouldDemote ~= false then
		local rpname = ply:getfprpVar("rpname");
		ply:changeTeam(demoteTeam, true);
		if not suppressMsg then fprp.notifyAll(0, 5, msg or fprp.getPhrase("hes_afk_demoted", rpname)) end
	end
	ply:setSelffprpVar("AFKDemoted", true);
	ply:setfprpVar("job", "AFK");
end

local function SetAFK(ply)
	local rpname = ply:getfprpVar("rpname");
	ply:setSelffprpVar("AFK", not ply:getfprpVar("AFK"));

	SendUserMessage("blackScreen", ply, ply:getfprpVar("AFK"));

	if ply:getfprpVar("AFK") then
		fprp.retrieveSalary(ply, function(amount) ply.OldSalary = amount end)
		ply.OldJob = ply:getfprpVar("job");
		ply.lastHealth = ply:Health();
		fprp.notifyAll(0, 5, fprp.getPhrase("player_now_afk", rpname));

		ply.AFKDemote = math.huge

		ply:KillSilent();
		ply:Lock();
	else
		ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
		fprp.notifyAll(1, 5, fprp.getPhrase("player_no_longer_afk", rpname));
		fprp.notify(ply, 0, 5, fprp.getPhrase("salary_restored"));
		ply:Spawn();
		ply:UnLock();

		ply:SetHealth(ply.lastHealth or 100);
		ply.lastHealth = nil
	end
	ply:setfprpVar("job", ply:getfprpVar("AFK") and "AFK" or ply:getfprpVar("AFKDemoted") and team.GetName(ply:Team()) or ply.OldJob);
	ply:setSelffprpVar("salary", ply:getfprpVar("AFK") and 0 or ply.OldSalary or 0);

	hook.Run("playerSetAFK", ply, ply:getfprpVar("AFK"));
end

fprp.defineChatCommand("afk", function(ply)
	if ply.fprpLastAFK and not ply:getfprpVar("AFK") and ply.fprpLastAFK > CurTime() - GAMEMODE.Config.AFKDelay then
		fprp.notify(ply, 0, 5, fprp.getPhrase("unable", "go AFK", "Spam prevention."));
		return ""
	end

	ply.fprpLastAFK = CurTime();
	SetAFK(ply);

	return ""
end);

local function StartAFKOnPlayer(ply)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
end
hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", StartAFKOnPlayer);

local function AFKTimer(ply, key)
	ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
	if ply:getfprpVar("AFKDemoted") then
		ply:setfprpVar("job", team.GetName(ply:Team()));
		timer.Simple(3, function() ply:setSelffprpVar("AFKDemoted", nil) end)
	end
end
hook.Add("KeyPress", "fprpKeyReleasedCheck", AFKTimer);

local function KillAFKTimer()
	for id, ply in pairs(player.GetAll()) do
		if ply.AFKDemote and CurTime() > ply.AFKDemote and not ply:getfprpVar("AFK") then
			SetAFK(ply);
			AFKDemote(ply);
			ply.AFKDemote = math.huge
		end
	end
end
hook.Add("Think", "fprpKeyPressedCheck", KillAFKTimer);

local function BlockAFKTeamChange(ply, t, force)
	if ply:getfprpVar("AFK") and (not force or t ~= GAMEMODE.DefaultTeam) then
		local TEAM = RPExtraTeams[t]
		if TEAM then fprp.notify(ply, 1, 4, fprp.getPhrase("unable", GAMEMODE.Config.chatCommandPrefix .. TEAM.command, fprp.getPhrase("afk_mode"))) end
		return false
	end
end
hook.Add("playerCanChangeTeam", "AFKCanChangeTeam", BlockAFKTeamChange);
