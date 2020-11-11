local function Cloak(ply, cmd, args)
    local targets = FAdmin.FindPlayer(args[1]) or {ply}

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Cloak", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_cloaked") then
            target:FAdmin_SetGlobal("FAdmin_cloaked", true)
            target:SetNoDraw(true)

            for _, v in ipairs(target:GetWeapons()) do
                v:SetNoDraw(true)
            end
        end
    end
    FAdmin.Messages.ActionMessage(ply, targets, "You have cloaked %s", "You were cloaked by %s", "Cloaked %s")

    return true, targets
end

local function UnCloak(ply, cmd, args)
    local targets = FAdmin.FindPlayer(args[1]) or {ply}

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Cloak", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_cloaked") then
            target:FAdmin_SetGlobal("FAdmin_cloaked", false)

            target:SetNoDraw(false)

            for _, v in ipairs(target:GetWeapons()) do
                v:SetNoDraw(false)
            end
        end
    end
    FAdmin.Messages.ActionMessage(ply, targets, "You have uncloaked %s", "You were uncloaked by %s", "Uncloaked %s")

    return true, targets
end

FAdmin.StartHooks["Cloak"] = function()
    FAdmin.Commands.AddCommand("Cloak", Cloak)
    FAdmin.Commands.AddCommand("Uncloak", UnCloak)

    FAdmin.Access.AddPrivilege("Cloak", 2)
end

hook.Add("PlayerSwitchWeapon", "FAdmin_Cloak", function(ply, _, weapon)
    if not ply:FAdmin_GetGlobal("FAdmin_cloaked") or not IsValid(weapon) then return end
    weapon:SetNoDraw(true)
end)
