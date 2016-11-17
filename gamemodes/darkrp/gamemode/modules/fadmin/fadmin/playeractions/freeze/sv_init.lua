local function Freeze(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    local time = tonumber(args[2]) or 0

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Freeze", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_frozen") then
            target:FAdmin_SetGlobal("FAdmin_frozen", true)
            target:Lock()

            if time == 0 then continue end

            timer.Simple(time, function()
                if not IsValid(target) or not target:FAdmin_GetGlobal("FAdmin_frozen") then return end
                target:FAdmin_SetGlobal("FAdmin_frozen", false)
                target:UnLock()
            end)
        end
    end
    FAdmin.Messages.FireNotification("freeze", ply, targets, {time})

    return true, targets, time
end

local function Unfreeze(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Freeze", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_frozen") then
            target:FAdmin_SetGlobal("FAdmin_frozen", false)
            target:UnLock()
        end
    end

    FAdmin.Messages.FireNotification("unfreeze", ply, targets)

    return true, targets
end

FAdmin.StartHooks["Freeze"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "freeze",
        hasTarget = true,
        receivers = "involved+admins",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 16) end,
        message = {"instigator", " froze ", "targets", " ", "extraInfo.1"},
    }

    FAdmin.Messages.RegisterNotification{
        name = "unfreeze",
        hasTarget = true,
        receivers = "involved+admins",
        message = {"instigator", " unfroze ", "targets"},
    }

    FAdmin.Commands.AddCommand("freeze", Freeze)
    FAdmin.Commands.AddCommand("unfreeze", Unfreeze)

    FAdmin.Access.AddPrivilege("Freeze", 2)
end

local disallow = function(ply) if ply:FAdmin_GetGlobal("FAdmin_frozen") then return false end end

hook.Add("PlayerSpawnObject", "FAdmin_jail", disallow)
hook.Add("CanPlayerSuicide", "FAdmin_jail", disallow)
