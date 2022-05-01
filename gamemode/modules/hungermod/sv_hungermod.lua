local function HMPlayerSpawn(ply)
    ply:setSelfDarkRPVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HMPlayerSpawn", HMPlayerSpawn)

local function HMThink()
    for _, v in ipairs(player.GetAll()) do
        if not v:Alive() then continue end
        v:hungerUpdate()
    end
end
timer.Create("HMThink", 10, 0, HMThink)

local function HMPlayerInitialSpawn(ply)
    ply:newHungerData()
end
hook.Add("PlayerInitialSpawn", "HMPlayerInitialSpawn", HMPlayerInitialSpawn)

local function HMAFKHook(ply, afk)
    if afk then
        ply.preAFKHunger = ply:getDarkRPVar("Energy")
    else
        ply:setSelfDarkRPVar("Energy", ply.preAFKHunger or 100)
        ply.preAFKHunger = nil
    end
end
hook.Add("playerSetAFK", "Hungermod", HMAFKHook)

local function BuyFood(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    for _, v in pairs(FoodItems) do
        if string.lower(args) ~= string.lower(v.name) then continue end

        if (v.requiresCook == nil or v.requiresCook == true) and not ply:isCook() then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyfood", DarkRP.getPhrase("cooks_only")))
            return ""
        end

        if v.customCheck and not v.customCheck(ply) then
            if v.customCheckMessage then
                DarkRP.notify(ply, 1, 4, v.customCheckMessage)
            end
            return ""
        end

        local foodTable = {
            cmd = "buyfood",
            max = GAMEMODE.Config.maxfooditems
        }

        if ply:customEntityLimitReached(foodTable) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", GAMEMODE.Config.chatCommandPrefix .. "buyfood"))

            return ""
        end

        ply:addCustomEntity(foodTable)

        local cost = v.price

        if not ply:canAfford(cost) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("food")))
            return ""
        end
        ply:addMoney(-cost)
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", v.name, DarkRP.formatMoney(cost), ""))

        local trace = {}
        trace.start = ply:EyePos()
        trace.endpos = trace.start + ply:GetAimVector() * 85
        trace.filter = ply

        local tr = util.TraceLine(trace)

        local SpawnedFood = ents.Create("spawned_food")
        SpawnedFood.DarkRPItem = foodTable
        SpawnedFood:Setowning_ent(ply)
        SpawnedFood:SetPos(tr.HitPos)
        SpawnedFood.onlyremover = true
        SpawnedFood.SID = ply.SID
        SpawnedFood:SetModel(v.model)

        -- for backwards compatibility
        SpawnedFood.FoodName = v.name
        SpawnedFood.FoodEnergy = v.energy
        SpawnedFood.FoodPrice = v.price

        SpawnedFood.foodItem = v
        SpawnedFood:Spawn()

        DarkRP.placeEntity(SpawnedFood, tr, ply)

        hook.Call("playerBoughtFood", nil, ply, v, SpawnedFood, cost)
        return ""
    end
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
    return ""
end
DarkRP.defineChatCommand("buyfood", BuyFood)
