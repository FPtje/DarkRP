--[[---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------]]
local meta = FindMetaTable("Player")
function meta:changeTeam(t, force, suppressNotification, ignoreMaxMembers)
    local prevTeam = self:Team()
    local notify = suppressNotification and fn.Id or DarkRP.notify
    local notifyAll = suppressNotification and fn.Id or DarkRP.notifyAll

    if self:isArrested() and not force then
        notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), ""))
        return false
    end

    local allowed, time = self:changeAllowed(t)
    if t ~= GAMEMODE.DefaultTeam and not allowed and not force then
        local notif = time and DarkRP.getPhrase("have_to_wait", math.ceil(time), "/job, " .. DarkRP.getPhrase("banned_or_demoted")) or DarkRP.getPhrase("unable", team.GetName(t), DarkRP.getPhrase("banned_or_demoted"))
        notify(self, 1, 4, notif)
        return false
    end

    if self.LastJob and GAMEMODE.Config.changejobtime - (CurTime() - self.LastJob) >= 0 and not force then
        notify(self, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(GAMEMODE.Config.changejobtime - (CurTime() - self.LastJob)), "/job"))
        return false
    end

    if self.IsBeingDemoted then
        self:teamBan()
        self.IsBeingDemoted = false
        self:changeTeam(GAMEMODE.DefaultTeam, true)
        DarkRP.destroyVotesWithEnt(self)
        notify(self, 1, 4, DarkRP.getPhrase("tried_to_avoid_demotion"))

        return false
    end


    if prevTeam == t then
        notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), ""))
        return false
    end

    local TEAM = RPExtraTeams[t]
    if not TEAM then return false end

    if TEAM.customCheck and not TEAM.customCheck(self) and (not force or force and not GAMEMODE.Config.adminBypassJobRestrictions) then
        local message = isfunction(TEAM.CustomCheckFailMsg) and TEAM.CustomCheckFailMsg(self, TEAM) or
            TEAM.CustomCheckFailMsg or
            DarkRP.getPhrase("unable", team.GetName(t), "")
        notify(self, 1, 4, message)
        return false
    end

    if not force then
        if isnumber(TEAM.NeedToChangeFrom) and prevTeam ~= TEAM.NeedToChangeFrom then
            notify(self, 1,4, DarkRP.getPhrase("need_to_be_before", team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
            return false
        elseif istable(TEAM.NeedToChangeFrom) and not table.HasValue(TEAM.NeedToChangeFrom, prevTeam) then
            local teamnames = ""
            for _, b in pairs(TEAM.NeedToChangeFrom) do
                teamnames = teamnames .. " or " .. team.GetName(b)
            end
            notify(self, 1, 8, DarkRP.getPhrase("need_to_be_before", string.sub(teamnames, 5), TEAM.name))
            return false
        end
        local max = TEAM.max
        local numPlayers = team.NumPlayers(t)
        if not ignoreMaxMembers and
        max ~= 0 and -- No limit
        (max >= 1 and numPlayers >= max or -- absolute maximum
        max < 1 and (numPlayers + 1) / player.GetCount() > max) then -- fractional limit (in percentages)
            notify(self, 1, 4, DarkRP.getPhrase("team_limit_reached", TEAM.name))
            return false
        end
    end

    if TEAM.PlayerChangeTeam then
        local val = TEAM.PlayerChangeTeam(self, prevTeam, t)
        if val ~= nil then
            return val
        end
    end

    local hookValue, reason = hook.Call("playerCanChangeTeam", nil, self, t, force)
    if hookValue == false then
        if reason then
            notify(self, 1, 4, reason)
        end
        return false
    end

    local isMayor = RPExtraTeams[prevTeam] and RPExtraTeams[prevTeam].mayor
    if isMayor and GetGlobalBool("DarkRP_LockDown") then
        DarkRP.unLockdown(self)
    end
    self:updateJob(TEAM.name)
    self:setSelfDarkRPVar("salary", TEAM.salary)
    notifyAll(0, 4, DarkRP.getPhrase("job_has_become", self:Nick(), TEAM.name))


    if self:getDarkRPVar("HasGunlicense") and GAMEMODE.Config.revokeLicenseOnJobChange then
        self:setDarkRPVar("HasGunlicense", nil)
    end
    if TEAM.hasLicense then
        self:setDarkRPVar("HasGunlicense", true)
    end

    self.LastJob = CurTime()

    if GAMEMODE.Config.removeclassitems then
        -- Must not be ipairs, DarkRPEntities might have missing keys when
        -- DarkRP.removeEntity is called.
        for _, v in pairs(DarkRPEntities) do
            if GAMEMODE.Config.preventClassItemRemoval[v.ent] then continue end
            if not v.allowed then continue end
            if istable(v.allowed) and (table.HasValue(v.allowed, t) or not table.HasValue(v.allowed, prevTeam)) then continue end
            for _, e in ipairs(ents.FindByClass(v.ent)) do
                if e.SID == self.SID then e:Remove() end
            end
        end

        if not GAMEMODE.Config.preventClassItemRemoval["spawned_shipment"] then
            for _, v in ipairs(ents.FindByClass("spawned_shipment")) do
                if v.allowed and istable(v.allowed) and table.HasValue(v.allowed, t) then continue end
                if v.SID == self.SID then v:Remove() end
            end
        end
    end

    if isMayor then
        for _, ent in ipairs(self.lawboards or {}) do
            if IsValid(ent) then
                ent:Remove()
            end
        end
        self.lawboards = {}
    end

    if isMayor and GAMEMODE.Config.shouldResetLaws then
        DarkRP.resetLaws()
    end

    local DoEffect = false

    self:SetTeam(t)
    hook.Call("OnPlayerChangedTeam", GAMEMODE, self, prevTeam, t)
    DarkRP.log(self:Nick() .. " (" .. self:SteamID() .. ") changed to " .. team.GetName(t), nil, Color(100, 0, 255))
    if self:InVehicle() then self:ExitVehicle() end
    if GAMEMODE.Config.norespawn and self:Alive() then
        if GAMEMODE.Config.keepPickedUp then
            for k, v in ipairs(RPExtraTeams[prevTeam].weapons) do
                self:StripWeapon(v)
            end
        else
            self:StripWeapons()
            self:RemoveAllAmmo()
        end

        DoEffect = true
        player_manager.SetPlayerClass(self, TEAM.playerClass or "player_darkrp")
        self:applyPlayerClassVars(false)
        gamemode.Call("PlayerSetModel", self)
        gamemode.Call("PlayerLoadout", self)
    else
        if GAMEMODE.Config.instantjob then
            DoEffect = true

            self:StripWeapons()
            self:RemoveAllAmmo()
            self:Spawn()
        else
            self:KillSilent()
        end
    end

    if DoEffect then
        local vPoint = self:GetShootPos() + Vector(0,0,50)
        local effectdata = EffectData()
        effectdata:SetEntity(self)
        effectdata:SetStart(vPoint) -- Not sure if we need a start and origin (endpoint) for this effect, but whatever
        effectdata:SetOrigin(vPoint)
        effectdata:SetScale(1)
        util.Effect("entity_remove", effectdata)
    end

    umsg.Start("OnChangedTeam", self)
        umsg.Short(prevTeam)
        umsg.Short(t)
    umsg.End()
    return true
end

function meta:updateJob(job)
    self:setDarkRPVar("job", job)
    self.LastJob = CurTime()

    local timerid = self:SteamID64() .. "jobtimer"

    timer.Create(timerid, GAMEMODE.Config.paydelay, 0, function()
        if not IsValid(self) then
            timer.Remove(timerid)
            return
        end
        self:payDay()
    end)
end

function meta:teamUnBan(Team)
    self.bannedfrom = self.bannedfrom or {}

    local group = DarkRP.getDemoteGroup(Team)
    self.bannedfrom[group] = nil
end

function meta:teamBan(t, time)
    if not self.bannedfrom then self.bannedfrom = {} end
    t = t or self:Team()

    local group = DarkRP.getDemoteGroup(t)
    self.bannedfrom[group] = true

    local timerid = "teamban" .. self:UserID() .. "," .. group.value

    timer.Remove(timerid)

    if time == 0 then return end

    timer.Create(timerid, time or GAMEMODE.Config.demotetime, 1, function()
        if not IsValid(self) then return end
        self:teamUnBan(t)
    end)
end

function meta:teamBanTimeLeft(t)
    local group = DarkRP.getDemoteGroup(t or self:Team())
    return timer.TimeLeft("teamban" .. self:UserID() .. "," .. (group and group.value or ""))
end

function meta:changeAllowed(t)
    local group = DarkRP.getDemoteGroup(t)
    if self.bannedfrom and self.bannedfrom[group] then return false, self:teamBanTimeLeft(t) end

    return true
end

function GM:canChangeJob(ply, args)
    if ply:isArrested() then return false end
    if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then return false, DarkRP.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), "/job") end
    if not ply:Alive() then return false end

    local len = string.len(args)

    if len < 3 then return false, DarkRP.getPhrase("unable", "/job", ">2") end
    if len > 25 then return false, DarkRP.getPhrase("unable", "/job", "<26") end

    return true
