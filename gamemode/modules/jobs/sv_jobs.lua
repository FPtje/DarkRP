/*---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player");
function meta:changeTeam(t, force)
	local prevTeam = self:Team();

	if self:isArrested() and not force then
		fprp.notify(self, 1, 4, fprp.getPhrase("unable", team.GetName(t), ""));
		return false
	end

	if t ~= GAMEMODE.DefaultTeam and not self:changeAllowed(t) and not force then
		fprp.notify(self, 1, 4, fprp.getPhrase("unable", team.GetName(t), "banned/demoted"));
		return false
	end

	if self.LastJob and GAMEMODE.Config.changejobtime - (CurTime() - self.LastJob) >= 0 and not force then
		fprp.notify(self, 1, 4, fprp.getPhrase("have_to_wait",  math.ceil(GAMEMODE.Config.changejobtime - (CurTime() - self.LastJob)), "/job"));
		return false
	end

	if self.IsBeingDemoted then
		self:teamBan();
		self.IsBeingDemoted = false
		self:changeTeam(GAMEMODE.DefaultTeam, true);
		fprp.destroyVotesWithEnt(self);
		fprp.notify(self, 1, 4, fprp.getPhrase("tried_to_avoid_demotion"));

		return false
	end


	if prevTeam == t then
		fprp.notify(self, 1, 4, fprp.getPhrase("unable", team.GetName(t), ""));
		return false
	end

	local TEAM = RPExtraTeams[t]
	if not TEAM then return false end

	if TEAM.customCheck and not TEAM.customCheck(self) and (not force or force and not GAMEMODE.Config.adminBypassJobRestrictions) then
		local message = isfunction(TEAM.CustomCheckFailMsg) and TEAM.CustomCheckFailMsg(self, TEAM) or
			TEAM.CustomCheckFailMsg or
			fprp.getPhrase("unable", team.GetName(t), "");
		fprp.notify(self, 1, 4, message);
		return false
	end

	if not force then
		if type(TEAM.NeedToChangeFrom) == "number" and prevTeam ~= TEAM.NeedToChangeFrom then
			fprp.notify(self, 1,4, fprp.getPhrase("need_to_be_before", team.GetName(TEAM.NeedToChangeFrom), TEAM.name));
			return false
		elseif type(TEAM.NeedToChangeFrom) == "table" and not table.HasValue(TEAM.NeedToChangeFrom, prevTeam) then
			local teamnames = ""
			for a,b in pairs(TEAM.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
			fprp.notify(self, 1,4, string.format(string.sub(teamnames, 5), team.GetName(TEAM.NeedToChangeFrom), TEAM.name));
			return false
		end
		local max = TEAM.max
		if max ~= 0 and -- No limit
		(max >= 1 and team.NumPlayers(t) >= max or -- absolute maximum
		max < 1 and (team.NumPlayers(t) + 1) / #player.GetAll() > max) then -- fractional limit (in percentages);
			fprp.notify(self, 1, 4,  fprp.getPhrase("team_limit_reached", TEAM.name));
			return false
		end
	end

	if TEAM.PlayerChangeTeam then
		local val = TEAM.PlayerChangeTeam(self, prevTeam, t);
		if val ~= nil then
			return val
		end
	end

	local hookValue = hook.Call("playerCanChangeTeam", nil, self, t, force);
	if hookValue == false then return false end

	local isMayor = RPExtraTeams[prevTeam] and RPExtraTeams[prevTeam].mayor
	if isMayor and GetGlobalBool("fprp_LockDown") then
		fprp.unLockdown(self);
	end
	self:updateJob(TEAM.name);
	self:setSelffprpVar("salary", TEAM.salary);
	fprp.notifyAll(0, 4, fprp.getPhrase("job_has_become", self:Nick(), TEAM.name));


	if self:getfprpVar("HasGunlicense") and GAMEMODE.Config.revokeLicenseOnJobChange then
		self:setfprpVar("HasGunlicense", nil);
	end
	if TEAM.hasLicense then
		self:setfprpVar("HasGunlicense", true);
	end

	self.LastJob = CurTime();

	if GAMEMODE.Config.removeclassitems then
		for k, v in pairs(fprpEntities) do
			if GAMEMODE.Config.preventClassItemRemoval[v.ent] then continue end
			if not v.allowed then continue end
			if type(v.allowed) == "table" and (table.HasValue(v.allowed, t) or not table.HasValue(v.allowed, prevTeam)) then continue end
			for _, e in pairs(ents.FindByClass(v.ent)) do
				if e.SID == self.SID then e:Remove() end
			end
		end

		if not GAMEMODE.Config.preventClassItemRemoval["spawned_shipment"] then
			for k,v in pairs(ents.FindByClass("spawned_shipment")) do
				if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
				if v.SID == self.SID then v:Remove() end
			end
		end
	end

	if isMayor then
		for _, ent in pairs(self.lawboards or {}) do
			if IsValid(ent) then
				ent:Remove();
			end
		end
	end

	if isMayor and GAMEMODE.Config.shouldResetLaws then
		fprp.resetLaws();
	end

	self:SetTeam(t);
	hook.Call("OnPlayerChangedTeam", GAMEMODE, self, prevTeam, t);
	fprp.log(self:Nick().." ("..self:SteamID()..") changed to "..team.GetName(t), nil, Color(100, 0, 255));
	if self:InVehicle() then self:ExitVehicle() end
	if GAMEMODE.Config.norespawn and self:Alive() then
		self:StripWeapons();
		local vPoint = self:GetShootPos() + Vector(0,0,50);
		local effectdata = EffectData();
		effectdata:SetEntity(self);
		effectdata:SetStart( vPoint ) -- Not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( vPoint );
		effectdata:SetScale(1);
		util.Effect("entity_remove", effectdata);
		hook.Call("UpdatePlayerSpeed", GAMEMODE, self);
		gamemode.Call("PlayerSetModel", self);
		gamemode.Call("PlayerLoadout", self);
	else
		self:KillSilent();
	end

	umsg.Start("OnChangedTeam", self);
		umsg.Short(prevTeam);
		umsg.Short(t);
	umsg.End();
	return true
end

function meta:updateJob(job)
	self:setfprpVar("job", job);
	self.LastJob = CurTime();

	timer.Create(self:UniqueID() .. "jobtimer", GAMEMODE.Config.paydelay, 0, function()
		if not IsValid(self) then return end
		self:payDay();
	end);
end

function meta:teamUnBan(Team)
	if not IsValid(self) then return end
	self.bannedfrom = self.bannedfrom or {}

	local group = fprp.getDemoteGroup(Team);
	self.bannedfrom[group] = nil
end

function meta:teamBan(t, time)
	if not self.bannedfrom then self.bannedfrom = {} end
	t = t or self:Team();

	local group = fprp.getDemoteGroup(t);
	self.bannedfrom[group] = true

	if time == 0 then return end
	timer.Simple(time or GAMEMODE.Config.demotetime, function()
		if not IsValid(self) then return end
		self:teamUnBan(t);
	end);
end

function meta:changeAllowed(t)
	local group = fprp.getDemoteGroup(t);
	if not self.bannedfrom then return true end
	if self.bannedfrom[group] then return false else return true end
end


function GM:canChangeJob(ply, args)
	if ply:isArrested() then return false end
	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then return false, fprp.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), "/job") end
	if not ply:Alive() then return false end

	local len = string.len(args);

	if len < 3 then return false, fprp.getPhrase("unable", "/job", ">2") end
	if len > 25 then return false, fprp.getPhrase("unable", "/job", "<26") end

	return true
end

/*---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------*/
local function ChangeJob(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end

	if not GAMEMODE.Config.customjobs then
		fprp.notify(ply, 1, 4, fprp.getPhrase("disabled", "/job", ""));
		return ""
	end

	local canChangeJob, message, replace = gamemode.Call("canChangeJob", ply, args);
	if canChangeJob == false then
		fprp.notify(ply, 1, 4, message or fprp.getPhrase("unable", "/job", ""));
		return ""
	end

	local job = replace or args
	fprp.notifyAll(2, 4, fprp.getPhrase("job_has_become", ply:Nick(), job));
	ply:updateJob(job);
	return ""
end
fprp.defineChatCommand("job", ChangeJob);

local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:teamBan();
		if target:Alive() then
			target:changeTeam(GAMEMODE.DefaultTeam, true);
			if target:isArrested() then
				target:arrest();
			end
		else
			target.demotedWhileDead = true
		end

		hook.Call("onPlayerDemoted", nil, vote.info.source, target, vote.info.reason);
		fprp.notifyAll(0, 4, fprp.getPhrase("demoted", target:Nick()));
	else
		fprp.notifyAll(1, 4, fprp.getPhrase("demoted_not", target:Nick()));
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args);
	if #tableargs == 1 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("vote_specify_reason"));
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2);
	if string.len(reason) > 99 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/demote", "<100"));
		return ""
	end
	local p = fprp.findPlayer(tableargs[1]);
	if p == ply then
		fprp.notify(ply, 1, 4, fprp.getPhrase("cant_demote_self"));
		return ""
	end

	local canDemote, message = hook.Call("canDemote", GAMEMODE, ply, p, reason);
	if canDemote == false then
		fprp.notify(ply, 1, 4, message or fprp.getPhrase("unable", "demote", ""));
		return ""
	end

	if p then
		if CurTime() - ply.LastVoteCop < 80 then
			fprp.notify(ply, 1, 4, fprp.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"));
			return ""
		end
		if not RPExtraTeams[p:Team()] or RPExtraTeams[p:Team()].candemote == false then
			fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/demote", ""));
		else
			fprp.talkToPerson(p, team.GetColor(ply:Team()), fprp.getPhrase("demote") .. " " ..ply:Nick(),Color(255,0,0,255), fprp.getPhrase("i_want_to_demote_you", reason), p);
			fprp.notifyAll(0, 4, fprp.getPhrase("demote_vote_started", ply:Nick(), p:Nick()));
			fprp.log(fprp.getPhrase("demote_vote_started", string.format("%s(%s)[%s]", ply:Nick(), ply:SteamID(), team.GetName(ply:Team())), string.format("%s(%s)[%s] for %s", p:Nick(), p:SteamID(), team.GetName(p:Team()), reason)), Color(255, 128, 255, 255));
			p.IsBeingDemoted = true

			fprp.createVote(p:Nick() .. ":\n"..fprp.getPhrase("demote_vote_text", reason), "demote", p, 20, FinishDemote,
			{
				[p] = true,
				[ply] = true
			}, function(vote)
				if not IsValid(vote.target) then return end
				vote.target.IsBeingDemoted = nil
			end, {source = ply, reason = reason});
			ply:GetTable().LastVoteCop = CurTime();
		end
		return ""
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", tostring(args)));
		return ""
	end
end
fprp.defineChatCommand("demote", Demote);

local function ExecSwitchJob(answer, ent, ply, target)
	ply.RequestedJobSwitch = nil
	if not tobool(answer) then return end
	local Pteam = ply:Team();
	local Tteam = target:Team();

	if not ply:changeTeam(Tteam) then return end
	if not target:changeTeam(Pteam) then
		ply:changeTeam(Pteam, true) -- revert job change
		return
	end
	fprp.notify(ply, 2, 4, fprp.getPhrase("job_switch"));
	fprp.notify(target, 2, 4, fprp.getPhrase("job_switch"));
end

local function SwitchJob(ply) --Idea by Godness.
	if not GAMEMODE.Config.allowjobswitch then return "" end

	if ply.RequestedJobSwitch then return end

	local eyetrace = ply:GetEyeTrace();
	if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return "" end

	local team1 = RPExtraTeams[ply:Team()]
	local team2 = RPExtraTeams[eyetrace.Entity:Team()]

	if not team1 or not team2 then return "" end
	if team1.customCheck and not team1.customCheck(eyetrace.Entity) or team2.customCheck and not team2.customCheck(ply) then
		-- notify only the player trying to switch
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "switch jobs", ""));
		return ""
	end

	ply.RequestedJobSwitch = true
	fprp.createQuestion(fprp.getPhrase("job_switch_question", ply:Nick()), "switchjob"..tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity);
	fprp.notify(ply, 0, 4, fprp.getPhrase("job_switch_requested"));

	return ""
