FoodItems = {}
local function AddFoodItem(name, mdl, energy)
	table.insert(FoodItems, {name = name, model = mdl, energy = energy})
end

AddFoodItem("banana", "models/props/cs_italy/bananna.mdl", 10)
AddFoodItem("bananabunch", "models/props/cs_italy/bananna_bunch.mdl", 20)
AddFoodItem("melon", "models/props_junk/watermelon01.mdl", 20)
AddFoodItem("glassbottle", "models/props_junk/GlassBottle01a.mdl", 20)
AddFoodItem("popcan", "models/props_junk/PopCan01a.mdl", 5)
AddFoodItem("plasticbottle", "models/props_junk/garbage_plasticbottle003a.mdl", 15)
AddFoodItem("milk", "models/props_junk/garbage_milkcarton002a.mdl", 20)
AddFoodItem("bottle1", "models/props_junk/garbage_glassbottle001a.mdl", 10)
AddFoodItem("bottle2", "models/props_junk/garbage_glassbottle002a.mdl", 10)
AddFoodItem("bottle3", "models/props_junk/garbage_glassbottle003a.mdl", 10)
AddFoodItem("orange", "models/props/cs_italy/orange.mdl", 20)

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
