FAdmin.StartHooks["CleanUp"] = function()
    FAdmin.Access.AddPrivilege("CleanUp", 2)
    FAdmin.Commands.AddCommand("ClearDecals", nil)
    FAdmin.Commands.AddCommand("StopSounds", nil)
    FAdmin.Commands.AddCommand("CleanUp", nil)

    FAdmin.ScoreBoard.Server:AddServerAction("Clear decals", "fadmin/icons/cleanup", Color(155, 0, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") end, function(ply, button)
        RunConsoleCommand("_FAdmin", "ClearDecals")
    end)

    FAdmin.ScoreBoard.Server:AddServerAction("Stop all sounds", "fadmin/icons/cleanup", Color(155, 0, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") end, function(ply, button)
        RunConsoleCommand("_FAdmin", "StopSounds")
    end)

    usermessage.Hook("FAdmin_StopSounds", function()
        RunConsoleCommand("stopsound") -- bypass for ConCommand blocking it
    end)

    FAdmin.ScoreBoard.Server:AddServerAction("Clean up server", "fadmin/icons/cleanup", Color(155, 0, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") end, function(ply, button)
        RunConsoleCommand("_FAdmin", "CleanUp")
    end)
end
