local PANEL = {}

local function canBuyFood(food)
    local ply = LocalPlayer()

    if (food.requiresCook == nil or food.requiresCook == true) and not ply:isCook() then return false, true end
    if food.customCheck and not food.customCheck(LocalPlayer()) then return false, false end

    if not ply:canAfford(food.price) then return false, false end

    return true
end

function PANEL:generateButtons()
    for _, v in pairs(FoodItems) do
        local pnl = vgui.Create("F4MenuEntityButton", self)
        pnl:setDarkRPItem(v)
        pnl.DoClick = fn.Partial(RunConsoleCommand, "DarkRP", "buyfood", v.name)
        self:AddItem(pnl)
    end
end

function PANEL:shouldHide()
    for _, v in pairs(FoodItems) do
        local canBuy, important = canBuyFood(v)
        if not self:isItemHidden(not canBuy, important) then return false end
    end
    return true
end

function PANEL:PerformLayout()
    for _, v in pairs(self.Items) do
        local canBuy, important = canBuyFood(v.DarkRPItem)
        v:SetDisabled(not canBuy, important)
    end
    self.BaseClass.PerformLayout(self)
end

derma.DefineControl("F4MenuFood", "DarkRP F4 Food Tab", PANEL, "F4MenuEntitiesBase")

hook.Add("F4MenuTabs", "HungerMod_F4Tabs", function()
    if not table.IsEmpty(FoodItems) then
        DarkRP.addF4MenuTab(DarkRP.getPhrase("Food"), vgui.Create("F4MenuFood"))
    end
end)
