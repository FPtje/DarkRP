local function BuyPistol(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	if ply:isArrested() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buy", ""))
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

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local class = nil
	local model = nil

	local shipment
	local price = 0
	for k,v in pairs(CustomShipments) do
		if v.seperate and string.lower(v.name) == string.lower(args) and GAMEMODE:CustomObjFitsMap(v) then
			shipment = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false

			if not GAMEMODE.Config.restrictbuypistol or
			(GAMEMODE.Config.restrictbuypistol and (not v.allowed[1] or table.HasValue(v.allowed, ply:Team()))) then
				canbuy = true
			end

			if v.customCheck and not v.customCheck(ply) then
				DarkRP.notify(ply, 1, 4, v.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase"))
				return ""
			end

			if not canbuy then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/buy"))
				return ""
			end
		end
	end

	if not class then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "weapon"))
		return ""
	end

	if not ply:canAfford(price) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", "/buy"))
		return ""
	end

	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon:SetPos(tr.HitPos)
	weapon.ammoadd = weapons.Get(class) and weapons.Get(class).Primary.DefaultClip
	weapon.nodupe = true
	weapon:Spawn()

	if shipment.onBought then
		shipment.onBought(ply, shipment, weapon)
	end
	hook.Call("playerBoughtPistol", nil, ply, shipment, weapon)

	if IsValid( weapon ) then
		ply:addMoney(-price)
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", args, GAMEMODE.Config.currency, price))
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buy", args))
	end

	return ""
end
DarkRP.defineChatCommand("buy", BuyPistol, 0.2)

local function BuyShipment(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if ply.LastShipmentSpawn and ply.LastShipmentSpawn > (CurTime() - GAMEMODE.Config.ShipmentSpamTime) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("shipment_antispam_wait"))
		return ""
	end
	ply.LastShipmentSpawn = CurTime()

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if ply:isArrested() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyshipment", ""))
		return ""
	end

	local found = false
	local foundKey
	for k,v in pairs(CustomShipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship and GAMEMODE:CustomObjFitsMap(v) then
			found = v
			foundKey = k
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if ply:Team() == b then
					canbecome = true
				end
			end

			if v.customCheck and not v.customCheck(ply) then
				DarkRP.notify(ply, 1, 4, v.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase"))
				return ""
			end

			if not canbecome then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/buyshipment"))
				return ""
			end
		end
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", "shipment"))
		return ""
	end

	local cost = found.price

	if not ply:canAfford(cost) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", "shipment"))
		return ""
	end

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

	if CustomShipments[foundKey].onBought then
		CustomShipments[foundKey].onBought(ply, CustomShipments[foundKey], weapon)
	end
	hook.Call("playerBoughtShipment", nil, ply, CustomShipments[foundKey], weapon)

	if IsValid( crate ) then
		ply:addMoney(-cost)
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", args, GAMEMODE.Config.currency, cost))
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyshipment", arg))
	end

	return ""
end
DarkRP.defineChatCommand("buyshipment", BuyShipment)

local function BuyVehicle(ply, args)
	if ply:isArrested() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyvehicle", ""))
		return ""
	end
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
	if found.allowed and not table.HasValue(found.allowed, ply:Team()) then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/buyvehicle")) return "" end

	if found.customCheck and not found.customCheck(ply) then
		DarkRP.notify(ply, 1, 4, v.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase"))
		return ""
	end

	if not ply.Vehicles then ply.Vehicles = 0 end
	if GAMEMODE.Config.maxvehicles and ply.Vehicles >= GAMEMODE.Config.maxvehicles then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", "vehicle"))
		return ""
	end

	if not ply:canAfford(found.price) then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", "vehicle")) return "" end

	local Vehicle = DarkRP.getAvailableVehicles()[found.name]
	if not Vehicle then GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "")) return "" end

	ply:addMoney(-found.price)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", found.name, GAMEMODE.Config.currency, found.price))

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

local function BuyAmmo(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if ply:isArrested() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyammo", ""))
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

	if not found or (found.customCheck and not found.customCheck(ply)) then
		DarkRP.notify(ply, 1, 4, found and found.CustomCheckFailMsg or DarkRP.getPhrase("unavailable", "ammo"))
		return ""
	end

	if not ply:canAfford(found.price) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", "ammo"))

		return ""
	end

	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", found.name, GAMEMODE.Config.currency, found.price))
	ply:addMoney(-found.price)

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
