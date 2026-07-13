local Vote = {}
local Votes = {}

local function ccDoVote(ply, cmd, args)
    if ply:EntIndex() == 0 then
        print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
        return
    end

    local vote = Votes[tonumber(args[1] or 0)]

    if not vote then return end
    if args[2] ~= "yea" and args[2] ~= "nay" then return end

    local canVote, message = hook.Call("canVote", GAMEMODE, ply, vote)

    if vote.voters[ply] or vote.exclude[ply] or canVote == false then
        DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("you_cannot_vote"))
        return
    end
    vote.voters[ply] = true

    vote:handleNewVote(ply, args[2])
end
concommand.Add("vote", ccDoVote)

function Vote:handleNewVote(ply, choice)
    self[choice] = self[choice] + 1

    local excludeCount = table.Count(self.exclude)
    local voteCount = table.Count(self.voters)

    if voteCount >= player.GetCount() - excludeCount then
        self:handleEnd()
    end
end

function Vote:handleEnd()
    local win = hook.Call("getVoteResults", nil, self, self.yea, self.nay)
    win = win or self.yea > self.nay and 1 or self.nay > self.yea and -1 or 0

    umsg.Start("KillVoteVGUI", self:getFilter())
        umsg.String(self.id)
    umsg.End()

    Votes[self.id] = nil
    timer.Remove(self.id .. "DarkRPVote")

    self:callback(win)
end

function Vote:getFilter()
    local filter = RecipientFilter()

    for _, v in ipairs(player.GetAll()) do
        if self.exclude[v] then continue end
        local canVote = hook.Call("canVote", GAMEMODE, v, self)

        if canVote == false then
            self.exclude[v] = true
            continue
        end

        filter:AddPlayer(v)
    end

    return filter
end

function DarkRP.hooks:canStartVote(newvote)
    if player.GetCount() <= table.Count(newvote.exclude) then
        local ply = istable(newvote.info) and isentity(newvote.info.source) and newvote.info.source or newvote.target
        if ply and ply:IsPlayer() then
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("vote_alone"))
        end
        return false, true
    end
    return true
end

function DarkRP.createVote(question, voteType, target, time, callback, excludeVoters, fail, extraInfo)
    excludeVoters = excludeVoters or {[target] = true}

    local newvote = {}
    setmetatable(newvote, {__index = Vote})

    newvote.id = table.insert(Votes, newvote)
    newvote.question = question
    newvote.votetype = voteType
    newvote.target = target
    newvote.time = time
    newvote.callback = callback
    newvote.fail = fail or function() end
    newvote.exclude = excludeVoters
    newvote.voters = {}
    newvote.info = extraInfo

    newvote.yea = 0
    newvote.nay = 0

    local ply = istable(extraInfo) and isentity(extraInfo.source) and extraInfo.source or target

    local canStart, callSuccess, message = hook.Call("canStartVote", DarkRP.hooks, newvote)
    if not canStart then
        if callSuccess then
            newvote:callback(1)
        else
            if ply:IsPlayer() then
                DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", DarkRP.getPhrase("create_vote_for_job"), ""))
            end
            newvote:fail()
        end
        return
    end

    hook.Call("onVoteStarted", nil, newvote)

    if ply:IsPlayer() then
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("vote_started"))
    end

    umsg.Start("DoVote", newvote:getFilter())
        umsg.String(question)
        umsg.Short(newvote.id)
        umsg.Float(time)
    umsg.End()

    timer.Create(newvote.id .. "DarkRPVote", time, 1, function() newvote:handleEnd() end)

    return newvote
end

function DarkRP.destroyVotesWithEnt(ent)
    for k, v in pairs(Votes) do
        if v.target ~= ent then continue end

        timer.Remove(v.id .. "DarkRPVote")
        umsg.Start("KillVoteVGUI", v:getFilter())
            umsg.Short(v.id)
        umsg.End()

        v:fail()

        Votes[k] = nil
    end
end

function DarkRP.destroyLastVote()
    local lastVote = Votes[#Votes]

    if not lastVote then return false end

    timer.Remove(lastVote.id .. "DarkRPVote")
    umsg.Start("KillVoteVGUI", lastVote:getFilter())
        umsg.Short(lastVote.id)
    umsg.End()

    lastVote:fail()

    Votes[lastVote.id] = nil

    return true
end

local function CancelVote(ply)
    local result = DarkRP.destroyLastVote()

    if result then
        DarkRP.notifyAll(0, 4, DarkRP.getPhrase("x_cancelled_vote", ply:EntIndex() ~= 0 and ply:Nick() or "Console"))
        if ply:EntIndex() == 0 then
            print(DarkRP.getPhrase("x_cancelled_vote", "Console"))
        end
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_cancel_vote"))
    end
end
DarkRP.definePrivilegedChatCommand("forcecancelvote", "DarkRP_AdminCommands", CancelVote)