end

--[[---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------]]
local function ChangeJob(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    if not GAMEMODE.Config.customjobs then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/job", ""))
        return ""
    end

    local canChangeJob, message, replace = gamemode.Call("canChangeJob", ply, args)
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
            local demoteTeam = hook.Call("demoteTeam", nil, target) or GAMEMODE.DefaultTeam
            target:changeTeam(demoteTeam, true)
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
    if #args == 0 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demote", ""))
        return ""
    end
    if #args == 1 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("vote_specify_reason"))
        return ""
    end
    local reason = table.concat(args, ' ', 2)

    if string.len(reason) > 99 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demote", "<100"))
        return ""
    end
    local p = DarkRP.findPlayer(args[1])
    if p == ply then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_demote_self"))
        return ""
    end

    local canDemote, message = hook.Call("canDemote", GAMEMODE, ply, p, reason)
    if canDemote == false then
        DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", "/demote", ""))
        return ""
    end

    if not p then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args and args[1]))
        return ""
    end

    if CurTime() - ply.LastVoteCop < 80 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"))
        return ""
    end

    local Team = p:Team()
    if not RPExtraTeams[Team] or RPExtraTeams[Team].candemote == false then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demote", ""))
    else
        DarkRP.talkToPerson(p, team.GetColor(ply:Team()), DarkRP.getPhrase("demote") .. " " .. ply:Nick(), Color(255, 0, 0, 255), DarkRP.getPhrase("i_want_to_demote_you", reason), p)

        local voteInfo = DarkRP.createVote(p:Nick() .. ":\n" .. DarkRP.getPhrase("demote_vote_text", reason), DarkRP.getPhrase("demote_vote"), p, 20, FinishDemote, {
            [p] = true,
            [ply] = true
        }, function(vote)
            if not IsValid(vote.target) then return end
            vote.target.IsBeingDemoted = nil
        end, {
            source = ply,
            reason = reason
        })

        if voteInfo then
            -- Vote has started
            DarkRP.notifyAll(0, 4, DarkRP.getPhrase("demote_vote_started", ply:Nick(), p:Nick()))
            DarkRP.log(DarkRP.getPhrase("demote_vote_started", string.format("%s(%s)[%s]", ply:Nick(), ply:SteamID(), team.GetName(ply:Team())), string.format("%s(%s)[%s] for %s", p:Nick(), p:SteamID(), team.GetName(p:Team()), reason)), Color(255, 128, 255, 255))
            p.IsBeingDemoted = true
        end
        ply.LastVoteCop = CurTime()
    end
    return ""
