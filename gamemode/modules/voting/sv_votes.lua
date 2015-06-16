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

	if voteCount >= #player.GetAll() - excludeCount then
		self:handleEnd()
	end
end

function Vote:handleEnd()
	local win = hook.Call("getVoteResults", nil, self, self.yea, self.nay)
	win = win or self.yea > self.nay and 1 or self.nay > self.yea and -1 or 0

	net.Start("KillVoteVGUI")
		net.WriteString(self.id)
	net.Send(self:getFilter())

	Votes[self.id] = nil
	timer.Destroy(self.id .. "DarkRPVote")

	self:callback(win)
end

function Vote:getFilter()
	--local filter = RecipientFilter()
	local filter = {}

	for k,v in pairs(player.GetAll()) do
		if self.exclude[v] then continue end
		local canVote = hook.Call("canVote", GAMEMODE, v, self)

		if canVote == false then
			self.exclude[v] = true
			continue
		end

		table.insert(filter, v)
	end

	return filter
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

	if #player.GetAll() <= table.Count(excludeVoters) then
		DarkRP.notify(target, 0, 4, DarkRP.getPhrase("vote_alone"))
		newvote:callback(1)
		return
	end

	if target:IsPlayer() then
		DarkRP.notify(target, 1, 4, DarkRP.getPhrase("vote_started"))
	end

	net.Start("DoVote")
		net.WriteString(question)
		net.WriteUInt(newvote.id, 16)
		net.WriteFloat(time)
	net.Send(newvote:getFilter())

	timer.Create(newvote.id .. "DarkRPVote", time, 1, function() newvote:handleEnd() end)

	return newvote
end

function DarkRP.destroyVotesWithEnt(ent)
	for k, v in pairs(Votes) do
		if v.target ~= ent then continue end

		timer.Destroy(v.id .. "DarkRPVote")
		net.Start("KillVoteVGUI")
			net.WriteUInt(v.id, 16)
		net.Send(v:getFilter())

		v:fail()

		Votes[k] = nil
	end
end

function DarkRP.destroyLastVote()
	local lastVote = Votes[#Votes]

	if not lastVote then return false end

	timer.Destroy(lastVote.id .. "DarkRPVote")
	net.Start("KillVoteVGUI")
		net.WriteUInt(lastVote.id, 16)
	net.Send(lastVote:getFilter())

	lastVote:fail()

	Votes[lastVote.id] = nil

	return true
end

local function CancelVote(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_cancelvote"))
		return
	end

	local result = DarkRP.destroyLastVote()

	if result then
		DarkRP.notifyAll(0, 4, DarkRP.getPhrase("x_cancelled_vote", ply:EntIndex() ~= 0 and ply:Nick() or "Console"))
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("x_cancelled_vote", "Console"))
		end
	else
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("cant_cancel_vote"))
	end
end
concommand.Add("rp_cancelvote", CancelVote)
