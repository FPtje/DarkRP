if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Rick Darkaliono, philxyz"
SWEP.Instructions = "Left click to lock. Right click to unlock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModel = Model("models/weapons/v_hands.mdl")

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
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
	if SERVER then
		self.Owner:DrawWorldModel(false)
	end
end

function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or (trace.Entity.DoorData and trace.Entity.DoorData.NonOwnable) or (trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65) or (trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100) then
		if CLIENT then RunConsoleCommand("_DarkRP_AnimationMenu") end
		return
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}

	local Team = self.Owner:Team()
	local DoorData = table.Copy(trace.Entity.DoorData or {}) -- Copy table to make non-permanent changes
	if SERVER and DoorData.TeamOwn then
		local decoded = {}
		for k, v in pairs(string.Explode("\n", DoorData.TeamOwn)) do
			if v and v != "" then
				decoded[tonumber(v)] = true
			end
		end
		DoorData.TeamOwn = decoded
	end
	if trace.Entity:OwnedBy(self.Owner) or (DoorData.GroupOwn and table.HasValue(RPExtraTeamDoors[DoorData.GroupOwn] or {}, Team)) or (DoorData.TeamOwn and DoorData.TeamOwn[Team]) then
		if SERVER then
			self.Owner:EmitSound("npc/metropolice/gear".. math.floor(math.Rand(1,7)) ..".wav")
			trace.Entity:KeysLock() -- Lock the door immediately so it won't annoy people

			timer.Simple(0.9, function() if IsValid(self.Owner) then self.Owner:EmitSound(self.Sound) end end)

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
			GAMEMODE:Notify(self.Owner, 1, 3, "You don't own this vehicle!")
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

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or (trace.Entity.DoorData and trace.Entity.DoorData.NonOwnable) or (trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65) or (trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100) then
		if CLIENT then RunConsoleCommand("_DarkRP_AnimationMenu") end
		return
	end

	local Team = self.Owner:Team()
	local DoorData = table.Copy(trace.Entity.DoorData or {}) -- Copy table to make non-permanent changes
	if SERVER and DoorData.TeamOwn then
		local decoded = {}
		for k, v in pairs(string.Explode("\n", DoorData.TeamOwn)) do
			if v and v != "" then
				decoded[tonumber(v)] = true
			end
		end
		DoorData.TeamOwn = decoded
	end
	if trace.Entity:OwnedBy(self.Owner) or (DoorData.GroupOwn and table.HasValue(RPExtraTeamDoors[DoorData.GroupOwn] or {}, Team)) or (DoorData.TeamOwn and DoorData.TeamOwn[Team]) then
		if SERVER then
			self.Owner:EmitSound("npc/metropolice/gear".. math.floor(math.Rand(1,7)) ..".wav")
			trace.Entity:KeysUnLock() -- Unlock the door immediately so it won't annoy people

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
			GAMEMODE:Notify(self.Owner, 1, 3, "You don't own this vehicle!")
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
	if not IsValid(trace.Entity) or (IsValid(trace.Entity) and ((not trace.Entity:IsDoor() and not trace.Entity:IsVehicle()) or self.Owner:EyePos():Distance(trace.HitPos) > 200)) then
		if not self.OnceReload then
			if SERVER then GAMEMODE:Notify(self.Owner, 1, 3, "You need to be looking at a door/vehicle in order to bring up the menu") end
			self.OnceReload = true
			timer.Simple(3, function() self.OnceReload = false end)
		end
		return
	end
	if SERVER then
		umsg.Start("KeysMenu", self.Owner)
			umsg.Bool(self.Owner:GetEyeTrace().Entity:IsVehicle())
		umsg.End()
	end
end
