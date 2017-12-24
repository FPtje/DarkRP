FAdmin.StartHooks["Slay"] = function()
    FAdmin.Access.AddPrivilege("Slay", 2)
    FAdmin.Commands.AddCommand("Slay", nil, "<Player>", "[Normal/Silent/Explode/Rocket]")

    FAdmin.ScoreBoard.Main.AddPlayerRightClick("Slay", function(ply)
        RunConsoleCommand("_FAdmin", "slay", ply:UserID())
    end)

    FAdmin.ScoreBoard.Player:AddActionButton("Slay", "fadmin/icons/slay", Color(255, 130, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Slay", ply) end,
    function(ply)
        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Kill Type:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)
        menu:AddPanel(Title)

        for k, v in pairs(FAdmin.PlayerActions.SlayTypes) do
            local uid = ply:UserID()
            menu:AddOption(v, function()
                RunConsoleCommand("_FAdmin", "slay", uid, k)
            end)
        end

        menu:Open()
    end)
end
