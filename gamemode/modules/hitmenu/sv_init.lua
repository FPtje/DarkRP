local plyMeta = FindMetaTable("Player")
local hits = {}
local questionCallback

/*---------------------------------------------------------------------------
Net messages
---------------------------------------------------------------------------*/
util.AddNetworkString("onHitAccepted")
util.AddNetworkString("onHitCompleted")
util.AddNetworkString("onHitFailed")

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function plyMeta:requestHit(customer, target, price)
	local canRequest, msg = hook.Call("canRequestHit", DarkRP.hooks, self, customer, target, price)

	if canRequest == false then
		DarkRP.notify(customer, 1, 4, msg)
		return false
	end

	DarkRP.createQuestion(DarkRP.getPhrase("accept_hit_question", customer:Nick(), target:Nick(), GAMEMODE.Config.currency, price),
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
	if hits[self] then error("This person has an active hit!") end

	hits[self] = {}
	hits[self].price = price -- the agreed upon price (as opposed to the price set by the hitman)

	self:setHitCustomer(customer)
	self:setHitTarget(target)

	DarkRP.payPlayer(customer, self, price)

	hook.Call("onHitAccepted", DarkRP.hooks, self, target, customer)
end

function plyMeta:setHitTarget(target)
	if not hits[self] then error("This person has no active hit!") end

	self:setDarkRPVar("hitTarget", target)
end

function plyMeta:setHitPrice(price)
	self:setDarkRPVar("hitPrice", math.Max(GAMEMODE.Config.minHitPrice or 200, price))
end

function plyMeta:setHitCustomer(customer)
	if not hits[self] then error("This person has no active hit!") end

	hits[self].customer = customer
end

function plyMeta:getHitCustomer()
	return hits[self] and hits[self].customer or nil
end

function plyMeta:abortHit(message)
	if not hits[self] then error("This person has no active hit!") end

	msg = msg or ""

	hook.Call("onHitFailed", DarkRP.hooks, self, self:getHitTarget(), message)
	DarkRP.notifyAll(0, 4, DarkRP.getPhrase("hit_aborted", message))

	self:finishHit()
end

function plyMeta:finishHit()
	self:setHitCustomer(nil)
	self:setHitTarget(nil)
	hits[self] = nil
end

function questionCallback(answer, hitman, customer, target, price)
	if not IsValid(customer) then return end

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

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
DarkRP.defineChatCommand("hitprice", function(ply, args)
	if not ply:isHitman() then return "" end
	local price = tonumber(args) or 0
	ply:setHitPrice(price)
	price = ply:getHitPrice()

	DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("hit_price_set_to_x", GAMEMODE.Config.currency, price))

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

/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
function DarkRP.hooks:onHitAccepted(hitman, target, customer)
	net.Start("onHitAccepted")
		net.WriteEntity(hitman)
		net.WriteEntity(target)
		net.WriteEntity(customer)
	net.Broadcast()

	DarkRP.notify(customer, 0, 8, DarkRP.getPhrase("hit_accepted"))
	customer.lastHitAccepted = CurTime()

	DarkRP.log("Hitman " .. hitman:Nick() .. " accepted a hit on " .. target:Nick() .. ", ordered by " .. customer:Nick() .. " for $" .. hits[hitman].price, false, Color(255, 0, 255))
end

function DarkRP.hooks:onHitCompleted(hitman, target, customer)
	net.Start("onHitCompleted")
		net.WriteEntity(hitman)
		net.WriteEntity(target)
		net.WriteEntity(customer)
	net.Broadcast()

	DarkRP.notifyAll(0, 6, DarkRP.getPhrase("hit_complete", hitman:Nick()))

	local targetname = IsValid(target) and target:Nick() or "disconnected player"

	DarkRP.log("Hitman " .. hitman:Nick() .. " finished a hit on " .. targetname .. ", ordered by " .. hits[hitman].customer:Nick() .. " for $" .. hits[hitman].price,
		false, Color(255, 0, 255))

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

	DarkRP.log("Hit on " .. targetname .. " failed. Reason: " .. reason, false, Color(255, 0, 255))
end

hook.Add("PlayerDeath", "DarkRP Hitman System", function(ply, inflictor, attacker)
	if hits[ply] then -- player was hitman
		ply:abortHit(DarkRP.getPhrase("hitman_died"))
	end

	if IsValid(attacker) and attacker:IsPlayer() and attacker:getHitTarget() == ply then
		hook.Call("onHitCompleted", DarkRP.hooks, attacker, ply, hits[attacker].customer)
	end

	for hitman, hit in pairs(hits) do
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

	local filter = RecipientFilter()
	filter:RemoveAllPlayers()

	for k, v in pairs(player.GetAll()) do
		if GAMEMODE.CivilProtection[v:Team()] then
			filter:AddPlayer(v)
		end
	end

	umsg.Start("AdminTell", filter)
		umsg.String(DarkRP.getPhrase("x_had_hit_ordered_by_y", ply:Nick(), hits[ply].customer:Nick()))
	umsg.End()

	ply:abortHit(DarkRP.getPhrase("hitman_arrested"))
end)

hook.Add("OnPlayerChangedTeam", "Hitman system", function(ply, prev, new)
	if hits[ply] then
		ply:abortHit(DarkRP.getPhrase("hitman_changed_team"))
	end
end)
