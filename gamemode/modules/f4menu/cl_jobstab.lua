--[[---------------------------------------------------------------------------
Vote/become job button
---------------------------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
    self.BaseClass.Init(self)
    self:SetFont("F4MenuFont02")
    self:SetTall(50)
end

function PANEL:setJob(job, closeFunc)
    if not job.team then
        self:SetVisible(false)
    elseif job.vote or job.RequiresVote and job.RequiresVote(LocalPlayer(), job.team) then
        self:SetVisible(true)
        self:SetText(DarkRP.getPhrase("create_vote_for_job"))
        self.DoClick = fn.Compose{closeFunc, fn.Partial(RunConsoleCommand, "darkrp", "vote" .. job.command)}
    else
        self:SetVisible(true)
        self:SetText(DarkRP.getPhrase("become_job"))
        self.DoClick = fn.Compose{closeFunc, fn.Partial(RunConsoleCommand, "darkrp", job.command)}
    end
end

local red, dark = Color(140, 0, 0, 180), Color(0, 0, 0, 200)
function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, dark)
    draw.RoundedBox(4, 5, 5, w - 10, h - 10, red)
end

derma.DefineControl("F4MenuJobBecomeButton", "", PANEL, "DButton")

--[[---------------------------------------------------------------------------
Icon for the model choose panel
---------------------------------------------------------------------------]]
PANEL = {}

AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "depressed", "Depressed", FORCE_BOOL)
function PANEL:Init()
    self:SetSize(60, 60)
    self:SetText("")

    self.model = self.model or vgui.Create("ModelImage", self)
    self.model:SetSize(60, 60)
    self.model:SetPos(0, 0)
    self.model.OnMousePressed = fn.Partial(self.OnMousePressed, self)
    self.model.OnMouseReleased = fn.Partial(self.OnMouseReleased, self)
end

local gray = Color(140, 140, 140, 255)
function PANEL:Paint(w, h)
    if self:GetSelected() then
        draw.RoundedBox(4, 0, 0, w, h, red)
        draw.RoundedBox(4, 3, 3, w - 6, h - 6, gray)
        return
    end
    local depressed = self:GetDepressed()
    local x, y = depressed and 3 or 0, depressed and 3 or 0
    w, h = depressed and w - 6 or w, depressed and h - 6 or h
    draw.RoundedBox(4, x, y, w, h, gray)
end

function PANEL:OnMousePressed()
    self:SetDepressed(true)
    self.model:SetSize(50, 50)
    self.model:SetPos(5, 5)
end

function PANEL:OnMouseReleased()
    self:SetSelected(true)
    self:SetDepressed(false)
    self.hostPanel:onSelected(self)
    DarkRP.setPreferredJobModel(self.job.team, self.strModel)
end

function PANEL:updateInfo(job, model, host)
    self.hostPanel = host
    self.strModel = model
    self.model:SetModel(model, 1, "000000000")
    self.job = job
    self:SetTooltip(model)
end

derma.DefineControl("F4MenuChooseJobModelIcon", "", PANEL, "DButton")

--[[---------------------------------------------------------------------------
Choose model panel
---------------------------------------------------------------------------]]
PANEL = {}

function PANEL:Rebuild()
    if table.IsEmpty(self.iconList.Items) then return end

    local x = 0
    for _, item in pairs(self.iconList.Items) do
        item:SetPos(x)

        x = x + item:GetWide() + 2
    end
    self.iconList:GetCanvas():SetWide(x)
end

function PANEL:getScroll()
    return self.scroll
end

function PANEL:setScroll(scroll)
    local canvas = self.iconList:GetCanvas()
    local x, y = canvas:GetPos()
    local minScroll = 0
    local maxScroll = math.Max(self.iconList:GetWide(), canvas:GetWide()) - self.iconList:GetWide()

    self.scroll = math.Max(0, scroll)
    local scrollPos = math.Clamp(scroll * -62, -maxScroll, -minScroll)

    if scrollPos == x then
        self.scroll = math.Max(self.scroll - 1, 0)
        return
    end

    canvas:SetPos(scrollPos, y)
end

