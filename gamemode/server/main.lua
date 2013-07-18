CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) -- Don't save this one!
/*---------------------------------------------------------
 Flammable
 ---------------------------------------------------------*/
local FlammableProps = {drug = true,
drug_lab = true,
food = true,
gunlab = true,
letter = true,
microwave = true,
money_printer = true,
spawned_shipment = true,
spawned_weapon = true,
spawned_money = true}

local function IsFlammable(ent)
	return FlammableProps[ent:GetClass()] ~= nil
end

-- FireSpread from SeriousRP
local function FireSpread(e)
	if not e:IsOnFire() then return end

	if e:IsMoneyBag() then
		e:Remove()
	end

	local rand = math.random(0, 300)

	if rand > 1 then return end
	local en = ents.FindInSphere(e:GetPos(), math.random(20, 90))

	for k, v in pairs(en) do
		if not IsFlammable(v) then continue end

		if not v.burned then
			v:Ignite(math.random(5,180), 0)
			v.burned = true
		else
			local color = v:GetColor()
			if (color.r - 51) >= 0 then color.r = color.r - 51 end
			if (color.g - 51) >= 0 then color.g = color.g - 51 end
			if (color.b - 51) >= 0 then color.b = color.b - 51 end
			v:SetColor(color)
			if (color.r + color.g + color.b) < 103 and math.random(1, 100) < 35 then
				v:Fire("enablemotion","",0)
				constraint.RemoveAll(v)
			end
		end
		break -- Don't ignite all entities in sphere at once, just one at a time
	end
end

local function FlammablePropThink()
	for k, v in pairs(FlammableProps) do
		local ens = ents.FindByClass(k)

		for a, b in pairs(ens) do
			FireSpread(b)
		end
	end
end
timer.Create("FlammableProps", 0.1, 0, FlammablePropThink)

/*---------------------------------------------------------
 Shipments
 ---------------------------------------------------------*/

local function DropWeapon(ply)
	local ent = ply:GetActiveWeapon()
	if not IsValid(ent) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
		return ""
	end

	local canDrop = hook.Call("CanDropWeapon", GAMEMODE, ply, ent)
	if not canDrop then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
		return ""
	end

	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_dropitem", RP)
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) and IsValid(ent) and ent:GetModel() then
			ply:DropDRPWeapon(ent)
		end
	end)
	return ""
end
DarkRP.defineChatCommand("drop", DropWeapon)
DarkRP.defineChatCommand("dropweapon", DropWeapon)
DarkRP.defineChatCommand("weapondrop", DropWeapon)

/*---------------------------------------------------------
Spawning
 ---------------------------------------------------------*/
local function SetSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then
		DarkRP.notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "setspawn"))
		return ""
	end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("created_spawnpos", v.name))
		end
	end

	if t then
		DarkRP.storeTeamSpawnPos(t, pos)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "team: "..tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("setspawn", SetSpawnPos)

local function AddSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then
		DarkRP.notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "addspawn"))
		return ""
	end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("updated_spawnpos", v.name))
		end
	end

	if t then
		DarkRP.addTeamSpawnPos(t, pos)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "team: "..tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("addspawn", AddSpawnPos)

local function RemoveSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then
		DarkRP.notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "remove spawn"))
		return ""
	end

	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("updated_spawnpos", v.name))
		end
	end

	if t then
		DarkRP.removeTeamSpawnPos(t)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "team: "..tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("removespawn", RemoveSpawnPos)

function GM:ShowTeam(ply)
end

function GM:ShowHelp(ply)
end

local function LookPersonUp(ply, cmd, args)
	if not args[1] then
		ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "argument", ""))
		return
	end
	local P = DarkRP.findPlayer(args[1])
	if not IsValid(P) then
		if ply:EntIndex() ~= 0 then
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
	if ply:EntIndex() ~= 0 then
		ply:PrintMessage(2, "Nick: ".. P:Nick())
		ply:PrintMessage(2, "Steam name: "..P:SteamName())
		ply:PrintMessage(2, "Steam ID: "..P:SteamID())
		ply:PrintMessage(2, "Job: ".. team.GetName(P:Team()))
		ply:PrintMessage(2, "Kills: ".. P:Frags())
		ply:PrintMessage(2, "Deaths: ".. P:Deaths())
		if ply:IsAdmin() then
			ply:PrintMessage(2, "Money: ".. P:getDarkRPVar("money"))
		end
	else
		print(DarkRP.getPhrase("name", P:Nick()))
		print("Steam ".. DarkRP.getPhrase("name", P:SteamName()))
		print("Steam ID: "..P:SteamID())
		print(DarkRP.getPhrase("job", team.GetName(P:Team())))
		print(DarkRP.getPhrase("kills", P:Frags()))
		print(DarkRP.getPhrase("deaths", P:Death()))

		print(DarkRP.getPhrase("wallet", GAMEMODE.Config.currency, P:getDarkRPVar("money")))
	end
