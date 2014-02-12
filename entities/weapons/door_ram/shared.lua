if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Battering Ram"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server
SWEP.Base = "weapon_cs_base2"

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to break open doors/unfreeze props or get people out of their vehicles\nRight click to raise"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")
SWEP.AnimPrefix = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = 0     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false     -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self.LastIron = CurTime()
	self:SetWeaponHoldType("normal")
	self.Ready = false
end

/*---------------------------------------------------------------------------
Name: SWEP:Deploy()
Desc: called when the weapon is deployed
---------------------------------------------------------------------------*/
function SWEP:Deploy()
	self.Ready = false
	return true
end

function SWEP:Holster()
	if not self.Ready or not SERVER then return true end
	self.Ironsights = false
	hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner)
	self.Owner:SetJumpPower(200)

	return true
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if CLIENT then return end

	if not self.Ready then return end

	local trace = self.Owner:GetEyeTrace()

	self.Weapon:SetNextPrimaryFire(CurTime() + 2.5)
	if (not IsValid(trace.Entity) or (not trace.Entity:isDoor() and not trace.Entity:IsVehicle() and trace.Entity:GetClass() ~= "prop_physics")) then
		return
	end

	if trace.Entity:isDoor() and (self.Owner:EyePos():Distance(trace.HitPos) > 45 or
		(not GAMEMODE.Config.canforcedooropen and trace.Entity:getKeysNonOwnable())) then
		return
	end

	if (trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.HitPos) > 100) then
		return
	end

	local a = GAMEMODE.Config.copscanunfreeze
	local d = GAMEMODE.Config.copscanunweld
	local b = trace.Entity:GetClass() == "prop_physics"
	local c = false

	local Owner = trace.Entity:CPPIGetOwner()
	if Owner then
		c = Owner.warranted or Owner:isWanted() or Owner:isArrested()
	end
	if (trace.Entity:isDoor()) then
		local allowed = false
		local team = self.Owner:Team()
		-- if we need a warrant to get in
		if GAMEMODE.Config.doorwarrants and trace.Entity:isKeysOwned() and not trace.Entity:isKeysOwnedBy(self.Owner) then
			-- if anyone who owns this door has a warrant for their arrest
			-- allow the police to smash the door in
			for k, v in pairs(player.GetAll()) do
				if trace.Entity:isKeysOwnedBy(v) and (v.warranted == true or v:isWanted() or v:isArrested()) then
					allowed = true
					break
				end
			end
		else
			-- rp_doorwarrants 0, allow warrantless entry
			allowed = true
		end

		-- Be able to open the door if anyone is warranted
		if GAMEMODE.Config.doorwarrants and trace.Entity:getKeysDoorGroup() and RPExtraTeamDoors[trace.Entity:getKeysDoorGroup()] then
			allowed = false
			for k,v in pairs(player.GetAll()) do
				if table.HasValue(RPExtraTeamDoors[trace.Entity:getKeysDoorGroup()], v:Team()) and (v.warranted or v:isWanted() or v:isArrested()) then
					allowed = true
					break
				end
			end
		end
		-- Do we have a warrant for this player?
		if allowed then
			trace.Entity:keysUnLock()
			trace.Entity:Fire("open", "", .6)
			trace.Entity:Fire("setanimation", "open", .6)
		else
			DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("warrant_required"))
			return
		end
	elseif (trace.Entity:IsVehicle()) then
		local driver = trace.Entity:GetDriver()
		if driver and driver.ExitVehicle then
			driver:ExitVehicle()
		end
		trace.Entity:keysLock()
	elseif trace.Entity.isFadingDoor and self.Owner:EyePos():Distance(trace.HitPos) < 100 then
		if not c then
			DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("warrant_required"))
			return
		end

		if trace.Entity.isFadingDoor and trace.Entity.fadeActivate and not trace.Entity.fadeActive then
			trace.Entity:fadeActivate()
			timer.Simple(5, function() if trace.Entity.fadeActive then trace.Entity:fadeDeactivate() end end)
		end
	elseif a and b and not trace.Entity:GetPhysicsObject():IsMoveable() and self.Owner:EyePos():Distance(trace.HitPos) < 100 then
		if not c then
			DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("warrant_required_unfreeze"))
			return
		end

		trace.Entity:GetPhysicsObject():EnableMotion(true)
	end
	if d and b and self.Owner:EyePos():Distance(trace.HitPos) < 100 then
		if not c then
			DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("warrant_required_unweld"))
			return
		end

		constraint.RemoveConstraints(trace.Entity, "Weld")
	end

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:EmitSound(self.Sound)
	self.Owner:ViewPunch(Angle(-10, math.random(-5, 5), 0))
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	self.LastIron = CurTime()
	self.Ready = not self.Ready
	self.Ironsights = not self.Ironsights
	if self.Ready then
		self:SetWeaponHoldType("rpg")
		if SERVER then
			-- Prevent them from being able to run and jump
			hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner)
			self.Owner:SetJumpPower(0)
		end
	else
		self:SetWeaponHoldType("normal")
		if SERVER then
			hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner)
			self.Owner:SetJumpPower(200)
		end
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	local Mul = 1

	if self.LastIron > CurTime() - 0.25 then
		Mul = math.Clamp((CurTime() - self.LastIron) / 0.25, 0, 1)
	end

	if self.Ready then
		Mul = 1-Mul
	end

	ang:RotateAroundAxis(ang:Right(), - 15 * Mul)
	return pos,ang
end
