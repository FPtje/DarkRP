local convar = CreateConVar("FAdmin_commandprefix", "/", {FCVAR_SERVER_CAN_EXECUTE})

SetGlobalString("FAdmin_commandprefix", convar:GetString())

cvars.AddChangeCallback("FAdmin_commandprefix", function()
    SetGlobalString("FAdmin_commandprefix", convar:GetString())
end)

hook.Add("PlayerSay", "FAdminChatCommands", function(ply, text, Team, dead)
    local prefix = convar:GetString()

    if string.sub(text, 1, 1) ~= prefix then return end

    local TExplode = string.Explode(" ", string.sub(text, 2))
    if not TExplode then return end

    for k, v in pairs(TExplode) do
        if string.sub(v, -1) == "," and TExplode[k + 1] then
            TExplode[k] = (TExplode[k] or "") .. (TExplode[k + 1] or "")
            table.remove(TExplode, k + 1)
        end
    end
    table.ClearKeys(TExplode, false)

    local Command = string.lower(TExplode[1])
    local Args = table.Copy(TExplode)
    Args[1] = nil
    Args = table.ClearKeys(Args)
    if FAdmin.Commands.List[Command] then
        local res = {FAdmin.Commands.List[Command].callback(ply, Command, Args)}
        hook.Call("FAdmin_OnCommandExecuted", nil, ply, Command, Args, res)
        return ""
    end
end)


FAdmin.StartHooks["Chatcommands"] = function()
    convar = convar or GetConVar("FAdmin_commandprefix")

    FAdmin.Commands.AddCommand("CommandPrefix", function(ply, cmd, args)
        if not FAdmin.Access.PlayerHasPrivilege(ply, "ServerSetting") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if not args[1] or string.len(args[1]) ~= 1 then return end

        FAdmin.Messages.ActionMessage(ply, player.GetAll(), ply:Nick() .. " set FAdmin's chat command prefix to " .. args[1], "FAdmin's chat command prefix has been set to " .. args[1], "Chat command prefix set to" .. args[1])

        RunConsoleCommand("FAdmin_commandprefix", args[1])

        FAdmin.SaveSetting("FAdmin_commandprefix", args[1])

        return true
    end)
end
