local updateModel, getModelValue, onModelUpdate =
    DarkRP.tipJarUIModel.updateModel,
    DarkRP.tipJarUIModel.getModelValue,
    DarkRP.tipJarUIModel.onModelUpdate


--[[-------------------------------------------------------------------------
Donation amount entry
---------------------------------------------------------------------------]]
local DONATE_ENTRY = {}

function DONATE_ENTRY:Init()
    self.BaseClass.Init(self)

    self:SetNumeric(true)
    self:SetSize(290, 70)
    self:SetFont("HUDNumber5")
    self:SetText("")

    onModelUpdate("amount", function(new, _, src)
        if not IsValid(self) or src == self then return end

        local pos = self:GetCaretPos()
        self:SetText(new)
        self:SetCaretPos(math.min(pos, string.len(new)))
    end)

    onModelUpdate("lastTipAmount", function()
        self:SelectAllText()
        self:RequestFocus()
    end)
end

function DONATE_ENTRY:CheckNumeric(value)
    if DarkRP.toInt(value) then return false end

    return true
end

function DONATE_ENTRY:OnChange()
    local value = DarkRP.toInt(self:GetText())

    if not value then return end

    updateModel("amount", value, self)
end

function DONATE_ENTRY:OnEnter()
    updateModel("frameVisible", false)
    updateModel("lastTipAmount", getModelValue("amount"))
end

derma.DefineControl("DarkRP_TipJar_DONATE_ENTRY", "", DONATE_ENTRY, "DTextEntry")

local DONATE_BUTTON = {}

function DONATE_BUTTON:Init()
    self.BaseClass.Init(self)

    self:SetSize(290, 80)
    self:SetText("")

    self.donateLabel = vgui.Create("DLabel", self)
    self.donateLabel:SetFont("HUDNumber5")
    self.donateLabel:SetText(DarkRP.getPhrase("Donate"))
    self.donateLabel:SizeToContents()
    self.donateLabel:SetPos(50, 10)
    self.donateLabel:CenterHorizontal()

    self.amountLabel = vgui.Create("DLabel", self)
    self.amountLabel:SetFont("HUDNumber5")
    self.amountLabel:SetPos(50, 40)

    onModelUpdate("amount", function(new)
        if not IsValid(self) then return end

        self.amountLabel:SetText(DarkRP.formatMoney(new))
        self.amountLabel:SizeToContents()
        self.amountLabel:CenterHorizontal()
    end)
end

function DONATE_BUTTON:DoClick()
    -- updateModel("frameVisible", false)
    updateModel("lastTipAmount", getModelValue("amount"))
end

derma.DefineControl("DarkRP_TipJar_DONATE_BUTTON", "", DONATE_BUTTON, "DButton")


local DONATE_LIST_ITEM = {}

function DONATE_LIST_ITEM:Init()
    self:SetSize(470, 25)
    self:SetPaintBackground(false)

    self.textL = vgui.Create("DLabel", self)
    self.textL:SetFont("DarkRPHUD2")
    self.textL:Dock(LEFT)

    self.textR = vgui.Create("DLabel", self)
    self.textR:SetFont("DarkRPHUD2")
    self.textR:DockMargin(5, 5, 20, 5)
    self.textR:Dock(RIGHT)

    self.donatedColor = Color(50, 130, 50)
    self.activeColor = Color(180, 180, 180)
    self.moneyColor = Color(50, 130, 50)
end

function DONATE_LIST_ITEM:SetActive(name, amount)
    self.textL:SetText(name)
    self.textL:SetTextColor(self.activeColor)
    self.textL:SizeToContents()

    self.textR:SetText(amount)
    self.textR:SetTextColor(self.activeColor)
    self.textR:SizeToContents()
end

function DONATE_LIST_ITEM:SetDonated(name, amount)
    self.textL:SetText(name)
    self.textL:SetTextColor(self.donatedColor)
    self.textL:SizeToContents()

    self.textR:SetText(amount)
    self.textR:SetTextColor(self.moneyColor)
    self.textR:SizeToContents()
end

derma.DefineControl("DarkRP_TipJar_DONATE_LIST_ITEM", "", DONATE_LIST_ITEM, "DPanel")


local DONATE_LIST = {}

