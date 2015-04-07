/*---------------------------------------------------------------------------
Base panel for custom entities
---------------------------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
	self:EnableVerticalScrollbar();
	self:generateButtons();
end

function PANEL:Rebuild()
	if #self.Items == 0 then return end

	local lHeight, rHeight = 0, 0
	local height = 0
	local k = 0
	for i, item in pairs(self.Items) do
		if not item:IsVisible() then continue end
		k = k + 1
		local goRight = k % 2 == 0

		-- Make last item stretch if it's the first and last
		if k == #self.Items and k == 1 then
			item:SetWide(self:GetWide());
			item:SetPos(0, lHeight);
			lHeight = lHeight + item:GetTall() + 2
			break
		end

		item:SetWide(self:GetWide() / 2 - 10);
		local x = goRight and self:GetWide() / 2 or 0
		item:SetPos(x, goRight and rHeight or lHeight);

		rHeight = goRight and rHeight + item:GetTall() + 2 or rHeight
		lHeight = goRight and lHeight or lHeight + item:GetTall() + 2
	end
	height = math.max(lHeight, rHeight);
	self:GetCanvas():SetTall(height);
end

function PANEL:generateButtons()
	// override this
end

function PANEL:isItemHidden(cantBuy, important)
	return cantBuy and (GAMEMODE.Config.hideNonBuyable or (important and GAMEMODE.Config.hideTeamUnbuyable));
end

function PANEL:shouldHide()
	// override this
end

function PANEL:Refresh()
	for k,v in pairs(self.Items) do
		if v.Refresh then v:Refresh() end
	end
	self:InvalidateLayout();
end

derma.DefineControl("F4MenuEntitiesBase", "", PANEL, "DPanelList");

-- Create categories for an entity tab
local function createCategories(self, categories, itemClick, canBuy)
	for _, cat in pairs(categories) do
		if #cat.members == 0 or isfunction(cat.canSee) and not cat.canSee(LocalPlayer()) then continue end
		local dCat = vgui.Create("F4MenuCategory", self);

		dCat:SetButtonFactory(function(item, ui)
			local pnl = vgui.Create("F4MenuEntityButton", ui);
			pnl:setfprpItem(item);
			pnl.DoClick = fp{itemClick, item}

			return pnl
		end);

		dCat:SetPerformLayout(function(contents)
			for k,v in pairs(contents.Items) do
				local canBuy, important, price = canBuy(v.fprpItem);
				v:SetDisabled(not canBuy, important);
				v:updatePrice(price);
			end
		end);

		dCat:SetCategory(cat);
		self:AddItem(dCat);
	end
end

/*---------------------------------------------------------------------------
Entities panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyEntity(item)
	local ply = LocalPlayer();

	if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false, true end
	if item.customCheck and not item.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, item);
	local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price
	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:generateButtons()
	local categories = fprp.getCategories().entities

	createCategories(self, categories, function(item) RunConsoleCommand("fprp", item.cmd) end, canBuyEntity)
end

function PANEL:shouldHide()
	for k,v in pairs(fprpEntities) do
		local canBuy, important = canBuyEntity(v);
		if not self:isItemHidden(not canBuy, important) then return false end
	end
	return true
end

derma.DefineControl("F4MenuEntities", "", PANEL, "F4MenuEntitiesBase");

/*---------------------------------------------------------------------------
Shipments panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyShipment(ship)
	local ply = LocalPlayer();

	if not table.HasValue(ship.allowed, ply:Team()) then return false, true end
	if ship.customCheck and not ship.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyShipment", nil, ply, ship);
	local cost = price or ship.getPrice and ship.getPrice(ply, ship.price) or ship.price

	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:generateButtons()
	local categories = fprp.getCategories().shipments

	createCategories(self, categories, function(item) RunConsoleCommand("fprp", "buyshipment", item.name) end, canBuyShipment)
end

function PANEL:shouldHide()
	local shipments = fn.Filter(fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noship")}, CustomShipments);

	for k,v in pairs(shipments) do
		local canBuy, important = canBuyShipment(v);
		if not self:isItemHidden(not canBuy, important) then return false end
	end

	return true
end

derma.DefineControl("F4MenuShipments", "", PANEL, "F4MenuEntitiesBase");

/*---------------------------------------------------------------------------
Gun buying panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyGun(ship)
	local ply = LocalPlayer();

	if GAMEMODE.Config.restrictbuypistol and not table.HasValue(ship.allowed, ply:Team()) then return false, true end
	if ship.customCheck and not ship.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyPistol", nil, ply, ship);
	local cost = price or ship.getPrice and ship.getPrice(ply, ship.pricesep) or ship.pricesep

	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:generateButtons()
	local categories = fprp.getCategories().weapons

	createCategories(self, categories, function(item) RunConsoleCommand("fprp", "buy", item.name) end, canBuyGun)
end

function PANEL:shouldHide()
	local shipments = fn.Filter(fn.Curry(fn.GetValue, 2)("seperate"), CustomShipments);

	for k,v in pairs(shipments) do
		local canBuy, important = canBuyGun(v);

		if not self:isItemHidden(not canBuy, important) then return false end
	end

	return true
end

derma.DefineControl("F4MenuGuns", "", PANEL, "F4MenuEntitiesBase");

/*---------------------------------------------------------------------------
Ammo panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyAmmo(item)
	local ply = LocalPlayer();

	if item.customCheck and not item.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyAmmo", nil, ply, item);
	local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price
	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, price
	end

	return true, nil, price
end

function PANEL:generateButtons()
	local categories = fprp.getCategories().ammo

	createCategories(self, categories, function(item) RunConsoleCommand("fprp", "buyammo", item.id) end, canBuyAmmo)
end

function PANEL:shouldHide()
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		local canBuy, important = canBuyAmmo(v);
		if not self:isItemHidden(not canBuy, important) then return false end
	end
	return true
end

derma.DefineControl("F4MenuAmmo", "", PANEL, "F4MenuEntitiesBase");

/*---------------------------------------------------------------------------
Vehicles panel
---------------------------------------------------------------------------*/
PANEL = {}

local function canBuyVehicle(item)
	local ply = LocalPlayer();
	local cost = item.getPrice and item.getPrice(ply, item.price) or item.price

	if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false, true end
	if item.customCheck and not item.customCheck(ply) then return false, true end

	local canbuy, suppress, message, price = hook.Call("canBuyVehicle", nil, ply, item);

	cost = price or cost

	if not ply:canAfford(cost) then return false, false, cost end

	if canbuy == false then
		return false, suppress, cost
	end

	return true, nil, cost
end

function PANEL:generateButtons()
	local categories = fprp.getCategories().vehicles

	createCategories(self, categories, function(item) RunConsoleCommand("fprp", "buyvehicle", item.name) end, canBuyVehicle)
end

derma.DefineControl("F4MenuVehicles", "", PANEL, "F4MenuEntitiesBase");
