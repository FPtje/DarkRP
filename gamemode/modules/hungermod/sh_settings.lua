-- foodspawn - Whether players(non-cooks) can spawn food props or not
GM.Config.foodspawn = true
-- foodspecialcost <1 or 0> - Enable/disable whether spawning food props have a special cost
GM.Config.foodpay = true
-- foodcost <Amount> - Set food cost
GM.Config.foodcost = 15
-- hungerspeed <Amount> - Set the rate at which players will become hungry (2 is the default)
GM.Config.hungerspeed = 2
-- starverate <Amount> - How much health that is taken away every second the player is starving  (3 is the default)
GM.Config.starverate = 3

/*---------------------------------------------------------------------------
Settings for the job and entities
---------------------------------------------------------------------------*/
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
	cook = true,
	mayorCanSetSalary = true
})

AddEntity("Microwave", {
	ent = "microwave",
	model = "models/props/cs_office/microwave.mdl",
	price = 400,
	max = 1,
	cmd = "/buymicrowave",
	allowed = TEAM_COOK
})