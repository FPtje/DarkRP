if CLIENT then
	SWEP.PrintName = "Blowtorch, best weapon imo - grimes"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "NotSoSuper"
SWEP.Instructions = "Left Click: Hold to torch props!"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = true

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel			= "models/weapons/v_smg_ump45.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_ump45.mdl"

SWEP.ShootSound = Sound("ambient/energy/spark1.wav");

SWEP.TorchDistance = 90;
SWEP.TorchAmount = 80;
SWEP.TorchTimeout = 180;

local TorchableEnts = {"prop_physics"};

function SWEP:TorchEntity(ent)
	ent.TorchAmount = nil;
	ent.SavedColor = ent:GetColor();
	ent.SavedSolid = ent:GetSolid();
	
	ent:SetRenderMode(1)
	ent:SetColor(Color(255,255,255,100));
	ent:SetSolid(SOLID_NONE);
	
	local vPoint = ent:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata, true, true)
	ent:GetPhysicsObject():EnableMotion(false);
	timer.Simple(self.TorchTimeout, function()
		if IsValid(ent) then
			ent:SetColor(ent.SavedColor);
			ent:SetSolid(ent.SavedSolid);
		end
	end);
end

function SWEP:Initialize()
	self:SetWeaponHoldType("pistol")
end

function SWEP:Deploy()
	self:SetWeaponHoldType("pistol")
end

function SWEP:CanPrimaryAttack ( ) return true; end

function SWEP:PrimaryAttack()	
	if self:GetTable().LastNoise == nil then self:GetTable().LastNoise = true; end
	if self:GetTable().LastNoise then
		self.Weapon:EmitSound(self.ShootSound, 60)
		self:GetTable().LastNoise = false;
	else
		self:GetTable().LastNoise = true;
	end
	local Trace = self.Owner:GetEyeTrace();
	
	if Trace.HitPos:Distance(self.Owner:GetPos()) > self.TorchDistance || !IsValid(Trace.Entity) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 1)
		if SERVER then Notify(self.Owner, 1, 4, "Must use on a entity!"); end
		return false;
	end
	
	
	if !table.HasValue(TorchableEnts, Trace.Entity:GetClass()) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 1)
		if SERVER then Notify(self.Owner, 1, 4, "Can't use on this entity!"); end
		return false;
	end
	local effectdata = EffectData()
	effectdata:SetOrigin(Trace.HitPos)
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	if !SERVER then return end
	local ent = Trace.Entity;
	if !ent.TorchAmount then ent.TorchAmount = 0; end
	ent.TorchAmount = ent.TorchAmount + 1;
	
	timer.Create(tostring(ent:EntIndex()) .. "_torch_reset", 1, 1, function()
		if IsValid(ent) then
			ent.TorchAmount = nil;
		end
	end)
	
	if ent.TorchAmount >= self.TorchAmount then
		self:TorchEntity(ent);
		timer.Remove(tostring(ent:EntIndex()) .. "_torch_reset")
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack();
end
