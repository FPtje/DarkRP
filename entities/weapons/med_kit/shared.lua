if (SERVER) then
	AddCSLuaFile("shared.lua")
end

SWEP.PrintName = "Medic Kit"
SWEP.Author = "Jake Johnson"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Description = "Heals the wounded."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left Click to heal player infront of user."

SWEP.Spawnable = false       -- Change to false to make Admin only.
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_package.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.3
SWEP.Secondary.Ammo = "none"

function SWEP:createViewModels()
	local viewmodel = self:GetOwner():GetViewModel()

	self.viewModels = {}
	self.viewModels[1] = self.viewModels[1] or ents.Create("prop_physics")
	self.viewModels[2] = self.viewModels[2] or ents.Create("prop_physics")

	self.viewModels[1]:SetAngles(viewmodel:GetAngles())
	self.viewModels[2]:SetAngles(viewmodel:GetAngles())

	local ang1 = viewmodel:GetAngles()
	local ang2 = viewmodel:GetAngles()
	ang1:RotateAroundAxis(ang1:Up(), 90)
	ang2:RotateAroundAxis(ang2:Right(), 90)

	self.viewModels[1]:SetAngles(ang1)
	self.viewModels[2]:SetAngles(ang2)

	viewmodel:SetNoDraw(true)

	self:CallOnRemove("RemoveViewModels", function(a,b)
		SafeRemoveEntity(self.viewModels[1])
		SafeRemoveEntity(self.viewModels[2])
	end)

	for k,v in pairs(self.viewModels) do

		v:SetModel("models/Mechanics/roboticslarge/a2.mdl")
		v:SetColor(255,0,0,255)
		v:SetMaterial("models/debug/debugwhite")

		v:SetModelScale(Vector(0.1,0.1,0.1))
		v:SetParent(viewmodel)
		v:SetPos(viewmodel:GetPos() + viewmodel:GetAngles():Forward() * 13 + viewmodel:GetAngles():Right() * 8 - viewmodel:GetAngles():Up() * 6)
		v:Spawn()
		v:Activate()

	end
end

function SWEP:Think()
	if SERVER then return end
	if not self.viewModels or not ValidEntity(self.viewModels[1]) then
		self:createViewModels()
	end

	self:GetOwner():GetViewModel():SetNoDraw(true)
	for k,v in pairs(self.viewModels) do
		v:SetNoDraw(false)
	end

	if LocalPlayer():KeyDown(IN_ATTACK) or LocalPlayer():KeyDown(IN_ATTACK2) then
		local angle = self.viewModels[1]:GetAngles()
		angle:RotateAroundAxis(angle:Up(), 1)
		self.viewModels[1]:SetAngles(angle)
	end
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawViewModel(false)
	end
end

function SWEP:Holster()
	if SERVER and ValidEntity(self:GetOwner()) then
		SendUserMessage("med_kit_model", self:GetOwner(), self)
		return true
	end
end

if CLIENT then
	usermessage.Hook("med_kit_model", function(um)
		local ent = um:ReadEntity()
		if ValidEntity(ent) then
			for k,v in pairs(ent.viewModels or {}) do
				SafeRemoveEntity(v)
			end
		end
	end)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 85)
	trace.filter = { self.Owner, self.Weapon }
	tr = util.TraceLine(trace)

	if (tr.HitNonWorld) and SERVER then
		local enthit = tr.Entity
		local maxhealth = enthit.StartHealth or 100
		if enthit:IsPlayer() and enthit:Health() < maxhealth then
			enthit:SetHealth(enthit:Health() + 1)
			self.Owner:EmitSound("hl1/fvox/boop.wav", 150, enthit:Health())
		end
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	local maxhealth = self.Owner.StartHealth or 100
	if self.Owner:Health() < maxhealth and SERVER then
		self.Owner:SetHealth(self.Owner:Health() + 1)
		self.Owner:EmitSound("hl1/fvox/boop.wav", 150, self.Owner:Health())
	end
end

function SWEP:OnRemove()
	if SERVER and ValidEntity(self:GetOwner()) then
		SendUserMessage("med_kit_model", self:GetOwner(), self)
	end
end
