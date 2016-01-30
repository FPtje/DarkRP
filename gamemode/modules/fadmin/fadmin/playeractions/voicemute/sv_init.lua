local function MuteVoice(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    local time = tonumber(args[2]) or 0

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Voicemute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_voicemuted") then
            target:FAdmin_SetGlobal("FAdmin_voicemuted", true)

            if time == 0 then continue end

            timer.Simple(time, function()
                if not IsValid(target) or not target:FAdmin_GetGlobal("FAdmin_voicemuted") then return false end
                target:FAdmin_SetGlobal("FAdmin_voicemuted", false)
            end)
        end
    end

    FAdmin.Messages.FireNotification("voicemute", ply, targets, {time})

    return true, targets, time
end

local function UnMuteVoice(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Voicemute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_voicemuted") then
            target:FAdmin_SetGlobal("FAdmin_voicemuted", false)
        end
    end

    FAdmin.Messages.FireNotification("voiceunmute", ply, targets)

    return true, targets
end

FAdmin.StartHooks["VoiceMute"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "voicemute",
        hasTarget = true,
        receivers = "involved+admins",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 16) end,
        message = {"instigator", " voice muted ", "targets", " ", "extraInfo.1"},
    }

    FAdmin.Messages.RegisterNotification{
        name = "voiceunmute",
        hasTarget = true,
        receivers = "involved+admins",
        message = {"instigator", " voice unmuted ", "targets"},
    }

    FAdmin.Commands.AddCommand("Voicemute", MuteVoice)
    FAdmin.Commands.AddCommand("UnVoicemute", UnMuteVoice)

    FAdmin.Access.AddPrivilege("Voicemute", 2)
end

hook.Add("PlayerCanHearPlayersVoice", "FAdmin_Voicemute", function(Listener, Talker)
    if Talker:FAdmin_GetGlobal("FAdmin_voicemuted") then return false end
end)
