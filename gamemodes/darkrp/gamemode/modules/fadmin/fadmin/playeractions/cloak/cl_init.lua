FAdmin.StartHooks["zz_Cloak"] = function()
    FAdmin.Access.AddPrivilege("Cloak", 2)
    FAdmin.Commands.AddCommand("Cloak", nil, "<Player>")
    FAdmin.Commands.AddCommand("Uncloak", nil, "<Player>")

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_cloaked") then return "Uncloak" end
        return "Cloak"
    end, function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_cloaked") then return "fadmin/icons/cloak", "fadmin/icons/disable" end
        return "fadmin/icons/cloak"
    end, Color(0, 200, 0, 255),

    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Cloak", ply) end, function(ply, button)
        if not ply:FAdmin_GetGlobal("FAdmin_cloaked") then
            RunConsoleCommand("_FAdmin", "Cloak", ply:UserID())
        else
            RunConsoleCommand("_FAdmin", "Uncloak", ply:UserID())
        end

        if not ply:FAdmin_GetGlobal("FAdmin_cloaked") then button:SetImage2("fadmin/icons/disable") button:SetText("Uncloak") button:GetParent():InvalidateLayout() return end
        button:SetImage2("null")
        button:SetText("Cloak")
        button:GetParent():InvalidateLayout()
    end)
end
