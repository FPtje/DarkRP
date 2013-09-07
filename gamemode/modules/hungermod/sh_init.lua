FoodItems = {}
local function AddFoodItem(name, mdl, energy, price)
	local foodItem = istable(mdl) and mdl or {model = mdl, energy = energy, price = price}
	foodItem.name = name
	table.insert(FoodItems, foodItem)
end

AddFoodItem("banana", {
	model = "models/props/cs_italy/bananna.mdl",
	energy = 10,
	price = 10
})
AddFoodItem("bananabunch", {
	model = "models/props/cs_italy/bananna_bunch.mdl",
	energy = 20,
	price = 20
})
AddFoodItem("melon", {
	model = "models/props_junk/watermelon01.mdl",
	energy = 20,
	price = 20
})
AddFoodItem("glassbottle", {
	model = "models/props_junk/GlassBottle01a.mdl",
	energy = 20,
	price = 20
})
AddFoodItem("popcan", {
	model = "models/props_junk/PopCan01a.mdl",
	energy = 5,
	price = 5
})
AddFoodItem("plasticbottle", {
	model = "models/props_junk/garbage_plasticbottle003a.mdl",
	energy = 15,
	price = 15
})
AddFoodItem("milk", {
	model = "models/props_junk/garbage_milkcarton002a.mdl",
	energy = 20, 
	price = 20
})
AddFoodItem("bottle1", {
	model = "models/props_junk/garbage_glassbottle001a.mdl",
	energy = 10, 
	price = 10
})
AddFoodItem("bottle2", { 
	model = "models/props_junk/garbage_glassbottle002a.mdl",
	energy = 10,
	price = 10
})
AddFoodItem("bottle3", {
	model = "models/props_junk/garbage_glassbottle003a.mdl",
	energy = 10,
	price = 10
})
AddFoodItem("orange", {
	model = "models/props/cs_italy/orange.mdl",
	energy = 20,
	price = 20
})

/*---------------------------------------------------------------------------
Settings for the job and entities
---------------------------------------------------------------------------*/
timer.Simple(0, function()
	DarkRP.DARKRP_LOADING = true

	TEAM_COOK = AddExtraTeam("Cook", {
		color = Color(238, 99, 99, 255),
		model = "models/player/mossman.mdl",
		description = [[As a cook, it is your responsibility to feed the other members
			of your city.
			You can spawn a microwave and sell the food you make:
			/Buymicrowave]],
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
