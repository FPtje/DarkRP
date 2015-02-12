DarkRP.createShipment("Desert eagle", {
	model = "models/weapons/w_deserteagle.mdl",
	entity = "fas2_deagle",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 2200,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("M1911", {
	model = "models/weapons/w_1911.mdl",
	entity = "fas2_m1911",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 1000,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("OTs-33 Pernach", {
	model = "models/weapons/world/pistols/ots33.mdl",
	entity = "fas2_ots33",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 1350,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Ragging Bull", {
	model = "models/weapons/view/pistols/ragingbull.mdl",
	entity = "fas2_ragingbull",
	price = 0,
	amount = 10,
	seperate = true,
	pricesep = 2200,
	noship = true,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("AK47", {
	model = "models/weapons/w_rif_ak47.mdl",
	entity = "weapon_ak472",
	price = 2450,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("MP5", {
	model = "models/weapons/w_smg_mp5.mdl",
	entity = "weapon_mp52",
	price = 2200,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("M4", {
	model = "models/weapons/w_rif_m4a1.mdl",
	entity = "weapon_m42",
	price = 2450,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Mac 10", {
	model = "models/weapons/w_smg_mac10.mdl",
	entity = "weapon_mac102",
	price = 2150,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Pump shotgun", {
	model = "models/weapons/w_shot_m3super90.mdl",
	entity = "weapon_pumpshotgun2",
	price = 1750,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createShipment("Sniper rifle", {
	model = "models/weapons/w_snip_g3sg1.mdl",
	entity = "ls_sniper",
	price = 3750,
	amount = 10,
	seperate = false,
	pricesep = nil,
	noship = false,
	allowed = {TEAM_GUN}
})

DarkRP.createEntity("Drug lab", {
	ent = "drug_lab",
	model = "models/props_lab/crematorcase.mdl",
	price = 400,
	max = 3,
	cmd = "buydruglab",
	allowed = {TEAM_GANG, TEAM_MOB}
})

DarkRP.createEntity("Money printer", {
	ent = "money_printer",
	model = "models/props_c17/consolebox01a.mdl",
	price = 1000,
	max = 2,
	cmd = "buymoneyprinter"
})

DarkRP.createEntity("Gun lab", {
	ent = "gunlab",
	model = "models/props_c17/TrapPropeller_Engine.mdl",
	price = 500,
	max = 1,
	cmd = "buygunlab",
	allowed = TEAM_GUN
})

if not DarkRP.disabledDefaults["modules"]["hungermod"] then
	DarkRP.createEntity("Microwave", {
		ent = "microwave",
		model = "models/props/cs_office/microwave.mdl",
		price = 400,
		max = 1,
		cmd = "buymicrowave",
		allowed = TEAM_COOK
	})
end
