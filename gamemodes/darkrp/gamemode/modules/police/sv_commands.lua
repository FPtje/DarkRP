local function updateAgenda(ply, agenda, text)
    local txt = hook.Run("agendaUpdated", ply, agenda, text)

    agenda.text = txt or text

    for k,v in pairs(player.GetAll()) do
        if v:getAgendaTable() ~= agenda then continue end

        v:setSelfDarkRPVar("agenda", agenda.text)
        DarkRP.notify(v, 2, 4, DarkRP.getPhrase("agenda_updated"))
    end
end

local function CreateAgenda(ply, args)
    local agenda = ply:getAgendaTable()
    local plyTeam = ply:Team()

    if not agenda or not agenda.ManagersByKey[plyTeam] then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("unable", "agenda", "Incorrect team"))
        return ""
    end

    updateAgenda(ply, agenda, args)

    return ""
end
DarkRP.defineChatCommand("agenda", CreateAgenda, 0.1)

local function addAgenda(ply, args)
    local agenda = ply:getAgendaTable()
    local plyTeam = ply:Team()

    if not agenda or not agenda.ManagersByKey[plyTeam] then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("unable", "agenda", "Incorrect team"))
        return ""
    end

    agenda.text = agenda.text or ""
    args = args or ""

    updateAgenda(ply, agenda, agenda.text .. '\n' .. args)

    return ""
end
DarkRP.defineChatCommand("addagenda", addAgenda, 0.1)

--[[---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------]]
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
        DarkRP.notify(target, 0,4, DarkRP.getPhrase("lottery_entered", DarkRP.formatMoney(LotteryAmount)))
        hook.Run("playerEnteredLottery", target)
    elseif IsValid(target) and answer ~= nil and not table.HasValue(LotteryPeople, target) then
        DarkRP.notify(target, 1,4, DarkRP.getPhrase("lottery_not_entered", "You"))
    end

    if TimeIsUp then
        LotteryON = false
        CanLottery = CurTime() + 60

        for i = #LotteryPeople, 1, -1 do
            if not IsValid(LotteryPeople[i]) then table.remove(LotteryPeople, i) end
        end

        if table.Count(LotteryPeople) == 0 then
            DarkRP.notifyAll(1, 4, DarkRP.getPhrase("lottery_noone_entered"))
            hook.Run("lotteryEnded", LotteryPeople, nil)
            return
        end
        local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
        hook.Run("lotteryEnded", LotteryPeople, chosen, #LotteryPeople * LotteryAmount)
        chosen:addMoney(#LotteryPeople * LotteryAmount)
        DarkRP.notifyAll(0, 10, DarkRP.getPhrase("lottery_won", chosen:Nick(), DarkRP.formatMoney(#LotteryPeople * LotteryAmount)))
    end
end

local function DoLottery(ply, amount)
    if not ply:isMayor() then
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

    hook.Run("lotteryStarted", ply, LotteryAmount)

    LotteryON = true
    LotteryPeople = {}
    for k,v in pairs(player.GetAll()) do
        if v ~= ply then
            DarkRP.createQuestion(DarkRP.getPhrase("lottery_has_started", DarkRP.formatMoney(LotteryAmount)), "lottery" .. tostring(k), v, 30, EnterLottery, ply, v)
        end
    end
    timer.Create("Lottery", 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
    return ""
end
DarkRP.defineChatCommand("lottery", DoLottery, 1)


local lastLockdown = -math.huge
function DarkRP.lockdown(ply)
    local show = ply:EntIndex() == 0 and print or fp{DarkRP.notify, ply, 1, 4}
    if GetGlobalBool("DarkRP_LockDown") then
        show(DarkRP.getPhrase("unable", "/lockdown", DarkRP.getPhrase("stop_lockdown")))
        return ""
    end

    if ply:EntIndex() ~= 0 and not ply:isMayor() then
        show(DarkRP.getPhrase("incorrect_job", "/lockdown", ""))
        return ""
    end

    if not GAMEMODE.Config.lockdown then
        show(ply, 1, 4, DarkRP.getPhrase("disabled", "lockdown", ""))
        return ""
    end

    if lastLockdown > CurTime() - GAMEMODE.Config.lockdowndelay then
        show(DarkRP.getPhrase("wait_with_that"))
        return ""
    end

    for _, v in pairs(player.GetAll()) do
        v:ConCommand("play " .. GAMEMODE.Config.lockdownsound .. "\n")
    end

    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
    SetGlobalBool("DarkRP_LockDown", true)
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))

    return ""
end
DarkRP.defineChatCommand("lockdown", DarkRP.lockdown)

function DarkRP.unLockdown(ply)
    local show = ply:EntIndex() == 0 and print or fp{DarkRP.notify, ply, 1, 4}

    if not GetGlobalBool("DarkRP_LockDown") then
        show(DarkRP.getPhrase("unable", "/unlockdown", DarkRP.getPhrase("lockdown_ended")))
        return ""
    end

    if ply:EntIndex() ~= 0 and not ply:isMayor() then
        show(DarkRP.getPhrase("incorrect_job", "/unlockdown", ""))
        return ""
    end

    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_ended"))
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_ended"))
    SetGlobalBool("DarkRP_LockDown", false)

    lastLockdown = CurTime()

    return ""
end
DarkRP.defineChatCommand("unlockdown", DarkRP.unLockdown)

--[[---------------------------------------------------------
 License
 ---------------------------------------------------------]]
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
        if v:isMayor() and not v:getDarkRPVar("AFK") then
            ismayor = true
            break
        end
    end

    if not ismayor then
        for k,v in pairs(player.GetAll()) do
            if v:isChief() and not v:getDarkRPVar("AFK") then
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

    if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():DistToSqr(ply:GetPos()) > 10000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "mayor/chief/cop"))
        return ""
    end

    if ismayor and not LookingAt:isMayor() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "mayor"))
        return ""
    elseif ischief and not LookingAt:isChief() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "chief"))
        return ""
    elseif iscop and not LookingAt:isCP() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "cop"))
        return ""
    end

    ply.LicenseRequested = true
    DarkRP.notify(ply, 3, 4, DarkRP.getPhrase("gunlicense_requested", ply:Nick(), LookingAt:Nick()))
    DarkRP.createQuestion(DarkRP.getPhrase("gunlicense_question_text", ply:Nick()), "Gunlicense" .. ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
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
    if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():DistToSqr(ply:GetPos()) > 10000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "player"))
        return ""
    end

    DarkRP.notify(LookingAt, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
    LookingAt:setDarkRPVar("HasGunlicense", true)

    return ""
end
DarkRP.defineChatCommand("givelicense", GiveLicense)

local function rp_GiveLicense(ply, arg)
    local target = DarkRP.findPlayer(arg)

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(arg)))
        return
    end

    target:setDarkRPVar("HasGunlicense", true)

    local nick, steamID
    if ply:EntIndex() ~= 0 then
        nick = ply:Nick()
        steamID = ply:SteamID()
    else
        nick = "Console"
        steamID = "Console"
    end

    DarkRP.notify(target, 0, 4, DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
    if ply ~= target then
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
    end
    DarkRP.log(nick .. " (" .. steamID .. ") force-gave " .. target:Nick() .. " a gun license", Color(30, 30, 30))
end
DarkRP.definePrivilegedChatCommand("setlicense", "DarkRP_SetLicense", rp_GiveLicense)

local function rp_RevokeLicense(ply, arg)
    local target = DarkRP.findPlayer(arg)

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(arg)))
        return
    end

    target:setDarkRPVar("HasGunlicense", nil)

    local nick, steamID
    if ply:EntIndex() ~= 0 then
        nick = ply:Nick()
        steamID = ply:SteamID()
    else
        nick = "Console"
        steamID = "Console"
    end

    DarkRP.notify(target, 1, 4, DarkRP.getPhrase("gunlicense_denied", nick, target:Nick()))
    if ply ~= target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("gunlicense_denied", nick, target:Nick()))
    end
    DarkRP.log(nick .. " (" .. steamID .. ") force-removed " .. target:Nick() .. "'s gun license", Color(30, 30, 30))
