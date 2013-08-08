local PANEL = {}

local mouseX, mouseY = ScrW() / 2, ScrH() / 2
function PANEL:Init()
	self:SetSkin(GAMEMODE.Config.DarkRPSkin)

	self:SetTitle("")

	self.F4Down = true

	self:StretchToParent(100, 100, 100, 100)
	self:Center()
	self:SetVisible(true)
	self:MakePopup()
end

function PANEL:Think()
	F4Bind = F4Bind or input.KeyNameToNumber(input.LookupBinding("gm_showspare2"))

	if self.F4Down and not input.IsKeyDown(F4Bind) then
		self.F4Down = false
		return
	elseif not self.F4Down and input.IsKeyDown(F4Bind) then
		self.F4Down = true
		self:Hide()
	end
end

function PANEL:Show()
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

derma.DefineControl("F4MenuFrame", "", PANEL, "DFrame")
