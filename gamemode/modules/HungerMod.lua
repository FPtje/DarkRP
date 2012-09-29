GM:includeCS("HungerMod/cl_init.lua")

include("HungerMod/player.lua")

local HM = { }
local FoodItems = { }

GM:AddToggleCommand("rp_hungermod", "hungermod", 0)
GM:AddToggleCommand("rp_foodspawn", "foodspawn", 1)
GM:AddToggleCommand("rp_foodspecialcost", "foodpay", 1)
GM:AddValueCommand("rp_foodcost", "foodcost", 15)
GM:AddValueCommand("rp_hungerspeed", "hungerspeed", 2)
GM:AddValueCommand("rp_starverate", "starverate", 3)

concommand.Add("rp_hungerspeed", function(ply, cmd, args)
	if not ply:IsAdmin() then GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "rp_hungerspeed")) return end
	if not tonumber(args[1]) then GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "")) return end
	DB.SaveSetting("hungerspeed", tonumber(args[1]) / 10)
end)

local function AddFoodItem(name, mdl, amount)
	FoodItems[name] = { model = mdl, amount = amount }
end

function HM.PlayerSpawn(ply)
	ply:SetSelfDarkRPVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HM.PlayerSpawn", HM.PlayerSpawn)

function HM.Think()
	if GetConVarNumber("hungermod") ~= 1 then return end

	if GetConVarNumber("hungerspeed") == 0 then return end

	for k, v in pairs(player.GetAll()) do
		if v:Alive() and CurTime() - v:GetTable().LastHungerUpdate > 1 then
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

AddFoodItem("banana", "models/props/cs_italy/bananna.mdl", 10)
AddFoodItem("bananabunch", "models/props/cs_italy/bananna_bunch.mdl", 20)
AddFoodItem("melon", "models/props_junk/watermelon01.mdl", 20)
AddFoodItem("glassbottle", "models/props_junk/GlassBottle01a.mdl", 20)
AddFoodItem("popcan", "models/props_junk/PopCan01a.mdl", 5)
AddFoodItem("plasticbottle", "models/props_junk/garbage_plasticbottle003a.mdl", 15)
AddFoodItem("milk", "models/props_junk/garbage_milkcarton002a.mdl", 20)
AddFoodItem("bottle1", "models/props_junk/garbage_glassbottle001a.mdl", 10)
AddFoodItem("bottle2", "models/props_junk/garbage_glassbottle002a.mdl", 10)
AddFoodItem("bottle3", "models/props_junk/garbage_glassbottle003a.mdl", 10)
AddFoodItem("orange", "models/props/cs_italy/orange.mdl", 20)

local function BuyFood(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if GetConVarNumber("hungermod") == 0 and ply:Team() ~= TEAM_COOK then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "hungermod", ""))
		return ""
	end

	if ply:Team() ~= TEAM_COOK and team.NumPlayers(TEAM_COOK) > 0 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyfood", "cooks"))
		return ""
	end

	local food = FoodItems[string.lower(args)]
	if not food then return "" end
	local cost = GetConVarNumber("foodcost")
	if ply:CanAfford(cost) then
		ply:AddMoney(-cost)
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
		return ""
	end
	GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, string.lower(args), tostring(cost)))
	local SpawnedFood = ents.Create("spawned_food")
	SpawnedFood.dt.owning_ent = ply
	SpawnedFood.ShareGravgun = true
	SpawnedFood:SetPos(tr.HitPos)
	SpawnedFood.onlyremover = true
	SpawnedFood.SID = ply.SID
	SpawnedFood:SetModel(food.model)
	SpawnedFood.FoodEnergy = food.amount
	SpawnedFood:Spawn()
	return ""

end
AddChatCommand("/buyfood", BuyFood)