end
DarkRP.definePrivilegedChatCommand("unsetlicense", "DarkRP_SetLicense", rp_RevokeLicense)

local function FinishRevokeLicense(vote, win)
    if choice == 1 then
        vote.target:setDarkRPVar("HasGunlicense", nil)
        vote.target:StripWeapons()
        gamemode.Call("PlayerLoadout", vote.target)
        DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_removed", vote.target:Nick()))
    else
        DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_not_removed", vote.target:Nick()))
    end
end

local function VoteRemoveLicense(ply, args)
    if #args == 1 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("vote_specify_reason"))
        return ""
    end
    local reason = ""
    for i = 2, #args, 1 do
        reason = reason .. " " .. args[i]
    end
    reason = string.sub(reason, 2)
    if string.len(reason) > 22 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demotelicense", "<23"))
        return ""
    end
    local p = DarkRP.findPlayer(args[1])
    if p then
        if CurTime() - ply.LastVoteCop < 80 then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demotelicense"))
            return ""
        end
        if ply:getDarkRPVar("HasGunlicense") then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demotelicense", ""))
        else
            local voteInfo = DarkRP.createVote(p:Nick() .. ":\n" .. DarkRP.getPhrase("gunlicense_remove_vote_text2", reason), "removegunlicense", p, 20, FinishRevokeLicense, {
                [p] = true,
                [ply] = true
            }, nil, nil, {
                source = ply
            })

            if voteInfo then
                -- Vote has started
                DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_remove_vote_text", ply:Nick(), p:Nick()))
            end
            ply.LastVoteCop = CurTime()
        end
        return ""
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        return ""
    end
end
DarkRP.defineChatCommand("demotelicense", VoteRemoveLicense)
