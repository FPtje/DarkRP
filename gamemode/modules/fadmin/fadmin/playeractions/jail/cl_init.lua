FAdmin.StartHooks["Jail"] = function()
    FAdmin.Access.AddPrivilege("Jail", 2)
    FAdmin.Commands.AddCommand("Jail", nil, "<Player>", "[Small/Normal/Big]", "[Time]")
    FAdmin.Commands.AddCommand("UnJail", nil, "<Player>")

    FAdmin.ScoreBoard.Main.AddPlayerRightClick("Jail/Unjail", function(ply)
        if ply:FAdmin_GetGlobal("fadmin_jailed") then
            RunConsoleCommand("_FAdmin", "unjail", ply:UserID())
        else
            RunConsoleCommand("_FAdmin", "jail", ply:UserID())
        end
    end)

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        if ply:FAdmin_GetGlobal("fadmin_jailed") then return "Unjail" end
        return "Jail"
    end,
    function(ply)
        if ply:FAdmin_GetGlobal("fadmin_jailed") then return "fadmin/icons/jail", "fadmin/icons/disable" end
        return "fadmin/icons/jail"
    end,
    Color(255, 130, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Jail", ply) end,
    function(ply, button)
        if ply:FAdmin_GetGlobal("fadmin_jailed") then RunConsoleCommand("_FAdmin", "unjail", ply:UserID()) button:SetImage2("null") button:SetText("Jail") button:GetParent():InvalidateLayout() return end

        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Jail Type:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)

        menu:AddPanel(Title)

        for k, v in pairs(FAdmin.PlayerActions.JailTypes) do
            if v == "Unjail" then continue end
            FAdmin.PlayerActions.addTimeSubmenu(menu, v .. " jail",
                function()
                    RunConsoleCommand("_FAdmin", "Jail", ply:UserID(), k)
                    button:SetText("Unjail") button:GetParent():InvalidateLayout()
                    button:SetImage2("fadmin/icons/disable")
                end,
                function(secs)
                    RunConsoleCommand("_FAdmin", "Jail", ply:UserID(), k, secs)
                    button:SetText("Unjail")
                    button:GetParent():InvalidateLayout()
                    button:SetImage2("fadmin/icons/disable")
                end
            )
        end

        menu:Open()
    end)
end
