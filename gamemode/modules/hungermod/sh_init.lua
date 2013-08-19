/*---------------------------------------------------------------------------
Settings for the job and entities
---------------------------------------------------------------------------*/
hook.Add("Initialize", "HungerMod_Init", function()
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
end)
