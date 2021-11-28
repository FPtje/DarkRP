local plyMeta = FindMetaTable("Player")
local hits = {}
local questionCallback

--[[---------------------------------------------------------------------------
Net messages
---------------------------------------------------------------------------]]
util.AddNetworkString("onHitAccepted")
util.AddNetworkString("onHitCompleted")
util.AddNetworkString("onHitFailed")

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
DarkRP.getHits = fp{fn.Id, hits}

function plyMeta:requestHit(customer, target, price)
    local canRequest, msg, cost = hook.Call("canRequestHit", DarkRP.hooks, self, customer, target, price)
    price = cost or price

    if canRequest == false then
        DarkRP.notify(customer, 1, 4, msg)
        return false
    end

    DarkRP.createQuestion(DarkRP.getPhrase("accept_hit_request", customer:Nick(), target:Nick(), DarkRP.formatMoney(price)),
        "hit" .. self:UserID() .. "|" .. customer:UserID() .. "|" .. target:UserID(),
        self,
        20,
        questionCallback,
        customer,
        target,
        price
    )

    DarkRP.notify(customer, 1, 4, DarkRP.getPhrase("hit_requested"))

    return true
end

function plyMeta:placeHit(customer, target, price)
    if hits[self] then DarkRP.error("This person has an active hit!", 2) end

    if not customer:canAfford(price) then
        DarkRP.notify(customer, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("hit")))
        return
    end

    hits[self] = {}
    hits[self].price = price -- the agreed upon price (as opposed to the price set by the hitman)

    self:setHitCustomer(customer)
    self:setHitTarget(target)

    DarkRP.payPlayer(customer, self, price)

    hook.Call("onHitAccepted", DarkRP.hooks, self, target, customer)
end

function plyMeta:setHitTarget(target)
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end

    self:setSelfDarkRPVar("hitTarget", target)
    self:setDarkRPVar("hasHit", target and true or nil)
end

function plyMeta:setHitPrice(price)
    self:setDarkRPVar("hitPrice", math.Min(GAMEMODE.Config.maxHitPrice or 50000, math.Max(GAMEMODE.Config.minHitPrice or 200, price)))
end

function plyMeta:setHitCustomer(customer)
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end

    hits[self].customer = customer
end

function plyMeta:getHitCustomer()
    return hits[self] and hits[self].customer or nil
end

function plyMeta:abortHit(message)
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end

    message = message or ""

    hook.Call("onHitFailed", DarkRP.hooks, self, self:getHitTarget(), message)
    DarkRP.notifyAll(0, 4, DarkRP.getPhrase("hit_aborted", message))

    self:finishHit()
end

function plyMeta:cancelHit()
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end
    if not self:canAfford(hits[self].price) then
        DarkRP.notify(self, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("hit_cancel")))
        return
    end

    DarkRP.payPlayer(self, hits[self].customer, hits[self].price)

    self:abortHit(DarkRP.getPhrase("hit_cancelled"))
end

function plyMeta:finishHit()
    self:setHitCustomer(nil)
    self:setHitTarget(nil)
    hits[self] = nil
end

function questionCallback(answer, hitman, customer, target, price)
    if not IsValid(customer) then return end
    if not IsValid(hitman) or not hitman:isHitman() then return end

    if not IsValid(customer) then
        DarkRP.notify(hitman, 1, 4, DarkRP.getPhrase("customer_left_server"))
        return
    end

    if not IsValid(target) then
        DarkRP.notify(hitman, 1, 4, DarkRP.getPhrase("target_left_server"))
        return
    end

    if not tobool(answer) then
        DarkRP.notify(customer, 1, 4, DarkRP.getPhrase("hit_declined"))
        return
    end

    if hits[hitman] then return end

    DarkRP.notify(hitman, 1, 4, DarkRP.getPhrase("hit_accepted"))

    hitman:placeHit(customer, target, price)
end

--[[---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------]]
DarkRP.defineChatCommand("hitprice", function(ply, args)
    if not ply:isHitman() then return "" end
    local price = DarkRP.toInt(args) or 0
    ply:setHitPrice(price)
    price = ply:getHitPrice()

    DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("hit_price_set", DarkRP.formatMoney(price)))

    return ""
end)

