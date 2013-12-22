local function CreateAgenda(ply, args)
	local agenda = ply:getAgendaTable()
	local plyTeam = ply:Team()

	if not agenda or agenda.Manager ~= plyTeam then
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("unable", "agenda", "Incorrect team"))
		return ""
	end

	agenda.text = args

	for k,v in pairs(player.GetAll()) do
		if v:getAgendaTable() ~= agenda then continue end

		v:setSelfDarkRPVar("agenda", agenda.text)
		DarkRP.notify(v, 2, 4, DarkRP.getPhrase("agenda_updated"))
	end

	return ""
end
DarkRP.defineChatCommand("agenda", CreateAgenda, 0.1)

/*---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------*/
CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) -- Don't save this one!
local LotteryPeople = {}
local LotteryON = false
local LotteryAmount = 0
local CanLottery = CurTime()
local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
	if tobool(answer) and not table.HasValue(LotteryPeople, target) then
		if not target:canAfford(LotteryAmount) then
			DarkRP.notify(target, 1,4, DarkRP.getPhrase("cant_afford", "lottery"))

			return
		end
		table.insert(LotteryPeople, target)
		target:addMoney(-LotteryAmount)
		DarkRP.notify(target, 0,4, DarkRP.getPhrase("lottery_entered", GAMEMODE.Config.currency..tostring(LotteryAmount)))
	elseif answer ~= nil and not table.HasValue(LotteryPeople, target) then
		DarkRP.notify(target, 1,4, DarkRP.getPhrase("lottery_not_entered", "You"))
	end

	if TimeIsUp then
		LotteryON = false
		CanLottery = CurTime() + 60
		if table.Count(LotteryPeople) == 0 then
			DarkRP.notifyAll(1, 4, DarkRP.getPhrase("lottery_noone_entered"))
			return
		end
		local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
		chosen:addMoney(#LotteryPeople * LotteryAmount)
		DarkRP.notifyAll(0,10, DarkRP.getPhrase("lottery_won", chosen:Nick(), GAMEMODE.Config.currency .. tostring(#LotteryPeople * LotteryAmount) ))
	end
end

local function DoLottery(ply, amount)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/lottery"))
		return ""
	end

	if not GAMEMODE.Config.lottery then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/lottery", ""))
		return ""
	end

	if #player.GetAll() <= 2 or LotteryON then
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("unable", "/lottery", ""))
		return ""
	end

	if CanLottery > CurTime() then
		DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("have_to_wait", tostring(CanLottery - CurTime()), "/lottery"))
		return ""
	end

	amount = tonumber(amount)
	if not amount then
		DarkRP.notify(ply, 1, 5, string.format("Please specify an entry cost ($%i-%i)", GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost))
		return ""
	end

	LotteryAmount = math.Clamp(math.floor(amount), GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost)

	LotteryON = true
	LotteryPeople = {}
	for k,v in pairs(player.GetAll()) do
		if v ~= ply then
			DarkRP.createQuestion(DarkRP.getPhrase("lottery_started", GAMEMODE.Config.currency, LotteryAmount), "lottery"..tostring(k), v, 30, EnterLottery, ply, v)
		end
	end
	timer.Create("Lottery", 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
	return ""
end
DarkRP.defineChatCommand("lottery", DoLottery, 1)

local lstat = false
local wait_lockdown = false

local function WaitLock()
	wait_lockdown = false
	lstat = false
	timer.Destroy("spamlock")
end

function DarkRP.lockdown(ply, args, cmdargs)
	if lstat then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("unable", "/lockdown", DarkRP.getPhrase("stop_lockdown")))
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("unable", "/lockdown", DarkRP.getPhrase("stop_lockdown")))
			return
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/lockdown", DarkRP.getPhrase("stop_lockdown")))
			return ""
		end
	end
	if ply:EntIndex() == 0 or (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].mayor) then
		for k,v in pairs(player.GetAll()) do
			v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
		end
		lstat = true
		DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
		RunConsoleCommand("DarkRP_LockDown", 1)
		DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("incorrect_job", "/lockdown", ""))
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("incorrect_job", "/lockdown", ""))
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/lockdown", ""))
		end
	end
	return ""
end
concommand.Add("rp_lockdown", function(ply) DarkRP.lockdown(ply) end)
DarkRP.defineChatCommand("lockdown", function(ply) DarkRP.lockdown(ply) end)

function DarkRP.unLockdown(ply, args, cmdargs)
	if not lstat or wait_lockdown then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("unable", "/ulockdown", DarkRP.getPhrase("lockdown_ended")))
			return
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("unable", "/unlockdown", DarkRP.getPhrase("lockdown_ended")))
			return
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/unlockdown", DarkRP.getPhrase("lockdown_ended")))
			return ""
		end
	end

	if ply:EntIndex() == 0 or (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].mayor) then
		DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_ended"))
		DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_ended"))
		wait_lockdown = true
		RunConsoleCommand("DarkRP_LockDown", 0)
		timer.Create("spamlock", 20, 1, function() WaitLock() end)
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("incorrect_job", "/unlockdown", ""))
		elseif cmdargs then
			ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("incorrect_job", "/unlockdown", ""))
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/unlockdown", ""))
		end
	end
	return ""
end
concommand.Add("rp_unlockdown", function(ply) DarkRP.unLockdown(ply) end)
DarkRP.defineChatCommand("unlockdown", function(ply) DarkRP.unLockdown(ply) end)

/*---------------------------------------------------------
 License
 ---------------------------------------------------------*/
