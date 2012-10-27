CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) -- Don't save this one!

-----------------------------------------------------------
-- TOGGLE COMMANDS --
-----------------------------------------------------------

function GM:AddTeamCommands(CTeam, max)
	if CLIENT then return end
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end

	if CTeam.vote then
		AddChatCommand("/vote"..CTeam.command, function(ply)
			if type(CTeam.NeedToChangeFrom) == "number" and ply:Team() ~= CTeam.NeedToChangeFrom then
				GAMEMODE:Notify(ply, 1,4, string.format(LANGUAGE.need_to_be_before, team.GetName(CTeam.NeedToChangeFrom), CTeam.name))
				return ""
			elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
				local teamnames = ""
				for a,b in pairs(CTeam.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
				GAMEMODE:Notify(ply, 1,4, string.format(LANGUAGE.need_to_be_before, string.sub(teamnames, 5), CTeam.name))
				return ""
			end
			if #player.GetAll() == 1 then
				GAMEMODE:Notify(ply, 0, 4, LANGUAGE.vote_alone)
				ply:ChangeTeam(k)
				return ""
			end
			if not ply:ChangeAllowed(k) then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/vote"..CTeam.command, "banned/demoted"))
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), CTeam.command))
				return ""
			end
			if ply:Team() == k then
				GAMEMODE:Notify(ply, 1, 4,  string.format(LANGUAGE.unable, CTeam.command, ""))
				return ""
			end
			local max = CTeam.max
			if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				GAMEMODE:Notify(ply, 1, 4,  string.format(LANGUAGE.team_limit_reached,CTeam.name))
				return ""
			end
			GAMEMODE.vote:Create(string.format(LANGUAGE.wants_to_be, ply:Nick(), CTeam.name), ply:EntIndex() .. "votecop", ply, 20, function(choice, ply)
				if choice == 1 then
					ply:ChangeTeam(k)
				else
					GAMEMODE:NotifyAll(1, 4, string.format(LANGUAGE.has_not_been_made_team, ply:Nick(), CTeam.name))
				end
			end)
			ply:GetTable().LastVoteCop = CurTime()
			return ""
		end)
		AddChatCommand("/"..CTeam.command, function(ply)
			if ply:HasPriv("rp_"..CTeam.command) then
				ply:ChangeTeam(k, true)
				return ""
			end

			local a = CTeam.admin
			if a > 0 and not ply:IsAdmin()
			or a > 1 and not ply:IsSuperAdmin()
			then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, CTeam.name))
				return ""
			end

			if a == 0 and not ply:IsAdmin()
			or a == 1 and not ply:IsSuperAdmin()
			or a == 2
			then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_to_make_vote, CTeam.name))
				return ""
			end

			ply:ChangeTeam(k, true)
			return ""
		end)
	else
		AddChatCommand("/"..CTeam.command, function(ply)
			if CTeam.admin == 1 and not ply:IsAdmin() then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/"..CTeam.command))
				return ""
			end
			if CTeam.admin > 1 and not ply:IsSuperAdmin() then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_sadmin, "/"..CTeam.command))
				return ""
			end
			ply:ChangeTeam(k)
			return ""
		end)
	end

	concommand.Add("rp_"..CTeam.command, function(ply, cmd, args)
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
			return
        end

		if CTeam.admin > 1 and not ply:IsSuperAdmin() then
			ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, cmd))
			return
		end

		if CTeam.vote then
			if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
				return
			elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, string.format(LANGUAGE.need_to_make_vote, CTeam.name))
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
				print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
			else
				ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
			end
			return
        end
	end)
end