end
fprp.defineChatCommand("switchjob", SwitchJob);
fprp.defineChatCommand("switchjobs", SwitchJob);
fprp.defineChatCommand("jobswitch", SwitchJob);


local function DoTeamBan(ply, args, cmdargs)
	if ply:EntIndex() ~= 0 and not ply:hasfprpPrivilege("rp_commands") then
		if cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("need_admin", "/teamban"));
			return
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("need_admin", "/teamban"));
			return ""
		end
	end

	if not args or args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "arguments", ""));
		return ""
	end

	if cmdargs and not cmdargs[2] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("rp_teamban_hint"));
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("rp_teamban_hint"));
		end
		return
	end

	args = cmdargs or string.Explode(" ", args);
	local ent = args[1]
	local Team = args[2]

	local target = fprp.findPlayer(ent);
	if not target or not IsValid(target) then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", ent or ""));
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("could_not_find", ent or ""));
			return
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", ent or ""));
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
			print(fprp.getPhrase("could_not_find", Team or ""));
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("could_not_find", Team or ""));
			return
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", Team or ""));
			return ""
		end
	end

	target:teamBan(tonumber(Team), tonumber(args[3] or 0));

	local nick
	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick();
	end
	fprp.notifyAll(0, 5, fprp.getPhrase("x_teambanned_y", nick, target:Nick(), team.GetName(tonumber(Team))));

	return ""
