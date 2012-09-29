local function ScoreboardAddTeam(Name, color)
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()

	local cat = vgui.Create("FAdminPlayerCatagory")
	cat:SetLabel("  "..Name)
	cat.CatagoryColor = color
	cat:SetWide((FAdmin.ScoreBoard.Width - 40)/2)

	function cat:Toggle()
	end

	local pan = vgui.Create("FAdminPanelList")
	pan:SetSpacing(2)
	pan:EnableHorizontal(true)
	pan:EnableVerticalScrollbar(true)
	pan:SizeToContents()

	cat:SetContents(pan)

	FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:AddItem(cat)
	return cat, pan
end

local function SortedPairsByFunction(Table, Sorted, SortDown)
	local CopyTable = {}
	for k,v in pairs(Table) do
		table.insert(CopyTable, {NAME = v:Nick(), PLY = v})
	end
	table.SortByMember(CopyTable, "NAME", SortDown)

	local SortedTable = {}
	for k,v in ipairs(CopyTable) do
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
	for k, ply in SortedPairsByFunction(player.GetAll(), Sorted, SortDown) do
		local Row = vgui.Create("FadminPlayerRow", FAdmin.ScoreBoard.Main.Controls.FAdminPanelList)
		Row:SetPlayer(ply)
		Row:InvalidateLayout()
		FAdmin.ScoreBoard.Main.Controls.FAdminPanelList:AddItem(Row)
	end
end