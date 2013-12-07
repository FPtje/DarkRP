/*---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")
function meta:changeTeam(t, force)
	local prevTeam = self:Team()

	if self:isArrested() and not force then
		DarkRP.notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), ""))
		return false
	end

	self:setDarkRPVar("agenda", nil)

	if t ~= GAMEMODE.DefaultTeam and not self:changeAllowed(t) and not force then
		DarkRP.notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), "banned/demoted"))
		return false
	end

	if self.LastJob and 10 - (CurTime() - self.LastJob) >= 0 and not force then
		DarkRP.notify(self, 1, 4, DarkRP.getPhrase("have_to_wait",  math.ceil(10 - (CurTime() - self.LastJob)), "/job"))
		return false
	end

	if self.IsBeingDemoted then
		self:teamBan()
		self.IsBeingDemoted = false
		self:changeTeam(GAMEMODE.DefaultTeam, true)
		DarkRP.destroyVotesWithEnt(self)
		DarkRP.notify(self, 1, 4, DarkRP.getPhrase("tried_to_avoid_demotion"))

		return false
	end


	if prevTeam == t then
		DarkRP.notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), ""))
		return false
	end

	local TEAM = RPExtraTeams[t]
	if not TEAM then return false end

	if TEAM.customCheck and not TEAM.customCheck(self) then
		DarkRP.notify(self, 1, 4, TEAM.CustomCheckFailMsg or DarkRP.getPhrase("unable", team.GetName(t), ""))
		return false
	end

	if not self.DarkRPVars["Priv"..TEAM.command] and not force then
		if type(TEAM.NeedToChangeFrom) == "number" and prevTeam ~= TEAM.NeedToChangeFrom then
			DarkRP.notify(self, 1,4, DarkRP.getPhrase("need_to_be_before", team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return false
		elseif type(TEAM.NeedToChangeFrom) == "table" and not table.HasValue(TEAM.NeedToChangeFrom, prevTeam) then
			local teamnames = ""
			for a,b in pairs(TEAM.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
			DarkRP.notify(self, 1,4, string.format(string.sub(teamnames, 5), team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return false
		end
		local max = TEAM.max
		if max ~= 0 and -- No limit
		(max >= 1 and team.NumPlayers(t) >= max or -- absolute maximum
		max < 1 and (team.NumPlayers(t) + 1) / #player.GetAll() > max) then -- fractional limit (in percentages)
			DarkRP.notify(self, 1, 4,  DarkRP.getPhrase("team_limit_reached", TEAM.name))
			return false
		end
	end

	if TEAM.PlayerChangeTeam then
		local val = TEAM.PlayerChangeTeam(self, prevTeam, t)
		if val ~= nil then
			return val
		end
	end

	local hookValue = hook.Call("playerCanChangeTeam", nil, self, t, force)
	if hookValue == false then return false end

	local isMayor = RPExtraTeams[prevTeam] and RPExtraTeams[prevTeam].mayor
	if isMayor and tobool(GetConVarNumber("DarkRP_LockDown")) then
		DarkRP.unLockdown(self)
	end
	self:updateJob(TEAM.name)
	self:setSelfDarkRPVar("salary", TEAM.salary)
	DarkRP.notifyAll(0, 4, DarkRP.getPhrase("job_has_become", self:Nick(), TEAM.name))


	if self:getDarkRPVar("HasGunlicense") then
		self:setDarkRPVar("HasGunlicense", false)
	end
	if TEAM.hasLicense and GAMEMODE.Config.license then
		self:setDarkRPVar("HasGunlicense", true)
	end

	self.LastJob = CurTime()

	if GAMEMODE.Config.removeclassitems then
		for k, v in pairs(ents.FindByClass("microwave")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end
		for k, v in pairs(ents.FindByClass("gunlab")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end

		for k, v in pairs(ents.FindByClass("drug_lab")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end

		for k,v in pairs(ents.FindByClass("spawned_shipment")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end
	end

	if isMayor then
		for _, ent in pairs(self.lawboards or {}) do
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end

	self:SetTeam(t)
	hook.Call("OnPlayerChangedTeam", GAMEMODE, self, prevTeam, t)
	DarkRP.log(self:Nick().." ("..self:SteamID()..") changed to "..team.GetName(t), nil, Color(100, 0, 255))
	if self:InVehicle() then self:ExitVehicle() end
	if GAMEMODE.Config.norespawn and self:Alive() then
		self:StripWeapons()
		local vPoint = self:GetShootPos() + Vector(0,0,50)
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetStart( vPoint ) -- Not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale(1)
		util.Effect("entity_remove", effectdata)
		hook.Call("UpdatePlayerSpeed", GAMEMODE, self)
		GAMEMODE:PlayerSetModel(self)
		GAMEMODE:PlayerLoadout(self)
	else
		self:KillSilent()
	end

	umsg.Start("OnChangedTeam", self)
		umsg.Short(prevTeam)
		umsg.Short(t)
	umsg.End()
	return true
end

function meta:updateJob(job)
	self:setDarkRPVar("job", job)

	timer.Create(self:UniqueID() .. "jobtimer", GAMEMODE.Config.paydelay, 0, function()
		if not IsValid(self) then return end
		self:payDay()
	end)
end

function meta:teamUnBan(Team)
	if not IsValid(self) then return end
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[Team] = 0
end

function meta:teamBan(t, time)
	if not self.bannedfrom then self.bannedfrom = {} end
	t = t or self:Team()
	self.bannedfrom[t] = 1

	if time == 0 then return end
	timer.Simple(time or GAMEMODE.Config.demotetime, function()
		if not IsValid(self) then return end
		self:teamUnBan(t)
	end)
end

function meta:changeAllowed(t)
	if not self.bannedfrom then return true end
	if self.bannedfrom[t] == 1 then return false else return true end
end

/*---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------*/
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
	ply:updateJob(job)
	return ""
