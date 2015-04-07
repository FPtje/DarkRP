local checkModel = function(model) return model ~= nil and (CLIENT or util.IsValidModel(model)) end
local validFood = {"name", model = checkModel, "energy", "price"}

FoodItems = {}
function fprp.createFood(name, mdl, energy, price)
	local foodItem = istable(mdl) and mdl or {model = mdl, energy = energy, price = price}
	foodItem.name = name

	if fprp.fprp_LOADING and fprp.disabledDefaults["food"][name] then return end

	for k,v in pairs(validFood) do
		local isfunction = isfunction(v)

		if (isFunction and not v(foodItem[k])) or (not isFunction and foodItem[v] == nil) then
			ErrorNoHalt("Corrupt food \"" .. (name or "") .. "\": element " .. (isfunction and k or v) .. " is corrupt.\n")
		end
	end

	table.insert(FoodItems, foodItem);
end
AddFoodItem = fprp.createFood

local plyMeta = FindMetaTable("Player");
plyMeta.isCook = fn.Compose{fn.Curry(fn.GetValue, 2)("cook"), plyMeta.getJobTable}

--[[
Valid members:
	model = string, -- the model of the food item
	energy = int, -- how much energy it restores
	price = int, -- the price of the food
	requiresCook = boolean, -- whether only cooks can buy this food
	customCheck = function(ply) return boolean end, -- customCheck on purchase function
	customCheckMessage = string -- message to people who cannot buy it because of the customCheck
]]
fprp.fprp_LOADING = true

fprp.registerfprpVar("Energy", net.WriteFloat, net.ReadFloat);

fprp.createFood("Banana", {
	model = "models/props/cs_italy/bananna.mdl",
	energy = 10,
	price = 10
});
fprp.createFood("Bunch of bananas", {
	model = "models/props/cs_italy/bananna_bunch.mdl",
	energy = 20,
	price = 20
});
fprp.createFood("Melon", {
	model = "models/props_junk/watermelon01.mdl",
	energy = 20,
	price = 20
});
fprp.createFood("Glass bottle", {
	model = "models/props_junk/GlassBottle01a.mdl",
	energy = 20,
	price = 20
});
fprp.createFood("Pop can", {
	model = "models/props_junk/PopCan01a.mdl",
	energy = 5,
	price = 5
});
fprp.createFood("Plastic bottle", {
	model = "models/props_junk/garbage_plasticbottle003a.mdl",
	energy = 15,
	price = 15
});
fprp.createFood("Milk", {
	model = "models/props_junk/garbage_milkcarton002a.mdl",
	energy = 20,
	price = 20
});
fprp.createFood("Bottle 1", {
	model = "models/props_junk/garbage_glassbottle001a.mdl",
	energy = 10,
	price = 10
});
fprp.createFood("Bottle 2", {
	model = "models/props_junk/garbage_glassbottle002a.mdl",
	energy = 10,
	price = 10
});
fprp.createFood("Bottle 3", {
	model = "models/props_junk/garbage_glassbottle003a.mdl",
	energy = 10,
	price = 10
});
fprp.createFood("Orange", {
	model = "models/props/cs_italy/orange.mdl",
	energy = 20,
	price = 20
});

fprp.fprp_LOADING = nil
