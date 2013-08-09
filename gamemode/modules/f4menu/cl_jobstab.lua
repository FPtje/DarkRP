/*---------------------------------------------------------------------------
Left panel for the jobs
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:SetBackgroundColor(Color(0, 0, 0, 0))
	self:EnableVerticalScrollbar()
	self:SetSpacing(10)
	self.VBar.Paint = fn.Id
	self.VBar.btnUp.Paint = fn.Id
	self.VBar.btnDown.Paint = fn.Id
end

-- The white stuff is for testing purposes.
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,255))
end

derma.DefineControl("F4EmptyPanel", "", PANEL, "DPanelList")


/*---------------------------------------------------------------------------
Jobs panel
---------------------------------------------------------------------------*/
PANEL = {}

function PANEL:Init()
	self.pnlLeft = vgui.Create("F4EmptyPanel", self)
	self.pnlLeft:Dock(LEFT)

	self.pnlRight = vgui.Create("F4EmptyPanel", self)
	self.pnlRight:Dock(RIGHT)
end

function PANEL:PerformLayout()
	self.pnlLeft:SetWide(self:GetWide() * 2/3 - 5)
	self.pnlRight:SetWide(self:GetWide() * 1/3 - 5)
end

PANEL.Paint = fn.Id

derma.DefineControl("F4MenuJobs", "", PANEL, "DPanel")
