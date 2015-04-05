local plyMeta = FindMetaTable("Player")
local hitmanTeams = {}

function plyMeta:isHitman()
	return hitmanTeams[self:Team()]
end

function plyMeta:hasHit()
	return self:getfprpVar("hasHit") or false
end

function plyMeta:getHitTarget()
	return self:getfprpVar("hitTarget")
end

function plyMeta:getHitPrice()
	return self:getfprpVar("hitPrice") or GAMEMODE.Config.minHitPrice
end

function fprp.addHitmanTeam(job)
	if not job or not RPExtraTeams[job] then return end
	if fprp.fprp_LOADING and fprp.disabledDefaults["hitmen"][RPExtraTeams[job].command] then return end

	hitmanTeams[job] = true
end

fprp.getHitmanTeams = fp{fn.Id, hitmanTeams}

function fprp.hooks:canRequestHit(hitman, customer, target, price)
	if not hitman:isHitman() then return false, fprp.getPhrase("player_not_hitman") end
	if customer:GetPos():Distance(hitman:GetPos()) > GAMEMODE.Config.minHitDistance then return false, fprp.getPhrase("distance_too_big") end
	if hitman == target then return false, fprp.getPhrase("hitman_no_suicide") end
	if hitman == customer then return false, fprp.getPhrase("hitman_no_self_order") end
	if not customer:canAfford(price) then return false, fprp.getPhrase("cant_afford", fprp.getPhrase("hit")) end
	if price < GAMEMODE.Config.minHitPrice then return false, fprp.getPhrase("price_too_low") end
	if hitman:hasHit() then return false, fprp.getPhrase("hitman_already_has_hit") end
	if IsValid(target) and ((target:getfprpVar("lastHitTime") or -GAMEMODE.Config.hitTargetCooldown) > CurTime() - GAMEMODE.Config.hitTargetCooldown) then return false, fprp.getPhrase("hit_target_recently_killed_by_hit") end
	if IsValid(customer) and ((customer.lastHitAccepted or -GAMEMODE.Config.hitCustomerCooldown) > CurTime() - GAMEMODE.Config.hitCustomerCooldown) then return false, fprp.getPhrase("customer_recently_bought_hit") end

	return true
end

hook.Add("onJobRemoved", "hitmenuUpdate", function(i, job)
	hitmanTeams[i] = nil
end)

/*---------------------------------------------------------------------------
fprpVars
---------------------------------------------------------------------------*/
fprp.registerfprpVar("hasHit", net.WriteBit, fn.Compose{tobool, net.ReadBit})
fprp.registerfprpVar("hitTarget", net.WriteEntity, net.ReadEntity)
fprp.registerfprpVar("hitPrice", fn.Curry(fn.Flip(net.WriteInt), 2)(32), fn.Partial(net.ReadInt, 32))
fprp.registerfprpVar("lastHitTime", fn.Curry(fn.Flip(net.WriteInt), 2)(32), fn.Partial(net.ReadInt, 32))

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
fprp.declareChatCommand{
	command = "hitprice",
	description = "Set the price of your hits",
	condition = plyMeta.isHitman,
	delay = 10
}

fprp.declareChatCommand{
	command = "requesthit",
	description = "Request a hit from the player you're looking at",
	delay = 5,
	condition = fn.Compose{fn.Not, fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isHitman), player.GetAll}
}
