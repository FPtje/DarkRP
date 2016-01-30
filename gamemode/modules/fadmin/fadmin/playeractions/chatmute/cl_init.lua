FAdmin.StartHooks["Chatmute"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "chatmute",
        hasTarget = true,
        message = {"instigator", " chat muted ", "targets", " ", "extraInfo.1"},
        readExtraInfo = function()
            local time = net.ReadUInt(16)

            return {time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))}
        end
    }

    FAdmin.Messages.RegisterNotification{
        name = "chatunmute",
        hasTarget = true,
        message = {"instigator", " chat unmuted ", "targets"},
    }

    FAdmin.Access.AddPrivilege("Chatmute", 2)
    FAdmin.Commands.AddCommand("Chatmute", nil, "<Player>")
    FAdmin.Commands.AddCommand("UnChatmute", nil, "<Player>")

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_chatmuted") then return "Unmute chat" end
        return "Mute chat"
    end, function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_chatmuted") then return "fadmin/icons/chatmute" end
        return "fadmin/icons/chatmute", "fadmin/icons/disable"
    end, Color(255, 130, 0, 255),

    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Chatmute", ply) end, function(ply, button)
        if not ply:FAdmin_GetGlobal("FAdmin_chatmuted") then
            FAdmin.PlayerActions.addTimeMenu(function(secs)
                RunConsoleCommand("_FAdmin", "chatmute", ply:UserID(), secs)
                button:SetImage2("null")
                button:SetText("Unmute chat")
                button:GetParent():InvalidateLayout()
            end)
        else
            RunConsoleCommand("_FAdmin", "UnChatmute", ply:UserID())
        end

        button:SetImage2("fadmin/icons/disable")
        button:SetText("Mute chat")
        button:GetParent():InvalidateLayout()
    end)
end
