FAdmin.StartHooks["Freeze"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "freeze",
        hasTarget = true,
        message = {"instigator", " froze ", "targets", " ", "extraInfo.1"},
        readExtraInfo = function()
            local time = net.ReadUInt(16)

            return {time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))}
        end
    }

    FAdmin.Messages.RegisterNotification{
        name = "unfreeze",
        hasTarget = true,
        message = {"instigator", " unfroze ", "targets"},
    }


    FAdmin.Access.AddPrivilege("Freeze", 2)
    FAdmin.Commands.AddCommand("freeze", nil, "<Player>")
    FAdmin.Commands.AddCommand("unfreeze", nil, "<Player>")

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_frozen") then return "Unfreeze" end
        return "Freeze"
    end, function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_frozen") then return "fadmin/icons/freeze", "fadmin/icons/disable" end
        return "fadmin/icons/freeze"
    end, Color(255, 130, 0, 255),

    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Freeze", ply) end, function(ply, button)
        if not ply:FAdmin_GetGlobal("FAdmin_frozen") then
            FAdmin.PlayerActions.addTimeMenu(function(secs)
                RunConsoleCommand("_FAdmin", "freeze", ply:UserID(), secs)
                button:SetImage2("fadmin/icons/disable")
                button:SetText("Unfreeze")
                button:GetParent():InvalidateLayout()
            end)
        else
            RunConsoleCommand("_FAdmin", "unfreeze", ply:UserID())
        end

        button:SetImage2("null")
        button:SetText("Freeze")
        button:GetParent():InvalidateLayout()
    end)
end
