local CloakThink

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

            for _, v in ipairs(ents.FindByClass("physgun_beam")) do
                if v:GetParent() == target then
                    v:SetNoDraw(true)
                end
            end

            hook.Add("Think", "FAdmin_Cloak", CloakThink)
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

            for _, v in ipairs(ents.FindByClass("physgun_beam")) do
                if v:GetParent() == target then
                    v:SetNoDraw(false)
                end
            end

            target.FAdmin_CloakWeapon = nil

            local RemoveThink = true
            for _, v in ipairs(player.GetAll()) do
                if v:FAdmin_GetGlobal("FAdmin_cloaked") then
                    RemoveThink = false
                    break
                end
            end
            if RemoveThink then hook.Remove("Think", "FAdmin_Cloak") end
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

function CloakThink()
    for _, v in ipairs(player.GetAll()) do
        local ActiveWeapon = v:GetActiveWeapon()
        if v:FAdmin_GetGlobal("FAdmin_cloaked") and ActiveWeapon:IsValid() and ActiveWeapon ~= v.FAdmin_CloakWeapon then
            v.FAdmin_CloakWeapon = ActiveWeapon
            ActiveWeapon:SetNoDraw(true)

            if ActiveWeapon:GetClass() == "weapon_physgun" then
                for a,b in ipairs(ents.FindByClass("physgun_beam")) do
                    if b:GetParent() == v then
                        b:SetNoDraw(true)
                    end
                end
            end
        end
    end
end
