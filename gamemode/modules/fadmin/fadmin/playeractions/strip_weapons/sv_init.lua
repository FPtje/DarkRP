local function StripWeapons(ply, cmd, args)
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "StripWeapons", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) then
			target:StripWeapons()
		end
	end

	FAdmin.Messages.ActionMessage(ply, targets, "Stripped the weapons of %s", "Your weapons were stripped by %s", "Stripped the weapons of %s")
end

FAdmin.StartHooks["StripWeapons"] = function()
	FAdmin.Commands.AddCommand("StripWeapons", StripWeapons)
	FAdmin.Commands.AddCommand("Strip", StripWeapons)

	FAdmin.Access.AddPrivilege("StripWeapons", 2)
end