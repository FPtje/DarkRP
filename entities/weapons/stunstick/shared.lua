AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Stun Stick"
	SWEP.Slot = 0
	SWEP.SlotPos = 5

	killicon.AddAlias("stunstick", "weapon_stunstick")
end

DEFINE_BASECLASS("stick_base")

SWEP.Instructions = "Left click to discipline\nRight click to kill\nReload to threaten"

SWEP.Spawnable = true
SWEP.Category = "DarkRP (Utility)"

SWEP.StickColor = Color(0, 0, 255)

function SWEP:Initialize()
	BaseClass.Initialize(self)

	self.Hit = {
		Sound("weapons/stunstick/stunstick_impact1.wav"),
		Sound("weapons/stunstick/stunstick_impact2.wav")
	}

	self.FleshHit = {
		Sound("weapons/stunstick/stunstick_fleshhit1.wav"),
		Sound("weapons/stunstick/stunstick_fleshhit2.wav")
	}
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	-- Float 0 = LastPrimaryAttack
	-- Float 1 = ReloadEndTime
	-- Float 2 = BurstTime
	-- Float 3 = LastNonBurst
	-- Float 4 = SeqIdleTime
	-- Float 5 = HoldTypeChangeTime
	self:NetworkVar("Float", 6, "LastReload")
end

function SWEP:DoFlash(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	ply:ScreenFade(SCREENFADE.IN, color_white, 1.2, 0)
end

local entMeta = FindMetaTable("Entity")
function SWEP:DoAttack(dmg)
	if CLIENT then return end

	self:GetOwner():LagCompensation(true)
	local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
	self:GetOwner():LagCompensation(false)
	if IsValid(trace.Entity) and trace.Entity.onStunStickUsed then
		trace.Entity:onStunStickUsed(self:GetOwner())
		return
	elseif IsValid(trace.Entity) and trace.Entity:GetClass() == "func_breakable_surf" then
		trace.Entity:Fire("Shatter")
		self:GetOwner():EmitSound(self.Hit[math.random(1,#self.Hit)])
		return
	end

	local ent = self:GetOwner():getEyeSightHitEntity(100, 15, fn.FAnd{fp{fn.Neq, self:GetOwner()}, fc{IsValid, entMeta.GetPhysicsObject}})

	if not IsValid(ent) then return end

	if not ent:isDoor() then
		ent:SetVelocity((ent:GetPos() - self:GetOwner():GetPos()) * 7)
	end

	if dmg > 0 then
		ent:TakeDamage(dmg, self:GetOwner(), self)
	end

	if ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() then
		self:DoFlash(ent)
		self:GetOwner():EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
	else
		self:GetOwner():EmitSound(self.Hit[math.random(1,#self.Hit)])
		if FPP and FPP.plyCanTouchEnt(self:GetOwner(), ent, "EntityDamage") then
			if ent.SeizeReward and not ent.beenSeized and not ent.burningup and self:GetOwner():isCP() and ent.Getowning_ent and self:GetOwner() ~= ent:Getowning_ent() then
				self:GetOwner():addMoney(ent.SeizeReward)
				DarkRP.notify(self:GetOwner(), 1, 4, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(ent.SeizeReward), DarkRP.getPhrase("bonus_destroying_entity")))
				ent.beenSeized = true
			end
			ent:TakeDamage(1000-dmg, self:GetOwner(), self) -- for illegal entities
		end
	end
end

function SWEP:PrimaryAttack()
	BaseClass.PrimaryAttack(self)
	self:SetNextSecondaryFire(self:GetNextPrimaryFire())
	self:DoAttack(0)
end

function SWEP:SecondaryAttack()
	BaseClass.PrimaryAttack(self)
	self:SetNextSecondaryFire(self:GetNextPrimaryFire())
	self:DoAttack(10)
end

function SWEP:Reload()
	self:SetHoldType("melee")
	self:SetHoldTypeChangeTime(CurTime() + 1)

	if self:GetLastReload() + 0.1 > CurTime() then self:SetLastReload(CurTime()) return end
	self:SetLastReload(CurTime())
	self:EmitSound("weapons/stunstick/spark"..math.random(1,3)..".wav")
end
