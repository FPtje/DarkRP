RPExtraTeams = {}
function AddExtraTeam(Name, colorOrTable, model, Description, Weapons, command, maximum_amount_of_this_class, Salary, admin, Vote, Haslicense, NeedToChangeFrom, CustomCheck)
	local tableSyntaxUsed = colorOrTable.r == nil -- the color is not a color table.

	if not Name or not colorOrTable or not tableSyntaxUsed and (not model or not Description or
	not Weapons or not command or not maximum_amount_of_this_class or not Salary or not admin or Vote == nil) then
		local text = "One of the custom teams is wrongly made! Attempting to give name of the wrongly made team!(if it's nil then I failed):\n" .. tostring(Name)
		print(text)
		hook.Add("PlayerSpawn", "TeamError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text) end
		end)
	end

	local CustomTeam = tableSyntaxUsed and colorOrTable or
		{color = colorOrTable, model = model, description = Description, weapons = Weapons, command = command,
			max = maximum_amount_of_this_class, salary = Salary, admin = admin or 0, vote = tobool(Vote), hasLicense = Haslicense,
			NeedToChangeFrom = NeedToChangeFrom, customCheck = CustomCheck
		}
	CustomTeam.name = Name

	table.insert(RPExtraTeams, CustomTeam)
	team.SetUp(#RPExtraTeams, Name, CustomTeam.color)
	local Team = #RPExtraTeams

	timer.Simple(0, function() GAMEMODE:AddTeamCommands(CustomTeam, CustomTeam.max) end)

	// Precache model here. Not right before the job change is done
	if type(CustomTeam.model) == "table" then
		for k,v in pairs(CustomTeam.model) do util.PrecacheModel(v) end
	else
		util.PrecacheModel(CustomTeam.model)
	end
	return Team
end

RPExtraTeamDoors = {}
function AddDoorGroup(name, ...)
	RPExtraTeamDoors[name] = {...}
end

CustomVehicles = {}
CustomShipments = {}
function AddCustomShipment(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel, CustomCheck)
	local tableSyntaxUsed = type(model) == "table"
	if not name or not model or not tableSyntaxUsed and (not entity or not price or not Amount_of_guns_in_one_shipment or (Sold_seperately and not price_seperately)) then
		local text = "One of the custom shipments is wrongly made! Attempt to give name of the wrongly made shipment!(if it's nil then I failed):\n" .. tostring(name)
		print(text)
		hook.Add("PlayerSpawn", "ShipmentError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text) end end)
		return
	end

	local AllowedClasses = classes or {}
	if not classes then
		for k,v in pairs(team.GetAllTeams()) do
			table.insert(AllowedClasses, k)
		end
	end

	local price = tonumber(price)
	local shipmentmodel = shipmodel or "models/Items/item_item_crate.mdl"

	local customShipment = tableSyntaxUsed and model or
		{model = model, entity = entity, price = price, amount = Amount_of_guns_in_one_shipment,
		seperate = Sold_seperately, pricesep = price_seperately, noship = noshipment, allowed = AllowedClasses,
		shipmodel = shipmentmodel, customCheck = CustomCheck, weight = 5}

	customShipment.name = name
	customShipment.allowed = customShipment.allowed or {}

	if SERVER and not util.IsValidModel(customShipment.model) then
		local text = "The model of shipment "..name.." is incorrect! can not create custom shipment!"
		print(text)
		hook.Add("PlayerSpawn", "ShipmentError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text) end end)
		return
	end

	table.insert(CustomShipments, customShipment)
	util.PrecacheModel(customShipment.model)
end

function AddCustomVehicle(Name_of_vehicle, model, price, Jobs_that_can_buy_it)
	local function warn(add)
		local text
		if Name_of_vehicle then text = Name_of_vehicle end
		text = text.." FAILURE IN CUSTOM VEHICLE!"
		print(text)
		hook.Add("PlayerSpawn", "VehicleError", function(ply)
			if ply:IsAdmin() then ply:ChatPrint("WARNING: "..text.." "..add) end end)
	end
	if not Name_of_vehicle or not price or not model then
		warn("The name, model or the price is invalid/missing")
		return
	end
	local found = false
	for k,v in pairs(list.Get("Vehicles")) do
		if string.lower(k) == string.lower(Name_of_vehicle) then found = true break end
	end
	if not found and SERVER then
		warn("Vehicle not found!")
		return
	end
	table.insert(CustomVehicles, {name = Name_of_vehicle, model = model, price = price, allowed = Jobs_that_can_buy_it})
end

DarkRPEntities = {}
function AddEntity(name, entity, model, price, max, command, classes, CustomCheck)
	local tableSyntaxUsed = type(entity) == "table"

	if not name or not entity or not tableSyntaxUsed and (not price or not command) then
		hook.Add("PlayerSpawn", "ItemError", function(ply)
		if ply:IsAdmin() then ply:ChatPrint("WARNING: Item made incorrectly, failed to load!") end end)
		return
	end

	local tblEnt = tableSyntaxUsed and entity or
		{ent = entity, model = model, price = price, max = max,
		cmd = command, allowed = classes, customCheck = CustomCheck}
	tblEnt.name = name

	if type(tblEnt.allowed) == "number" then
		tblEnt.allowed = {tblEnt.allowed}
	end

	table.insert(DarkRPEntities, tblEnt)
end

DarkRPAgendas = {}

function AddAgenda(Title, Manager, Listeners)
	if not Manager then
		hook.Add("PlayerSpawn", "AgendaError", function(ply)
		if ply:IsAdmin() then ply:ChatPrint("WARNING: Agenda made incorrectly, there is no manager! failed to load!") end end)
		return
	end
	DarkRPAgendas[Manager] = {Title = Title, Listeners = Listeners}
end

GM.AmmoTypes = {}

function GM:AddAmmoType(ammoType, name, model, price, amountGiven, customCheck)
	table.insert(self.AmmoTypes, {
		ammoType = ammoType,
		name = name,
		model = model,
		price = price,
		amountGiven = amountGiven,
		customCheck = customCheck
	})
end

