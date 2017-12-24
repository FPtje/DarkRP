
FAdmin.StartHooks["zz_Teleport"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "goto",
        hasTarget = true,
        message = {"instigator", " teleported to ", "targets"}
    }

    FAdmin.Messages.RegisterNotification{
        name = "bring",
        hasTarget = true,
        message = {"instigator", " brought ", "targets", " to them"}
    }

    FAdmin.Access.AddPrivilege("Teleport", 2)

    FAdmin.Commands.AddCommand("Teleport", nil, "[Player]")
    FAdmin.Commands.AddCommand("TP", nil, "[Player]")
    FAdmin.Commands.AddCommand("Bring", nil, "<Player>", "[Player]")
    FAdmin.Commands.AddCommand("goto", nil, "<Player>")


    FAdmin.ScoreBoard.Player:AddActionButton("Teleport", "fadmin/icons/teleport", Color(0, 200, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport") end,
    function(ply, button)
        RunConsoleCommand("_FAdmin", "Teleport", ply:UserID())
    end)

    FAdmin.ScoreBoard.Player:AddActionButton("Goto", "fadmin/icons/teleport", Color(0, 200, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport") and ply ~= LocalPlayer() end,
    function(ply, button)
        RunConsoleCommand("_FAdmin", "goto", ply:UserID())
    end)

    FAdmin.ScoreBoard.Player:AddActionButton("Bring", "fadmin/icons/teleport", Color(0, 200, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport") and ply ~= LocalPlayer() end,
    function(ply, button)
        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Bring to:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)

        menu:AddPanel(Title)

        local uid = ply:UserID()
        menu:AddOption("Yourself", function() RunConsoleCommand("_FAdmin", "bring", uid) end)
        for _, v in pairs(DarkRP.nickSortedPlayers()) do
            if IsValid(v) and v ~= LocalPlayer() then
                local vUid = v:UserID()
                menu:AddOption(v:Nick(), function() RunConsoleCommand("_FAdmin", "bring", uid, vUid) end)
            end
        end
        menu:Open()
    end)
end
