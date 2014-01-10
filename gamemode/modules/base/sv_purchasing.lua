function DarkRP.hooks:canBuyPistol(ply, shipment)
	local price = shipment.getPrice and shipment.getPrice(ply, shipment.pricesep) or shipment.pricesep or 0

	if not GAMEMODE:CustomObjFitsMap(shipment) then
		return false, false, "Custom object does not fit map"
	end

	print(ply, "playerBoughtPistol")
	if ply:isArrested() then
		return false, false, DarkRP.getPhrase("unable", "/buy", "")
	end

	if shipment.customCheck and not shipment.customCheck(ply) then
		return false, false, shipment.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase")
	end

	if not ply:canAfford(price) then
		return false, false, DarkRP.getPhrase("cant_afford", "/buy")
	end

	if not GAMEMODE.Config.restrictbuypistol or
	(GAMEMODE.Config.restrictbuypistol and (not shipment.allowed[1] or table.HasValue(shipment.allowed, ply:Team()))) then
		return true
	end

	return false
end

local function BuyPistol(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not GAMEMODE.Config.enablebuypistol then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/buy", ""))
		return ""
	end

	if GAMEMODE.Config.noguns then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/buy", ""))
		return ""
	end

	local shipment
	for k, v in pairs(CustomShipments) do
		if not v.seperate or string.lower(v.name) ~= string.lower(args) then
			continue
		end

		shipment = v
		break
	end

	if not shipment then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "weapon"))
		return ""
	end

	local canbuy, suppress, message = hook.Call("canBuyPistol", DarkRP.hooks, ply, shipment)

	if not canbuy then
		message = message or DarkRP.getPhrase("incorrect_job", "/buy")
		if not suppress then DarkRP.notify(ply, 1, 4, message) end
		return ""
	end

	local price = shipment.getPrice and shipment.getPrice(ply, shipment.pricesep) or shipment.pricesep or 0

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(shipment.model)
	weapon.weaponclass = shipment.entity
	weapon.ShareGravgun = true
	weapon:SetPos(tr.HitPos)
	weapon.ammoadd = weapons.Get(shipment.entity) and weapons.Get(shipment.entity).Primary.DefaultClip
	weapon.nodupe = true
	weapon:Spawn()

	if shipment.onBought then
		shipment.onBought(ply, shipment, weapon)
	end
	hook.Call("playerBoughtPistol", nil, ply, shipment, weapon)

	if IsValid(weapon) then
		ply:addMoney(-price)
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", args, GAMEMODE.Config.currency, price))
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buy", args))
	end

	return ""
end
DarkRP.defineChatCommand("buy", BuyPistol, 0.2)

function DarkRP.hooks:canBuyShipment(ply, shipment)
	if not GAMEMODE:CustomObjFitsMap(shipment) then
		return false, false, "Custom object does not fit map"
	end

	if ply.LastShipmentSpawn and ply.LastShipmentSpawn > (CurTime() - GAMEMODE.Config.ShipmentSpamTime) then
		return false, false, DarkRP.getPhrase("shipment_antispam_wait")
	end

	if ply:isArrested() then
		return false, false, DarkRP.getPhrase("unable", "/buyshipment", "")
	end

	if shipment.customCheck and not shipment.customCheck(ply) then
		return false, false, shipment.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase")
	end

	local canbecome = false
	for a,b in pairs(shipment.allowed) do
		if ply:Team() == b then
			canbecome = true
			break
		end
	end

	if not canbecome then
		return false, false, DarkRP.getPhrase("incorrect_job", "/buyshipment")
	end

	local cost = shipment.getPrice and shipment.getPrice(ply, shipment.price) or shipment.price

	if not ply:canAfford(cost) then
		return false, false, DarkRP.getPhrase("cant_afford", "shipment")
	end

	return true
end