end
concommand.Add("rp_lookup", LookPersonUp)

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
local function MakeLetter(ply, args, type)
	if not GAMEMODE.Config.letters then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/write / /type", ""))
		return ""
	end

	if ply.maxletters and ply.maxletters >= GAMEMODE.Config.maxletters then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", "letter"))
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)), "/write / /type"))
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	ftext = string.gsub(ftext, "\\n", "\n") .. "\n\n" .. DarkRP.getPhrase("signed") .. "\n"..ply:Nick()
	local length = string.len(ftext)

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("letter")
	letter:SetModel("models/props_c17/paper01.mdl")
	letter:Setowning_ent(ply)
	letter.ShareGravgun = true
	letter:SetPos(trace.HitPos)
	letter.nodupe = true
	letter:Spawn()

	letter:GetTable().Letter = true
	letter.type = type
	letter.numPts = numParts

	local startpos = 1
	local endpos = 39
	letter.Parts = {}
	for k=1, numParts do
		table.insert(letter.Parts, string.sub(ftext, startpos, endpos))
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = ply.SID

	DarkRP.printMessageAll(2, DarkRP.getPhrase("created_x", ply:Nick(), "mail"))
	if not ply.maxletters then
		ply.maxletters = 0
	end
	ply.maxletters = ply.maxletters + 1
	timer.Simple(600, function() if IsValid(letter) then letter:Remove() end end)
end

local function WriteLetter(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	MakeLetter(ply, args, 1)
	return ""
end
DarkRP.defineChatCommand("write", WriteLetter)

local function TypeLetter(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	MakeLetter(ply, args, 2)
	return ""
end
DarkRP.defineChatCommand("type", TypeLetter)

local function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	DarkRP.notify(ply, 4, 4, DarkRP.getPhrase("cleaned_up", "mails"))
	return ""
end
DarkRP.defineChatCommand("removeletters", RemoveLetters)

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
		ply:AddMoney(-price)
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
		ply:AddMoney(-cost)
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

	ply:AddMoney(-found.price)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", found.name, GAMEMODE.Config.currency, found.price))

	local Vehicle = list.Get("Vehicles")[found.name]
	if not Vehicle then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "")) return "" end

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
	ent:CPPISetOwner(ply)
	ent:Spawn()
	ent:Activate()
	ent.SID = ply.SID
	ent.ClassOverride = Vehicle.Class
	if Vehicle.Members then
		table.Merge(ent, Vehicle.Members)
	end
	ent:Own(ply)
	hook.Call("PlayerSpawnedVehicle", GAMEMODE, ply, ent) -- VUMod compatability
	hook.Call("playerBoughtVehicle", nil, ply, found, ent)
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
	ply:AddMoney(-found.price)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local ammo = ents.Create("spawned_weapon")
	ammo:SetModel(found.model)
	ammo.ShareGravgun = true
	ammo:SetPos(tr.HitPos)
	ammo.nodupe = true
	function ammo:PlayerUse(user, ...)
		user:GiveAmmo(found.amountGiven, found.ammoType)
		self:Remove()
		return true
	end
	ammo:Spawn()

	return ""
end
DarkRP.defineChatCommand("buyammo", BuyAmmo, 1)

local function BuyHealth(ply)
	local cost = GAMEMODE.Config.healthcost
	if not tobool(GAMEMODE.Config.enablebuyhealth) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/buyhealth", ""))
		return ""
	end
	if not ply:Alive() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyhealth", ""))
		return ""
	end
	if not ply:canAfford(cost) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", "/buyhealth"))

		return ""
	end
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].medic then
		local foundMedics = false
		for k,v in pairs(RPExtraTeams) do
			if v.medic and team.NumPlayers(k) > 0 then
				foundMedics = true
				break
			end
		end
		if foundMedics then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyhealth", ""))
			return ""
		end
	end
	if ply.StartHealth and ply:Health() >= ply.StartHealth then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyhealth", ""))
		return ""
	end
	ply.StartHealth = ply.StartHealth or 100
	ply:AddMoney(-cost)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", "health", GAMEMODE.Config.currency, cost))
	ply:SetHealth(ply.StartHealth)
	return ""
end
DarkRP.defineChatCommand("buyhealth", BuyHealth)

