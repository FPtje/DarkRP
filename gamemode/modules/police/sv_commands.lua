local function updateAgenda(ply, agenda, text)
	local txt = hook.Run("agendaUpdated", ply, agenda, text)

	agenda.text = txt or text

	for k,v in pairs(player.GetAll()) do
		if v:getAgendaTable() ~= agenda then continue end

		v:setSelffprpVar("agenda", agenda.text)
		fprp.notify(v, 2, 4, fprp.getPhrase("agenda_updated"))
	end
end

local function CreateAgenda(ply, args)
	local agenda = ply:getAgendaTable()
	local plyTeam = ply:Team()

	if not agenda or not agenda.ManagersByKey[plyTeam] then
		fprp.notify(ply, 1, 6, fprp.getPhrase("unable", "agenda", "Incorrect team"))
		return ""
	end

	updateAgenda(ply, agenda, args)

	return ""
end
fprp.defineChatCommand("agenda", CreateAgenda, 0.1)

local function addAgenda(ply, args)
	local agenda = ply:getAgendaTable()
	local plyTeam = ply:Team()

	if not agenda or not agenda.ManagersByKey[plyTeam] then
		fprp.notify(ply, 1, 6, fprp.getPhrase("unable", "agenda", "Incorrect team"))
		return ""
	end

	agenda.text = agenda.text or ""
	args = args or ""

	updateAgenda(ply, agenda, agenda.text .. '\n' .. args)

	return ""
end
fprp.defineChatCommand("addagenda", addAgenda, 0.1)

