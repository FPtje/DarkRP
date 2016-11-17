local sbox_noclip = GetConVar("sbox_noclip")

local function SetNoclip(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "SetNoclip") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end
    local Toggle = tobool(tonumber(args[2])) or false


    for _, target in pairs(targets) do
        if IsValid(target) then
            if Toggle then
                target:FAdmin_SetGlobal("FADmin_CanNoclip", true)
                target:FAdmin_SetGlobal("FADmin_DisableNoclip", false)

                if not FAdmin.Access.PlayerHasPrivilege(target, "Noclip") then
                    FAdmin.Messages.SendMessage(ply, 3, "This is not permanent! Make it permanent with a custom group in SetAccess!")
                end
            else
                target:FAdmin_SetGlobal("FADmin_CanNoclip", false)
                target:FAdmin_SetGlobal("FADmin_DisableNoclip", true)

                if target:GetMoveType() == MOVETYPE_NOCLIP then
                    target:SetMoveType(MOVETYPE_WALK)
                end
            end
        end
    end
    if Toggle then
        FAdmin.Messages.FireNotification("noclipenable", ply, targets)
    else
        FAdmin.Messages.FireNotification("noclipdisable", ply, targets)
    end

    return true, targets, Toggle
end

FAdmin.StartHooks["zz_Noclip"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "noclipenable",
        hasTarget = true,
        receivers = "involved",
        message = {"instigator", " enabled noclip for ", "targets"},
    }

    FAdmin.Messages.RegisterNotification{
        name = "noclipdisable",
        hasTarget = true,
        receivers = "involved",
        message = {"instigator", " disabled noclip for ", "targets"},
    }

    FAdmin.Access.AddPrivilege("Noclip", 2)
    FAdmin.Access.AddPrivilege("SetNoclip", 2)

    FAdmin.Commands.AddCommand("SetNoclip", SetNoclip)
end

local function sendNoclipMessage(ply)
    if ply.FADmin_HasGotNoclipMessage then return end

    FAdmin.Messages.SendMessage(ply, 4, "Noclip allowed")
    ply.FADmin_HasGotNoclipMessage = true
end

hook.Add("PlayerNoClip", "FAdmin_noclip", function(ply)
    if ply:FAdmin_GetGlobal("FADmin_DisableNoclip") then
        FAdmin.Messages.SendMessage(ply, 5, "Noclip disallowed!")
        return false
    end

    -- No further judgement when sbox_noclip is on
    if sbox_noclip:GetBool() then return end

    if ply:FAdmin_GetGlobal("FADmin_CanNoclip") then
        sendNoclipMessage(ply)

        return true
    end

    -- Has privilege
    if not FAdmin.Access.PlayerHasPrivilege(ply, "Noclip") then return end

    -- Disallow if other hooks say no
    for k, v in pairs(hook.GetTable().PlayerNoClip) do
        if k == "FAdmin_noclip" then continue end
        if v(ply) == false then return false end
    end

    sendNoclipMessage(ply)

    return true
end)
