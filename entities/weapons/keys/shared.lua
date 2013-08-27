if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_menu.lua")
end

if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	include("cl_menu.lua")
end

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to lock. Right click to unlock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel	= ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Sound = "doors/door_latch3.wav"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
	if CLIENT or not IsValid(self.Owner) then return true end
	self.Owner:DrawWorldModel(false)
	return true
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetMaterial("debug/hsv")
end

function SWEP:Holster()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return true end
	self.Owner:GetViewModel():SetMaterial("")
	return true
end

function SWEP:OnRemove()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetMaterial("")
end

function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or
	not trace.Entity:isKeysOwnable() or
	trace.Entity:getKeysNonOwnable() or
	(trace.Entity:isDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65) or
	(trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:NearestPoint(self.Owner:EyePos())) > 100) then

		if CLIENT then RunConsoleCommand("_DarkRP_AnimationMenu") end
		return
	end

	local Team = self.Owner:Team()

	local group = trace.Entity:getKeysDoorGroup()
	local teamOwn = trace.Entity:getKeysDoorTeams()
	if trace.Entity:isKeysOwnedBy(self.Owner) or (group and table.HasValue(RPExtraTeamDoors[group] or {}, Team)) or (teamOwn and teamOwn[Team]) then
		if SERVER then
			self.Owner:EmitSound("npc/metropolice/gear".. math.floor(math.Rand(1,7)) ..".wav")
			trace.Entity:keysLock() -- Lock the door immediately so it won't annoy people

			timer.Simple(0.9, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound(self.Sound) end end)

			local RP = RecipientFilter()
			RP:AddAllPlayers()

			umsg.Start("anim_keys", RP)
				umsg.Entity(self.Owner)
				umsg.String("usekeys")
			umsg.End()
			self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
	else
		if trace.Entity:IsVehicle() and SERVER then
			DarkRP.notify(self.Owner, 1, 3, DarkRP.getPhrase("do_not_own_ent"))
		elseif not trace.Entity:IsVehicle() then
			if SERVER then self.Owner:EmitSound("physics/wood/wood_crate_impact_hard2.wav", 100, math.random(90, 110))
				umsg.Start("anim_keys", RP)
					umsg.Entity(self.Owner)
					umsg.String("knocking")
				umsg.End()

				self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
			end
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
	end
end

function SWEP:SecondaryAttack()
	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or
	not trace.Entity:isKeysOwnable() or
	trace.Entity:getKeysNonOwnable() or
	(trace.Entity:isDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65) or
	(trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:NearestPoint(self.Owner:EyePos())) > 100) then

		if CLIENT then RunConsoleCommand("_DarkRP_AnimationMenu") end
		return
	end

	local Team = self.Owner:Team()

	local group = trace.Entity:getKeysDoorGroup()
	local teamOwn = trace.Entity:getKeysDoorTeams()
	if trace.Entity:isKeysOwnedBy(self.Owner) or (group and table.HasValue(RPExtraTeamDoors[group] or {}, Team)) or (teamOwn and teamOwn[Team]) then
		if SERVER then
			self.Owner:EmitSound("npc/metropolice/gear".. math.floor(math.Rand(1,7)) ..".wav")
			trace.Entity:keysUnLock() -- Unlock the door immediately so it won't annoy people

			timer.Simple(0.9, function() if IsValid(self.Owner) then self.Owner:EmitSound(self.Sound) end end)

			umsg.Start("anim_keys", RP)
				umsg.Entity(self.Owner)
				umsg.String("usekeys")
			umsg.End()
			self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
		end
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
	else
		if trace.Entity:IsVehicle() and SERVER then
			DarkRP.notify(self.Owner, 1, 3, DarkRP.getPhrase("do_not_own_ent"))
		elseif not trace.Entity:IsVehicle() then
			if SERVER then self.Owner:EmitSound("physics/wood/wood_crate_impact_hard3.wav", 100, math.random(90, 110))
				umsg.Start("anim_keys", RP)
					umsg.Entity(self.Owner)
					umsg.String("knocking")
				umsg.End()

				self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
			end
		end
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)
	end
end

SWEP.OnceReload = false
function SWEP:Reload()
	local trace = self.Owner:GetEyeTrace()
	if not IsValid(trace.Entity) or (IsValid(trace.Entity) and ((not trace.Entity:isDoor() and not trace.Entity:IsVehicle()) or self.Owner:EyePos():Distance(trace.HitPos) > 200)) then
		if not self.OnceReload then
			if SERVER then DarkRP.notify(self.Owner, 1, 3, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle"))) end
			self.OnceReload = true
			timer.Simple(3, function() self.OnceReload = false end)
		end
		return
	end
	if SERVER then
		umsg.Start("KeysMenu", self.Owner)
		umsg.End()
	end
end
