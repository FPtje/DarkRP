local plyMeta = FindMetaTable("Player")
local hitmanTeams = {}

function plyMeta:isHitman()
	return hitmanTeams[self:Team()]
end

function plyMeta:hasHit()
	return IsValid(self:getHitTarget())
end

function plyMeta:getHitTarget()
	return self.DarkRPVars.hitTarget
end

function plyMeta:getHitPrice()
	return self.DarkRPVars.hitPrice or GAMEMODE.Config.minHitPrice
end

function DarkRP.addHitmanTeam(job)
	hitmanTeams[job] = true
end

function DarkRP.hooks:canRequestHit(hitman, customer, target, price)
	if not hitman:isHitman() then return false, "This player is not a hitman!" end
	if customer:GetPos():Distance(hitman:GetPos()) > GAMEMODE.Config.minHitDistance then return false, "Distance too big" end
	if hitman == target then return false, "The hitman won't kill himself" end
	if not customer:CanAfford(price) then return false, "Cannot afford!" end
	if price < GAMEMODE.Config.minHitPrice then return false, "Price too low!" end
	if hitman:hasHit() then return false, "Hitman already has a hit ongoing" end

	return true
end
