local function RCon(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "RCon") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local CommandArgs = table.Copy(args)
	CommandArgs[1] = nil
	CommandArgs = table.ClearKeys(CommandArgs)
	RunConsoleCommand(args[1], unpack(CommandArgs))
end

FAdmin.StartHooks["RCon"] = function()
	FAdmin.Commands.AddCommand("RCon", RCon)

	FAdmin.Access.AddPrivilege("RCon", 3) -- Root only
end