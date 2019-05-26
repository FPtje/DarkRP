--[[---------------------------------------------------------------------------
F4 tab
---------------------------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
    self.BaseClass.Init(self)
end

local gray = Color(110, 110, 110, 255)
function PANEL:Paint(w, h)
    local drawFunc = self:GetSkin().tex.TabT_Inactive

    if self:GetDisabled() then
        drawFunc(0, 0, w, h, gray)
        return
    end
    self.BaseClass.Paint(self, w, h)
end

function PANEL:ApplySchemeSettings()
    local ExtraInset = 10

    if self.Image then
        ExtraInset = ExtraInset + self.Image:GetWide()
    end

    local Active = self:GetPropertySheet():GetActiveTab() == self

    self:SetTextInset(ExtraInset, 4)
    local w, h = self:GetContentSize()
    h = Active and 38 or 30

    self:SetSize(w + 30, h)

    DLabel.ApplySchemeSettings(self)
end

derma.DefineControl("F4MenuTab", "", PANEL, "DTab")



--[[---------------------------------------------------------------------------
F4 tab sheet
---------------------------------------------------------------------------]]

PANEL = {}

local mouseX, mouseY = ScrW() / 2, ScrH() / 2
function PANEL:Init()
    self.F4Down = true

    self:StretchToParent(100, 100, 100, 100)
    self:Center()
    self:SetVisible(true)
    self:MakePopup()
    self:SetupCloseButton(fn.Curry(self.Hide, 2)(self))
    self:ParentToHUD()
end

function PANEL:SetupCloseButton(func)
    self.CloseButton = self.tabScroller:Add("DButton")
    self.CloseButton:SetText("")
    self.CloseButton.DoClick = func
    self.CloseButton.Paint = function(panel, w, h) derma.SkinHook("Paint", "WindowCloseButton", panel, w, h) end
    self.CloseButton:Dock(RIGHT)
    self.CloseButton:DockMargin(0, 0, 0, 8)
    self.CloseButton:SetSize(32, 32)
end

function PANEL:AddSheet(label, panel, material, NoStretchX, NoStretchY, Tooltip, order)
    if not IsValid(panel) then return end

    local sheet = {}

    sheet.Name = label

    sheet.Tab = vgui.Create("F4MenuTab", self)
    sheet.Tab:Setup(label, self, panel, material)
    sheet.Tab:SetTooltip(Tooltip)
    sheet.Tab:SetFont("DarkRPHUD2")

    sheet.Panel = panel
    sheet.Panel.tab = sheet.Tab
    sheet.Panel.NoStretchX = NoStretchX
    sheet.Panel.NoStretchY = NoStretchY
    sheet.Panel:SetPos(self:GetPadding(), sheet.Tab:GetTall() + 8 + self:GetPadding())
    sheet.Panel:SetVisible(false)
    if sheet.Panel.shouldHide and sheet.Panel:shouldHide() then sheet.Tab:SetDisabled(true) end

    panel:SetParent(self)

    local index = #self.Items + 1
    if order then
        table.insert(self.Items, order, sheet)
        index = order
    else
        table.insert(self.Items, sheet)
    end

    if not self:GetActiveTab() then
        self:SetActiveTab(sheet.Tab)
        sheet.Panel:SetVisible(true)
    end

    if order then
        table.insert(self.tabScroller.Panels, order, sheet.Tab)
        sheet.Tab:SetParent(self.tabScroller.pnlCanvas)
        self.tabScroller:InvalidateLayout(true)
    else
        self.tabScroller:AddPanel(sheet.Tab)
    end

    if panel.Refresh then panel:Refresh() end

    return sheet, index
end

local F4Bind
function PANEL:Think()
    self.CloseButton:SetVisible(not self.tabScroller.btnRight:IsVisible())

    F4Bind = F4Bind or input.KeyNameToNumber(input.LookupBinding("gm_showspare2"))
    if not F4Bind then return end

    if self.F4Down and not input.IsKeyDown(F4Bind) then
        self.F4Down = false
        return
    elseif not self.F4Down and input.IsKeyDown(F4Bind) then
        self.F4Down = true
        self:Hide()
    end
end

hook.Add("PlayerBindPress", "DarkRPF4Bind", function(ply, bind, pressed)
    if string.find(bind, "gm_showspare2", 1, true) then
        F4Bind = input.KeyNameToNumber(input.LookupBinding(bind))
    end
end)

function PANEL:Refresh()
    for _, v in pairs(self.Items) do
        if v.Panel.shouldHide and v.Panel:shouldHide() then v.Tab:SetDisabled(true)
        else v.Tab:SetDisabled(false) end
        if v.Panel.Refresh then v.Panel:Refresh() end
    end
end

function PANEL:Show()
    self:Refresh()
    if not table.IsEmpty(self.Items) and self:GetActiveTab() and self:GetActiveTab():GetDisabled() then
        self:SetActiveTab(self.Items[1].Tab) --Jobs
    end
    self.F4Down = true
    self:SetVisible(true)
    gui.SetMousePos(mouseX, mouseY)
end

function PANEL:Hide()
    mouseX, mouseY = gui.MousePos()
    self:SetVisible(false)
end

function PANEL:Close()
    self:Hide()
end

function PANEL:createTab(name, panel, order)
    local sheet, index = self:AddSheet(name, panel, nil, nil, nil, nil, order)
    return index, sheet
end

function PANEL:removeTab(name)
    for _, v in pairs(self.Items) do
        if v.Tab:GetText() ~= name then continue end
        return self:CloseTab(v.Tab, true)
    end
end

function PANEL:switchTabOrder(tab1, tab2)
    self.Items[tab1], self.Items[tab2] = self.Items[tab2], self.Items[tab1]
    self.tabScroller.Panels[tab1], self.tabScroller.Panels[tab2] = self.tabScroller.Panels[tab2], self.tabScroller.Panels[tab1]
    self.tabScroller:InvalidateLayout(true)
end


function PANEL:generateTabs()
    DarkRP.hooks.F4MenuTabs()
    hook.Call("F4MenuTabs")
    self:SetSkin(GAMEMODE.Config.DarkRPSkin)
end

derma.DefineControl("F4EditablePropertySheet", "", vgui.GetControlTable("DPropertySheet"), "EditablePanel")
derma.DefineControl("F4MenuFrame", "", PANEL, "F4EditablePropertySheet")
