local plyMeta = FindMetaTable("Player")
local hitmanTeams = {}
local minHitDistanceSqr = GM.Config.minHitDistance * GM.Config.minHitDistance

function plyMeta:isHitman()
    return hitmanTeams[self:Team()]
end

function plyMeta:hasHit()
    return self:getDarkRPVar("hasHit") or false
end

function plyMeta:getHitTarget()
    return self:getDarkRPVar("hitTarget")
end

function plyMeta:getHitPrice()
    return self:getDarkRPVar("hitPrice") or GAMEMODE.Config.minHitPrice
end

function DarkRP.addHitmanTeam(job)
    if not job or not RPExtraTeams[job] then return end
    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["hitmen"][RPExtraTeams[job].command] then return end

    hitmanTeams[job] = true
end

DarkRP.getHitmanTeams = fp{fn.Id, hitmanTeams}

function DarkRP.hooks:canRequestHit(hitman, customer, target, price)
    if not hitman:isHitman() then return false, DarkRP.getPhrase("player_not_hitman") end
    if customer:GetPos():DistToSqr(hitman:GetPos()) > minHitDistanceSqr then return false, DarkRP.getPhrase("distance_too_big") end
    if not customer:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("place_a_hit")) end
    if hitman == target then return false, DarkRP.getPhrase("hitman_no_suicide") end
    if hitman == customer then return false, DarkRP.getPhrase("hitman_no_self_order") end
    if not customer:canAfford(price) then return false, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("hit")) end
    if price < GAMEMODE.Config.minHitPrice then return false, DarkRP.getPhrase("price_too_low") end
    if hitman:hasHit() then return false, DarkRP.getPhrase("hitman_already_has_hit") end
    if IsValid(target) and ((target:getDarkRPVar("lastHitTime") or -GAMEMODE.Config.hitTargetCooldown) > CurTime() - GAMEMODE.Config.hitTargetCooldown) then return false, DarkRP.getPhrase("hit_target_recently_killed_by_hit") end
    if IsValid(customer) and ((customer.lastHitAccepted or -GAMEMODE.Config.hitCustomerCooldown) > CurTime() - GAMEMODE.Config.hitCustomerCooldown) then return false, DarkRP.getPhrase("customer_recently_bought_hit") end

    return true
end

hook.Add("onJobRemoved", "hitmenuUpdate", function(i, job)
    hitmanTeams[i] = nil
end)

--[[---------------------------------------------------------------------------
DarkRPVars
---------------------------------------------------------------------------]]
DarkRP.registerDarkRPVar("hasHit", net.WriteBit, fn.Compose{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("hitTarget", net.WriteEntity, net.ReadEntity)
DarkRP.registerDarkRPVar("hitPrice", fn.Curry(fn.Flip(net.WriteInt), 2)(32), fn.Partial(net.ReadInt, 32))
DarkRP.registerDarkRPVar("lastHitTime", fn.Curry(fn.Flip(net.WriteInt), 2)(32), fn.Partial(net.ReadInt, 32))

--[[---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------]]
DarkRP.declareChatCommand{
    command = "hitprice",
    description = "Set the price of your hits",
    condition = plyMeta.isHitman,
    delay = 10
}

DarkRP.declareChatCommand{
    command = "requesthit",
    description = "Request a hit from the player you're looking at",
    delay = 5,
    condition = fn.Compose{fn.Not, fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isHitman), player.GetAll}
}

DarkRP.declareChatCommand{
    command = "cancelhit",
    description = "Cancel your on active hit",
    delay = 5,
    condition = plyMeta.hasHit
}
