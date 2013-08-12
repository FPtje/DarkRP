/*---------------------------------------------------------------------------
Base panel for custom entities
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:EnableVerticalScrollbar()
	self:generateButtons()
end

function PANEL:Rebuild()
	local height = 0
	for i, item in pairs(self.Items) do
		item:SetWide(self:GetWide() / 2 - 10)
		local goRight = i % 2 == 0
		local x = goRight and self:GetWide() / 2 or 0
		item:SetPos(x, height)

		if goRight then
			height = height + math.Max(item:GetTall(), self.Items[i - 1]:GetTall()) + 2
		end
	end
	self:GetCanvas():SetTall(height)
end

function PANEL:generateButtons()
	// override this
end

derma.DefineControl("F4MenuEntitiesBase", "", PANEL, "DPanelList")


/*---------------------------------------------------------------------------
Shipments panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyShipment(ship)
	local ply = LocalPlayer()

	if not table.HasValue(ship.allowed, ply:Team()) then return false end
	if ship.customCheck and not ship.customCheck(ply) then return false end
	if not ply:canAfford(ship.price) then return false end

	return true
end

function PANEL:generateButtons()
	local shipments = fn.Filter(fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("seperate")}, CustomShipments)

	for k,v in pairs(shipments) do
		local pnl = vgui.Create("F4MenuEntityButton", self)
		pnl:setDarkRPItem(v)

		if not canBuyShipment(v) then
			pnl:SetDisabled(true)
		end

		self:AddItem(pnl)
	end
end

function PANEL:PerformLayout()
	for k,v in pairs(self.Items) do
		if not canBuyShipment(v.DarkRPItem) then
			v:SetDisabled(true)
		else
			v:SetDisabled(false)
		end
	end
	self.BaseClass.PerformLayout(self)
end
derma.DefineControl("F4MenuShipments", "", PANEL, "F4MenuEntitiesBase")
