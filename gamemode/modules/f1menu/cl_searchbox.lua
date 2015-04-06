local PANEL = {}

function PANEL:Init()
	self:SetWide(300)
	self:SetKeyBoardInputEnabled(true)
	self.BaseClass.Init(self)
	self.SleekF1Down = true
	self:SetFont("fprpHUD2")
	self:SetTextColor(Color(255,255,255,255))
	self:SetCursorColor(Color(255,255,255,255))

	self.lblSearch = vgui.Create("DLabel", self)
	self.lblSearch:SetFont("fprpHUD2")
	self.lblSearch:SetColor(Color(200, 200, 200, 200))
	self.lblSearch:SetText(fprp.getPhrase("F1Search"))
	self.lblSearch:SizeToContents()
	self.lblSearch:SetPos(5)
end

function PANEL:OnLoseFocus()

end

local SleekF1Bind
function PANEL:Think()
	SleekF1Bind = SleekF1Bind or input.KeyNameToNumber(input.LookupBinding("gm_showhelp"))
	if not SleekF1Bind then return end

	if self.SleekF1Down and not input.IsKeyDown(SleekF1Bind) then
		self.SleekF1Down = false
		return
	elseif not self.SleekF1Down and input.IsKeyDown(SleekF1Bind) then
		self.SleekF1Down = true
		self:GetParent():slideOut()
	end
end

hook.Add("PlayerBindPress", "fprpSleekF1Bind", function(ply, bind, pressed)
	if string.find(bind, "gm_showhelp", 1, true) then
		SleekF1Bind = input.KeyNameToNumber(input.LookupBinding(bind))
	end
end)

function PANEL:OnTextChanged()
	self.BaseClass.OnTextChanged(self)
	if self:GetText() == "" then
		self.lblSearch:SetVisible(true)
	else
		self.lblSearch:SetVisible(false)
	end
end

derma.DefineControl("SleekF1SearchBox", "The search box to search chat commands", PANEL, "DTextEntry")