end
DarkRP.defineChatCommand("job", ChangeJob)

local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:teamBan()
		if target:Alive() then
			target:changeTeam(GAMEMODE.DefaultTeam, true)
			if target:isArrested() then
				target:arrest()
			end
		else
			target.demotedWhileDead = true
		end

		hook.Call("onPlayerDemoted", nil, vote.info.source, target, vote.info.reason)
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

	local canDemote, message = hook.Call("canDemote", GAMEMODE, ply, p, reason)
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

			DarkRP.createVote(p:Nick() .. ":\n"..DarkRP.getPhrase("demote_vote_text", reason), "demote", p, 20, FinishDemote,
			{
				[p] = true,
				[ply] = true
			}, function(vote)
				if not IsValid(vote.target) then return end
				vote.target.IsBeingDemoted = nil
			end, {source = ply, reason = reason})
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
		return ""
	end
end
DarkRP.defineChatCommand("demote", Demote)

local function ExecSwitchJob(answer, ent, ply, target)
	ply.RequestedJobSwitch = nil
	if not tobool(answer) then return end
	local Pteam = ply:Team()
	local Tteam = target:Team()

	if not ply:changeTeam(Tteam) then return end
	if not target:changeTeam(Pteam) then
		ply:changeTeam(Pteam, true) -- revert job change
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
	DarkRP.createQuestion(DarkRP.getPhrase("job_switch_question", ply:Nick()), "switchjob"..tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("job_switch_requested"))
	return ""
end
DarkRP.defineChatCommand("switchjob", SwitchJob)
DarkRP.defineChatCommand("switchjobs", SwitchJob)
DarkRP.defineChatCommand("jobswitch", SwitchJob)


local function DoTeamBan(ply, args, cmdargs)
	if ply:EntIndex() ~= 0 and not ply:hasDarkRPPrivilege("rp_commands") then
		if cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "/teamban"))
			return
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/teamban"))
			return ""
		end
	end

	if not args or args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "arguments", ""))
		return ""
	end

	if cmdargs and not cmdargs[2] then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("rp_teamban_hint"))
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("rp_teamban_hint"))
		end
		return
	end

	args = cmdargs or string.Explode(" ", args)
	local ent = args[1]
	local Team = args[2]

	local target = DarkRP.findPlayer(ent)
	if not target or not IsValid(target) then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", ent or ""))
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("could_not_find", ent or ""))
			return
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", ent or ""))
			return ""
		end
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
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", Team or ""))
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("could_not_find", Team or ""))
			return
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", Team or ""))
			return ""
		end
	end

	target:teamBan(tonumber(Team), tonumber(args[3] or 0))

	local nick
	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end
	DarkRP.notifyAll(0, 5, DarkRP.getPhrase("x_teambanned_y", nick, target:Nick(), team.GetName(tonumber(Team))))

	return ""
end
DarkRP.defineChatCommand("teamban", DoTeamBan)
concommand.Add("rp_teamban", DoTeamBan)

local function DoTeamUnBan(ply, args, cmdargs)
	if ply:EntIndex() ~= 0 and not ply:hasDarkRPPrivilege("rp_commands") then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/teamunban"))
		return ""
	end

	if not args or args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "arguments", ""))
		return ""
	end

	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[2] then
			if ply:EntIndex() == 0 then
				print(DarkRP.getPhrase("rp_teamunban_hint"))
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("rp_teamunban_hint"))
			end
			return
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
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", ent or ""))
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("could_not_find", ent or ""))
			return
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", ent or ""))
			return ""
		end
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
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", Team or ""))
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("could_not_find", Team or ""))
			return
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", Team or ""))
			return ""
		end
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[tonumber(Team)] = nil

	local nick
	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end
	DarkRP.notifyAll(1, 5, DarkRP.getPhrase("x_teamunbanned_y", nick, target:Nick(), team.GetName(tonumber(Team))))

	return ""
end
DarkRP.defineChatCommand("teamunban", DoTeamUnBan)
concommand.Add("rp_teamunban", DoTeamUnBan)
