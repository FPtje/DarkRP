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
		GAMEMODE:Notify(customer, 1, 4, msg)
		return false
	end

	GAMEMODE.ques:Create("Accept hit from " .. customer:Nick() .. "\nregarding " .. target:Nick() .. " for " .. GAMEMODE.Config.currency .. price .. "?",
		"hit" .. self:UserID() .. "|" .. customer:UserID() .. "|" .. target:UserID(),
		self,
		20,
		questionCallback,
		customer,
		target,
		price
	)

	GAMEMODE:Notify(customer, 1, 4, "Hit requested!")

	return true
end

function plyMeta:placeHit(customer, target, price)
	if hits[self] then error("This person has an active hit!") end

	hits[self] = {}
	hits[self].price = price -- the agreed upon price (as opposed to the price set by the hitman)

	self:setHitCustomer(customer)
	self:setHitTarget(target)

	DB.PayPlayer(customer, self, price)

	hook.Call("onHitAccepted", DarkRP.hooks, self, target, customer)
end

function plyMeta:setHitTarget(target)
	if not hits[self] then error("This person has no active hit!") end

	self:SetDarkRPVar("hitTarget", target)
end

function plyMeta:setHitPrice(price)
	self:SetDarkRPVar("hitPrice", math.Max(GAMEMODE.Config.minHitPrice or 200, price))
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
	GAMEMODE:NotifyAll(0, 4, "Hit aborted! " .. message)

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
		GAMEMODE:Notify(hitman, 1, 4, "The customer has left the server!")
		return
	end

	if not IsValid(target) then
		GAMEMODE:Notify(hitman, 1, 4, "The target has left the server!")
		return
	end

	if not tobool(answer) then
		GAMEMODE:Notify(customer, 1, 4, "The hitman declined the hit!")
		return
	end

	if hits[self] then return end

	GAMEMODE:Notify(hitman, 1, 4, "Hit accepted!")

	hitman:placeHit(customer, target, price)
end

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
AddChatCommand("/hitprice", function(ply, args)
	local price = tonumber(args) or 0
	ply:setHitPrice(price)
	price = ply:getHitPrice()

	GAMEMODE:Notify(ply, 2, 4, "Hit price set to " .. GAMEMODE.Config.currency .. price)

	return ""
end)

AddChatCommand("/requesthit", function(ply, args)
	args = string.Explode(' ', args)
	local target = GAMEMODE:FindPlayer(args[1])
	local traceEnt = ply:GetEyeTrace().Entity
	local hitman = IsValid(traceEnt) and traceEnt:IsPlayer() and traceEnt or Player(tonumber(args[2] or -1) or -1)

	if not IsValid(hitman) or not IsValid(target) or not hitman:IsPlayer() then
		GAMEMODE:Notify(ply, 1, 4, "Invalid arguments!")
		return ""
	end

	hitman:requestHit(ply, target, hitman:getHitPrice())

	return ""
end, 20)

/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
function DarkRP.hooks:onHitAccepted(hitman, target, customer)
	net.Start("onHitAccepted")
		net.WriteEntity(hitman)
		net.WriteEntity(target)
		net.WriteEntity(customer)
	net.Broadcast()

	GAMEMODE:Notify(customer, 0, 8, "Hit Accepted!")
	customer.lastHitAccepted = CurTime()

	DB.Log("Hitman " .. hitman:Nick() .. " accepted a hit on " .. target:Nick() .. ", ordered by " .. customer:Nick() .. " for $" .. hits[hitman].price, false,
		Color(255, 0, 255))
end

function DarkRP.hooks:onHitCompleted(hitman, target, customer)
	net.Start("onHitCompleted")
		net.WriteEntity(hitman)
		net.WriteEntity(target)
		net.WriteEntity(customer)
	net.Broadcast()

	GAMEMODE:NotifyAll(0, 6, "Hit by " .. hitman:Nick() .. " completed!")

	local targetname = IsValid(target) and target:Nick() or "disconnected player"

	DB.Log("Hitman " .. hitman:Nick() .. " finished a hit on " .. targetname .. ", ordered by " .. hits[hitman].customer:Nick() .. " for $" .. hits[hitman].price,
		false, Color(255, 0, 255))

	target:SetDarkRPVar("lastHitTime", CurTime())

	hitman:finishHit()
end

function DarkRP.hooks:onHitFailed(hitman, target, reason)
	net.Start("onHitFailed")
		net.WriteEntity(hitman)
		net.WriteEntity(target)
		net.WriteString(reason)
	net.Broadcast()

	local targetname = IsValid(target) and target:Nick() or "disconnected player"

	DB.Log("Hit on " .. targetname .. " failed. Reason: " .. reason, false, Color(255, 0, 255))
end

hook.Add("PlayerDeath", "DarkRP Hitman System", function(ply, inflictor, attacker)
	if hits[ply] then -- player was hitman
		ply:abortHit("The hitman died!")
	end

	if IsValid(attacker) and attacker:IsPlayer() and attacker:getHitTarget() == ply then
		hook.Call("onHitCompleted", DarkRP.hooks, attacker, ply, hits[attacker].customer)
	end

	for hitman, hit in pairs(hits) do
		if hitman:getHitTarget() == ply then
			hitman:abortHit("The target has died!")
		end
	end
end)

hook.Add("PlayerDisconnected", "Hitman system", function(ply)
	if hits[ply] then
		ply:abortHit("Hitman disconnected!")
	end

	for hitman, hit in pairs(hits) do
		if hitman:getHitTarget() == ply then
			hitman:abortHit("Target disconnected!")
		end

		if hit.customer == ply then
			hitman:abortHit("Customer disconnected!")
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
		umsg.String(ply:Nick() .. " had an active hit ordered by " .. hits[ply].customer:Nick())
	umsg.End()

	ply:abortHit("The hitman was arrested!")
end)

hook.Add("OnPlayerChangedTeam", "Hitman system", function(ply, prev, new)
	if hits[ply] then
		ply:abortHit("Player changed team!")
	end
end)
