FAdmin.StartHooks["zzSetTeam"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "setteam",
        hasTarget = true,
        message = {"instigator", " set the team of ", "targets", " to ", "extraInfo.1"},
        readExtraInfo = function()
            return {team.GetName(net.ReadUInt(16))}
        end,
        extraInfoColors = {Color(255, 102, 0)}
    }

    FAdmin.Access.AddPrivilege("SetTeam", 2)
    FAdmin.Commands.AddCommand("SetTeam", nil, "<Player>", "<Team>")

    FAdmin.ScoreBoard.Player:AddActionButton("Set team", "fadmin/icons/changeteam", Color(0, 200, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetTeam", ply) end, function(ply, button)
        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Teams:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)

        menu:AddPanel(Title)
        for k, v in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
            local uid = ply:UserID()
            menu:AddOption(v.Name, function() RunConsoleCommand("_FAdmin", "setteam", uid, k) end)
        end
        menu:Open()
    end)
end