/*---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------*/
local LotteryPeople = {}
local LotteryON = false
local LotteryAmount = 0
local CanLottery = CurTime()
local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
	if tobool(answer) and not table.HasValue(LotteryPeople, target) then
		if not target:canAfford(LotteryAmount) then
			fprp.notify(target, 1,4, fprp.getPhrase("cant_afford", "lottery"))

			return
		end
		table.insert(LotteryPeople, target)
		target:addshekel(-LotteryAmount)
		fprp.notify(target, 0,4, fprp.getPhrase("lottery_entered", fprp.formatshekel(LotteryAmount)))
		hook.Run("playerEnteredLottery", target)
	elseif answer ~= nil and not table.HasValue(LotteryPeople, target) then
		fprp.notify(target, 1,4, fprp.getPhrase("lottery_not_entered", "You"))
	end

	if TimeIsUp then
		LotteryON = false
		CanLottery = CurTime() + 60

		if table.Count(LotteryPeople) == 0 then
			fprp.notifyAll(1, 4, fprp.getPhrase("lottery_noone_entered"))
			hook.Run("lotteryEnded", LotteryPeople, nil)
			return
		end
		local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
		hook.Run("lotteryEnded", LotteryPeople, chosen, #LotteryPeople * LotteryAmount)
		chosen:addshekel(#LotteryPeople * LotteryAmount)
		fprp.notifyAll(0,10, fprp.getPhrase("lottery_won", chosen:Nick(), fprp.formatshekel(#LotteryPeople * LotteryAmount)))
	end
end

local function DoLottery(ply, amount)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		fprp.notify(ply, 1, 4, fprp.getPhrase("incorrect_job", "/lottery"))
		return ""
	end

	if not GAMEMODE.Config.lottery then
		fprp.notify(ply, 1, 4, fprp.getPhrase("disabled", "/lottery", ""))
		return ""
	end

	if #player.GetAll() <= 2 or LotteryON then
		fprp.notify(ply, 1, 6, fprp.getPhrase("unable", "/lottery", ""))
		return ""
	end

	if CanLottery > CurTime() then
		fprp.notify(ply, 1, 5, fprp.getPhrase("have_to_wait", tostring(CanLottery - CurTime()), "/lottery"))
		return ""
	end

	amount = tonumber(amount)
	if not amount then
		fprp.notify(ply, 1, 5, string.format("Please specify an entry cost ($%i-%i)", GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost))
		return ""
	end

	LotteryAmount = math.Clamp(math.floor(amount), GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost)

	hook.Run("lotteryStarted", ply, LotteryAmount)

	LotteryON = true
	LotteryPeople = {}
	for k,v in pairs(player.GetAll()) do
		if v ~= ply then
			fprp.createQuestion(fprp.getPhrase("lottery_has_started", fprp.formatshekel(LotteryAmount)), "lottery"..tostring(k), v, 30, EnterLottery, ply, v)
		end
	end
	timer.Create("Lottery", 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
	return ""
end
fprp.defineChatCommand("lottery", DoLottery, 1)

local wait_lockdown = false

local function WaitLock()
	wait_lockdown = false
	timer.Destroy("spamlock")
end

function fprp.lockdown(ply)
	local show = ply:EntIndex() == 0 and print or fp{fprp.notify, ply, 1, 4}
	if GetGlobalBool("fprp_LockDown") then
		show(fprp.getPhrase("unable", "/lockdown", fprp.getPhrase("stop_lockdown")))
		return ""
	end

	if ply:EntIndex() ~= 0 and (not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor) then
		show(fprp.getPhrase("incorrect_job", "/lockdown", ""))
		return ""
	end

	for k,v in pairs(player.GetAll()) do
		v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
	end

	fprp.printMessageAll(HUD_PRINTTALK, fprp.getPhrase("lockdown_started"))
	SetGlobalBool("fprp_LockDown", true)
	fprp.notifyAll(0, 3, fprp.getPhrase("lockdown_started"))

	return ""
end
concommand.Add("rp_lockdown", function(ply) fprp.lockdown(ply) end)
fprp.defineChatCommand("lockdown", function(ply) fprp.lockdown(ply) end)

function fprp.unLockdown(ply)
	local show = ply:EntIndex() == 0 and print or fp{fprp.notify, ply, 1, 4}

	if not GetGlobalBool("fprp_LockDown") then
		show(fprp.getPhrase("unable", "/unlockdown", fprp.getPhrase("lockdown_ended")))
		return ""
	end
	if wait_lockdown then
		show(fprp.getPhrase("wait_with_that"))
		return ""
	end

	if ply:EntIndex() ~= 0 and (not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor) then
		show(fprp.getPhrase("incorrect_job", "/unlockdown", ""))
		return ""
	end

	fprp.printMessageAll(HUD_PRINTTALK, fprp.getPhrase("lockdown_ended"))
	fprp.notifyAll(0, 3, fprp.getPhrase("lockdown_ended"))
	wait_lockdown = true
	SetGlobalBool("fprp_LockDown", false)
	timer.Create("spamlock", 20, 1, WaitLock)

	return ""
end
concommand.Add("rp_unlockdown", function(ply) fprp.unLockdown(ply) end)
fprp.defineChatCommand("unlockdown", function(ply) fprp.unLockdown(ply) end)

/*---------------------------------------------------------
 License
 ---------------------------------------------------------*/
local function GrantLicense(answer, Ent, Initiator, Target)
	Initiator.LicenseRequested = nil
	if tobool(answer) then
		fprp.notify(Initiator, 0, 4, fprp.getPhrase("gunlicense_granted", Target:Nick(), Initiator:Nick()))
		fprp.notify(Target, 0, 4, fprp.getPhrase("gunlicense_granted", Target:Nick(), Initiator:Nick()))
		Initiator:setfprpVar("HasGunlicense", true)
	else
		fprp.notify(Initiator, 1, 4, fprp.getPhrase("gunlicense_denied", Target:Nick(), Initiator:Nick()))
	end
end

local function RequestLicense(ply)
	if ply:getfprpVar("HasGunlicense") or ply.LicenseRequested then
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/requestlicense", ""))
		return ""
	end
	local LookingAt = ply:GetEyeTrace().Entity

	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].mayor and not v:getfprpVar("AFK") then
			ismayor = true
			break
		end
	end

	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].chief and not v:getfprpVar("AFK") then
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
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/requestlicense", ""))
		return ""
	end

	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("must_be_looking_at", "mayor/chief/cop"))
		return ""
	end

	if ismayor and (not RPExtraTeams[LookingAt:Team()] or not RPExtraTeams[LookingAt:Team()].mayor) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("must_be_looking_at", "mayor"))
		return ""
	elseif ischief and (not RPExtraTeams[LookingAt:Team()] or not RPExtraTeams[LookingAt:Team()].chief) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("must_be_looking_at", "chief"))
		return ""
	elseif iscop and not LookingAt:isCP() then
		fprp.notify(ply, 1, 4, fprp.getPhrase("must_be_looking_at", "cop"))
		return ""
	end

	ply.LicenseRequested = true
	fprp.notify(ply, 3, 4, fprp.getPhrase("gunlicense_requested", ply:Nick(), LookingAt:Nick()))
	fprp.createQuestion(fprp.getPhrase("gunlicense_question_text", ply:Nick()), "Gunlicense"..ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
	return ""
end
fprp.defineChatCommand("requestlicense", RequestLicense)

local function GiveLicense(ply)
	local noMayorExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(ply.isMayor), player.GetAll}
	local noChiefExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(ply.isChief), player.GetAll}

	local canGiveLicense = fn.FOr{
		ply.isMayor, -- Mayors can hand out licenses
		fn.FAnd{ply.isChief, noMayorExists}, -- Chiefs can if there is no mayor
		fn.FAnd{ply.isCP, noChiefExists, noMayorExists} -- CP's can if there are no chiefs nor mayors
	}

	if not canGiveLicense(ply) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("incorrect_job", "/givelicense"))
		return ""
	end

	local LookingAt = ply:GetEyeTrace().Entity
	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("must_be_looking_at", "player"))
		return ""
	end

	fprp.notify(LookingAt, 0, 4, fprp.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
	fprp.notify(ply, 0, 4, fprp.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
	LookingAt:setfprpVar("HasGunlicense", true)

	return ""
end
fprp.defineChatCommand("givelicense", GiveLicense)

local function rp_GiveLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, fprp.getPhrase("need_sadmin", "rp_givelicense"))
		return
	end

	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		end
		return
	end

	local target = fprp.findPlayer(args[1])

	if target then
		target:setfprpVar("HasGunlicense", true)

		local nick, steamID
		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
			steamID = ply:SteamID()
		else
			nick = "Console"
			steamID = "Console"
		end

		fprp.notify(target, 0, 4, fprp.getPhrase("gunlicense_granted", nick, target:Nick()))
		if ply ~= target then
			if ply:EntIndex() == 0 then
				print(fprp.getPhrase("gunlicense_granted", nick, target:Nick()))
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("gunlicense_granted", nick, target:Nick()))
			end
		end
		fprp.log(nick.." ("..steamID..") force-gave "..target:Nick().." a gun license", Color(30, 30, 30))
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])))
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])))
		end
	end
