/*---------------------------------------------------------------------------
Base panel for custom entities
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:EnableVerticalScrollbar()
	self:generateButtons()
end

function PANEL:Rebuild()
	if #self.Items == 0 then return end

	local height = 0
	local k = 0
	for i, item in pairs(self.Items) do
		if not item:IsVisible() then continue end
		k = k + 1
		item:SetWide(self:GetWide() / 2 - 10)
		local goRight = k % 2 == 0
		local x = goRight and self:GetWide() / 2 or 0
		item:SetPos(x, height)

		if goRight then
			height = height + math.Max(item:GetTall(), self.Items[k - 1]:GetTall()) + 2
		end
	end
	self:GetCanvas():SetTall(height + self.Items[#self.Items]:GetTall())
end

function PANEL:generateButtons()
	// override this
end

function PANEL:isItemHidden(cantBuy, important)
	return cantBuy and (GAMEMODE.Config.hideNonBuyable or (important and GAMEMODE.Config.hideTeamUnbuyable))
end

function PANEL:shouldHide()
	// override this
end

function PANEL:Refresh()
	for k,v in pairs(self.Items) do
		if v.Refresh then v:Refresh() end
	end
	self:InvalidateLayout()
end

derma.DefineControl("F4MenuEntitiesBase", "", PANEL, "DPanelList")

/*---------------------------------------------------------------------------
Entities panel
---------------------------------------------------------------------------*/
PANEL = {}

function PANEL:generateButtons()
	for k,v in pairs(DarkRPEntities) do
		local pnl = vgui.Create("F4MenuEntityButton", self)
		pnl:setDarkRPItem(v)
		pnl.DoClick = fn.Partial(RunConsoleCommand, "DarkRP", v.cmd)
		self:AddItem(pnl)
	end
end

local function canBuyEntity(item)
	local ply = LocalPlayer()

	if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false, true end
	if item.customCheck and not item.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, item)
	local cost = price or item.price
	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:shouldHide()
	for k,v in pairs(DarkRPEntities) do
		local canBuy, important = canBuyEntity(v)
		if not self:isItemHidden(not canBuy, important) then return false end
	end
	return true
end

function PANEL:PerformLayout()
	for k,v in pairs(self.Items) do
		local canBuy, important, price = canBuyEntity(v.DarkRPItem)

		v:SetDisabled(not canBuy, important)
		v:updatePrice(price)
	end
	self.BaseClass.PerformLayout(self)
end

derma.DefineControl("F4MenuEntities", "", PANEL, "F4MenuEntitiesBase")

/*---------------------------------------------------------------------------
Shipments panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyShipment(ship)
	local ply = LocalPlayer()

	if not table.HasValue(ship.allowed, ply:Team()) then return false, true end
	if ship.customCheck and not ship.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyShipment", nil, ply, ship)
	local cost = price or ship.getPrice and ship.getPrice(ply, ship.price) or ship.price

	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:generateButtons()
	local shipments = fn.Filter(fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noship")}, CustomShipments)

	for k,v in pairs(shipments) do
		local pnl = vgui.Create("F4MenuEntityButton", self)
		pnl:setDarkRPItem(v)

		pnl.DoClick = fn.Partial(RunConsoleCommand, "DarkRP", "buyshipment", v.name)
		self:AddItem(pnl)
	end
end

function PANEL:shouldHide()
	local shipments = fn.Filter(fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noship")}, CustomShipments)

	for k,v in pairs(shipments) do
		local canBuy, important = canBuyShipment(v)
		if not self:isItemHidden(not canBuy, important) then return false end
	end

	return true
end

function PANEL:PerformLayout()
	for k,v in pairs(self.Items) do
		local canBuy, important, price = canBuyShipment(v.DarkRPItem)

		v:SetDisabled(not canBuy, important)
		v:updatePrice(price)
	end
	self.BaseClass.PerformLayout(self)
end

derma.DefineControl("F4MenuShipments", "", PANEL, "F4MenuEntitiesBase")

/*---------------------------------------------------------------------------
Gun buying panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyGun(ship)
	local ply = LocalPlayer()

	if GAMEMODE.Config.restrictbuypistol and not table.HasValue(ship.allowed, ply:Team()) then return false, true end
	if ship.customCheck and not ship.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyPistol", nil, ply, ship)
	local cost = price or ship.getPrice and ship.getPrice(ply, ship.pricesep) or ship.pricesep

	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:generateButtons()
	local shipments = fn.Filter(fn.Curry(fn.GetValue, 2)("seperate"), CustomShipments)

	for k,v in pairs(shipments) do
		local pnl = vgui.Create("F4MenuPistolButton", self)
		pnl:setDarkRPItem(v)

		self:AddItem(pnl)
	end
end

function PANEL:shouldHide()
	local shipments = fn.Filter(fn.Curry(fn.GetValue, 2)("seperate"), CustomShipments)

	for k,v in pairs(shipments) do
		local canBuy, important = canBuyGun(v)

		if not self:isItemHidden(not canBuy, important) then return false end
	end

	return true
end


function PANEL:PerformLayout()
	for k,v in pairs(self.Items) do
		local canBuy, important, price = canBuyGun(v.DarkRPItem)

		v:SetDisabled(not canBuy, important)
		v:updatePrice(price)
	end
	self.BaseClass.PerformLayout(self)
end


derma.DefineControl("F4MenuGuns", "", PANEL, "F4MenuEntitiesBase")

/*---------------------------------------------------------------------------
Ammo panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyAmmo(item)
	local ply = LocalPlayer()

	if item.customCheck and not item.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyAmmo", nil, ply, item)
	local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price
	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, price
	end

	return true, nil, price
end

function PANEL:generateButtons()
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		local pnl = vgui.Create("F4MenuEntityButton", self)
		pnl:setDarkRPItem(v)
		pnl.DoClick = fn.Partial(RunConsoleCommand, "DarkRP", "buyammo", k)
		self:AddItem(pnl)
	end
end

function PANEL:shouldHide()
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		local canBuy, important = canBuyAmmo(v)
		if not self:isItemHidden(not canBuy, important) then return false end
	end
	return true
end

function PANEL:PerformLayout()
	for k,v in pairs(self.Items) do
		local canBuy, important, price = canBuyAmmo(v.DarkRPItem)
		v:SetDisabled(not canBuy, important)
		v:updatePrice(price)
	end
	self.BaseClass.PerformLayout(self)
end

derma.DefineControl("F4MenuAmmo", "", PANEL, "F4MenuEntitiesBase")

/*---------------------------------------------------------------------------
Vehicles panel
---------------------------------------------------------------------------*/
PANEL = {}

function PANEL:generateButtons()
	for k,v in pairs(CustomVehicles) do
		local pnl = vgui.Create("F4MenuEntityButton", self)
		pnl:setDarkRPItem(v)
		pnl.DoClick = fn.Partial(RunConsoleCommand, "DarkRP", "buyvehicle", v.name)
		self:AddItem(pnl)
	end
end

local function canBuyVehicle(item)
	local ply = LocalPlayer()
	local cost = item.getPrice and item.getPrice(ply, item.price) or item.price

	if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false, true end
	if item.customCheck and not item.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyVehicle", nil, ply, item)

	cost = price or cost

	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:PerformLayout()
	for k,v in pairs(self.Items) do
		local canBuy, important, price = canBuyVehicle(v.DarkRPItem)

		v:SetDisabled(not canBuy, important)
		v:updatePrice(price)
	end
	self.BaseClass.PerformLayout(self)
end

derma.DefineControl("F4MenuVehicles", "", PANEL, "F4MenuEntitiesBase")
