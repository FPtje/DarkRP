local plyMeta = FindMetaTable("Player");
local finishWarrantRequest
local arrestedPlayers = {}

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function plyMeta:warrant(warranter, reason)
	if self.warranted then return end
	local suppressMsg = hook.Call("playerWarranted", GAMEMODE, self, warranter, reason);

	self.warranted = true
	timer.Simple(GAMEMODE.Config.searchtime, function()
		if not IsValid(self) then return end
		self:unWarrant(warranter);
	end);

	if suppressMsg then return end

	local warranterNick = IsValid(warranter) and warranter:Nick() or fprp.getPhrase("disconnected_player");
	local centerMessage = fprp.getPhrase("warrant_approved", self:Nick(), reason, warranterNick);
	local printMessage = fprp.getPhrase("warrant_ordered", warranterNick, self:Nick(), reason);

	for a, b in pairs(player.GetAll()) do
		b:PrintMessage(HUD_PRINTCENTER, centerMessage);
		b:PrintMessage(HUD_PRINTCONSOLE, printMessage);
	end

	fprp.notify(warranter, 0, 4, fprp.getPhrase("warrant_approved2"));
end

function plyMeta:unWarrant(unwarranter)
	if not self.warranted then return end

	local suppressMsg = hook.Call("playerUnWarranted", GAMEMODE, self, unwarranter);

	self.warranted = false

	if suppressMsg then return end

	fprp.notify(unwarranter, 2, 4, fprp.getPhrase("warrant_expired", self:Nick()));
end

function plyMeta:requestWarrant(suspect, actor, reason)
	local question = fprp.getPhrase("warrant_request", actor:Nick(), suspect:Nick(), reason);
	fprp.createQuestion(question, suspect:EntIndex() .. "warrant", self, 40, finishWarrantRequest, actor, suspect, reason);
end

function plyMeta:wanted(actor, reason)
	local suppressMsg = hook.Call("playerWanted", fprp.hooks, self, actor, reason);

	self:setfprpVar("wanted", true);
	self:setfprpVar("wantedReason", reason);

	timer.Create(self:UniqueID() .. " wantedtimer", GAMEMODE.Config.wantedtime, 1, function()
		if not IsValid(self) then return end
		self:unWanted();
	end);

	if suppressMsg then return end

	local actorNick = IsValid(actor) and actor:Nick() or fprp.getPhrase("disconnected_player");
	local centerMessage = fprp.getPhrase("wanted_by_police", self:Nick(), reason, actorNick);
	local printMessage = fprp.getPhrase("wanted_by_police_print", actorNick, self:Nick(), reason);

	for _, ply in pairs(player.GetAll()) do
		ply:PrintMessage(HUD_PRINTCENTER, centerMessage);
		ply:PrintMessage(HUD_PRINTCONSOLE, printMessage);
	end
end

function plyMeta:unWanted(actor)
	local suppressMsg = hook.Call("playerUnWanted", GAMEMODE, self, actor);
	self:setfprpVar("wanted", nil);
	self:setfprpVar("wantedReason", nil);

	timer.Destroy(self:UniqueID() .. " wantedtimer");

	if suppressMsg then return end

	local expiredMessage = IsValid(actor) and fprp.getPhrase("wanted_revoked", self:Nick(), actor:Nick() or "") or
		fprp.getPhrase("wanted_expired", self:Nick());

	for _, ply in pairs(player.GetAll()) do
		ply:PrintMessage(HUD_PRINTCENTER, expiredMessage);
		ply:PrintMessage(HUD_PRINTCONSOLE, expiredMessage);
	end
end

function plyMeta:arrest(time, arrester)
	time = time or GAMEMODE.Config.jailtimer or 120

	hook.Call("playerArrested", fprp.hooks, self, time, arrester);
	if self:InVehicle() then self:ExitVehicle() end
	self:setfprpVar("Arrested", true);
	arrestedPlayers[self:SteamID()] = true

	-- Always get sent to jail when Arrest() is called, even when already under arrest
	if GAMEMODE.Config.teletojail and fprp.jailPosCount() ~= 0 then
		self:Spawn();
	end
end

function plyMeta:unArrest(unarrester)
	if not self:isArrested() then return end

	self:setfprpVar("Arrested", nil);
	arrestedPlayers[self:SteamID()] = nil
	hook.Call("playerUnArrested", fprp.hooks, self, unarrester);
