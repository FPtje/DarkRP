local HM = {}

function HM.PlayerSpawn(ply)
	ply:setSelfDarkRPVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HM.PlayerSpawn", HM.PlayerSpawn)

function HM.Think()
	if not GAMEMODE.Config.hungerspeed then return end

	for k, v in pairs(player.GetAll()) do
		if v:Alive() and (not v.LastHungerUpdate or CurTime() - v.LastHungerUpdate > 1) then
			v:HungerUpdate()
		end
	end
end
hook.Add("Think", "HM.Think", HM.Think)

function HM.PlayerInitialSpawn(ply)
	ply:NewHungerData()
end
hook.Add("PlayerInitialSpawn", "HM.PlayerInitialSpawn", HM.PlayerInitialSpawn)

for k, v in pairs(player.GetAll()) do
	v:NewHungerData()
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

	for k,v in pairs(FoodItems) do
		if string.lower(args) == k then
			local cost = GAMEMODE.Config.foodcost
			if ply:canAfford(cost) then
				ply:addMoney(-cost)
			else
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))
				return ""
			end
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", k, GAMEMODE.Config.currency, cost))
			local SpawnedFood = ents.Create("spawned_food")
			SpawnedFood:Setowning_ent(ply)
			SpawnedFood.ShareGravgun = true
			SpawnedFood:SetPos(tr.HitPos)
			SpawnedFood.onlyremover = true
			SpawnedFood.SID = ply.SID
			SpawnedFood:SetModel(v.model)
			SpawnedFood.FoodEnergy = v.amount
			SpawnedFood:Spawn()
			return ""
		end
	end
	DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
	return ""
end
DarkRP.defineChatCommand("buyfood", BuyFood)
