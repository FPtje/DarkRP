FAdmin.StartHooks["00RCon"] = function()
    FAdmin.Access.AddPrivilege("RCon", 3)
    FAdmin.Commands.AddCommand("RCon", "<command>", "<args>")

    FAdmin.ScoreBoard.Server:AddServerAction("RCon", "fadmin/icons/rcon", Color(155, 0, 0, 255), function() return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "RCon") end,
    function(ply, button)
        Derma_StringRequest("RCon comand", "Enter a command to be run on the server. Note: a lot of commands are blocked and they will not work!", "",
            function(text) RunConsoleCommand("_FAdmin", "RCon", unpack(string.Explode(" ", text))) end)
    end)
end
