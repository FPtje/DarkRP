local function MuteChat(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1]) or {}
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    local time = tonumber(args[2] or 0)

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Chatmute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_chatmuted") then
            target:FAdmin_SetGlobal("FAdmin_chatmuted", true)

            if time == 0 then continue end

            timer.Simple(time, function()
                if not IsValid(target) or not target:FAdmin_GetGlobal("FAdmin_chatmuted") then return false end
                target:FAdmin_SetGlobal("FAdmin_chatmuted", false)
            end)
        end
    end

    FAdmin.Messages.FireNotification("chatmute", ply, targets, {time})

    return true, targets, time
end

local function UnMuteChat(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Chatmute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_chatmuted") then
            target:FAdmin_SetGlobal("FAdmin_chatmuted", false)
        end
    end
    FAdmin.Messages.FireNotification("chatunmute", ply, targets)

    return true, targets
end

FAdmin.StartHooks["Chatmute"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "chatmute",
        hasTarget = true,
        receivers = "involved+admins",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 16) end,
        message = {"instigator", " chat muted ", "targets", " ", "extraInfo.1"},
    }

    FAdmin.Messages.RegisterNotification{
        name = "chatunmute",
        hasTarget = true,
        receivers = "involved+admins",
        message = {"instigator", " chat unmuted ", "targets"},
    }

    FAdmin.Commands.AddCommand("Chatmute", MuteChat)
    FAdmin.Commands.AddCommand("UnChatmute", UnMuteChat)

    FAdmin.Access.AddPrivilege("Chatmute", 2)
end

hook.Add("PlayerSay", "FAdmin_Chatmute", function(ply, text, Team, dead)
    if ply:FAdmin_GetGlobal("FAdmin_chatmuted") then return "" end
end)
