local function God(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "God") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_godded") then
            target:FAdmin_SetGlobal("FAdmin_godded", true)
            target:GodEnable()
        end
    end
    FAdmin.Messages.FireNotification("god", ply, targets)

    return true, targets
end

local function Ungod(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "God") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_godded") then
            target:FAdmin_SetGlobal("FAdmin_godded", false)
            target:GodDisable()
        end
    end
    FAdmin.Messages.FireNotification("ungod", ply, targets)

    return true, targets
end

FAdmin.StartHooks["God"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "god",
        hasTarget = true,
        message = {"instigator", " enabled godmode for ", "targets"},
        receivers = "everyone",
    }

    FAdmin.Messages.RegisterNotification{
        name = "ungod",
        hasTarget = true,
        message = {"instigator", " disabled godmode for ", "targets"},
        receivers = "everyone",
    }

    FAdmin.Commands.AddCommand("God", God)
    FAdmin.Commands.AddCommand("Ungod", Ungod)

    FAdmin.Access.AddPrivilege("God", 2)
end

hook.Add("PlayerSpawn", "FAdmin_God", function(ply)
    if ply:FAdmin_GetGlobal("FAdmin_godded") then
        ply:GodEnable()
    end
end)
