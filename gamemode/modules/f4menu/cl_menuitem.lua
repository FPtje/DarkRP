local PANEL = {}

AccessorFunc(PANEL, "borderColor", "BorderColor")

/*---------------------------------------------------------------------------
Generic item
---------------------------------------------------------------------------*/
function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self:SetCursor("hand")

	self:SetFont("F4MenuFont1")
	self:SetTextColor(Color(255, 255, 255, 255))
	self:SetTall(60)
	self:DockPadding(0, 0, 10, 5)

	self.model = self.model or vgui.Create("ModelImage", self)
	self.model:SetSize(60, 60)
	self.model:SetPos(0, 0)

	self.txtRight = self.txtRight or vgui.Create("DLabel", self)
	self.txtRight:SetFont("F4MenuFont1")
	self.txtRight:Dock(RIGHT)
	self.txtRight:SetTextColor(Color(255, 255, 255, 255))
end

local black, gray = Color(0, 0, 0, 255), Color(140, 140, 140, 255)
function PANEL:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, black) -- background

	draw.RoundedBoxEx(4, h, h - 10, w - 60, 10, self:GetBorderColor() or black, false, false, false, true) -- the colored bar

	draw.RoundedBoxEx(4, 0, 0, h, h, gray, true, false, false, false) -- gray box for the model
end

function PANEL:SetModel(mdl, skin)
	self.model:SetModel(mdl, skin, "000000000")
end

function PANEL:SetTextRight(text)
	self.txtRight:SetText(text)
	self.txtRight:SizeToContents()
	self.txtRight:Dock(RIGHT)
end

-- For overriding
function PANEL:setDarkRPItem(item)

end

function PANEL:Refresh()

end

derma.DefineControl("F4MenuItemButton", "", PANEL, "DButton")

/*---------------------------------------------------------------------------
Job item
---------------------------------------------------------------------------*/
PANEL = {}

local function getMaxOfTeam(job)
	if not job.max or job.max == 0 then return "∞" end
	if job.max % 1 == 0 then return tostring(job.max) end

	return tostring(math.floor(job.max * #player.GetAll()))
end

function PANEL:setDarkRPItem(job)
	self.DarkRPItem = job

	self:SetBorderColor(job.color)
	self:SetModel(istable(job.model) and job.model[1] or job.model)
	self:SetText(job.name)
	self:SetTextRight(string.format("%s/%s", team.NumPlayers(job.team), getMaxOfTeam(job)))
end

function PANEL:Refresh()
	self:SetTextRight(string.format("%s/%s", team.NumPlayers(self.DarkRPItem.team), getMaxOfTeam(self.DarkRPItem)))
end

function PANEL:DoClick()
	// Todo
end

derma.DefineControl("F4MenuJobButton", "", PANEL, "F4MenuItemButton")