function PANEL:Init()
    self:SetTall(70)
    self:StretchRightTo(self:GetParent())

    self.scroll = 0

    self.leftButton = vgui.Create("F4MenuJobBecomeButton", self)
    self.leftButton:SetText("<")
    self.leftButton:SetWide(40)
    self.leftButton:Dock(LEFT)
    self.leftButton.DoClick = function(btn) self:setScroll(self:getScroll() - 1) end
    self.leftButton.DoDoubleClick = self.leftButton.DoClick

    self.rightButton = vgui.Create("F4MenuJobBecomeButton", self)
    self.rightButton:SetText(">")
    self.rightButton:SetWide(40)
    self.rightButton:Dock(RIGHT)
    self.rightButton.DoClick = function(btn) self:setScroll(self:getScroll() + 1) end
    self.rightButton.DoDoubleClick = self.rightButton.DoClick

    self.iconList = vgui.Create("DPanelList", self)

    self.iconList:EnableHorizontal(true)
    self.iconList.PerformLayout = fn.Partial(self.PerformLayout, self)
    self.iconList.Rebuild = fn.Curry(self.Rebuild, 2)(self)
end

function PANEL:PerformLayout()
    self.iconList:SetPos(40, 5)
    self.iconList:SetSize(self:GetWide() - 2 * 40, 60)
    self.iconList:GetCanvas():SetTall(60)
    self.iconList:Rebuild()
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, dark)
end

function PANEL:onSelected(item)
    for _,v in pairs(self.iconList.Items) do
        if v == item then continue end
        v:SetSelected(false)
        v.model:SetSize(60, 60)
        v.model:SetPos(0, 0)
    end
end

function PANEL:updateInfo(job)
    self.iconList:Clear()
    if not istable(job.model) then return end

    local preferredModel = DarkRP.getPreferredJobModel(job.team)
    for _, mdl in ipairs(job.model) do
        local btn = vgui.Create("F4MenuChooseJobModelIcon", self.iconList)
        btn:updateInfo(job, mdl, self)
        if preferredModel == mdl then
            btn:SetSelected(true)
            btn.model:SetSize(50, 50)
            btn.model:SetPos(5, 5)
        end
        self.iconList:AddItem(btn)
    end

    self.iconList:InvalidateLayout()
end

derma.DefineControl("F4MenuChooseJobModel", "", PANEL, "DPanel")

--[[---------------------------------------------------------------------------
Left panel for the jobs
---------------------------------------------------------------------------]]
PANEL = {}

function PANEL:Init()
    self:SetBackgroundColor(color_transparent)
    self:EnableVerticalScrollbar()
    self:SetSpacing(2)
    self.VBar.Paint = fn.Id
    self.VBar.btnUp.Paint = fn.Id
    self.VBar.btnDown.Paint = fn.Id
end

function PANEL:Refresh()
    for _,v in pairs(self.Items) do
        if v.Refresh then v:Refresh() end
    end
    self:InvalidateLayout()
end

function PANEL:Paint(w, h)
    if not self.category then return end
    draw.RoundedBox(4, 0, 0, w, h, color_white)
end

derma.DefineControl("F4EmptyPanel", "", PANEL, "DPanelList")

--[[---------------------------------------------------------------------------
Right panel for the jobs
---------------------------------------------------------------------------]]
PANEL = {}

function PANEL:Init()
    self.BaseClass.Init(self)

    self:SetPadding(10)
    self:DockPadding(5, 5, 5, 5)

    self.innerPanel = vgui.Create("F4EmptyPanel", self)
    self.innerPanel:SetPos(0, 0)

    self.lblTitle = vgui.Create("DLabel")
    self.lblTitle:SetFont("F4MenuFont02")
    self.innerPanel:AddItem(self.lblTitle)

    self.lblDescription = vgui.Create("DLabel")
    self.lblDescription:SetWide(self:GetWide() - 20)
    self.lblDescription:SetFont("Roboto Light")
    self.lblDescription:SetAutoStretchVertical(true)
    self.innerPanel:AddItem(self.lblDescription)

    self.filler = VGUIRect(0, 0, 0, 20)
    self.filler:SetColor(color_transparent)
    self.innerPanel:AddItem(self.filler)

    self.lblWeapons = vgui.Create("DLabel")
    self.lblWeapons:SetFont("F4MenuFont02")
    self.lblWeapons:SetText(DarkRP.getPhrase("F4guns"))
    self.lblWeapons:SizeToContents()
    self.lblWeapons:SetTall(50)
    self.innerPanel:AddItem(self.lblWeapons)

    self.lblSweps = vgui.Create("DLabel")
    self.lblSweps:SetAutoStretchVertical(true)
    self.lblSweps:SetFont("Roboto Light")
    self.innerPanel:AddItem(self.lblSweps)

    self.btnGetJob = vgui.Create("F4MenuJobBecomeButton", self)
    self.btnGetJob:Dock(BOTTOM)

    self.pnlChooseMdl = vgui.Create("F4MenuChooseJobModel", self)
    self.pnlChooseMdl:Dock(BOTTOM)

    self.job = {}
