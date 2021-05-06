AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.SpawnOffset = Vector(0, 0, 23)

function ENT:canUse(activator)
    if activator.maxFoods and activator.maxFoods >= GAMEMODE.Config.maxfoods then
        DarkRP.notify(activator, 1, 3, DarkRP.getPhrase("limit", self.itemPhrase))
        return false
    end
    return true
end

function ENT:createItem(activator)
    local foodPos = self:GetPos() + self.SpawnOffset
    local food = ents.Create("food")
    food:SetPos(foodPos)
    food:Setowning_ent(activator)
    food.nodupe = true
    food:Spawn()
    if not activator.maxFoods then
        activator.maxFoods = 0
    end
    activator.maxFoods = activator.maxFoods + 1
end
