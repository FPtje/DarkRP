local function SetHealth(ply, cmd, args)
	if not args[1] then return end

	local Health = tonumber(args[2] or 100)
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) or not targets then
		targets = {ply}
		Health = math.floor(tonumber(args[1] or 100))
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "SetHealth", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) then
			target:SetHealth(Health)
		end
	end

	FAdmin.Messages.ActionMessage(ply, targets, "You've set the health of %s to ".. Health, "Your health was set by %s", "Set the health of %s to ".. Health)
end

FAdmin.StartHooks["Health"] = function()
	FAdmin.Commands.AddCommand("SetHealth", SetHealth)
	FAdmin.Commands.AddCommand("hp", SetHealth)

	FAdmin.Access.AddPrivilege("SetHealth", 2)
end