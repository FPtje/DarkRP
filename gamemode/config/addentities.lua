fprp.createShipment("Desert eagle", {
	model = "models/weapons/w_pist_deagle.mdl",
	entity = "weapon_deagle2",
	price = 215,
	amount = 10,
	seperate = true,
	pricesep = 215,
	noship = true,
	allowed = {TEAM_GUN},
	category = "Pistols",
});

fprp.createShipment("Fiveseven", {
	model = "models/weapons/w_pist_fiveseven.mdl",
	entity = "weapon_fiveseven2",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 205,
	noship = true,
	allowed = {TEAM_GUN},
	category = "Pistols",
});

fprp.createShipment("Glock", {
	model = "models/weapons/w_pist_glock18.mdl",
	entity = "weapon_glock2",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 160,
	noship = true,
	allowed = {TEAM_GUN},
	category = "Pistols",
});

fprp.createShipment("P228", {
	model = "models/weapons/w_pist_p228.mdl",
	entity = "weapon_p2282",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 185,
	noship = true,
	allowed = {TEAM_GUN},
	category = "Pistols",
});

fprp.createShipment("AK47", {
	model = "models/weapons/w_rif_ak47.mdl",
	entity = "weapon_ak472",
	price = 2450,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN},
	category = "Rifles",
});

fprp.createShipment("MP5", {
	model = "models/weapons/w_smg_mp5.mdl",
	entity = "weapon_mp52",
	price = 2200,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN},
	category = "Rifles",
});

fprp.createShipment("M4", {
	model = "models/weapons/w_rif_m4a1.mdl",
	entity = "weapon_m42",
	price = 2450,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN},
	category = "Rifles",
});

fprp.createShipment("Mac 10", {
	model = "models/weapons/w_smg_mac10.mdl",
	entity = "weapon_mac102",
	price = 2150,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
});

fprp.createShipment("Pump shotgun", {
	model = "models/weapons/w_shot_m3super90.mdl",
	entity = "weapon_pumpshotgun2",
	price = 1750,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN},
	category = "Shotguns",
});

fprp.createShipment("Sniper rifle", {
	model = "models/weapons/w_snip_g3sg1.mdl",
	entity = "ls_sniper",
	price = 3750,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN},
	category = "Snipers",
});

fprp.createEntity("Drug lab", {
	ent = "drug_lab",
	model = "models/props_lab/crematorcase.mdl",
	price = 400,
	max = 3,
	cmd = "buydruglab",
	allowed = {TEAM_GANG, TEAM_MOB}
});

fprp.createEntity("shekel printer", {
	ent = "money_printer",
	model = "models/props_c17/consolebox01a.mdl",
	price = 1000,
	max = 2,
	cmd = "buyshekelprinter"
});

fprp.createEntity("Printer Mover", {
	ent = "printer_mover",
	model = "models/props_interiors/refrigerator01a.mdl",
	price = 1000,
	max = 2,
	cmd = "buyprintermover"
});

fprp.createEntity("Gun lab", {
	ent = "gunlab",
	model = "models/props_c17/TrapPropeller_Engine.mdl",
	price = 500,
	max = 1,
	cmd = "buygunlab",
	allowed = TEAM_GUN
});

if not fprp.disabledDefaults["modules"]["hungermod"] then
	fprp.createEntity("Microwave", {
		ent = "microwave",
		model = "models/props/cs_office/microwave.mdl",
		price = 400,
		max = 1,
		cmd = "buymicrowave",
		allowed = TEAM_COOK
	});
end

fprp.createCategory{
	name = "Other",
	categorises = "entities",
	startExpanded = true,
	color = Color(0, 107, 0, 255),
	canSee = fp{fn.Id, true},
	sortOrder = 255,
}

fprp.createCategory{
    name = "Other",
    categorises = "shipments",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 255,
}

fprp.createCategory{
    name = "Rifles",
    categorises = "shipments",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 100,
}

fprp.createCategory{
    name = "Shotguns",
    categorises = "shipments",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

fprp.createCategory{
    name = "Snipers",
    categorises = "shipments",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 102,
}

fprp.createCategory{
	name = "Pistols",
	categorises = "weapons",
	startExpanded = true,
	color = Color(0, 107, 0, 255),
	canSee = fp{fn.Id, true},
	sortOrder = 100,
}

fprp.createCategory{
	name = "Other",
	categorises = "weapons",
	startExpanded = true,
	color = Color(0, 107, 0, 255),
	canSee = fp{fn.Id, true},
	sortOrder = 255,
}

fprp.createCategory{
	name = "Other",
	categorises = "vehicles",
	startExpanded = true,
	color = Color(0, 107, 0, 255),
	canSee = fp{fn.Id, true},
	sortOrder = 255,
}
