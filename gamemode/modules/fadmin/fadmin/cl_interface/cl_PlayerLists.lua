local function SortedPairsByFunction(Table, Sorted, SortDown)
    local CopyTable = {}
    for k,v in pairs(Table) do
        table.insert(CopyTable, {NAME = tostring(v:Nick()), PLY = v})
    end
    table.SortByMember(CopyTable, "NAME", SortDown)

    local SortedTable = {}
    for k,v in ipairs(CopyTable) do
        if not IsValid(v.PLY) or not v.PLY[Sorted] then continue end
        local SortBy = (Sorted ~= "Team" and v.PLY[Sorted](v.PLY)) or team.GetName(v.PLY[Sorted](v.PLY))
        SortedTable[SortBy] = SortedTable[SortBy] or {}
        table.insert(SortedTable[SortBy], v.PLY)
    end

    local SecondSort = {}
    for k,v in SortedPairs(SortedTable, SortDown) do
        table.insert(SecondSort, v)
    end

    CopyTable = {}
    for k,v in pairs(SecondSort) do
        for a,b in pairs(v) do
            table.insert(CopyTable, b)
        end
    end

    return ipairs(CopyTable)
end

function FAdmin.ScoreBoard.Main.PlayerListView(Sorted, SortDown)
    FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:Clear(true)
    for k, ply in SortedPairsByFunction(player.GetAll(), Sorted, SortDown) do
        local Row = vgui.Create("FadminPlayerRow")
        Row:SetPlayer(ply)
        Row:Dock(TOP)
        Row:InvalidateLayout()

        FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:AddItem(Row)
    end
end