end
DarkRP.defineChatCommand("demote", Demote)

local function ExecSwitchJob(answer, ent, ply, target)
    if not IsValid(ply) or not IsValid(target) then return end

    ply.RequestedJobSwitch = nil
    if not tobool(answer) then return end
    local Pteam = ply:Team()
    local Tteam = target:Team()

    if not ply:changeTeam(Tteam, nil, nil, true) then return end
    if not target:changeTeam(Pteam, nil, nil, true) then
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
    local ent = eyetrace.Entity

    if not IsValid(ent) or not ent:IsPlayer() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", DarkRP.getPhrase("switch_jobs"), ""))
        return ""
    end

    local team1 = RPExtraTeams[ply:Team()]
    local team2 = RPExtraTeams[ent:Team()]

    if not team1 or not team2 then return "" end
    if team1 == team2 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", DarkRP.getPhrase("switch_jobs"), ""))
        return ""
    end
    if team1.customCheck and not team1.customCheck(ent) or team2.customCheck and not team2.customCheck(ply) then
        -- notify only the player trying to switch
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", DarkRP.getPhrase("switch_jobs"), ""))
        return ""
    end

    ply.RequestedJobSwitch = true
    DarkRP.createQuestion(DarkRP.getPhrase("job_switch_question", ply:Nick()), "switchjob" .. tostring(ply:EntIndex()), ent, 30, ExecSwitchJob, ply, ent)
    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("job_switch_requested"))

    return ""
end
DarkRP.defineChatCommand("switchjob", SwitchJob)
DarkRP.defineChatCommand("switchjobs", SwitchJob)
DarkRP.defineChatCommand("jobswitch", SwitchJob)


local function DoTeamBan(ply, args)
    local ent = args[1]
    local Team = args[2]

    if not Team then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    local target = DarkRP.findPlayer(ent)
    if not target or not IsValid(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", ent or ""))
        return
    end

    local found = false
    for k, v in pairs(RPExtraTeams) do
        if string.lower(v.name) == string.lower(Team) or string.lower(v.command) == string.lower(Team) or k == tonumber(Team or -1) then
            Team = k
            found = true
            break
        end
    end

    if not found then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", Team or ""))
        return
    end

    local time = tonumber(args[3] or 0)

    target:teamBan(tonumber(Team), time)

    local nick
    if ply:EntIndex() == 0 then
        nick = "Console"
    else
        nick = ply:Nick()
    end
    DarkRP.notifyAll(0, 5, DarkRP.getPhrase("x_teambanned_y_for_z", nick, target:Nick(), team.GetName(tonumber(Team)), time / 60))
end
DarkRP.definePrivilegedChatCommand("teamban", "DarkRP_AdminCommands", DoTeamBan)

local function DoTeamUnBan(ply, args)
    if #args < 2 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    local ent = args[1]
    local Team = args[2]

    local target = DarkRP.findPlayer(ent)
    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", ent or ""))
        return
    end

    local found = false
    for k, v in pairs(RPExtraTeams) do
        if string.lower(v.name) == string.lower(Team) or string.lower(v.command) == string.lower(Team) then
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
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", Team or ""))
        return
    end

    target:teamUnBan(tonumber(Team))

    local nick
    if ply:EntIndex() == 0 then
        nick = "Console"
    else
        nick = ply:Nick()
    end
    DarkRP.notifyAll(0, 5, DarkRP.getPhrase("x_teamunbanned_y", nick, target:Nick(), team.GetName(tonumber(Team))))
end
DarkRP.definePrivilegedChatCommand("teamunban", "DarkRP_AdminCommands", DoTeamUnBan)
