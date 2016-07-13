local sbox_noclip = GetConVar("sbox_noclip")

local function EnableDisableNoclip(ply)
    return ply:FAdmin_GetGlobal("FADmin_CanNoclip") or
        ((FAdmin.Access.PlayerHasPrivilege(ply, "Noclip") or sbox_noclip:GetBool())
            and not ply:FAdmin_GetGlobal("FADmin_DisableNoclip"))
end

FAdmin.StartHooks["zz_Noclip"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "noclipenable",
        hasTarget = true,
        message = {"instigator", " enabled noclip for ", "targets"},
    }

    FAdmin.Messages.RegisterNotification{
        name = "noclipdisable",
        hasTarget = true,
        message = {"instigator", " disabled noclip for ", "targets"},
    }

    FAdmin.Access.AddPrivilege("Noclip", 2)
    FAdmin.Access.AddPrivilege("SetNoclip", 2)

    FAdmin.Commands.AddCommand("SetNoclip", nil, "<Player>", "<Toggle 1/0>")

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        if EnableDisableNoclip(ply) then
            return "Disable noclip"
        end
        return "Enable noclip"
    end, function(ply) return "fadmin/icons/noclip", EnableDisableNoclip(ply) and "fadmin/icons/disable" end, Color(0, 200, 0, 255),

    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetNoclip") end, function(ply, button)
        if EnableDisableNoclip(ply) then
            RunConsoleCommand("_FAdmin", "SetNoclip", ply:UserID(), 0)
        else
            RunConsoleCommand("_FAdmin", "SetNoclip", ply:UserID(), 1)
        end

        if EnableDisableNoclip(ply) then
            button:SetText("Enable noclip")
            button:SetImage2("null")
            button:GetParent():InvalidateLayout()
            return
        end
        button:SetText("Disable noclip")
        button:SetImage2("fadmin/icons/disable")
        button:GetParent():InvalidateLayout()
    end)
end
