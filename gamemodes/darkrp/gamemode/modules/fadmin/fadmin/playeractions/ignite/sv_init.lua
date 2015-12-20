local function Ignite(ply, cmd, args)
    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    local time = tonumber(args[2]) or 10

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Ignite", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) then
            target:Ignite(time, 0)
            target:FAdmin_SetGlobal("FAdmin_ignited", true)

            timer.Simple(time, function()
                if IsValid(target) then target:FAdmin_SetGlobal("FAdmin_ignited", false) end
            end)
        end
    end
    FAdmin.Messages.FireNotification("ignite", ply, targets, {time})

    return true, targets
end

local function UnIgnite(ply, cmd, args)
    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Ignite") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) then
            target:Extinguish()

            target:FAdmin_SetGlobal("FAdmin_ignited", false)
        end
    end

    FAdmin.Messages.FireNotification("unignite", ply, targets)
    return true, targets
end


FAdmin.StartHooks["Ignite"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "ignite",
        hasTarget = true,
        receivers = "involved+admins",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 16) end,
        message = {"instigator", " ignited ", "targets", " ", "extraInfo.1"},
    }

    FAdmin.Messages.RegisterNotification{
        name = "unignite",
        hasTarget = true,
        message = {"instigator", " unignited ", "targets"},
        receivers = "involved+admins",
    }

    FAdmin.Commands.AddCommand("Ignite", Ignite)
    FAdmin.Commands.AddCommand("Unignite", UnIgnite)

    FAdmin.Access.AddPrivilege("Ignite", 2)
end
