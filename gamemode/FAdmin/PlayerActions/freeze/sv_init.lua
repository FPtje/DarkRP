local function Freeze(ply, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Freeze", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_frozen") then
			target:FAdmin_SetGlobal("FAdmin_frozen", true)
			target:Lock()
		end
	end
	FAdmin.Messages.ActionMessage(ply, targets, "You have frozen %s", "You were frozen by %s", "Froze %s")
end

local function Unfreeze(ply, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Freeze", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_frozen") then
			target:FAdmin_SetGlobal("FAdmin_frozen", false)
			target:UnLock()
		end
	end
	FAdmin.Messages.ActionMessage(ply, targets, "You have unfrozen %s", "You were unfrozen by %s", "Unfroze %s")
end

FAdmin.StartHooks["Freeze"] = function()
	FAdmin.Commands.AddCommand("freeze", Freeze)
	FAdmin.Commands.AddCommand("unfreeze", Unfreeze)

	FAdmin.Access.AddPrivilege("Freeze", 2)
end

hook.Add("PlayerSpawnObject", "FAdmin_jail", function(ply)
	if ply:FAdmin_GetGlobal("FAdmin_frozen") then
		return false
	end
end)