function DONATE_LIST:Init()
    self.activeLines = {}
    self.donatedLines = {}

    self:SetSize(480, 465)

    self:SetBackgroundColor(color_transparent)
    self:EnableVerticalScrollbar()
    self:SetSpacing(10)
    self.VBar.Paint = fn.Id
    self.VBar.btnUp.Paint = fn.Id
    self.VBar.btnDown.Paint = fn.Id


    onModelUpdate("activeDonationUpdate", function()
        local tipjar = getModelValue("tipjar")

        if not IsValid(self) then return end
        if not IsValid(tipjar) then return end

        self:RebuildLines(tipjar)
    end)

    onModelUpdate("donatedUpdate", function()
        local tipjar = getModelValue("tipjar")

        if not IsValid(self) then return end
        if not IsValid(tipjar) then return end

        self:RebuildLines(tipjar)

        self:PerformLayout()
        self.VBar:SetScroll(math.huge)
    end)
end

function DONATE_LIST:AddActiveLine(name, amount)
    local line = vgui.Create("DarkRP_TipJar_DONATE_LIST_ITEM", self)
    line:SetActive(name, amount)
    self:AddItem(line)

    table.insert(self.activeLines, line)
end

function DONATE_LIST:AddDonatedLine(name, amount)
    local line = vgui.Create("DarkRP_TipJar_DONATE_LIST_ITEM", self)
    line:SetDonated(name, amount)
    self:AddItem(line)

    table.insert(self.donatedLines, line)
end

function DONATE_LIST:ClearLines()
    for _, line in ipairs(self.activeLines) do
        line:Remove()
    end

    for _, line in ipairs(self.donatedLines) do
        line:Remove()
    end

    table.Empty(self.activeLines)
    table.Empty(self.donatedLines)
end

function DONATE_LIST:RebuildLines(tipjar)
    self:ClearLines()

    for _, donation in ipairs(tipjar.madeDonations) do
        self:AddDonatedLine(donation.name, DarkRP.formatMoney(donation.amount))
    end

    for ply, amount in pairs(tipjar.activeDonations) do
        -- Don't show the owner looking at this page
        if ply == tipjar:Getowning_ent() then continue end

        self.activeLines[ply:Nick()] = DarkRP.formatMoney(amount)
    end

    for name, amount in SortedPairs(self.activeLines) do
        self:AddActiveLine(name, amount)
    end
end

derma.DefineControl("DarkRP_TipJar_DONATE_LIST", "", DONATE_LIST, "DPanelList")


--[[-------------------------------------------------------------------------
Main frame
---------------------------------------------------------------------------]]
local FRAME = {}

function FRAME:Init()
    self:SetTitle("Tipping jar")
    self:SetSize(800, 500)
    self:Center()
    self:SetVisible(true)
    self:MakePopup()
    self:SetDeleteOnClose(false)

    self.donateEntry = vgui.Create("DarkRP_TipJar_DONATE_ENTRY", self)
    self.donateEntry:SetPos(10, 175)

    self.donateButton = vgui.Create("DarkRP_TipJar_DONATE_BUTTON", self)
    self.donateButton:SetPos(10, 245)

    self.donateList = vgui.Create("DarkRP_TipJar_DONATE_LIST", self)
    self.donateList:SetPos(310, 25)


    self:SetSkin(GAMEMODE.Config.DarkRPSkin)
end

function FRAME:OnClose()
    updateModel("frameVisible", false)
end

function FRAME:Think()
    local tipJar = getModelValue("tipjar")

    if not IsValid(tipJar) or
       tipJar:GetPos():DistToSqr(LocalPlayer():GetPos()) > 100 * 100 then
        updateModel("frameVisible", false)
   end
end

derma.DefineControl("DarkRP_TipJar_FRAME", "", FRAME, "DFrame")

onModelUpdate("frameVisible", function(visible)
    local tipjar = getModelValue("tipjar")
    if not IsValid(tipjar) then return end

    if not getModelValue("frame") then
        if not visible then return end

        updateModel("frame", vgui.Create("DarkRP_TipJar_FRAME"))
    end

    local frame = getModelValue("frame")

    frame:SetVisible(visible)

    if visible then
        updateModel("amount", 0)
        frame.donateEntry:SelectAllText()
        frame.donateEntry:RequestFocus()

        local disable = getModelValue("isOwner")
        frame.donateEntry:SetDisabled(disable)
        frame.donateButton:SetDisabled(disable)
    end
end)

function DarkRP.tipJarUI(tipjar)
    updateModel("tipjar", tipjar)
    updateModel("isOwner", tipjar:Getowning_ent() == LocalPlayer())
    updateModel("amount", 0)
    updateModel("frameVisible", true)
end
