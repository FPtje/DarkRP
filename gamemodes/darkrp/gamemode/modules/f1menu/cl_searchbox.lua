local PANEL = {}

function PANEL:Init()
    self:SetWide(300)
    self:SetKeyboardInputEnabled(true)
    self.F1Down = true
    self:SetFont("DarkRPHUD2")

    -- This will eventually be gone when placeholder support is added to GMod
    self.lblSearch = vgui.Create("DLabel", self)
    self.lblSearch:SetFont("DarkRPHUD2")
    self.lblSearch:SetText(DarkRP.getPhrase("f1Search"))
    self.lblSearch:SizeToContents()
    self.lblSearch:SetPos(5)
    function self.lblSearch:UpdateColours(skin)
        self:SetTextStyleColor(skin.colTextEntryTextPlaceholder or Color(169, 169, 169))
    end
end

function PANEL:OnLoseFocus()

end

local F1Bind
function PANEL:Think()
    F1Bind = F1Bind or input.KeyNameToNumber(input.LookupBinding("gm_showhelp"))
    if not F1Bind then return end

    if self.F1Down and not input.IsKeyDown(F1Bind) then
        self.F1Down = false
        return
    elseif not self.F1Down and input.IsKeyDown(F1Bind) then
        self.F1Down = true
        self:GetParent():slideOut()
    end
end

hook.Add("PlayerBindPress", "DarkRPF1Bind", function(ply, bind, pressed)
    if string.find(bind, "gm_showhelp", 1, true) then
        F1Bind = input.KeyNameToNumber(input.LookupBinding(bind))
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

derma.DefineControl("F1SearchBox", "The search box to search chat commands", PANEL, "DTextEntry")