/*---------------------------------------------------------
 Jobs
 ---------------------------------------------------------*/
local function CreateAgenda(ply, args)
	if DarkRPAgendas[ply:Team()] then
		ply:setDarkRPVar("agenda", args)

		DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("agenda_updated"))
		for k,v in pairs(DarkRPAgendas[ply:Team()].Listeners) do
			for a,b in pairs(team.GetPlayers(v)) do
				DarkRP.notify(b, 2, 4, DarkRP.getPhrase("agenda_updated"))
			end
		end
	else
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("unable", "agenda", "Incorrect team"))
	end
	return ""
end
DarkRP.defineChatCommand("agenda", CreateAgenda, 0.1)

local function ChangeJob(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if ply:isArrested() then
		DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("unable", "/job", ""))
		return ""
	end

	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), "/job"))
		return ""
	end
	ply.LastJob = CurTime()

	if not ply:Alive() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/job", ""))
		return ""
	end

	if not GAMEMODE.Config.customjobs then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/job", ""))
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/job", ">2"))
		return ""
	end

	if len > 25 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/job", "<26"))
		return ""
	end

	local canChangeJob, message, replace = hook.Call("canChangeJob", nil, ply, args)
	if canChangeJob == false then
		DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", "/job", ""))
		return ""
	end

	local job = replace or args
	DarkRP.notifyAll(2, 4, DarkRP.getPhrase("job_has_become", ply:Nick(), job))
	ply:UpdateJob(job)
	return ""
end
DarkRP.defineChatCommand("job", ChangeJob)

local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:TeamBan()
		if target:Alive() then
			target:ChangeTeam(GAMEMODE.DefaultTeam, true)
			if target:isArrested() then
				target:arrest()
			end
		else
			target.demotedWhileDead = true
		end

		DarkRP.notifyAll(0, 4, DarkRP.getPhrase("demoted", target:Nick()))
	else
		DarkRP.notifyAll(1, 4, DarkRP.getPhrase("demoted_not", target:Nick()))
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("vote_specify_reason"))
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 99 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demote", "<100"))
		return ""
	end
	local p = DarkRP.findPlayer(tableargs[1])
	if p == ply then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_demote_self"))
		return ""
	end

	local canDemote, message = hook.Call("CanDemote", GAMEMODE, ply, p, reason)
	if canDemote == false then
		DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", "demote", ""))
		return ""
	end

	if p then
		if CurTime() - ply.LastVoteCop < 80 then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"))
			return ""
		end
		if not RPExtraTeams[p:Team()] or RPExtraTeams[p:Team()].candemote == false then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demote", ""))
		else
			DarkRP.talkToPerson(p, team.GetColor(ply:Team()), DarkRP.getPhrase("demote") .. " " ..ply:Nick(),Color(255,0,0,255), DarkRP.getPhrase("i_want_to_demote_you", reason), p)
			DarkRP.notifyAll(0, 4, DarkRP.getPhrase("demote_vote_started", ply:Nick(), p:Nick()))
			DarkRP.log(DarkRP.getPhrase("demote_vote_started", ply:Nick(), p:Nick()) .. " (" .. reason .. ")",
				false, Color(255, 128, 255, 255))
			p.IsBeingDemoted = true

			GAMEMODE.vote:create(p:Nick() .. ":\n"..DarkRP.getPhrase("demote_vote_text", reason), "demote", p, 20, FinishDemote,
			{
				[p] = true,
				[ply] = true
			}, function(vote)
				if not IsValid(vote.target) then return end
				vote.target.IsBeingDemoted = nil
			end)
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
		return ""
	end
end
DarkRP.defineChatCommand("demote", Demote)

local function ExecSwitchJob(answer, ent, ply, target)
	ply.RequestedJobSwitch = nil
	if not tobool(answer) then return end
	local Pteam = ply:Team()
	local Tteam = target:Team()

	if not ply:ChangeTeam(Tteam) then return end
	if not target:ChangeTeam(Pteam) then
		ply:ChangeTeam(Pteam, true) -- revert job change
		return
	end
	DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("job_switch"))
	DarkRP.notify(target, 2, 4, DarkRP.getPhrase("job_switch"))
end

local function SwitchJob(ply) --Idea by Godness.
	if not GAMEMODE.Config.allowjobswitch then return "" end

	if ply.RequestedJobSwitch then return end

	local eyetrace = ply:GetEyeTrace()
	if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return "" end
	ply.RequestedJobSwitch = true
	GAMEMODE.ques:Create(DarkRP.getPhrase("job_switch_question", ply:Nick()), "switchjob"..tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("job_switch_reqested"))
	return ""
