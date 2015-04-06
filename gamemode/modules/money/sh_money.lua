local pMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

function pMeta:canAfford(amount)
	if not amount or self.fprpUnInitialized then return false end
	return math.floor(amount) >= 0 and (self:getfprpVar("money") or 0) - math.floor(amount) >= 0
end

function entMeta:isMoneyBag()
	return self:GetClass() == "spawned_money" or self:GetClass() == GAMEMODE.Config.MoneyClass
end
