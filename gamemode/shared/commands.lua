CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) -- Don't save this one!

-----------------------------------------------------------
-- TOGGLE COMMANDS --
-----------------------------------------------------------

function GM:AddTeamCommands(CTeam, max)
	if CLIENT then return end

	if not self:CustomObjFitsMap(CTeam) then return end
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end

	if CTeam.vote or CTeam.RequiresVote then
		AddChatCommand("/vote"..CTeam.command, function(ply)
			if CTeam.RequiresVote and not CTeam.RequiresVote(ply, k) then
				GAMEMODE:Notify(ply, 1,4, "This job does not require a vote at this moment!")
				return ""
			end
			if type(CTeam.NeedToChangeFrom) == "number" and ply:Team() ~= CTeam.NeedToChangeFrom then
				GAMEMODE:Notify(ply, 1,4, DarkRP.getPhrase("need_to_be_before", team.GetName(CTeam.NeedToChangeFrom), CTeam.name))
				return ""
			elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
				local teamnames = ""
				for a,b in pairs(CTeam.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
				GAMEMODE:Notify(ply, 1,4, DarkRP.getPhrase("need_to_be_before", string.sub(teamnames, 5), CTeam.name))
				return ""
			end

			if CTeam.customCheck and not CTeam.customCheck(ply) then
				GAMEMODE:Notify(ply, 1, 4, CTeam.CustomCheckFailMsg or DarkRP.getPhrase("unable", team.GetName(t), ""))
				return ""
			end
			if #player.GetAll() == 1 then
				GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("vote_alone"))
				ply:ChangeTeam(k)
				return ""
			end
			if not ply:ChangeAllowed(k) then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "/vote"..CTeam.command, "banned/demoted"))
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), CTeam.command))
				return ""
			end
			if ply:Team() == k then
				GAMEMODE:Notify(ply, 1, 4,  DarkRP.getPhrase("unable", CTeam.command, ""))
				return ""
			end
			local max = CTeam.max
			if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				GAMEMODE:Notify(ply, 1, 4,  DarkRP.getPhrase("team_limit_reached",CTeam.name))
				return ""
			end
			GAMEMODE.vote:create(DarkRP.getPhrase("wants_to_be", ply:Nick(), CTeam.name), "job", ply, 20, function(vote, choice)
				local ply = vote.target

				if not IsValid(ply) then return end
				if choice >= 0 then
					ply:ChangeTeam(k)
				else
					GAMEMODE:NotifyAll(1, 4, DarkRP.getPhrase("has_not_been_made_team", ply:Nick(), CTeam.name))
				end
			end)
			ply:GetTable().LastVoteCop = CurTime()
			return ""
		end)
		AddChatCommand("/"..CTeam.command, function(ply)
			if ply:HasPriv("rp_"..CTeam.command) then
				ply:ChangeTeam(k)
				return ""
			end

			local a = CTeam.admin
			if a > 0 and not ply:IsAdmin()
			or a > 1 and not ply:IsSuperAdmin()
			then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("need_admin", CTeam.name))
				return ""
			end

			if not CTeam.RequiresVote and
				(a == 0 and not ply:IsAdmin()
				or a == 1 and not ply:IsSuperAdmin()
				or a == 2)
			or CTeam.RequiresVote and CTeam.RequiresVote(ply, k)
			then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
				return ""
			end

			ply:ChangeTeam(k)
			return ""
		end)
	else
		AddChatCommand("/"..CTeam.command, function(ply)
			if CTeam.admin == 1 and not ply:IsAdmin() then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/"..CTeam.command))
				return ""
			end
			if CTeam.admin > 1 and not ply:IsSuperAdmin() then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("need_sadmin", "/"..CTeam.command))
				return ""
			end
			ply:ChangeTeam(k)
			return ""
		end)
	end

	concommand.Add("rp_"..CTeam.command, function(ply, cmd, args)
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			ply:PrintMessage(2, DarkRP.getPhrase("need_admin", cmd))
			return
        end

		if CTeam.admin > 1 and not ply:IsSuperAdmin() then
			ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", cmd))
			return
		end

		if CTeam.vote then
			if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, DarkRP.getPhrase("need_admin", cmd))
				return
			elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
				return
			end
		end

		if not args[1] then return end
		local target = GAMEMODE:FindPlayer(args[1])

        if (target) then
			target:ChangeTeam(k, true)
			if (ply:EntIndex() ~= 0) then
				nick = ply:Nick()
			else
				nick = "Console"
			end
			target:PrintMessage(2, nick .. " has made you a " .. CTeam.name .. "!")
        else
			if (ply:EntIndex() == 0) then
				print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
			else
				ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
			end
			return
        end
	end)
end

function GM:AddEntityCommands(tblEnt)
	if CLIENT then return end

	local function buythis(ply, args)
		if ply:isArrested() then return "" end
		if type(tblEnt.allowed) == "table" and not table.HasValue(tblEnt.allowed, ply:Team()) then
			GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", tblEnt.cmd))
			return ""
		end
		local cmdname = string.gsub(tblEnt.ent, " ", "_")

		if tblEnt.customCheck and not tblEnt.customCheck(ply) then
			GAMEMODE:Notify(ply, 1, 4, tblEnt.CustomCheckFailMsg or "You're not allowed to purchase this item")
			return ""
		end

		local max = tonumber(tblEnt.max or 3)

		if ply["max"..cmdname] and tonumber(ply["max"..cmdname]) >= tonumber(max) then
			GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("limit", tblEnt.cmd))
			return ""
		end

		if not ply:CanAfford(tblEnt.price) then
			GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", tblEnt.cmd))
			return ""
		end
		ply:AddMoney(-tblEnt.price)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local item = ents.Create(tblEnt.ent)
		item.dt = item.dt or {}
		item.dt.owning_ent = ply
		if item.Setowning_ent then item:Setowning_ent(ply) end
		item:SetPos(tr.HitPos)
		item.SID = ply.SID
		item.onlyremover = true
		item.allowed = tblEnt.allowed
		item:Spawn()
		local phys = item:GetPhysicsObject()
		if phys:IsValid() then phys:Wake() end

		GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", tblEnt.name, GAMEMODE.Config.currency..tblEnt.price))
		if not ply["max"..cmdname] then
			ply["max"..cmdname] = 0
		end
		ply["max"..cmdname] = ply["max"..cmdname] + 1
		return ""
	end
	AddChatCommand(tblEnt.cmd, buythis)
end