end
DarkRP.defineChatCommand("switchjob", SwitchJob)
DarkRP.defineChatCommand("switchjobs", SwitchJob)
DarkRP.defineChatCommand("jobswitch", SwitchJob)


local function DoTeamBan(ply, args, cmdargs)
	if not args or args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "arguments", ""))
		return ""
	end

	args = cmdargs or string.Explode(" ", args)
	local ent = args[1]
	local Team = args[2]
	if cmdargs and not cmdargs[1] then
		ply:PrintMessage(HUD_PRINTNOTIFY, DarkRP.getPhrase("rp_teamban_hint"))
		return
	end

	local target = DarkRP.findPlayer(ent)
	if not target or not IsValid(target) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player!"))
		return ""
	end

	if (not FAdmin or not FAdmin.Access.PlayerHasPrivilege(ply, "rp_commands", target)) and not ply:IsAdmin() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/teamban"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or string.lower(v.command) == string.lower(Team) or k == tonumber(Team or -1) then
			Team = k
			found = true
			break
		end
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "job!"))
		return ""
	end

	target:TeamBan(tonumber(Team), tonumber(args[3] or 0))
	DarkRP.notifyAll(0, 5, DarkRP.getPhrase("x_teambanned_y", ply:Nick(), target:Nick(), team.GetName(tonumber(Team))))
	return ""
end
DarkRP.defineChatCommand("teamban", DoTeamBan)
concommand.Add("rp_teamban", DoTeamBan)

local function DoTeamUnBan(ply, args, cmdargs)
	if not ply:IsAdmin() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/teamunban"))
		return ""
	end

	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, DarkRP.getPhrase("rp_teamunban_hint"))
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args, a + 1)
	end

	local target = DarkRP.findPlayer(ent)
	if not target or not IsValid(target) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player!"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or  string.lower(v.command) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == tonumber(Team or -1) then
			found = true
			break
		end
	end

	if not found then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "job!"))
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[tonumber(Team)] = nil
	DarkRP.notifyAll(1, 5, DarkRP.getPhrase("x_teamunbanned_y", ply:Nick(), target:Nick(), team.GetName(tonumber(Team))))
	return ""
end
DarkRP.defineChatCommand("teamunban", DoTeamUnBan)
concommand.Add("rp_teamunban", DoTeamUnBan)


/*---------------------------------------------------------
Talking
 ---------------------------------------------------------*/
local function PM(ply, args)
	local namepos = string.find(args, " ")
	if not namepos then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local name = string.sub(args, 1, namepos - 1)
	local msg = string.sub(args, namepos + 1)

	if msg == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	target = DarkRP.findPlayer(name)

	if target then
		local col = team.GetColor(ply:Team())
		DarkRP.talkToPerson(target, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply)
		DarkRP.talkToPerson(ply, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player: "..tostring(name)))
	end

	return ""
end
DarkRP.defineChatCommand("pm", PM, 1.5)

local function Whisper(ply, args)
	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
		DarkRP.talkToRange(ply, "(".. DarkRP.getPhrase("whisper") .. ") " .. ply:Nick(), text, 90)
	end
	return args, DoSay
end
DarkRP.defineChatCommand("w", Whisper, 1.5)

local function Yell(ply, args)
	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
		DarkRP.talkToRange(ply, "(".. DarkRP.getPhrase("yell") .. ") " .. ply:Nick(), text, 550)
	end
	return args, DoSay
end
DarkRP.defineChatCommand("y", Yell, 1.5)

local function Me(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
		if GAMEMODE.Config.alltalk then
			for _, target in pairs(player.GetAll()) do
				DarkRP.talkToPerson(target, team.GetColor(ply:Team()), ply:Nick() .. " " .. text)
			end
		else
			DarkRP.talkToRange(ply, ply:Nick() .. " " .. text, "", 250)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("me", Me, 1.5)

local function OOC(ply, args)
	if not GAMEMODE.Config.ooc then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", DarkRP.getPhrase("ooc"), ""))
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
		local col = team.GetColor(ply:Team())
		local col2 = Color(255,255,255,255)
		if not ply:Alive() then
			col2 = Color(255,200,200,255)
			col = col2
		end
		for k,v in pairs(player.GetAll()) do
			DarkRP.talkToPerson(v, col, DarkRP.getPhrase("ooc").." "..ply:Name(), col2, text, ply)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("/", OOC, true, 1.5)
DarkRP.defineChatCommand("a", OOC, true, 1.5)
DarkRP.defineChatCommand("ooc", OOC, true, 1.5)

local function PlayerAdvertise(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return
		end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team())
			DarkRP.talkToPerson(v, col, DarkRP.getPhrase("advert") .." "..ply:Nick(), Color(255,255,0,255), text, ply)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("advert", PlayerAdvertise, 1.5)

local function MayorBroadcast(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then DarkRP.notify(ply, 1, 4, "You have to be mayor") return "" end
	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return
		end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team())
			DarkRP.talkToPerson(v, col, DarkRP.getPhrase("broadcast") .. " " ..ply:Nick(), Color(170, 0, 0,255), text, ply)
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("broadcast", MayorBroadcast, 1.5)

local function SetRadioChannel(ply,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 100 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "0<channel<100"))
		return ""
	end
	DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("channel_set_to_x", args))
	ply.RadioChannel = tonumber(args)
	return ""
