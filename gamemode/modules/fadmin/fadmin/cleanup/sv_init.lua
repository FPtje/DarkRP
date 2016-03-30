local function ClearDecals(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    for k,v in pairs(player.GetAll()) do
        v:ConCommand("r_cleardecals")
    end
    FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have removed all decals. NOTE: this does NOT make the server ANY less laggy!", "All decals have been removed. NOTE: this does NOT make the server ANY less laggy!", "Removed all decals.")

    ply.FAdminClearDecals = ply.FAdminClearDecals or 0
    ply.FAdminClearDecals = ply.FAdminClearDecals + 1

    if GAMEMODE.Config.AprilFools and ply.FAdminClearDecals >= 3 then
        ply:Kick("For weeks now you have ignored the god damn message that says:\n\"NOTE: THIS DOES NOT MAKE THE SERVER ANY LESS LAGGY!\"\nYet you fucking continue spamming the ever living fuck out of this button.\nLearn to fucking read you IMBECILE\n(April's fools)")
    end

    return true
end

local function StopSounds(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    umsg.Start("FAdmin_StopSounds")
    umsg.End()

    FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have stopped all sounds", "All sounds have been stopped", "Stopped all sounds")

    return true
end

local function CleanUp(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    game.CleanUpMap()
    FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have cleaned up the map", "The map has been cleaned up", "Cleaned up the map")

    return true
end

FAdmin.StartHooks["CleanUp"] = function()
    FAdmin.Commands.AddCommand("ClearDecals", ClearDecals)
    FAdmin.Commands.AddCommand("StopSounds", StopSounds)
    FAdmin.Commands.AddCommand("CleanUp", CleanUp)

    local oldCleanup = concommand.GetTable()["gmod_admin_cleanup"]
    concommand.Add("gmod_admin_cleanup", function(ply, cmd, args)
        if args[1] then return oldCleanup(ply, cmd, args) end
        return CleanUp(ply, cmd, args)
    end)

    FAdmin.Access.AddPrivilege("CleanUp", 2)
end
