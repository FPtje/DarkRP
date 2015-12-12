hook.Add("PlayerBindPress", "FAdmin_voicemuted", function(ply, bind, pressed)
    if ply:FAdmin_GetGlobal("FAdmin_voicemuted") and string.find(string.lower(bind), "voicerecord") then return true end
    -- The voice muting is not done clientside, this is just so people know they can't talk
end)

FAdmin.StartHooks["VoiceMute"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "voicemute",
        hasTarget = true,
        message = {"instigator", " voice muted ", "targets", " ", "extraInfo.1"},
        readExtraInfo = function()
            local time = net.ReadUInt(16)
            return {time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))}
        end
    }

    FAdmin.Messages.RegisterNotification{
        name = "voiceunmute",
        hasTarget = true,
        message = {"instigator", " voice unmuted ", "targets"}
    }

    FAdmin.Access.AddPrivilege("Voicemute", 2)
    FAdmin.Commands.AddCommand("Voicemute", nil, "<Player>")
    FAdmin.Commands.AddCommand("UnVoicemute", nil, "<Player>")

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
            if ply:FAdmin_GetGlobal("FAdmin_voicemuted") then return "Unmute voice globally" end
            return "Mute voice globally"
        end,

    function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_voicemuted") then return "fadmin/icons/voicemute" end
        return "fadmin/icons/voicemute", "fadmin/icons/disable"
    end,
    Color(255, 130, 0, 255),

    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Voicemute", ply) end,
    function(ply, button)
        if not ply:FAdmin_GetGlobal("FAdmin_voicemuted") then
            FAdmin.PlayerActions.addTimeMenu(function(secs)
                RunConsoleCommand("_FAdmin", "Voicemute", ply:UserID(), secs)
                button:SetImage2("null")
                button:SetText("Unmute voice globally")
                button:GetParent():InvalidateLayout()
            end)
        else
            RunConsoleCommand("_FAdmin", "UnVoicemute", ply:UserID())
        end

        button:SetImage2("fadmin/icons/disable")
        button:SetText("Mute voice globally")
        button:GetParent():InvalidateLayout()
    end)

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        return ply.FAdminMuted and "Unmute voice" or "Mute voice"
    end,
    function(ply)
        if ply.FAdminMuted then return "fadmin/icons/voicemute" end
        return "fadmin/icons/voicemute", "fadmin/icons/disable"
    end,
    Color(255, 130, 0, 255),

    true,

    function(ply, button)
        ply:SetMuted(not ply.FAdminMuted)
        ply.FAdminMuted = not ply.FAdminMuted

        if ply.FAdminMuted then button:SetImage2("null") button:SetText("Unmute voice") button:GetParent():InvalidateLayout() return end

        button:SetImage2("fadmin/icons/disable")
        button:SetText("Mute voice")
        button:GetParent():InvalidateLayout()
    end)

    FAdmin.ScoreBoard.Main.AddPlayerRightClick("Mute/Unmute", function(ply, Panel)
        ply:SetMuted(not ply.FAdminMuted)
        ply.FAdminMuted = not ply.FAdminMuted
    end)
end