end
fprp.defineChatCommand("teamban", DoTeamBan);
concommand.Add("rp_teamban", DoTeamBan);

local function DoTeamUnBan(ply, args, cmdargs)
	if ply:EntIndex() ~= 0 and not ply:hasfprpPrivilege("rp_commands") then
		fprp.notify(ply, 1, 4, fprp.getPhrase("need_admin", "/teamunban"));
		return ""
	end

	if not args or args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "arguments", ""));
		return ""
	end

	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[2] then
			if ply:EntIndex() == 0 then
				print(fprp.getPhrase("rp_teamunban_hint"));
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("rp_teamunban_hint"));
			end
			return
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ");
		ent = string.sub(args, 1, a - 1);
		Team = string.sub(args, a + 1);
	end

	local target = fprp.findPlayer(ent);
	if not target or not IsValid(target) then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", ent or ""));
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("could_not_find", ent or ""));
			return
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", ent or ""));
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
			print(fprp.getPhrase("could_not_find", Team or ""));
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("could_not_find", Team or ""));
			return
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", Team or ""));
			return ""
		end
	end

	target:teamUnBan(tonumber(Team));

	local nick
	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick();
	end
	fprp.notifyAll(1, 5, fprp.getPhrase("x_teamunbanned_y", nick, target:Nick(), team.GetName(tonumber(Team))));

	return ""
end
fprp.defineChatCommand("teamunban", DoTeamUnBan);
concommand.Add("rp_teamunban", DoTeamUnBan);
