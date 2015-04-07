local function SetHealth(ply, cmd, args)
	if not args[1] then return false end

	local Health = tonumber(args[2] or 100);
	if not Health then return false end

	local targets = FAdmin.FindPlayer(args[1]);
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		targets = {ply}
		Health = math.floor(tonumber(args[1] or 100));
		return false
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "SetHealth", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
		if IsValid(target) then
			target:SetHealth(Health);
		end
	end

	FAdmin.Messages.ActionMessage(ply, targets, "You've set the health of %s to ".. Health, "Your health was set by %s", "Set the health of %s to ".. Health);

	return true, targets, Health
end

FAdmin.StartHooks["Health"] = function()
	FAdmin.Commands.AddCommand("SetHealth", SetHealth);
	FAdmin.Commands.AddCommand("hp", SetHealth);

	FAdmin.Access.AddPrivilege("SetHealth", 2);
end
