local Sorted, SortDown = CreateClientConVar("FAdmin_SortPlayerList", "Team", true), CreateClientConVar("FAdmin_SortPlayerListDown", 1, true)
local allowedSorts = {
    ["Name"] = true,
    ["Team"] = true,
    ["Frags"] = true,
    ["Deaths"] = true,
    ["Ping"] = true
}

function FAdmin.ScoreBoard.Main.Show()
    local Sort = {}
    local ScreenWidth, ScreenHeight = ScrW(), ScrH()

    FAdmin.ScoreBoard.X = ScreenWidth * 0.05
    FAdmin.ScoreBoard.Y = ScreenHeight * 0.025
    FAdmin.ScoreBoard.Width = ScreenWidth * 0.9
    FAdmin.ScoreBoard.Height = ScreenHeight * 0.95

    FAdmin.ScoreBoard.ChangeView("Main")

    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList = FAdmin.ScoreBoard.Main.Controls.FAdminPanelList or vgui.Create("DPanelList")
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:SetVisible(true)
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:Clear(true)
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList.Padding = 3
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:EnableVerticalScrollbar(true)


    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:Clear(true)

    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 90 + 30 + 20)
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:SetSize(FAdmin.ScoreBoard.Width - 40, FAdmin.ScoreBoard.Height - 90 - 30 - 20 - 20)

    Sort.Name = Sort.Name or vgui.Create("DLabel")
    Sort.Name:SetText("Sort by:     Name")
    Sort.Name:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 90 + 30)
    Sort.Name.Type = "Name"
    Sort.Name:SetVisible(true)

    Sort.Team = Sort.Team or vgui.Create("DLabel")
    Sort.Team:SetText("Team")
    Sort.Team:SetPos(ScreenWidth * 0.5 - 30, FAdmin.ScoreBoard.Y + 90 + 30)
    Sort.Team.Type = "Team"
    Sort.Team:SetVisible(true)

    Sort.Frags = Sort.Frags or vgui.Create("DLabel")
    Sort.Frags:SetText("Kills")
    Sort.Frags:SetPos(FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:GetWide() - 200, FAdmin.ScoreBoard.Y + 90 + 30)
    Sort.Frags.Type = "Frags"
    Sort.Frags:SetVisible(true)

    Sort.Deaths = Sort.Deaths or vgui.Create("DLabel")
    Sort.Deaths:SetText("Deaths")
    Sort.Deaths:SetPos(FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:GetWide() - 140, FAdmin.ScoreBoard.Y + 90 + 30)
    Sort.Deaths.Type = "Deaths"
    Sort.Deaths:SetVisible(true)

    Sort.Ping = Sort.Ping or vgui.Create("DLabel")
    Sort.Ping:SetText("Ping")
    Sort.Ping:SetPos(FAdmin.ScoreBoard.X + FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:GetWide() - 50, FAdmin.ScoreBoard.Y + 90 + 30)
    Sort.Ping.Type = "Ping"
    Sort.Ping:SetVisible(true)

    local sortBy = Sorted:GetString()
    sortBy = allowedSorts[sortBy] and sortBy or "Team"

    FAdmin.ScoreBoard.Main.PlayerListView(sortBy, SortDown:GetBool())

    for _, v in pairs(Sort) do
        v:SetFont("Trebuchet20")
        v:SizeToContents()

        local X, Y = v:GetPos()

        v.BtnSort = vgui.Create("DButton")
        v.BtnSort:SetText("")
        v.BtnSort.Type = "Down"
        v.BtnSort.Paint = function(panel, w, h) derma.SkinHook("Paint", "ButtonDown", panel, w, h) end
        v.BtnSort:SetSkin(GAMEMODE.Config.DarkRPSkin)
        if Sorted:GetString() == v.Type then
            v.BtnSort.Depressed = true
            v.BtnSort.Type = (SortDown:GetBool() and "Down") or "Up"
        end
        v.BtnSort:SetSize(16, 16)
        v.BtnSort:SetPos(X + v:GetWide() + 5, Y + 4)
        function v.BtnSort.DoClick()
            for _, b in pairs(Sort) do
                b.BtnSort.Depressed = b.BtnSort == v.BtnSort
            end
            v.BtnSort.Type = (v.BtnSort.Type == "Down" and "Up") or "Down"
            v.BtnSort.Paint = function(panel, w, h)
                derma.SkinHook("Paint", "Button" .. v.BtnSort.Type, panel, w, h)
            end

            RunConsoleCommand("FAdmin_SortPlayerList", v.Type)
            RunConsoleCommand("FAdmin_SortPlayerListDown", (v.BtnSort.Type == "Down" and "1") or "0")
            FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:Clear(true)
            FAdmin.ScoreBoard.Main.PlayerListView(v.Type, v.BtnSort.Type == "Down")
        end
        table.insert(FAdmin.ScoreBoard.Main.Controls, v) -- Add them to the table so they get removed when you close the scoreboard
        table.insert(FAdmin.ScoreBoard.Main.Controls, v.BtnSort)
    end
end

function FAdmin.ScoreBoard.Main.AddPlayerRightClick(Name, func)
    FAdmin.PlayerIcon.RightClickOptions[Name] = func
end

FAdmin.StartHooks["CopySteamID"] = function()
    FAdmin.ScoreBoard.Main.AddPlayerRightClick("Copy SteamID", function(ply) SetClipboardText(ply:SteamID()) end)
end
