local plyMeta = FindMetaTable("Player")
local hitmanTeams = {}

function plyMeta:isHitman()
	return hitmanTeams[self:Team()]
end

function plyMeta:hasHit()
	return IsValid(self:getHitTarget())
end

function plyMeta:getHitTarget()
	return self:getDarkRPVar("hitTarget")
end

function plyMeta:getHitPrice()
	return self:getDarkRPVar("hitPrice") or GAMEMODE.Config.minHitPrice
end

function DarkRP.addHitmanTeam(job)
	if not job or not RPExtraTeams[job] then
		error([[The server owner is trying to add a hitman job, but the job doesn't exist. Get them to fix this.
		Note: This is the fault of the owner/scripter of this server.]], 0)
	end
	hitmanTeams[job] = true
end

function DarkRP.hooks:canRequestHit(hitman, customer, target, price)
	if not hitman:isHitman() then return false, "This player is not a hitman!" end
	if customer:GetPos():Distance(hitman:GetPos()) > GAMEMODE.Config.minHitDistance then return false, "Distance too big" end
	if hitman == target then return false, "The hitman won't kill himself" end
	if hitman == customer then return false, "The hitman cannot order a hit for himself" end
	if not customer:CanAfford(price) then return false, "Cannot afford!" end
	if price < GAMEMODE.Config.minHitPrice then return false, "Price too low!" end
	if hitman:hasHit() then return false, "Hitman already has a hit ongoing" end
	if IsValid(target) and ((target:getDarkRPVar("lastHitTime") or 0) > CurTime() - GAMEMODE.Config.hitTargetCooldown) then return false, "The target was recently killed" end
	if IsValid(customer) and ((customer.lastHitAccepted or 0) > CurTime() - GAMEMODE.Config.hitCustomerCooldown) then return false, "The customer has recently requested a hit" end

	return true
end
