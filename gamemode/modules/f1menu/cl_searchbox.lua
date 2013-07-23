local PANEL = {}

function PANEL:Init()
	self:SetWide(300)
	self:SetKeyBoardInputEnabled(true)
	self.BaseClass.Init(self)
	self.F1Down = true
	self:SetFont("DarkRPHUD2")
	self:SetTextColor(Color(255,255,255,255))
	self:SetCursorColor(Color(255,255,255,255))
	self:SetDrawBackground(false)
end

function PANEL:OnLoseFocus()
	self:GetParent():SetKeyboardInputEnabled(false)
end

local F1Bind
function PANEL:Think()
	F1Bind = F1Bind or input.KeyNameToNumber(input.LookupBinding("gm_showhelp"))
	if self.F1Down and not input.IsKeyDown(F1Bind) then
		self.F1Down = false
		return
	elseif not self.F1Down and input.IsKeyDown(F1Bind) then
		self.F1Down = true
		self:GetParent():slideOut()
	end
end

derma.DefineControl("F1SearchBox", "The search box to search chat commands", PANEL, "DTextEntry")
