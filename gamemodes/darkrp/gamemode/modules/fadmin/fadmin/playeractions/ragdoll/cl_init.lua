FAdmin.StartHooks["Ragdoll"] = function()
    FAdmin.Access.AddPrivilege("Ragdoll", 2)
    FAdmin.Commands.AddCommand("Ragdoll", nil, "<Player>", "[normal/hang/kick]")
    FAdmin.Commands.AddCommand("UnRagdoll", nil, "<Player>")

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        if ply:FAdmin_GetGlobal("fadmin_ragdolled") then return "Unragdoll" end
        return "Ragdoll"
    end,
    function(ply)
        if ply:FAdmin_GetGlobal("fadmin_ragdolled") then return "fadmin/icons/ragdoll", "fadmin/icons/disable" end
        return "fadmin/icons/ragdoll"
    end,
    Color(255, 130, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Ragdoll", ply) end,
    function(ply, button)
        if ply:FAdmin_GetGlobal("fadmin_ragdolled") then
            RunConsoleCommand("_FAdmin", "unragdoll", ply:UserID())
            button:SetImage2("null")
            button:SetText("Ragdoll")
            button:GetParent():InvalidateLayout()
        return end

        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Ragdoll Type:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)

        menu:AddPanel(Title)

        for k, v in pairs(FAdmin.PlayerActions.RagdollTypes) do
            if v == "Unragdoll" then continue end
            FAdmin.PlayerActions.addTimeSubmenu(menu, v,
                function()
                    RunConsoleCommand("_FAdmin", "Ragdoll", ply:UserID(), k)
                    button:SetImage2("fadmin/icons/disable")
                    button:SetText("Unragdoll")
                    button:GetParent():InvalidateLayout()
                end,
                function(secs)
                    RunConsoleCommand("_FAdmin", "Ragdoll", ply:UserID(), k, secs)
                    button:SetImage2("fadmin/icons/disable")
                    button:SetText("Unragdoll")
                    button:GetParent():InvalidateLayout()
                end
            )
        end

        menu:Open()
    end)
end
