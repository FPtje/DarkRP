local function HMPlayerSpawn(ply)
	ply:setSelffprpVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HMPlayerSpawn", HMPlayerSpawn)

local function HMThink()
	if not GAMEMODE.Config.hungerspeed then return end

	for k, v in pairs(player.GetAll()) do
		if v:Alive() and (not v.LastHungerUpdate or CurTime() - v.LastHungerUpdate > 10) then
			v:hungerUpdate()
		end
	end
end
hook.Add("Think", "HMThink", HMThink)

local function HMPlayerInitialSpawn(ply)
	ply:newHungerData()
end
hook.Add("PlayerInitialSpawn", "HMPlayerInitialSpawn", HMPlayerInitialSpawn)

timer.Simple(0, function()
	for k, v in pairs(player.GetAll()) do
		if v:getfprpVar("Energy") ~= nil then continue end
		v:newHungerData()
	end
end)

local function BuyFood(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	for _,v in pairs(FoodItems) do
		if string.lower(args) ~= string.lower(v.name) then continue end

		if (v.requiresCook == nil or v.requiresCook == true) and not ply:isCook() then
			fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/buyfood", fprp.getPhrase("cooks_only")))
			return ""
		end

		if v.customCheck and not v.customCheck(ply) then
			if v.customCheckMessage then
				fprp.notify(ply, 1, 4, v.customCheckMessage)
			end
			return ""
		end

		local cost = v.price

		if not ply:canAfford(cost) then
			fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", string.lower(fprp.getPhrase("food"))))
			return ""
		end
		ply:addshekel(-cost)
		fprp.notify(ply, 0, 4, fprp.getPhrase("you_bought", v.name, fprp.formatshekel(cost), ""))

		local SpawnedFood = ents.Create("spawned_food")
		SpawnedFood:Setowning_ent(ply)
		SpawnedFood.ShareGravgun = true
		SpawnedFood:SetPos(tr.HitPos)
		SpawnedFood.onlyremover = true
		SpawnedFood.SID = ply.SID
		SpawnedFood:SetModel(v.model)
		SpawnedFood.FoodName = v.name
		SpawnedFood.FoodEnergy = v.energy
		SpawnedFood.FoodPrice = v.price
		SpawnedFood:Spawn()
		return ""
	end
	fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""))
	return ""
end
fprp.defineChatCommand("buyfood", BuyFood)
