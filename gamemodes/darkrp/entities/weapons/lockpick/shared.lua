if SERVER then
	AddCSLuaFile("shared.lua")
	util.AddNetworkString("lockpick_time")
end

if CLIENT then
	SWEP.PrintName = "Lock Pick"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left or right click to pick a lock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

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
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.LockPickTime = 30

--[[-------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()
	self:SetHoldType("normal")
end

if CLIENT then
	net.Receive("lockpick_time", function()
		local wep = net.ReadEntity()
		local ent = net.ReadEntity()
		local time = net.ReadUInt(5)

		wep.IsLockPicking = true
		wep.LockPickEnt = ent
		wep.StartPick = CurTime()
		wep.LockPickTime = time
		wep.EndPick = CurTime() + time

		wep.Dots = wep.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
			if not IsValid(wep) then timer.Destroy("LockPickDots") return end
			local len = string.len(wep.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			wep.Dots = dots[len]
		end)
	end)
end

--[[-------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)
	if self.IsLockPicking then return end

	local trace = self.Owner:GetEyeTrace()
	local ent = trace.Entity

	if not IsValid(ent) then return end
	local canLockpick = hook.Call("canLockpick", nil, self.Owner, ent)

	if canLockpick == false then return end
	if canLockpick ~= true and (
			trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 or
			(not GAMEMODE.Config.canforcedooropen and ent:getKeysNonOwnable()) or
			(not ent:isDoor() and not ent:IsVehicle() and not string.find(string.lower(ent:GetClass()), "vehicle") and (not GAMEMODE.Config.lockpickfading or not ent.isFadingDoor))
		) then
		return
	end

	self:SetHoldType("pistol")

	if CLIENT then return end

	self.IsLockPicking = true
	self.LockPickEnt = ent
	self.StartPick = CurTime()
	self.LockPickTime = math.Rand(10, 30)
	net.Start("lockpick_time")
		net.WriteEntity(self)
		net.WriteEntity(ent)
		net.WriteUInt(self.LockPickTime, 5) -- 2^5 = 32 max
	net.Send(self.Owner)
	self.EndPick = CurTime() + self.LockPickTime

	timer.Create("LockPickSounds", 1, self.LockPickTime, function()
		if not IsValid(self) then return end
		local snd = {1,3,4}
		self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100)
	end)
end

function SWEP:Holster()
	self.IsLockPicking = false
	self.LockPickEnt = nil
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
	return true
end

function SWEP:Succeed()
	self:SetHoldType("normal")

	local ent = self.LockPickEnt
	self.IsLockPicking = false
	self.LockPickEnt = nil

	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end

	if not IsValid(ent) then return end

	local override = hook.Call("onLockpickCompleted", nil, self.Owner, true, ent)

	if override then return end

	if ent.isFadingDoor and ent.fadeActivate and not ent.fadeActive then
		ent:fadeActivate()
		timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end)
	elseif ent.Fire then
		ent:keysUnLock()
		ent:Fire("open", "", .6)
		ent:Fire("setanimation", "open", .6)
	end
end

function SWEP:Fail()
	self.IsLockPicking = false
	self:SetHoldType("normal")

	hook.Call("onLockpickCompleted", nil, self.Owner, false, self.LockPickEnt)
	self.LockPickEnt = nil

	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Think()
	if not self.IsLockPicking or not self.EndPick then return end

	local trace = self.Owner:GetEyeTrace()
	if not IsValid(trace.Entity) or trace.Entity ~= self.LockPickEnt or trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 then
		self:Fail()
	elseif self.EndPick <= CurTime() then
		self:Succeed()
	end
end

function SWEP:DrawHUD()
	if not self.IsLockPicking or not self.EndPick then return end

	self.Dots = self.Dots or ""
	local w = ScrW()
	local h = ScrH()
	local x,y,width,height = w/2-w/10, h/2-60, w/5, h/15
	draw.RoundedBox(8, x, y, width, height, Color(10,10,10,120))

	local time = self.EndPick - self.StartPick
	local curtime = CurTime() - self.StartPick
	local status = math.Clamp(curtime/time, 0, 1)
	local BarWidth = status * (width - 16)
	local cornerRadius = math.Min(8, BarWidth/3*2 - BarWidth/3*2%2)
	draw.RoundedBox(cornerRadius, x+8, y+8, BarWidth, height-16, Color(255-(status*255), 0+(status*255), 0, 255))

	draw.DrawNonParsedSimpleText(DarkRP.getPhrase("picking_lock") .. self.Dots, "Trebuchet24", w/2, y + height/2, Color(255,255,255,255), 1, 1)
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end


DarkRP.hookStub{
	name = "canLockpick",
	description = "Whether an entity can be lockpicked.",
	parameters = {
		{
			name = "ply",
			description = "The player attempting to lockpick an entity.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The entity being lockpicked.",
			type = "Entity"
		},
	},
	returns = {
		{
			name = "allowed",
			description = "Whether the entity can be lockpicked",
			type = "boolean"
		}
	},
	realm = "Server"
}

DarkRP.hookStub{
	name = "onLockpickCompleted",
	description = "Result of a player attempting to lockpick an entity.",
	parameters = {
		{
			name = "ply",
			description = "The player attempting to lockpick the entity.",
			type = "Player"
		},
		{
			name = "success",
			description = "Whether the player succeeded in lockpicking the entity.",
			type = "boolean"
		},
		{
			name = "ent",
			description = "The entity that was lockpicked.",
			type = "Entity"
		},
	},
	returns = {
		{
			name = "override",
			description = "Return true to override default behaviour, which is opening the (fading) door.",
			type = "boolean"
		}
	},
	realm = "Shared"
}
