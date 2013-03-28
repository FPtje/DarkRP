local function SetTeam(ply, cmd, args)
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for k,v in pairs(team.GetAllTeams()) do
		if k == tonumber(args[2]) or string.lower(v.Name) == string.lower(args[2] or "") then
			for _, target in pairs(targets) do
				if not FAdmin.Access.PlayerHasPrivilege(ply, "SetTeam", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
				local SetTeam = target.ChangeTeam or target.SetTeam -- DarkRP compatibility
				if IsValid(target) then
					SetTeam(target, k, true)
					end
			end
			FAdmin.Messages.ActionMessage(ply, targets, "You have set the team of %s", "Your team was set to "..v.Name.." by %s", "Set the team of %s")
			break
		end
	end
end

FAdmin.StartHooks["SetTeam"] = function()
	FAdmin.Commands.AddCommand("SetTeam", SetTeam)

	FAdmin.Access.AddPrivilege("SetTeam", 2)
end