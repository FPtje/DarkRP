AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function UnDrugPlayer(ply)
	if not IsValid(ply) then return end
	ply.isDrugged = false
	local IDSteam = ply:UniqueID()

	timer.Remove(IDSteam.."DruggedHealth")

	SendUserMessage("DrugEffects", ply, false)

	ply:SetJumpPower(190)
	hook.Call("UpdatePlayerSpeed", GAMEMODE, ply)

	hook.Remove("PlayerDeath", ply)
end

local function DrugPlayer(ply)
	if not IsValid(ply) then return end

	SendUserMessage("DrugEffects", ply, true)

	ply:SetJumpPower(300)
	ply.isDrugged = true
	hook.Call("UpdatePlayerSpeed", GAMEMODE, ply)

	local IDSteam = ply:UniqueID()
	if not timer.Exists(IDSteam.."DruggedHealth") then
		ply:SetHealth(ply:Health() + 100)
		local i = 0
		timer.Create(IDSteam.."DruggedHealth", 60/(100 + 5), 100 + 5, function()
			if not IsValid(ply) then return end
			ply:SetHealth(ply:Health() - 1)
			if ply:Health() <= 0 then ply:Kill() end
			i = i + 1
			if i == 105 then
				UnDrugPlayer(ply)
			end
		end)
	end

	hook.Add("PlayerDeath", ply, UnDrugPlayer)
end

function ENT:Initialize()
	self:SetModel("models/props_lab/jar01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.CanUse = true
	local phys = self:GetPhysicsObject()

	phys:Wake()

	self.damage = 10
	self:Setprice(self:Getprice() or 100)
	self.SeizeReward = GAMEMODE.Config.pricemin or 35
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()

	if (self.damage <= 0) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(2)
		effectdata:SetScale(2)
		effectdata:SetRadius(3)
		util.Effect("Sparks", effectdata)
		self:Remove()
	end
end

function ENT:Use(activator,caller)
	if not self.CanUse then return false end
	local Owner = self:Getowning_ent()
	if activator ~= Owner then
		if not activator:CanAfford(self:Getprice()) then
			return false
		end
		DB.PayPlayer(activator, Owner, self:Getprice())
		GAMEMODE:Notify(activator, 0, 4, "You have paid " .. GAMEMODE.Config.currency .. self:Getprice() .. " for using drugs.")
		GAMEMODE:Notify(Owner, 0, 4, "You have received " .. GAMEMODE.Config.currency .. self:Getprice() .. " for selling drugs.")
	end
	DrugPlayer(caller)
	self.CanUse = false
	self:Remove()
end

function ENT:OnRemove()
	local ply = self:Getowning_ent()
	if not IsValid(ply) then return end
	ply.maxDrugs = ply.maxDrugs - 1
end

hook.Add("UpdatePlayerSpeed", "DruggedPlayer", function(ply)
	if not ply.isDrugged then return end
	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed * 2, GAMEMODE.Config.runspeed * 2)

	return true -- Prevent the gamemode setting the runspeed
end)