end
DarkRP.defineChatCommand("channel", SetRadioChannel)

local function SayThroughRadio(ply,args)
	if not ply.RadioChannel then ply.RadioChannel = 1 end
	if not args or args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return
		end
		for k,v in pairs(player.GetAll()) do
			if v.RadioChannel == ply.RadioChannel then
				DarkRP.talkToPerson(v, Color(180,180,180,255), DarkRP.getPhrase("radio_x", ply.RadioChannel), Color(180,180,180,255), text, ply)
			end
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("radio", SayThroughRadio, 1.5)

local function GroupMsg(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return
		end

		local t = ply:Team()
		local col = team.GetColor(ply:Team())

		local hasReceived = {}
		for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
			-- not the group of the player
			if not func(ply) then continue end

			for _, target in pairs(player.GetAll()) do
				if func(target) and not hasReceived[target] then
					hasReceived[target] = true
					DarkRP.talkToPerson(target, col, DarkRP.getPhrase("group") .. " " .. ply:Nick(), Color(255,255,255,255), text, ply)
				end
			end
		end
		if next(hasReceived) == nil then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/g", ""))
		end
	end
	return args, DoSay
end
DarkRP.defineChatCommand("g", GroupMsg, 1.5)

-- here's the new easter egg. Easier to find, more subtle, doesn't only credit FPtje and unib5
-- WARNING: DO NOT EDIT THIS
-- You can edit DarkRP but you HAVE to credit the original authors!
-- You even have to credit all the previous authors when you rename the gamemode.
local CreditsWait = true
local function GetDarkRPAuthors(ply, args)
	local target = DarkRP.findPlayer(args); -- Only send to one player. Prevents spamming
	if not IsValid(target) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("player_doesnt_exist"))
		return ""
	end

	if not CreditsWait then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("wait_with_that")) return "" end
	CreditsWait = false
	timer.Simple(60, function() CreditsWait = true end)--so people don't spam it

	local rf = RecipientFilter()
	rf:AddPlayer(target)
	if ply ~= target then
		rf:AddPlayer(ply)
	end

	umsg.Start("DarkRP_Credits", rf)
	umsg.End()

	return ""
end
DarkRP.defineChatCommand("credits", GetDarkRPAuthors, 50)

/*---------------------------------------------------------
 Money
 ---------------------------------------------------------*/
local function GiveMoney(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ">=1"))
			return
		end

		if not ply:canAfford(amount) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

			return ""
		end

		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start("anim_giveitem", RP)
			umsg.Entity(ply)
		umsg.End()
		ply.anim_GivingItem = true

		timer.Simple(1.2, function()
			if IsValid(ply) then
				local trace2 = ply:GetEyeTrace()
				if IsValid(trace2.Entity) and trace2.Entity:IsPlayer() and trace2.Entity:GetPos():Distance(ply:GetPos()) < 150 then
					if not ply:canAfford(amount) then
						DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

						return ""
					end
					DarkRP.payPlayer(ply, trace2.Entity, amount)

					DarkRP.notify(trace2.Entity, 0, 4, DarkRP.getPhrase("has_given", ply:Nick(), GAMEMODE.Config.currency .. tostring(amount)))
					DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_gave", trace2.Entity:Nick(), GAMEMODE.Config.currency .. tostring(amount)))
					DarkRP.log(ply:Nick().. " (" .. ply:SteamID() .. ") has given "..GAMEMODE.Config.currency .. tostring(amount).. " to "..trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")")
				end
			else
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/give", ""))
			end
		end)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "player"))
	end
	return ""
end
DarkRP.defineChatCommand("give", GiveMoney, 0.2)