end

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
local function CombineRequest(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	local t = ply:Team();

	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return
		end
		for k, v in pairs(player.GetAll()) do
			if v:isCP() or v == ply then
				fprp.talkToPerson(v, team.GetColor(ply:Team()), fprp.getPhrase("request") ..ply:Nick(), Color(255,0,0,255), text, ply);
			end
		end
	end
	return args, DoSay
end
fprp.defineChatCommand("cr", CombineRequest, 1.5);

local function warrantCommand(ply, args)
	local expl = string.Explode(" ", args or "");
	local target = fprp.findPlayer(expl[1]);
	local reason = table.concat(expl, " ", 2);

	local canRequest, message = hook.Call("canRequestWarrant", fprp.hooks, target, ply, reason);
	if not canRequest then
		fprp.notify(ply, 1, 4, message);
		return ""
	end

	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then -- No need to search through all the teams if the player is a mayor
		local mayors = {}

		for k,v in pairs(RPExtraTeams) do
			if v.mayor then
				table.Add(mayors, team.GetPlayers(k));
			end
		end

		if #mayors > 0 then -- Request a warrant if there's a mayor
			local mayor = table.Random(mayors);
			mayor:requestWarrant(target, ply, reason);
			fprp.notify(ply, 0, 4, fprp.getPhrase("warrant_request2", mayor:Nick()));
			return ""
		end
	end

	target:warrant(ply, reason);

	return ""
end
fprp.defineChatCommand("warrant", warrantCommand);

local function wantedCommand(ply, args)
	local expl = string.Explode(" ", args or "");
	local target = fprp.findPlayer(expl[1]);
	local reason = table.concat(expl, " ", 2);

	local canWanted, message = hook.Call("canWanted", fprp.hooks, target, ply, reason);
	if not canWanted then
		fprp.notify(ply, 1, 4, message);
		return ""
	end

	target:wanted(ply, reason);

	return ""
end
fprp.defineChatCommand("wanted", wantedCommand);

local function unwantedCommand(ply, args)
	local target = fprp.findPlayer(args);

	local canUnwant, message = hook.Call("canUnwant", fprp.hooks, target, ply);
	if not canUnwant then
		fprp.notify(ply, 1, 4, message);
		return ""
	end

	target:unWanted(ply);

	return ""
end
fprp.defineChatCommand("unwanted", unwantedCommand);

/*---------------------------------------------------------------------------
Admin commands
---------------------------------------------------------------------------*/
local function ccArrest(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:hasfprpPrivilege("rp_commands") then
		ply:PrintMessage(2, fprp.getPhrase("need_admin", "rp_arrest"));
		return
	end

	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		end
		return
	end

	if fprp.jailPosCount() == 0 then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("no_jail_pos"));
		else
			ply:PrintMessage(2, fprp.getPhrase("no_jail_pos"));
		end
		return
	end

	local targets = fprp.findPlayers(args[1]);

	if not targets then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])));
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])));
		end

		return
	end

	for k, target in pairs(targets) do
		local length = tonumber(args[2]);
		if length then
			target:arrest(length, ply);
		else
			target:arrest(nil, ply);
		end

		if ply:EntIndex() == 0 then
			fprp.log("Console force-arrested "..target:SteamName(), Color(0, 255, 255));
		else
			fprp.log(ply:Nick().." ("..ply:SteamID()..") force-arrested "..target:SteamName(), Color(0, 255, 255));
		end
	end
end
concommand.Add("rp_arrest", ccArrest);

local function ccUnarrest(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:hasfprpPrivilege("rp_commands") then
		ply:PrintMessage(2, fprp.getPhrase("need_admin", "rp_unarrest"));
		return
	end

	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		end
		return
	end

	local targets = fprp.findPlayers(args[1]);

	if not targets then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])));
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])));
		end

		return
	end

	for _, target in pairs(targets) do
		target:unArrest(ply);
		if not target:Alive() then target:Spawn() end

		if ply:EntIndex() == 0 then
			fprp.log("Console force-unarrested "..target:SteamName(), Color(0, 255, 255));
		else
			fprp.log(ply:Nick().." ("..ply:SteamID()..") force-unarrested "..target:SteamName(), Color(0, 255, 255));
		end
	end
end
concommand.Add("rp_unarrest", ccUnarrest);

/*---------------------------------------------------------------------------
Callback functions
---------------------------------------------------------------------------*/
function finishWarrantRequest(choice, mayor, initiator, suspect, reason)
	if not tobool(choice) then
		fprp.notify(initiator, 1, 4, fprp.getPhrase("warrant_denied", mayor:Nick()));
		return
	end
	if IsValid(suspect) then
		suspect:warrant(initiator, reason);
	end
end

/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
function fprp.hooks:playerArrested(ply, time, arrester)
	if ply:isWanted() then ply:unWanted(arrester) end
	ply:unWarrant(arrester);
	ply:setfprpVar("HasGunlicense", nil);

	-- UpdatePlayerSpeed won't work here as the "Arrested" fprpVar is set AFTER this hook
	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed);
	ply:StripWeapons();

	if ply:isArrested() then return end -- hasn't been arrested before

	ply:PrintMessage(HUD_PRINTCENTER, fprp.getPhrase("youre_arrested", time));
	for k, v in pairs(player.GetAll()) do
		if v == ply then continue end
		v:PrintMessage(HUD_PRINTCENTER, fprp.getPhrase("hes_arrested", ply:Name(), time));
	end

	local steamID = ply:SteamID();
	timer.Create(ply:UniqueID() .. "jailtimer", time, 1, function()
		if IsValid(ply) then ply:unArrest() end
		arrestedPlayers[steamID] = nil
	end);
	umsg.Start("GotArrested", ply);
		umsg.Float(time);
	umsg.End();
end

function fprp.hooks:playerUnArrested(ply, actor)
	if ply.Sleeping and GAMEMODE.KnockoutToggle then
		fprp.toggleSleep(ply, "force");
	end

	-- "Arrested" fprpVar is set to false BEFORE this hook however, so it is safe here.
	hook.Call("UpdatePlayerSpeed", GAMEMODE, ply);
	gamemode.Call("PlayerLoadout", ply);
	if GAMEMODE.Config.telefromjail then
		local ent, pos = GAMEMODE:PlayerSelectSpawn(ply);
		timer.Simple(0, function() if IsValid(ply) then ply:SetPos(pos or ent:GetPos()) end end) -- workaround for SetPos in weapon event bug
	end

	timer.Destroy(ply:UniqueID() .. "jailtimer");
	fprp.notifyAll(0, 4, fprp.getPhrase("hes_unarrested", ply:Name()));
end

hook.Add("PlayerInitialSpawn", "Arrested", function(ply)
	if not arrestedPlayers[ply:SteamID()] then return end
	local time = GAMEMODE.Config.jailtimer
	ply:arrest(time);
	fprp.notify(ply, 0, 5, fprp.getPhrase("jail_punishment", time));
end);
