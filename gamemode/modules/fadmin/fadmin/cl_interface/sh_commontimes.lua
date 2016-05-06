--[[---------------------------------------------------------------------------
Common times for several punishment actions
---------------------------------------------------------------------------]]
FAdmin.PlayerActions.commonTimes = {}
FAdmin.PlayerActions.commonTimes[0] = "indefinitely"
FAdmin.PlayerActions.commonTimes[10] = "10 seconds"
FAdmin.PlayerActions.commonTimes[30] = "30 seconds"
FAdmin.PlayerActions.commonTimes[60] = "1 minute"
FAdmin.PlayerActions.commonTimes[300] = "5 minutes"
FAdmin.PlayerActions.commonTimes[600] = "10 minutes"

function FAdmin.PlayerActions.addTimeSubmenu(menu, submenuText, submenuClick, submenuItemClick)
    local SubMenu = menu:AddSubMenu(submenuText, submenuClick)

    local Padding = vgui.Create("DPanel")
    Padding:SetPaintBackgroundEnabled(false)
    Padding:SetSize(1,5)
    SubMenu:AddPanel(Padding)

    local SubMenuTitle = vgui.Create("DLabel")
    SubMenuTitle:SetText("  Time:\n")
    SubMenuTitle:SetFont("UiBold")
    SubMenuTitle:SizeToContents()
    SubMenuTitle:SetTextColor(color_black)

    SubMenu:AddPanel(SubMenuTitle)

    for secs, Time in SortedPairs(FAdmin.PlayerActions.commonTimes) do
        SubMenu:AddOption(Time, function() submenuItemClick(secs) end)
    end
end

function FAdmin.PlayerActions.addTimeMenu(ItemClick)
    local menu = DermaMenu()

    local Padding = vgui.Create("DPanel")
    Padding:SetPaintBackgroundEnabled(false)
    Padding:SetSize(1,5)
    menu:AddPanel(Padding)

    local Title = vgui.Create("DLabel")
    Title:SetText("  Time:\n")
    Title:SetFont("UiBold")
    Title:SizeToContents()
    Title:SetTextColor(color_black)

    menu:AddPanel(Title)

    for secs, Time in SortedPairs(FAdmin.PlayerActions.commonTimes) do
        menu:AddOption(Time, function() ItemClick(secs) end)
    end
    menu:Open()
end
