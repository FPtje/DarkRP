AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("lab_base")

ENT.SeizeReward = 350
ENT.SpawnOffset = Vector(0, 0, 35)

function ENT:Initialize()
    BaseClass.Initialize(self)
    self.SID = self:Getowning_ent().SID
end

function ENT:SalePrice(activator)
    return math.random(math.Round(self:Getprice() / 8), math.Round(self:Getprice() / 4))
end

function ENT:canUse(activator)
    if activator.maxDrugs and activator.maxDrugs >= GAMEMODE.Config.maxdrugs then
        DarkRP.notify(activator, 1, 3, DarkRP.getPhrase("limit", self.itemPhrase))
        return false
    end
    return true
end

function ENT:createItem(activator)
    local drugPos = self:GetPos() + self.SpawnOffset
    local drug = ents.Create("drug")
    drug:SetPos(drugPos)
    drug:Setowning_ent(activator)
    drug.SID = activator.SID
    drug.nodupe = true
    drug:Setprice(self:Getprice() or self.initialPrice)
    drug:Spawn()
    if not activator.maxDrugs then
        activator.maxDrugs = 0
    end
    activator.maxDrugs = activator.maxDrugs + 1
end
