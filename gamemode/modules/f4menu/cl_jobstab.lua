/*---------------------------------------------------------------------------
Left panel for the jobs
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:SetBackgroundColor(Color(0, 0, 0, 0))
	self:EnableVerticalScrollbar()
	self:SetSpacing(2)
	self.VBar.Paint = fn.Id
	self.VBar.btnUp.Paint = fn.Id
	self.VBar.btnDown.Paint = fn.Id

end

function PANEL:Refresh()
	for k,v in pairs(self.Items) do
		if v.Refresh then v:Refresh() end
	end
end

/*-- The white stuff is for testing purposes.
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,255))
end*/

derma.DefineControl("F4EmptyPanel", "", PANEL, "DPanelList")

/*---------------------------------------------------------------------------
Right panel for the jobs
---------------------------------------------------------------------------*/
PANEL = {}

function PANEL:Init()
	self.BaseClass.Init(self)
	self:SetPadding(10)
end

local black = Color(0, 0, 0, 170)
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, black)
end

function PANEL:updateInfo(job)
	self:Clear()

	local lblTitle = vgui.Create("DLabel")
	lblTitle:SetFont("HUDNumber5")
	lblTitle:SetText(job.name)
	lblTitle:SizeToContents()
	self:AddItem(lblTitle)

	local lblDescription = vgui.Create("DLabel")
	lblDescription:SetWide(self:GetWide() - 20)
	lblDescription:SetAutoStretchVertical(true)
	lblDescription:SetText(job.description)
	self:AddItem(lblDescription)
end

derma.DefineControl("F4JobsPanelRight", "", PANEL, "F4EmptyPanel")


/*---------------------------------------------------------------------------
Jobs panel
---------------------------------------------------------------------------*/
PANEL = {}

function PANEL:Init()
	self.pnlLeft = vgui.Create("F4EmptyPanel", self)
	self.pnlLeft:Dock(LEFT)

	self.pnlRight = vgui.Create("F4JobsPanelRight", self)
	self.pnlRight:Dock(RIGHT)

	self:fillData()
	self.pnlRight:updateInfo(RPExtraTeams[1])
end

function PANEL:PerformLayout()
	self.pnlLeft:SetWide(self:GetWide() * 2/3 - 5)
	self.pnlRight:SetWide(self:GetWide() * 1/3 - 5)
end

PANEL.Paint = fn.Id

function PANEL:Refresh()
	self.pnlLeft:Refresh()
end

function PANEL:fillData()
	for i, job in ipairs(RPExtraTeams) do
		local item = vgui.Create("F4MenuJobButton")
		item:setDarkRPItem(job)
		item.DoClick = fn.Compose{fn.Curry(self.pnlRight.updateInfo, 2)(self.pnlRight), fn.Curry(fn.GetValue, 3)("DarkRPItem")(item)}
		self.pnlLeft:AddItem(item)
	end
end

derma.DefineControl("F4MenuJobs", "", PANEL, "DPanel")