local function DropMoney(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ">1"))
		return ""
	end

	if not ply:canAfford(amount) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

		return ""
	end

	ply:AddMoney(-amount)
	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_dropitem", RP)
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) then
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace)
			DarkRPCreateMoneyBag(tr.HitPos, amount)
			DarkRP.log(ply:Nick().. " (" .. ply:SteamID() .. ") has dropped "..GAMEMODE.Config.currency .. tostring(amount))
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/dropmoney", ""))
		end
	end)

	return ""
end
DarkRP.defineChatCommand("dropmoney", DropMoney, 0.3)
DarkRP.defineChatCommand("moneydrop", DropMoney, 0.3)

local function CreateCheque(ply, args)
	local argt = string.Explode(" ", args)
	local recipient = DarkRP.findPlayer(argt[1])
	local amount = tonumber(argt[2]) or 0

	if not recipient then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "recipient (1)"))
		return ""
	end

	if amount <= 1 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "amount (2)"))
		return ""
	end

	if not ply:canAfford(amount) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

		return ""
	end

	if IsValid(ply) and IsValid(recipient) then
		ply:AddMoney(-amount)
	end

	umsg.Start("anim_dropitem", RecipientFilter():AddAllPlayers())
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) and IsValid(recipient) then
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace)
			local Cheque = ents.Create("darkrp_cheque")
			Cheque:SetPos(tr.HitPos)
			Cheque:Setowning_ent(ply)
			Cheque:Setrecipient(recipient)

			Cheque:Setamount(amount)
			Cheque:Spawn()
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/cheque", ""))
		end
	end)
	return ""
end
DarkRP.defineChatCommand("cheque", CreateCheque, 0.3)
DarkRP.defineChatCommand("check", CreateCheque, 0.3) -- for those of you who can't spell


