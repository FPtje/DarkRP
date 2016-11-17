local function RCon(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "RCon") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local CommandArgs = table.Copy(args)
    CommandArgs[1] = nil
    CommandArgs = table.ClearKeys(CommandArgs)
    RunConsoleCommand(args[1], unpack(CommandArgs))

    return true, args[1], CommandArgs
end

FAdmin.StartHooks["RCon"] = function()
    FAdmin.Commands.AddCommand("RCon", RCon)

    FAdmin.Access.AddPrivilege("RCon", 3) -- Root only
end
