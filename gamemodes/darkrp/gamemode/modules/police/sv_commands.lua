local function updateAgenda(ply, agenda, text)
    local txt = hook.Run("agendaUpdated", ply, agenda, text)

    agenda.text = txt or text

    local phrase = DarkRP.getPhrase("agenda_updated")
    for _, v in ipairs(player.GetAll()) do
        if v:getAgendaTable() ~= agenda then continue end

        v:setSelfDarkRPVar("agenda", agenda.text)
        DarkRP.notify(v, 2, 4, phrase)
    end
end

local function CreateAgenda(ply, args)
    local agenda = ply:getAgendaTable()

    if not agenda or not agenda.ManagersByKey[ply:Team()] then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("agenda")))
        return ""
    end

    updateAgenda(ply, agenda, args)

    return ""
end
DarkRP.defineChatCommand("agenda", CreateAgenda, 0.1)

local function addAgenda(ply, args)
    local agenda = ply:getAgendaTable()

    if not agenda or not agenda.ManagersByKey[ply:Team()] then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("agenda")))
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
    local hasEntered = table.HasValue(LotteryPeople, target)
    if tobool(answer) and not hasEntered then
        if not target:canAfford(LotteryAmount) then
            DarkRP.notify(target, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("lottery")))

            return
        end
        table.insert(LotteryPeople, target)
        target:addMoney(-LotteryAmount)
        DarkRP.notify(target, 0,4, DarkRP.getPhrase("lottery_entered", DarkRP.formatMoney(LotteryAmount)))
        hook.Run("playerEnteredLottery", target)
    elseif IsValid(target) and answer ~= nil and not hasEntered then
        DarkRP.notify(target, 1,4, DarkRP.getPhrase("lottery_not_entered", target:Nick()))
    end

    if TimeIsUp then
        LotteryON = false
        CanLottery = CurTime() + 60

        for i = #LotteryPeople, 1, -1 do
            if not IsValid(LotteryPeople[i]) then table.remove(LotteryPeople, i) end
        end

        if table.IsEmpty(LotteryPeople) then
            DarkRP.notifyAll(1, 4, DarkRP.getPhrase("lottery_noone_entered"))
            hook.Run("lotteryEnded", LotteryPeople)
            return
        end
        local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
        local amt = #LotteryPeople * LotteryAmount
        hook.Run("lotteryEnded", LotteryPeople, chosen, amt)
        chosen:addMoney(amt)
        DarkRP.notifyAll(0, 10, DarkRP.getPhrase("lottery_won", chosen:Nick(), DarkRP.formatMoney(amt)))
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

    if player.GetCount() <= 2 then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("too_few_players_for_lottery", 2))
        return ""
    end

    if LotteryON then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("lottery_ongoing"))
        return ""
    end

    if CanLottery > CurTime() then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("have_to_wait", tostring(CanLottery - CurTime()), "/lottery"))
        return ""
    end

    amount = DarkRP.toInt(amount)
    if not amount then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("lottery_please_specify_an_entry_cost", DarkRP.formatMoney(GAMEMODE.Config.minlotterycost), DarkRP.formatMoney(GAMEMODE.Config.maxlotterycost)))
        return ""
    end

    LotteryAmount = math.Clamp(amount, GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost)

    hook.Run("lotteryStarted", ply, LotteryAmount)

    LotteryON = true
    LotteryPeople = {}

    local phrase = DarkRP.getPhrase("lottery_has_started", DarkRP.formatMoney(LotteryAmount))
    for k, v in ipairs(player.GetAll()) do
        if v ~= ply then
            DarkRP.createQuestion(phrase, "lottery_" .. tostring(k), v, 30, EnterLottery, ply, v)
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

    for _, v in ipairs(player.GetAll()) do
        v:ConCommand("play " .. GAMEMODE.Config.lockdownsound .. "\n")
    end

    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
    SetGlobalBool("DarkRP_LockDown", true)
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))

    hook.Run("lockdownStarted", ply)

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

    hook.Run("lockdownEnded", ply)

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
    for _, v in ipairs(player.GetAll()) do
        if v:isMayor() and not v:getDarkRPVar("AFK") then
            ismayor = true
            break
        end
    end

    if not ismayor then
        for _, v in ipairs(player.GetAll()) do
            if v:isChief() and not v:getDarkRPVar("AFK") then
                ischief = true
                break
            end
        end
    end

    if not ischief and not ismayor then
        for _, v in ipairs(player.GetAll()) do
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

    local mayors, chiefs, cops = {}, {}, {}
    for teamNr, jobTable in pairs(RPExtraTeams) do
        if jobTable.mayor then
            table.insert(mayors, jobTable.name)
        end

        if jobTable.chief then
            table.insert(chiefs, jobTable.name)
        end

        if GAMEMODE.CivilProtection[teamNr] then
            table.insert(cops, jobTable.name)
        end

    end
    mayors = table.concat(mayors, ", ")
    chiefs = table.concat(chiefs, ", ")
    cops   = table.concat(cops, ", ")

    if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():DistToSqr(ply:GetPos()) > 10000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", cops))
        return ""
    end

    if ismayor and not LookingAt:isMayor() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", mayors))
        return ""
    elseif ischief and not LookingAt:isChief() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", chiefs))
        return ""
    elseif iscop and not LookingAt:isCP() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", cops))
        return ""
    end

    ply.LicenseRequested = true
    DarkRP.notify(ply, 3, 4, DarkRP.getPhrase("gunlicense_requested", ply:Nick(), LookingAt:Nick()))
    DarkRP.createQuestion(DarkRP.getPhrase("gunlicense_question_text", ply:Nick()), "Gunlicense" .. ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
    return ""
end
DarkRP.defineChatCommand("requestlicense", RequestLicense)

local function GiveLicense(ply)
    local LookingAt = ply:GetEyeTrace().Entity
    if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():DistToSqr(ply:GetPos()) > 10000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("player")))
        return ""
    end

    local canGive, cantGiveReason = hook.Call("canGiveLicense", DarkRP.hooks, ply, LookingAt)
    if canGive == false then
        cantGiveReason = isstring(cantGiveReason) and cantGiveReason or DarkRP.getPhrase("unable", "/givelicense", "")
        DarkRP.notify(ply, 1, 4, cantGiveReason)
        return ""
    end

    DarkRP.notify(LookingAt, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
    LookingAt:setDarkRPVar("HasGunlicense", true)

    hook.Run("playerGotLicense", LookingAt, ply)

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
    if win == 1 then
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