end
concommand.Add("rp_givelicense", rp_GiveLicense)

local function rp_RevokeLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, fprp.getPhrase("need_sadmin", "rp_revokelicense"))
		return
	end

	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		end
		return
	end

	local target = fprp.findPlayer(args[1])

	if target then
		target:setfprpVar("HasGunlicense", nil)

		local nick, steamID
		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
			steamID = ply:SteamID()
		else
			nick = "Console"
			steamID = "Console"
		end

		fprp.notify(target, 1, 4, fprp.getPhrase("gunlicense_denied", nick, target:Nick()))
		if ply ~= target then
			if ply:EntIndex() == 0 then
				print(fprp.getPhrase("gunlicense_denied", nick, target:Nick()))
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("gunlicense_granted", nick, target:Nick()))
			end
		end
		fprp.log(nick.." ("..steamID..") force-removed "..target:Nick().."'s gun license", Color(30, 30, 30))
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])))
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])))
		end
	end
end
concommand.Add("rp_revokelicense", rp_RevokeLicense)

local function FinishRevokeLicense(vote, win)
	if choice == 1 then
		vote.target:setfprpVar("HasGunlicense", nil)
		vote.target:StripWeapons()
		gamemode.Call("PlayerLoadout", vote.target)
		fprp.notifyAll(0, 4, fprp.getPhrase("gunlicense_removed", vote.target:Nick()))
	else
		fprp.notifyAll(0, 4, fprp.getPhrase("gunlicense_not_removed", vote.target:Nick()))
	end
end

local function VoteRemoveLicense(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("vote_specify_reason"))
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 22 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/demotelicense", "<23"))
		return ""
	end
	local p = fprp.findPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			fprp.notify(ply, 1, 4, fprp.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demotelicense"))
			return ""
		end
		if ply:getfprpVar("HasGunlicense") then
			fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/demotelicense", ""))
		else
			fprp.notifyAll(0, 4, fprp.getPhrase("gunlicense_remove_vote_text", ply:Nick(), p:Nick()))
			fprp.createVote(p:Nick() .. ":\n"..fprp.getPhrase("gunlicense_remove_vote_text2", reason), "removegunlicense", p, 20,  FinishRevokeLicense,
			{
				[p] = true,
				[ply] = true
			})
			ply:GetTable().LastVoteCop = CurTime()
			fprp.notify(ply, 0, 4, fprp.getPhrase("vote_started"))
		end
		return ""
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", tostring(args)))
		return ""
	end
end
fprp.defineChatCommand("demotelicense", VoteRemoveLicense)
