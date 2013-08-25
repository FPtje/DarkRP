DarkRP.declareChatCommand{
	command = "rpname",
	description = "Set your RP name",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "name",
	description = "Set your RP name",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "nick",
	description = "Set your RP name",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "buy",
	description = "Buy a pistol",
	delay = 1.5,
	condition = fn.FAnd {
		fn.Compose{fn.Curry(fn.GetValue, 2)("enablebuypistol"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode},
		fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noguns"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}
	}
}

DarkRP.declareChatCommand{
	command = "buyshipment",
	description = "Buy a shipment",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "buyvehicle",
	description = "Buy a vehicle",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "buyammo",
	description = "Purchase ammo",
	delay = 1.5,
	condition = fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noguns"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}
}

DarkRP.declareChatCommand{
	command = "price",
	description = "Set the price of the microwave or gunlab you're looking at",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "setprice",
	description = "Set the price of the microwave or gunlab you're looking at",
	delay = 1.5
}
