FAdmin.PlayerActions.JailTypes = {}
FAdmin.PlayerActions.JailTypes[1] = "Small"
FAdmin.PlayerActions.JailTypes[2] = "Normal"
FAdmin.PlayerActions.JailTypes[3] = "Big"
FAdmin.PlayerActions.JailTypes[4] = "Unjail"

hook.Add("CanTool", "FAdmin_jailed", function(ply) -- shared so it doesn't look like you can use tool
    if ply:FAdmin_GetGlobal("fadmin_jailed") then
        return false
    end
end)

hook.Add("PlayerNoClip", "FAdmin_jail", function(ply)
    if ply:FAdmin_GetGlobal("fadmin_jailed") then
        return false
    end
end)

FAdmin.StartHooks["Jailing"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "jail",
        hasTarget = true,
        message = {"instigator", " jailed ", "targets", " ", "extraInfo.1"},
        receivers = "involved+admins",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 16) end,
        readExtraInfo = function()
            local time = net.ReadUInt(16)
            return {time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))}
        end
    }

    FAdmin.Messages.RegisterNotification{
        name = "unjail",
        hasTarget = true,
        message = {"instigator", " unjailed ", "targets"},
        receivers = "involved+admins",
    }
end
