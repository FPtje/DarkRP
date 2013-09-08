local function HMPlayerSpawn(ply)
	ply:setSelfDarkRPVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HMPlayerSpawn", HMPlayerSpawn)

local function HMThink()
	if not GAMEMODE.Config.hungerspeed then return end

	for k, v in pairs(player.GetAll()) do
		if v:Alive() and (not v.LastHungerUpdate or CurTime() - v.LastHungerUpdate > 1) then
			v:hungerUpdate()
		end
	end
end
hook.Add("Think", "HMThink", HMThink)

local function HMPlayerInitialSpawn(ply)
	ply:newHungerData()
end
hook.Add("PlayerInitialSpawn", "HMPlayerInitialSpawn", HMPlayerInitialSpawn)

for k, v in pairs(player.GetAll()) do
	v:newHungerData()
end

local function BuyFood(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].cook then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyfood", DarkRP.getPhrase("cooks_only")))
		return ""
	end

	for _,v in pairs(FoodItems) do
		if string.lower(args) == string.lower(v.name) then
			local cost = v.price
			if ply:canAfford(cost) then
				ply:addMoney(-cost)
			else
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", string.lower(DarkRP.getPhrase("food"))))
				return ""
			end
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", v.name, GAMEMODE.Config.currency, cost))
			local SpawnedFood = ents.Create("spawned_food")
			SpawnedFood:Setowning_ent(ply)
			SpawnedFood.ShareGravgun = true
			SpawnedFood:SetPos(tr.HitPos)
			SpawnedFood.onlyremover = true
			SpawnedFood.SID = ply.SID
			SpawnedFood:SetModel(v.model)
			SpawnedFood.FoodEnergy = v.energy
			SpawnedFood:Spawn()
			return ""
		end
	end
	DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
	return ""
end
DarkRP.defineChatCommand("buyfood", BuyFood)