/*---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------*/
local LotteryPeople = {}
local LotteryON = false
local LotteryAmount = 0
local CanLottery = CurTime()
local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
	if tobool(answer) and not table.HasValue(LotteryPeople, target) then
		if not target:canAfford(LotteryAmount) then
			DarkRP.notify(target, 1,4, DarkRP.getPhrase("cant_afford", "lottery"))

			return
		end
		table.insert(LotteryPeople, target)
		target:AddMoney(-LotteryAmount)
		DarkRP.notify(target, 0,4, DarkRP.getPhrase("lottery_entered", GAMEMODE.Config.currency..tostring(LotteryAmount)))
	elseif answer ~= nil and not table.HasValue(LotteryPeople, target) then
		DarkRP.notify(target, 1,4, DarkRP.getPhrase("lottery_not_entered", "You"))
	end

	if TimeIsUp then
		LotteryON = false
		CanLottery = CurTime() + 60
		if table.Count(LotteryPeople) == 0 then
			DarkRP.notifyAll(1, 4, DarkRP.getPhrase("lottery_noone_entered"))
			return
		end
		local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
		chosen:AddMoney(#LotteryPeople * LotteryAmount)
		DarkRP.notifyAll(0,10, DarkRP.getPhrase("lottery_won", chosen:Nick(), GAMEMODE.Config.currency .. tostring(#LotteryPeople * LotteryAmount) ))
	end
end

local function DoLottery(ply, amount)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/lottery"))
		return ""
	end

	if not GAMEMODE.Config.lottery then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/lottery", ""))
		return ""
	end

	if #player.GetAll() <= 2 or LotteryON then
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("unable", "/lottery", ""))
		return ""
	end

	if CanLottery > CurTime() then
		DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("have_to_wait", tostring(CanLottery - CurTime()), "/lottery"))
		return ""
	end

	amount = tonumber(amount)
	if not amount then
		DarkRP.notify(ply, 1, 5, string.format("Please specify an entry cost ($%i-%i)", GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost))
		return ""
	end

	LotteryAmount = math.Clamp(math.floor(amount), GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost)

	LotteryON = true
	LotteryPeople = {}
	for k,v in pairs(player.GetAll()) do
		if v ~= ply then
			GAMEMODE.ques:Create(DarkRP.getPhrase("lottery_started", GAMEMODE.Config.currency, LotteryAmount), "lottery"..tostring(k), v, 30, EnterLottery, ply, v)
		end
	end
	timer.Create("Lottery", 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
	return ""
end
DarkRP.defineChatCommand("lottery", DoLottery, 1)

local lstat = false
local wait_lockdown = false

local function WaitLock()
	wait_lockdown = false
	lstat = false
	timer.Destroy("spamlock")
end

function GM:Lockdown(ply)
	if lstat then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/lockdown", ""))
		return ""
	end
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].mayor then
		for k,v in pairs(player.GetAll()) do
			v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
		end
		lstat = true
		DarkRP.printMessageAll(HUD_PRINTTALK , DarkRP.getPhrase("lockdown_started"))
		RunConsoleCommand("DarkRP_LockDown", 1)
		DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/lockdown", ""))
	end
	return ""
end
concommand.Add("rp_lockdown", function(ply) GAMEMODE:Lockdown(ply) end)
DarkRP.defineChatCommand("lockdown", function(ply) GAMEMODE:Lockdown(ply) end)

function GM:UnLockdown(ply)
	if not lstat or wait_lockdown then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/unlockdown", ""))
		return ""
	end
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].mayor then
		DarkRP.printMessageAll(HUD_PRINTTALK , DarkRP.getPhrase("lockdown_ended"))
		DarkRP.notifyAll(1, 3, DarkRP.getPhrase("lockdown_ended"))
		wait_lockdown = true
		RunConsoleCommand("DarkRP_LockDown", 0)
		timer.Create("spamlock", 20, 1, function() WaitLock("") end)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/unlockdown", ""))
	end
	return ""
end
concommand.Add("rp_unlockdown", function(ply) GAMEMODE:UnLockdown(ply) end)
DarkRP.defineChatCommand("unlockdown", function(ply) GAMEMODE:UnLockdown(ply) end)

local function MayorSetSalary(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print("Console should use rp_setsalary instead.")
		return
	end

	if not GAMEMODE.Config.enablemayorsetsalary then
		ply:PrintMessage(2, DarkRP.getPhrase("disabled", "rp_setsalary", ""))
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "rp_setsalary", ""))
		return
	end

	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		ply:PrintMessage(2, DarkRP.getPhrase("incorrect_job", "rp_setsalary"))
		return
	end

	if not args[2] then
		ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "argument", ""))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "salary", args[2]))
		return
	end

	if amount > GAMEMODE.Config.maxmayorsetsalary then
		ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "salary", "< " .. GAMEMODE.Config.maxmayorsetsalary))
		return
	end

	local plynick = ply:Nick()
	local target = DarkRP.findPlayer(args[1])

	if target then
		local targetteam = target:Team()
		local targetnick = target:Nick()

		if RPExtraTeams[targetteam] and RPExtraTeams[targetteam].mayor then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "rp_setsalary", ""))
			return
		elseif target:IsCP() then
			if amount > GAMEMODE.Config.maxcopsalary then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "salary", "< " .. GAMEMODE.Config.maxcopsalary))
				return
			else
				DarkRP.storeSalary(target, amount)
				ply:PrintMessage(2, DarkRP.getPhrase("you_set_x_salary_to_y", targetnick, GAMEMODE.Config.currency, amount))
				target:PrintMessage(2, DarkRP.getPhrase("x_set_your_salary_to_y", plynick, GAMEMODE.Config.currency, amount))
			end
		elseif RPExtraTeams[targetteam] and RPExtraTeams[targetteam].mayorCanSetSalary then
			if amount > GAMEMODE.Config.maxnormalsalary then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "salary", "< " .. GAMEMODE.Config.maxnormalsalary))
				return
			else
				DarkRP.storeSalary(target, amount)
				ply:PrintMessage(2, DarkRP.getPhrase("you_set_x_salary_to_y", targetnick, GAMEMODE.Config.currency, amount))
				target:PrintMessage(2, DarkRP.getPhrase("x_set_your_salary_to_y", plynick, GAMEMODE.Config.currency, amount))
			end
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "rp_setsalary", ""))
			return
		end
	else
		ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
	end
	return
end
concommand.Add("rp_mayor_setsalary", MayorSetSalary)

/*---------------------------------------------------------
 License
 ---------------------------------------------------------*/
local function GrantLicense(answer, Ent, Initiator, Target)
	Initiator.LicenseRequested = nil
	if tobool(answer) then
		DarkRP.notify(Initiator, 0, 4, DarkRP.getPhrase("gunlicense_granted", Target:Nick(), Initiator:Nick()))
		DarkRP.notify(Target, 0, 4, DarkRP.getPhrase("gunlicense_granted", Target:Nick(), Initiator:Nick()))
		Initiator:setDarkRPVar("HasGunlicense", true)
	else
		DarkRP.notify(Initiator, 1, 4, DarkRP.getPhrase("gunlicense_denied", Target:Nick(), Initiator:Nick()))
	end
end

