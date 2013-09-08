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

DarkRP.DARKRP_LOADING = true
AddFoodItem("Banana", {
	model = "models/props/cs_italy/bananna.mdl",
	energy = 10,
	price = 10
})
AddFoodItem("Bunch of bananas", {
	model = "models/props/cs_italy/bananna_bunch.mdl",
	energy = 20,
	price = 20
})
AddFoodItem("Melon", {
	model = "models/props_junk/watermelon01.mdl",
	energy = 20,
	price = 20
})
AddFoodItem("Glass bottle", {
	model = "models/props_junk/GlassBottle01a.mdl",
	energy = 20,
	price = 20
})
AddFoodItem("Pop can", {
	model = "models/props_junk/PopCan01a.mdl",
	energy = 5,
	price = 5
})
AddFoodItem("Plastic bottle", {
	model = "models/props_junk/garbage_plasticbottle003a.mdl",
	energy = 15,
	price = 15
})
AddFoodItem("Milk", {
	model = "models/props_junk/garbage_milkcarton002a.mdl",
	energy = 20, 
	price = 20
})
AddFoodItem("Bottle 1", {
	model = "models/props_junk/garbage_glassbottle001a.mdl",
	energy = 10, 
	price = 10
})
AddFoodItem("Bottle 2", { 
	model = "models/props_junk/garbage_glassbottle002a.mdl",
	energy = 10,
	price = 10
})
AddFoodItem("Bottle 3", {
	model = "models/props_junk/garbage_glassbottle003a.mdl",
	energy = 10,
	price = 10
})
AddFoodItem("Orange", {
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

	TEAM_COOK = AddExtraTeam("Cook", {
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

	AddEntity("Microwave", {
		ent = "microwave",
		model = "models/props/cs_office/microwave.mdl",
		price = 400,
		max = 1,
		cmd = "buymicrowave",
		allowed = TEAM_COOK
	})

	DarkRP.DARKRP_LOADING = nil
end)
