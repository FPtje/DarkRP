local checkModel = function(model) return model ~= nil and (CLIENT or util.IsValidModel(model)) end
local validFood = {"name", model = checkModel, "energy", "price"}

FoodItems = {}
function DarkRP.createFood(name, mdl, energy, price)
	local foodItem = istable(mdl) and mdl or {model = mdl, energy = energy, price = price}
	foodItem.name = name

	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["food"][name] then return end

	for k,v in pairs(validFood) do
		local isFunction = isfunction(v)

		if (isFunction and not v(foodItem[k])) or (not isFunction and foodItem[v] == nil) then
			ErrorNoHalt("Corrupt food \"" .. (name or "") .. "\": element " .. (isFunction and k or v) .. " is corrupt.\n")
		end
	end

	table.insert(FoodItems, foodItem)
end
AddFoodItem = DarkRP.createFood

--[[
Valid members:
	model = string, -- the model of the food item
	energy = int, -- how much energy it restores
	price = int, -- the price of the food
	requiresCook = boolean, -- whether only cooks can buy this food
	customCheck = function(ply) return boolean end, -- customCheck on purchase function
	customCheckMessage = string -- message to people who cannot buy it because of the customCheck
]]
DarkRP.DARKRP_LOADING = true

DarkRP.registerDarkRPVar("Energy", net.WriteFloat, net.ReadFloat)

DarkRP.createFood("Banana", {
	model = "models/props/cs_italy/bananna.mdl",
	energy = 10,
	price = 10
})
DarkRP.createFood("Bunch of bananas", {
	model = "models/props/cs_italy/bananna_bunch.mdl",
	energy = 20,
	price = 20
})
DarkRP.createFood("Melon", {
	model = "models/props_junk/watermelon01.mdl",
	energy = 20,
	price = 20
})
DarkRP.createFood("Glass bottle", {
	model = "models/props_junk/GlassBottle01a.mdl",
	energy = 20,
	price = 20
})
DarkRP.createFood("Pop can", {
	model = "models/props_junk/PopCan01a.mdl",
	energy = 5,
	price = 5
})
DarkRP.createFood("Plastic bottle", {
	model = "models/props_junk/garbage_plasticbottle003a.mdl",
	energy = 15,
	price = 15
})
DarkRP.createFood("Milk", {
	model = "models/props_junk/garbage_milkcarton002a.mdl",
	energy = 20,
	price = 20
})
DarkRP.createFood("Bottle 1", {
	model = "models/props_junk/garbage_glassbottle001a.mdl",
	energy = 10,
	price = 10
})
DarkRP.createFood("Bottle 2", {
	model = "models/props_junk/garbage_glassbottle002a.mdl",
	energy = 10,
	price = 10
})
DarkRP.createFood("Bottle 3", {
	model = "models/props_junk/garbage_glassbottle003a.mdl",
	energy = 10,
	price = 10
})
DarkRP.createFood("Orange", {
	model = "models/props/cs_italy/orange.mdl",
	energy = 20,
	price = 20
})
DarkRP.DARKRP_LOADING = nil

/*---------------------------------------------------------------------------
Settings for the job and entities
---------------------------------------------------------------------------*/
timer.Simple(0, function()
	DarkRP.DARKRP_LOADING = true

	TEAM_COOK = DarkRP.createJob("Cook", {
		color = Color(238, 99, 99, 255),
		model = "models/player/mossman.mdl",
		description = [[As a cook, it is your responsibility to feed the other members of your city.
			You can spawn a microwave and sell the food you make:
			/buymicrowave]],
		weapons = {},
		command = "cook",
		max = 2,
		salary = 45,
		admin = 0,
		vote = false,
		hasLicense = false,
		cook = true
	})

	DarkRP.createEntity("Microwave", {
		ent = "microwave",
		model = "models/props/cs_office/microwave.mdl",
		price = 400,
		max = 1,
		cmd = "buymicrowave",
		allowed = TEAM_COOK
	})

	DarkRP.DARKRP_LOADING = nil
end)