local function RequestLicense(ply)
	if ply:getDarkRPVar("HasGunlicense") or ply.LicenseRequested then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/requestlicense", ""))
		return ""
	end
	local LookingAt = ply:GetEyeTrace().Entity

	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].mayor and not v:getDarkRPVar("AFK") then
			ismayor = true
			break
		end
	end

	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].chief and not v:getDarkRPVar("AFK") then
				ischief = true
				break
			end
		end
	end

	if not ischief and not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:IsCP() then
				iscop = true
				break
			end
		end
	end

	if not ismayor and not ischief and not iscop then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/requestlicense", ""))
		return ""
	end

	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "mayor/chief/cop"))
		return ""
	end

	if ismayor and (not RPExtraTeams[LookingAt:Team()] or not RPExtraTeams[LookingAt:Team()].mayor) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "mayor"))
		return ""
	elseif ischief and (not RPExtraTeams[LookingAt:Team()] or not RPExtraTeams[LookingAt:Team()].chief) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "chief"))
		return ""
	elseif iscop and not LookingAt:IsCP() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "cop"))
		return ""
	end

	ply.LicenseRequested = true
	DarkRP.notify(ply, 3, 4, DarkRP.getPhrase("gunlicense_requested", ply:Nick(), LookingAt:Nick()))
	GAMEMODE.ques:Create(DarkRP.getPhrase("gunlicense_question_text", ply:Nick()), "Gunlicense"..ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
	return ""
end
DarkRP.defineChatCommand("requestlicense", RequestLicense)

local function GiveLicense(ply)
	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].mayor and not v:getDarkRPVar("AFK") then
			ismayor = true
			break
		end
	end

	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].chief and not v:getDarkRPVar("AFK") then
				ischief = true
				break
			end
		end
	end

	if not ischief and not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:IsCP() then
				iscop = true
				break
			end
		end
	end

	if ismayor and (not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/givelicense"))
		return ""
	elseif ischief and (not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].chief) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/givelicense"))
		return ""
	elseif iscop and not ply:IsCP() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/givelicense"))
		return ""
	end

	local LookingAt = ply:GetEyeTrace().Entity
	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "player"))
		return ""
	end

	DarkRP.notify(LookingAt, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("gunlicense_granted", ply:Nick(), LookingAt:Nick()))
	LookingAt:setDarkRPVar("HasGunlicense", true)

	return ""
end
DarkRP.defineChatCommand("givelicense", GiveLicense)

local function rp_GiveLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_givelicense"))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		target:setDarkRPVar("HasGunlicense", true)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
			steamID = ply:SteamID()
		else
			nick = "Console"
			steamID = "Console"
		end

		DarkRP.notify(target, 1, 4, DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
		DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("gunlicense_granted", nick, target:Nick()))
		DarkRP.log(nick.." ("..steamID..") force-gave "..target:Nick().." a gun license", Color(30, 30, 30))
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_givelicense", rp_GiveLicense)

local function rp_RevokeLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_revokelicense"))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		target:setDarkRPVar("HasGunlicense", false)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
			steamID = ply:SteamID()
		else
			nick = "Console"
			steamID = "Console"
		end

		DarkRP.notify(target, 1, 4, DarkRP.getPhrase("gunlicense_denied", nick, target:Nick()))
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("gunlicense_denied", nick, target:Nick()))
		DarkRP.log(nick.." ("..steamID..") force-removed "..target:Nick().."'s gun license", Color(30, 30, 30))
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_revokelicense", rp_RevokeLicense)

local function FinishRevokeLicense(vote, win)
	if choice == 1 then
		vote.target:setDarkRPVar("HasGunlicense", false)
		vote.target:StripWeapons()
		GAMEMODE:PlayerLoadout(vote.target)
		DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_removed", vote.target:Nick()))
	else
		DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_not_removed", vote.target:Nick()))
	end
end

local function VoteRemoveLicense(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("vote_specify_reason"))
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 22 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demotelicense", "<23"))
		return ""
	end
	local p = DarkRP.findPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demotelicense"))
			return ""
		end
		if ply:getDarkRPVar("HasGunlicense") then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/demotelicense", ""))
		else
			DarkRP.notifyAll(0, 4, DarkRP.getPhrase("gunlicense_remove_vote_text", ply:Nick(), p:Nick()))
			GAMEMODE.vote:create(p:Nick() .. ":\n"..DarkRP.getPhrase("gunlicense_remove_vote_text2", reason), "removegunlicense", p, 20,  FinishRevokeLicense,
			{
				[p] = true,
				[ply] = true
			})
			ply:GetTable().LastVoteCop = CurTime()
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("vote_started"))
		end
		return ""
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
		return ""
	end
end
DarkRP.defineChatCommand("demotelicense", VoteRemoveLicense)
