local PANEL = {}

AccessorFunc(PANEL, "gamemodeList", "GamemodeList")
AccessorFunc(PANEL, "mapList", "MapList")

function PANEL:Init()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(false)

    self:SetDeleteOnClose(false)

    self:SetTitle("Change level")
    self:SetSize(630, ScrH() * 0.8)

    self.gamemodeList = {}
    self.mapList = {}

    self.catList = vgui.Create("DCategoryList", self)
    self.catList:Dock(FILL)

    self.topPanel = vgui.Create("DPanel", self)
    self.topPanel:SetPaintBackground(false)
    self.topPanel:DockMargin(0, 0, 0, 4)
    self.topPanel:Dock(TOP)
    self.gmLabel = vgui.Create("DLabel", self.topPanel)
    self.gmLabel:SetText("Gamemode:")
    self.gmLabel:Dock(LEFT)
    self.gmComboBox = vgui.Create("DComboBox", self.topPanel)
    self.gmComboBox:Dock(FILL)
    self.gmComboBox:SetValue("(current)")

    self.bottomPanel = vgui.Create("DPanel", self)
    self.bottomPanel:SetPaintBackground(false)
    self.bottomPanel:DockMargin(0, 4, 0, 0)
    self.bottomPanel:Dock(BOTTOM)
    self.changeButton = vgui.Create("DButton", self.bottomPanel)
    self.changeButton:SetText("Change level")
    self.changeButton:Dock(RIGHT)
    self.changeButton:SetWidth(100)
    self.changeButton:SetEnabled(false)
    self.changeButton.DoClick = function()
        if not IsValid(self.selectedIconPanel) then return end
        local _,gmName = self.gmComboBox:GetSelected()
        local mapName = self.selectedIconPanel:GetText()
        RunConsoleCommand("_FAdmin", "Changelevel", gmName and gmName or mapName, gmName and mapName)
    end
end

function PANEL:Refresh()
    for _, gmInfo in ipairs(self:GetGamemodeList()) do
        self.gmComboBox:AddChoice(gmInfo.title, gmInfo.name)
    end
    self.gmComboBox:SetValue("(current)")

    for catName, maps in pairs(self:GetMapList()) do
        local cat = self.catList:Add(catName)
        local iconLayout = vgui.Create("DIconLayout")
        iconLayout:SetSpaceX(5)
        iconLayout:SetSpaceY(5)
        for _, map in ipairs(maps) do
            local icon = iconLayout:Add("FAdmin_MapIcon")
            icon:SetText(map)
            icon:SetDark(true)
            local mat = Material("maps/thumb/" .. map .. ".png")
            if mat:IsError() then mat = Material("maps/thumb/noicon.png") end
            icon:SetMaterial(mat)
            local onToggled = icon.OnToggled
            icon.OnToggled = function(iconSelf, selected)
                onToggled(iconSelf, selected)
                if IsValid(self.selectedIconPanel) then
                    if selected and self.selectedIconPanel ~= iconSelf then
                        self.selectedIconPanel:Toggle()
                    elseif not selected and self.selectedIconPanel == iconSelf then
                        self.selectedIconPanel = nil
                        self.changeButton:SetEnabled(false)
                        return
                    end
                end
                self.selectedIconPanel = iconSelf
                self.changeButton:SetEnabled(true)
            end
        end
        cat:SetContents(iconLayout)
    end
end

vgui.Register("FAdmin_Changelevel", PANEL, "DFrame")