end

local black = Color(0, 0, 0, 170)
function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, black)
end

-- functions for getting the weapon names from the job table
local getWepName = fn.FOr{fn.FAnd{weapons.Get, fn.Compose{fn.Curry(fn.GetValue, 2)("PrintName"), weapons.Get}}, fn.Id}
local getWeaponNames = fn.Curry(fn.Map, 2)(getWepName)
local weaponString = fn.Compose{fn.Curry(fn.Flip(table.concat), 2)("\n"), fn.Curry(fn.Seq, 2)(table.sort), getWeaponNames, table.Copy}
function PANEL:updateInfo(job)
    self.job = job

    self.lblTitle:SetText(job.name and DarkRP.deLocalise(job.name) or (job.team and "" or "No jobs available"))
    self.lblTitle:SizeToContents()

    local weps
    if not job.weapons then
        self.lblWeapons:SetText("")
        weps = ""
    else
        weps = weaponString(job.weapons)
        weps = weps ~= "" and weps or DarkRP.getPhrase("no_extra_weapons")
    end

    self.lblSweps:SetText(weps)

    self.btnGetJob:setJob(job, fn.Partial(self:GetParent():GetParent().Hide, self:GetParent():GetParent()))

    if istable(job.model) and #job.model > 1 and (not isfunction(job.PlayerSetModel) or not job.PlayerSetModel(LocalPlayer())) then
        self.pnlChooseMdl:updateInfo(job)
        self.pnlChooseMdl:SetVisible(true)
    else
        self.pnlChooseMdl:SetVisible(false)
    end

    self:InvalidateLayout()
end

function PANEL:PerformLayout()
    local text = DarkRP.textWrap(DarkRP.deLocalise(self.job.description or ""):gsub('\t', ''), "Roboto Light", self:GetWide() - 43)
    surface.SetFont("Roboto Light")
    local _, h = surface.GetTextSize(text)
    self.BaseClass.PerformLayout(self)

    self.innerPanel:SetPos(3, 3)
    self.innerPanel:SetSize(self:GetWide() - 6, self:GetTall() - self.pnlChooseMdl:GetTall() - self.btnGetJob:GetTall() - 13)
    self.innerPanel:InvalidateLayout()
    self.lblDescription:SetText(text)
    self.lblDescription:SetTall(h)
end

derma.DefineControl("F4JobsPanelRight", "", PANEL, "F4EmptyPanel")


--[[---------------------------------------------------------------------------
Jobs panel
---------------------------------------------------------------------------]]
PANEL = {}

function PANEL:Init()
    self.pnlLeft = vgui.Create("F4EmptyPanel", self)
    self.pnlLeft:Dock(LEFT)

    self.pnlRight = vgui.Create("F4JobsPanelRight", self)
    self.pnlRight:Dock(RIGHT)

    self:fillData()
end

function PANEL:PerformLayout()
    self.pnlLeft:SetWide(self:GetWide() * 2 / 3 - 5)
    if not self.pnlRight then return end
    self.pnlRight:SetWide(self:GetWide() * 1 / 3 - 5)
end

PANEL.Paint = fn.Id

function PANEL:Refresh()
    self.pnlLeft:Refresh()

    if not self.pnlLeft.Items then self.pnlRight:updateInfo({}) return end

    -- don't refresh if still valid
    if not table.IsEmpty(self.pnlRight.job) then return end

    local job
    for _, cat in ipairs(self.pnlLeft:GetItems()) do
        for _, v in pairs(cat:GetItems()) do
            if v:GetDisabled() then continue end
            job = v.DarkRPItem
            goto break2
        end
    end
    ::break2::
    self.pnlRight:updateInfo(job or {})
end

function PANEL:fillData()
    local categories = DarkRP.getCategories().jobs

    for _, cat in pairs(categories) do
        local dCat = vgui.Create("F4MenuCategory", self)

        dCat:SetButtonFactory(function(item, ui)
            local pnl = vgui.Create("F4MenuJobButton", ui)
            pnl:setDarkRPItem(item)
            pnl.DoClick = fc{fp{self.pnlRight.updateInfo, self.pnlRight}, fp{fn.GetValue, "DarkRPItem", pnl}}

            pnl:Refresh()
            return pnl
        end)

        dCat:SetPerformLayout(function(contents)

        end)

        dCat:SetCategory(cat)
        self.pnlLeft:AddItem(dCat)
    end
end

derma.DefineControl("F4MenuJobs", "", PANEL, "DPanel")