local function BuyShipment(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local found = false
	local foundKey
	for k,v in pairs(CustomShipments) do
		if string.lower(args) ~= string.lower(v.name) or v.noship or not GAMEMODE:CustomObjFitsMap(v) then
			continue
		end

		found = v
		foundKey = k
		break
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "shipment"))
		return ""
	end

	local canbuy, suppress, message = hook.Call("canBuyShipment", DarkRP.hooks, ply, found)

	if not canbuy then
		message = message or DarkRP.getPhrase("incorrect_job", "/buy")
		if not suppress then DarkRP.notify(ply, 1, 4, message) end
		return ""
	end

	local cost = found.getPrice and found.getPrice(ply, found.price) or found.price

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local crate = ents.Create(found.shipmentClass or "spawned_shipment")
	crate.SID = ply.SID
	crate:Setowning_ent(ply)
	crate:SetContents(foundKey, found.amount)

	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate.nodupe = true
	crate:Spawn()
	crate:SetPlayer(ply)
	if found.shipmodel then
		crate:SetModel(found.shipmodel)
		crate:PhysicsInit(SOLID_VPHYSICS)
		crate:SetMoveType(MOVETYPE_VPHYSICS)
		crate:SetSolid(SOLID_VPHYSICS)
	end

	local phys = crate:GetPhysicsObject()
	phys:Wake()
	if found.weight then
		phys:SetMass(found.weight)
	end

	if CustomShipments[foundKey].onBought then
		CustomShipments[foundKey].onBought(ply, CustomShipments[foundKey], crate)
	end
	hook.Call("playerBoughtShipment", nil, ply, CustomShipments[foundKey], crate)

	if IsValid(crate) then
		ply:addMoney(-cost)
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", args, GAMEMODE.Config.currency, cost))
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyshipment", arg))
	end

	ply.LastShipmentSpawn = CurTime()

	return ""
end
DarkRP.defineChatCommand("buyshipment", BuyShipment)

function DarkRP.hooks:canBuyVehicle(ply, vehicle)
	if not GAMEMODE:CustomObjFitsMap(vehicle) then
		return false, false, "Custom object does not fit map"
	end

	if ply:isArrested() then
		return false, false, DarkRP.getPhrase("unable", "/buyammo", "")
	end

	if vehicle.allowed and not table.HasValue(vehicle.allowed, ply:Team()) then
		return false, false, DarkRP.getPhrase("incorrect_job", "/buyvehicle")
	end

	if vehicle.customCheck and not vehicle.customCheck(ply) then
		return false, false, vehicle.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase")
	end

	ply.Vehicles = ply.Vehicles or 0
	if GAMEMODE.Config.maxvehicles and ply.Vehicles >= GAMEMODE.Config.maxvehicles then
		return false, false, DarkRP.getPhrase("limit", "vehicle")
	end

	local cost = vehicle.getPrice and vehicle.getPrice(ply, vehicle.price) or vehicle.price
	if not ply:canAfford(cost) then
		return false, false, DarkRP.getPhrase("cant_afford", "vehicle")
	end

	return true
end

