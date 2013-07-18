local function ChangeJob(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if ply:isArrested() then
		DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("unable", "/job", ""))
		return ""
	end

	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), "/job"))
		return ""
	end
	ply.LastJob = CurTime()

	if not ply:Alive() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/job", ""))
		return ""
	end

	if not GAMEMODE.Config.customjobs then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/job", ""))
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/job", ">2"))
		return ""
	end

	if len > 25 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/job", "<26"))
		return ""
	end

	local canChangeJob, message, replace = hook.Call("canChangeJob", nil, ply, args)
	if canChangeJob == false then
		DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", "/job", ""))
		return ""
	end

	local job = replace or args
	DarkRP.notifyAll(2, 4, DarkRP.getPhrase("job_has_become", ply:Nick(), job))
	ply:UpdateJob(job)
	return ""
end
DarkRP.defineChatCommand("job", ChangeJob)

local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:TeamBan()
		if target:Alive() then
			target:ChangeTeam(GAMEMODE.DefaultTeam, true)
			if target:isArrested() then
				target:arrest()
			end
		else
			target.demotedWhileDead = true
		end

		DarkRP.notifyAll(0, 4, DarkRP.getPhrase("demoted", target:Nick()))
	else
		DarkRP.notifyAll(1, 4, DarkRP.getPhrase("demoted_not", target:Nick()))
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("vote_specify_reason"))
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 99 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demote", "<100"))
		return ""
	end
	local p = DarkRP.findPlayer(tableargs[1])
	if p == ply then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_demote_self"))
		return ""
	end

	local canDemote, message = hook.Call("CanDemote", GAMEMODE, ply, p, reason)
	if canDemote == false then
		DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", "demote", ""))
		return ""
	end

	if p then
		if CurTime() - ply.LastVoteCop < 80 then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"))
			return ""
		end
		if not RPExtraTeams[p:Team()] or RPExtraTeams[p:Team()].candemote == false then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demote", ""))
		else
			DarkRP.talkToPerson(p, team.GetColor(ply:Team()), DarkRP.getPhrase("demote") .. " " ..ply:Nick(),Color(255,0,0,255), DarkRP.getPhrase("i_want_to_demote_you", reason), p)
			DarkRP.notifyAll(0, 4, DarkRP.getPhrase("demote_vote_started", ply:Nick(), p:Nick()))
			DarkRP.log(DarkRP.getPhrase("demote_vote_started", ply:Nick(), p:Nick()) .. " (" .. reason .. ")",
				false, Color(255, 128, 255, 255))
			p.IsBeingDemoted = true

			GAMEMODE.vote:create(p:Nick() .. ":\n"..DarkRP.getPhrase("demote_vote_text", reason), "demote", p, 20, FinishDemote,
			{
				[p] = true,
				[ply] = true
			}, function(vote)
				if not IsValid(vote.target) then return end
				vote.target.IsBeingDemoted = nil
			end)
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
		return ""
	end
end
DarkRP.defineChatCommand("demote", Demote)

local function ExecSwitchJob(answer, ent, ply, target)
	ply.RequestedJobSwitch = nil
	if not tobool(answer) then return end
	local Pteam = ply:Team()
	local Tteam = target:Team()

	if not ply:ChangeTeam(Tteam) then return end
	if not target:ChangeTeam(Pteam) then
		ply:ChangeTeam(Pteam, true) -- revert job change
		return
	end
	DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("job_switch"))
	DarkRP.notify(target, 2, 4, DarkRP.getPhrase("job_switch"))
end

local function SwitchJob(ply) --Idea by Godness.
	if not GAMEMODE.Config.allowjobswitch then return "" end

	if ply.RequestedJobSwitch then return end

	local eyetrace = ply:GetEyeTrace()
	if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return "" end
	ply.RequestedJobSwitch = true
	GAMEMODE.ques:Create(DarkRP.getPhrase("job_switch_question", ply:Nick()), "switchjob"..tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("job_switch_reqested"))
	return ""
end
DarkRP.defineChatCommand("switchjob", SwitchJob)
DarkRP.defineChatCommand("switchjobs", SwitchJob)
DarkRP.defineChatCommand("jobswitch", SwitchJob)


local function DoTeamBan(ply, args, cmdargs)
	if not args or args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "arguments", ""))
		return ""
	end

	args = cmdargs or string.Explode(" ", args)
	local ent = args[1]
	local Team = args[2]
	if cmdargs and not cmdargs[1] then
		ply:PrintMessage(HUD_PRINTNOTIFY, DarkRP.getPhrase("rp_teamban_hint"))
		return
	end

	local target = DarkRP.findPlayer(ent)
	if not target or not IsValid(target) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player!"))
		return ""
	end

	if (not FAdmin or not FAdmin.Access.PlayerHasPrivilege(ply, "rp_commands", target)) and not ply:IsAdmin() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/teamban"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or string.lower(v.command) == string.lower(Team) or k == tonumber(Team or -1) then
			Team = k
			found = true
			break
		end
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "job!"))
		return ""
	end

	target:TeamBan(tonumber(Team), tonumber(args[3] or 0))
	DarkRP.notifyAll(0, 5, DarkRP.getPhrase("x_teambanned_y", ply:Nick(), target:Nick(), team.GetName(tonumber(Team))))
	return ""
end
DarkRP.defineChatCommand("teamban", DoTeamBan)
concommand.Add("rp_teamban", DoTeamBan)

local function DoTeamUnBan(ply, args, cmdargs)
	if not ply:IsAdmin() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/teamunban"))
		return ""
	end

	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, DarkRP.getPhrase("rp_teamunban_hint"))
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args, a + 1)
	end

	local target = DarkRP.findPlayer(ent)
	if not target or not IsValid(target) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player!"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or  string.lower(v.command) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == tonumber(Team or -1) then
			found = true
			break
		end
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "job!"))
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[tonumber(Team)] = nil
	DarkRP.notifyAll(1, 5, DarkRP.getPhrase("x_teamunbanned_y", ply:Nick(), target:Nick(), team.GetName(tonumber(Team))))
	return ""
end
DarkRP.defineChatCommand("teamunban", DoTeamUnBan)
concommand.Add("rp_teamunban", DoTeamUnBan)
