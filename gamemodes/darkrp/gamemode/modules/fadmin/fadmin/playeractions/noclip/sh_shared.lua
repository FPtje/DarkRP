local sbox_noclip = GetConVar("sbox_noclip")

local function sendNoclipMessage(ply)
    if not SERVER or ply.FADmin_HasGotNoclipMessage then return end

    FAdmin.Messages.SendMessage(ply, 4, "Noclip allowed")
    ply.FADmin_HasGotNoclipMessage = true
end

hook.Add("PlayerNoClip", "FAdmin_noclip", function(ply)
    if ply:FAdmin_GetGlobal("FADmin_DisableNoclip") then
        if SERVER then
            FAdmin.Messages.SendMessage(ply, 5, "Noclip disallowed!")
        end

        return false
    end

    -- No further judgement when sbox_noclip is on
    if sbox_noclip:GetBool() then return end

    if ply:FAdmin_GetGlobal("FADmin_CanNoclip") then
        sendNoclipMessage(ply)

        return true
    end

    if not ply:Alive() then return end

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