local function GrantLicense(answer, Ent, Initiator, Target)
	Initiator.LicenseRequested = nil
	if tobool(answer) then
		DarkRP.notify(Initiator, 0, 4, DarkRP.getPhrase("gunlicense_granted", Target:Nick(), Initiator:Nick()))
		DarkRP.notify(Target, 0, 4, DarkRP.getPhrase("gunlicense_granted", Target:Nick(), Initiator:Nick()))
		Initiator:setDarkRPVar("HasGunlicense", true)
	else
		DarkRP.notify(Initiator, 1, 4, DarkRP.getPhrase("gunlicense_denied", Target:Nick(), Initiator:Nick()))
	end
end

local function RequestLicense(ply)
	if ply:getDarkRPVar("HasGunlicense") or ply.LicenseRequested then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/requestlicense", ""))
		return ""
	end
	local LookingAt = ply:GetEyeTrace().Entity

	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].mayor and not v:getDarkRPVar("AFK") then
			ismayor = true
			break
		end
	end

	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].chief and not v:getDarkRPVar("AFK") then
				ischief = true
				break
			end
		end
	end

	if not ischief and not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:isCP() then
				iscop = true
				break
			end
		end
	end

	if not ismayor and not ischief and not iscop then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/requestlicense", ""))
		return ""
	end

	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "mayor/chief/cop"))
		return ""
	end

	if ismayor and (not RPExtraTeams[LookingAt:Team()] or not RPExtraTeams[LookingAt:Team()].mayor) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "mayor"))
		return ""
	elseif ischief and (not RPExtraTeams[LookingAt:Team()] or not RPExtraTeams[LookingAt:Team()].chief) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "chief"))
		return ""
	elseif iscop and not LookingAt:isCP() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "cop"))
		return ""
	end

	ply.LicenseRequested = true
	DarkRP.notify(ply, 3, 4, DarkRP.getPhrase("gunlicense_requested", ply:Nick(), LookingAt:Nick()))
	DarkRP.createQuestion(DarkRP.getPhrase("gunlicense_question_text", ply:Nick()), "Gunlicense"..ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
	return ""
end
DarkRP.defineChatCommand("requestlicense", RequestLicense)

local function GiveLicense(ply)
	local noMayorExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(ply.isMayor), player.GetAll}
	local noChiefExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(ply.isChief), player.GetAll}

	local canGiveLicense = fn.FOr{
		ply.isMayor, -- Mayors can hand out licenses
		fn.FAnd{ply.isChief, noMayorExists}, -- Chiefs can if there is no mayor
		fn.FAnd{ply.isCP, noChiefExists, noMayorExists} -- CP's can if there are no chiefs nor mayors
	}

	if not canGiveLicense(ply) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/givelicense"))
		return ""
	end

	local LookingAt = ply:GetEyeTrace().Entity
	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "player"))
		return ""
	end

	DarkRP.notify(LookingAt, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
	LookingAt:setDarkRPVar("HasGunlicense", true)

	return ""
end
DarkRP.defineChatCommand("givelicense", GiveLicense)

local function rp_GiveLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_givelicense"))
		return
	end

	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		end
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		target:setDarkRPVar("HasGunlicense", true)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
			steamID = ply:SteamID()
		else
			nick = "Console"
			steamID = "Console"
		end

		DarkRP.notify(target, 0, 4, DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
		if ply ~= target then
			if ply:EntIndex() == 0 then
				print(DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
			end
		end
		DarkRP.log(nick.." ("..steamID..") force-gave "..target:Nick().." a gun license", Color(30, 30, 30))
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		end
	end
end
concommand.Add("rp_givelicense", rp_GiveLicense)

local function rp_RevokeLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_revokelicense"))
		return
	end

	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		end
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		target:setDarkRPVar("HasGunlicense", false)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
			steamID = ply:SteamID()
		else
			nick = "Console"
			steamID = "Console"
		end

		DarkRP.notify(target, 1, 4, DarkRP.getPhrase("gunlicense_denied", nick, target:Nick()))
		if ply ~= target then
			if ply:EntIndex() == 0 then
				print(DarkRP.getPhrase("gunlicense_denied", nick, target:Nick()))
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
			end
		end
		DarkRP.log(nick.." ("..steamID..") force-removed "..target:Nick().."'s gun license", Color(30, 30, 30))
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		end
	end
end
concommand.Add("rp_revokelicense", rp_RevokeLicense)

local function FinishRevokeLicense(vote, win)
	if choice == 1 then
		vote.target:setDarkRPVar("HasGunlicense", false)
		vote.target:StripWeapons()
		GAMEMODE:PlayerLoadout(vote.target)
		DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_removed", vote.target:Nick()))
	else
		DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_not_removed", vote.target:Nick()))
	end
end

local function VoteRemoveLicense(ply, args)
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
	if string.len(reason) > 22 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demotelicense", "<23"))
		return ""
	end
	local p = DarkRP.findPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demotelicense"))
			return ""
		end
		if ply:getDarkRPVar("HasGunlicense") then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demotelicense", ""))
		else
			DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_remove_vote_text", ply:Nick(), p:Nick()))
			DarkRP.createVote(p:Nick() .. ":\n"..DarkRP.getPhrase("gunlicense_remove_vote_text2", reason), "removegunlicense", p, 20,  FinishRevokeLicense,
			{
				[p] = true,
				[ply] = true
			})
			ply:GetTable().LastVoteCop = CurTime()
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("vote_started"))
		end
		return ""
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
		return ""
	end
end
DarkRP.defineChatCommand("demotelicense", VoteRemoveLicense)
