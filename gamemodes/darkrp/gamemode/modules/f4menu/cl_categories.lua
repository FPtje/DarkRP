--[[---------------------------------------------------------------------------
Category header
---------------------------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
    self:SetContentAlignment(4)
    self:SetTextInset(5, 0)
    self:SetFont("DarkRPHUD2")
end

function PANEL:Paint(w, h)
    if not self.category then return end
    draw.RoundedBox(4, 0, 0, w, h, self.category.color)
end

function PANEL:UpdateColours() end

function PANEL:SetCategory(cat)
    self.category = cat
    self:SetText(cat.name)
end

derma.DefineControl("F4MenuCategoryHeader", "", PANEL, "DCategoryHeader")

--[[---------------------------------------------------------------------------
Contents of category headers
---------------------------------------------------------------------------]]
PANEL = {}

function PANEL:Init()
    self:EnableVerticalScrollbar()
end

function PANEL:Rebuild()
    if table.IsEmpty(self.Items) then return end

    local height = 0
    local k = 0
    for _, item in pairs(self.Items) do
        if not item:IsVisible() then continue end
        k = k + 1
        item:SetWide(self:GetWide() - 10)
        item:SetPos(5, height)
        height = height + item:GetTall() + 2
    end
    self:GetCanvas():SetTall(height)
    self:SetTall(height)
end


function PANEL:Refresh()
    for _, v in pairs(self.Items) do
        if v.Refresh then v:Refresh() end
    end
    self:InvalidateLayout()
end

derma.DefineControl("F4MenuCategoryContents", "", PANEL, "DPanelList")

--[[---------------------------------------------------------------------------
Category panel
---------------------------------------------------------------------------]]
PANEL = {}

function PANEL:Init()
    if self.Header then self.Header:Remove() end
    self.Header = vgui.Create("F4MenuCategoryHeader", self)
    self.Header:Dock(TOP)
    self.Header:SetSize(20, 40)
    self:SetSize(16, 16)
    self:SetExpanded(true)
    self:SetMouseInputEnabled(true)
    self:SetAnimTime(0.2)
    self.animSlide = Derma_Anim("Anim", self, self.AnimSlide)
    self:SetPaintBackgroundEnabled(false)
    self:DockMargin(0, 0, 0, 10)
    self:DockPadding(0, 0, 0, 10)

    self:SetContents(vgui.Create("F4MenuCategoryContents", self))
end

function PANEL:Paint()

end

function PANEL:SetButtonFactory(f)
    self.buttonFactory = f
end

function PANEL:SetCategory(cat)
    self.category = cat
    self.Header:SetCategory(cat)
    self:Fill()
    self:SetExpanded(cat.startExpanded)
end

function PANEL:SetPerformLayout(f)
    self.Contents.PerformLayout = function()
        f(self.Contents)
        self.Contents.BaseClass.PerformLayout(self.Contents)
    end
end

function PANEL:GetItems()
    return self.Contents:GetItems()
end

function PANEL:Fill()
    self.Contents:Clear(true)
    for _, v in ipairs(self.category.members) do
        local pnl = self.buttonFactory(v, self.Contents)
        self.Contents:AddItem(pnl)
    end

    self:InvalidateLayout(true)
end

function PANEL:Refresh()
    if IsValid(self.Contents) then self.Contents:Refresh() end

    if not self.category then return end
    local canSee = table.IsEmpty(self.category.members) or isfunction(self.category.canSee) and not self.category.canSee(LocalPlayer())
    self:SetVisible(not canSee)

    self:InvalidateLayout()
end

derma.DefineControl("F4MenuCategory", "", PANEL, "DCollapsibleCategory")
