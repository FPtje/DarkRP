if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_menu.lua")
	util.AddNetworkString("Keys_ViewModelMaterial")
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
	if CLIENT or not IsValid(self.Owner) then return end
	self.Owner:DrawWorldModel(false)
	net.Start("Keys_ViewModelMaterial")
		net.WriteString("debug/hsv") -- Make view model invisible but keep the new hands.
	net.Send(self.Owner)
end

function SWEP:Holster(wep)
	if CLIENT or not IsValid(self.Owner) then return true end
	net.Start("Keys_ViewModelMaterial")
		net.WriteString("") -- Reset
	net.Send(self.Owner)
	return true
end

function SWEP:Remove()
	if CLIENT or not IsValid(self.Owner) then return end
	net.Start("Keys_ViewModelMaterial")
		net.WriteString("") -- Reset
	net.Send(self.Owner)
end

net.Receive("Keys_ViewModelMaterial", function()
	if not IsValid(LocalPlayer()) then return end
	local viewmodel = LocalPlayer():GetViewModel()
	if not IsValid(viewmodel) then return end
	viewmodel:SetMaterial(net.ReadString())
end)

function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or (trace.Entity.DoorData and trace.Entity.DoorData.NonOwnable) or (trace.Entity:isDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65) or (trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:NearestPoint(self.Owner:EyePos())) > 100) then
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
	if trace.Entity:isKeysOwnedBy(self.Owner) or (DoorData.GroupOwn and table.HasValue(RPExtraTeamDoors[DoorData.GroupOwn] or {}, Team)) or (DoorData.TeamOwn and DoorData.TeamOwn[Team]) then
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

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or (trace.Entity.DoorData and trace.Entity.DoorData.NonOwnable) or (trace.Entity:isDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65) or (trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:NearestPoint(self.Owner:EyePos())) > 100) then
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
	if trace.Entity:isKeysOwnedBy(self.Owner) or (DoorData.GroupOwn and table.HasValue(RPExtraTeamDoors[DoorData.GroupOwn] or {}, Team)) or (DoorData.TeamOwn and DoorData.TeamOwn[Team]) then
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