DarkRP.defineChatCommand("requesthit", function(ply, args)
    args = string.Explode(' ', args)
    local target = DarkRP.findPlayer(args[1])
    local traceEnt = ply:GetEyeTrace().Entity
    local hitman = IsValid(traceEnt) and traceEnt:IsPlayer() and traceEnt or Player(tonumber(args[2] or -1) or -1)

    if not IsValid(hitman) or not IsValid(target) or not hitman:IsPlayer() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    hitman:requestHit(ply, target, hitman:getHitPrice())

    return ""
end)

DarkRP.defineChatCommand("cancelhit", function(ply, args)
    if not hits[ply] then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_active_hit"))
        return ""
    end

    ply:cancelHit()
end)

--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
function DarkRP.hooks:onHitAccepted(hitman, target, customer)
    net.Start("onHitAccepted")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteEntity(customer)
    net.Broadcast()

    DarkRP.notify(customer, 0, 8, DarkRP.getPhrase("hit_accepted"))
    customer.lastHitAccepted = CurTime()

    DarkRP.log("Hitman " .. hitman:Nick() .. " accepted a hit on " .. target:Nick() .. ", ordered by " .. customer:Nick() .. " for " .. DarkRP.formatMoney(hits[hitman].price), Color(255, 0, 255))
end

function DarkRP.hooks:onHitCompleted(hitman, target, customer)
    net.Start("onHitCompleted")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteEntity(customer)
    net.Broadcast()

    DarkRP.notifyAll(0, 6, DarkRP.getPhrase("hit_complete", hitman:Nick()))

    local targetname = IsValid(target) and target:Nick() or "disconnected player"
    local customername = IsValid(customer) and customer:Nick() or "disconnected player"

    DarkRP.log("Hitman " .. hitman:Nick() .. " finished a hit on " .. targetname .. ", ordered by " .. customername .. " for " .. DarkRP.formatMoney(hits[hitman].price), Color(255, 0, 255))

    target:setDarkRPVar("lastHitTime", CurTime())

    hitman:finishHit()
end

function DarkRP.hooks:onHitFailed(hitman, target, reason)
    net.Start("onHitFailed")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteString(reason)
    net.Broadcast()

    local targetname = IsValid(target) and target:Nick() or "disconnected player"

    DarkRP.log("Hit on " .. targetname .. " failed. Reason: " .. reason, Color(255, 0, 255))
end

hook.Add("PlayerDeath", "DarkRP Hitman System", function(ply, inflictor, attacker)
    if hits[ply] then -- player was hitman
        ply:abortHit(DarkRP.getPhrase("hitman_died"))
    end

    if IsValid(attacker) and attacker:IsPlayer() and hits[attacker] and attacker:getHitTarget() == ply then
        hook.Call("onHitCompleted", DarkRP.hooks, attacker, ply, hits[attacker].customer)
    end

    for hitman in pairs(hits) do
        if not hitman or not IsValid(hitman) then hits[hitman] = nil continue end
        if hitman:getHitTarget() == ply then
            hitman:abortHit(DarkRP.getPhrase("target_died"))
        end
    end
end)

hook.Add("PlayerDisconnected", "Hitman system", function(ply)
    if hits[ply] then
        ply:abortHit(DarkRP.getPhrase("hitman_left_server"))
    end

    for hitman, hit in pairs(hits) do
        if hitman:getHitTarget() == ply then
            hitman:abortHit(DarkRP.getPhrase("target_left_server"))
        end

        if hit.customer == ply then
            hitman:abortHit(DarkRP.getPhrase("customer_left_server"))
        end
    end
end)

hook.Add("playerArrested", "Hitman system", function(ply)
    if not hits[ply] or not IsValid(hits[ply].customer) then return end

    for _, v in ipairs(player.GetAll()) do
        if not v:isCP() then continue end

        DarkRP.notify(v, 0, 8, DarkRP.getPhrase("x_had_hit_ordered_by_y", ply:Nick(), hits[ply].customer:Nick()))
    end

    ply:abortHit(DarkRP.getPhrase("hitman_arrested"))
end)

hook.Add("OnPlayerChangedTeam", "Hitman system", function(ply, prev, new)
    if hits[ply] then
        ply:abortHit(DarkRP.getPhrase("hitman_changed_team"))
    end
end)