local function BuyVehicle(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local found = false
	for k,v in pairs(CustomVehicles) do
		if string.lower(v.name) == string.lower(args) then found = CustomVehicles[k] break end
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "vehicle"))
		return ""
	end

	local Vehicle = DarkRP.getAvailableVehicles()[found.name]
	if not Vehicle then DarkRP.notify(ply, 1, 4, "Incorrect vehicle, fix your vehicles.") return "" end

	local canbuy, suppress, message = hook.Call("canBuyVehicle", DarkRP.hooks, ply, found)

	if not canbuy then
		message = message or DarkRP.getPhrase("incorrect_job", "/buy")
		if not suppress then DarkRP.notify(ply, 1, 4, message) end
		return ""
	end

	local cost = found.getPrice and found.getPrice(ply, found.price) or found.price

	ply:addMoney(-cost)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", found.name, GAMEMODE.Config.currency, cost))

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply
	local tr = util.TraceLine(trace)

	local ent = ents.Create(Vehicle.Class)
	if not ent then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyvehicle", ""))
		return ""
	end
	ent:SetModel(Vehicle.Model)
	if Vehicle.KeyValues then
		for k, v in pairs(Vehicle.KeyValues) do
			ent:SetKeyValue(k, v)
		end
	end

	local Angles = ply:GetAngles()
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180
	ent:SetAngles(Angles)
	ent:SetPos(tr.HitPos)
	ent.VehicleName = found.name
	ent.VehicleTable = Vehicle
	ent:Spawn()
	ent:Activate()
	ent.SID = ply.SID
	ent.ClassOverride = Vehicle.Class
	if Vehicle.Members then
		table.Merge(ent, Vehicle.Members)
	end
	ent:CPPISetOwner(ply)
	ent:keysOwn(ply)
	hook.Call("PlayerSpawnedVehicle", GAMEMODE, ply, ent) -- VUMod compatability
	hook.Call("playerBoughtCustomVehicle", nil, ply, found, ent)
	if found.onBought then
		found.onBought(ply, found, ent)
	end

	return ""
end
DarkRP.defineChatCommand("buyvehicle", BuyVehicle)

function DarkRP.hooks:canBuyAmmo(ply, ammo)
	if not GAMEMODE:CustomObjFitsMap(ammo) then
		return false, false, "Custom object does not fit map"
	end

	if ply:isArrested() then
		return false, false, DarkRP.getPhrase("unable", "/buyammo", "")
	end

	if ammo.allowed and not table.HasValue(ammo.allowed, ply:Team()) then
		return false, false, DarkRP.getPhrase("incorrect_job", "/buyammo")
	end

	if ammo.customCheck and not ammo.customCheck(ply) then
		return false, false, ammo.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase")
	end

	local cost = ammo.getPrice and ammo.getPrice(ply, ammo.price) or ammo.price
	if not ply:canAfford(cost) then
		return false, false, DarkRP.getPhrase("cant_afford", "ammo")
	end

	return true
end

local function BuyAmmo(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if GAMEMODE.Config.noguns then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "ammo", ""))
		return ""
	end

	local found
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		if v.ammoType == args then
			found = v
			break
		end
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "ammo"))
		return ""
	end

	local canbuy, suppress, message = hook.Call("canBuyAmmo", DarkRP.hooks, ply, found)

	if not canbuy then
		message = message or DarkRP.getPhrase("incorrect_job", "/buy")
		if not suppress then DarkRP.notify(ply, 1, 4, message) end
		return ""
	end

	local cost = found.getPrice and found.getPrice(ply, found.price) or found.price

	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", found.name, GAMEMODE.Config.currency, cost))
	ply:addMoney(-cost)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local ammo = ents.Create("spawned_ammo")
	ammo:SetModel(found.model)
	ammo.ShareGravgun = true
	ammo:SetPos(tr.HitPos)
	ammo.nodupe = true
	ammo.amountGiven, ammo.ammoType = found.amountGiven, found.ammoType
	ammo:Spawn()

	return ""
end
DarkRP.defineChatCommand("buyammo", BuyAmmo, 1)

local function SetPrice(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local a = tonumber(args)
	if not a then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local b = math.Clamp(math.floor(a), GAMEMODE.Config.pricemin, (GAMEMODE.Config.pricecap ~= 0 and GAMEMODE.Config.pricecap) or 500)
	local trace = {}

	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if not IsValid(tr.Entity) then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "gunlab / druglab / microwave")) return "" end

	local class = tr.Entity:GetClass()
	if IsValid(tr.Entity) and (class == "gunlab" or class == "microwave" or class == "drug_lab") and tr.Entity.SID == ply.SID then
		tr.Entity:Setprice(b)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "gunlab / druglab / microwave"))
	end
	return ""
end
DarkRP.defineChatCommand("price", SetPrice)
DarkRP.defineChatCommand("setprice", SetPrice)
