local function StripWeapons(ply, cmd, args)
    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "StripWeapons", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) then
            target:StripWeapons()
        end
    end

    FAdmin.Messages.FireNotification("stripweapons", ply, targets)

    return true, targets
end

FAdmin.StartHooks["StripWeapons"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "stripweapons",
        hasTarget = true,
        receivers = "involved+admins",
        message = {"instigator", " stripped the weapons of ", "targets"},
    }

    FAdmin.Commands.AddCommand("StripWeapons", StripWeapons)
    FAdmin.Commands.AddCommand("Strip", StripWeapons)

    FAdmin.Access.AddPrivilege("StripWeapons", 2)
end
