AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function DrugPlayer(ply)
	if not IsValid(ply) then return end
	local RP = RecipientFilter()
	RP:RemoveAllPlayers()
	RP:AddPlayer(ply)
	umsg.Start("DarkRPEffects", RP)
		umsg.String("Drugged")
		umsg.String("1")
	umsg.End()

	RP:AddAllPlayers()

	ply:SetJumpPower(300)
	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed * 2, GAMEMODE.Config.runspeed * 2)

	local IDSteam = ply:UniqueID()
	if not timer.Exists(IDSteam.."DruggedHealth") and not timer.Exists(IDSteam) then
		ply:SetHealth(ply:Health() + 100)
		timer.Create(IDSteam.."DruggedHealth", 60/(100 + 5), 100 + 5, function()
			if not IsValid(ply) then return end
			ply:SetHealth(ply:Health() - 1)
			if ply:Health() <= 0 then ply:Kill() end
		end)
		timer.Create(IDSteam, 60, 1, function() UnDrugPlayer(ply) end)
	end
end

function UnDrugPlayer(ply) -- Global function, used in sv_gamemode_functions
	if not IsValid(ply) then return end
	local RP = RecipientFilter()
	RP:RemoveAllPlayers()
	RP:AddPlayer(ply)
	local IDSteam = ply:UniqueID()
	timer.Remove(IDSteam.."DruggedHealth")
	timer.Remove(IDSteam)
	umsg.Start("DarkRPEffects", RP)
		umsg.String("Drugged")
		umsg.String("0")
	umsg.End()
	RP:AddAllPlayers()
	ply:SetJumpPower(190)
	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed )
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
	self.dt.price = self.dt.price or 100
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
	local Owner = self.dt.owning_ent
	if activator ~= Owner then
		if not activator:CanAfford(self.dt.price) then
			return false
		end
		DB.PayPlayer(activator, Owner, self.dt.price)
		GAMEMODE:Notify(activator, 0, 4, "You have paid " .. CUR .. self.dt.price .. " for using drugs.")
		GAMEMODE:Notify(Owner, 0, 4, "You have received " .. CUR .. self.dt.price .. " for selling drugs.")
	end
	DrugPlayer(caller)
	self.CanUse = false
	self:Remove()
end

function ENT:OnRemove()
	local ply = self.dt.owning_ent
	if not IsValid(ply) then return end
	ply.maxDrugs = ply.maxDrugs - 1
end