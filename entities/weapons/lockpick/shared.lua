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
SWEP.Instructions = "Left click to pick a lock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.UseHands = true

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
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

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

if CLIENT then
	net.Receive("lockpick_time", function()
		local wep = net.ReadEntity()
		local time = net.ReadUInt(5)

		wep.IsLockPicking = true
		wep.StartPick = CurTime()
		wep.LockPickTime = time
		wep.EndPick = CurTime() + time
	end)

	usermessage.Hook("IsFadingDoor", function(um) -- Set isFadingDoor clientside (this is the best way I could think of to do this, if anyone can think of a better way feel free to change it.
		local door = um:ReadEntity()
		if IsValid(door) then
			door.isFadingDoor = true
		end
	end)
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)
	if self.IsLockPicking then return end

	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity
	if SERVER and e.isFadingDoor then SendUserMessage("IsFadingDoor", self.Owner, e) end -- The fading door tool only sets isFadingDoor serverside, for the lockpick to work we need this to be set clientside too.
	if not IsValid(e) or trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 or
		(not e:isDoor() and not e:IsVehicle() and not string.find(string.lower(e:GetClass()), "vehicle") and not e.isFadingDoor) then
		return
	end

	if not GAMEMODE.Config.canforcedooropen and e:getKeysNonOwnable() then
		return
	end

	if SERVER then
		self.IsLockPicking = true
		self.StartPick = CurTime()
		self.LockPickTime = math.Rand(10, 30)
		net.Start("lockpick_time")
			net.WriteEntity(self)
			net.WriteUInt(self.LockPickTime, 5) -- 2^5 = 32 max
		net.Send(self.Owner)
		self.EndPick = CurTime() + self.LockPickTime
	end

	self:SetWeaponHoldType("pistol")

	if SERVER then
		timer.Create("LockPickSounds", 1, self.LockPickTime, function()
			if not IsValid(self) then return end
			local snd = {1,3,4}
			self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100)
		end)
	elseif CLIENT then
		self.Dots = self.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
			if not self:IsValid() then timer.Destroy("LockPickDots") return end
			local len = string.len(self.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			self.Dots = dots[len]
		end)
	end
end

function SWEP:Holster()
	self.IsLockPicking = false
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
	return true
end

function SWEP:Succeed()
	self.IsLockPicking = false
	self:SetWeaponHoldType("normal")
	local trace = self.Owner:GetEyeTrace()
	if trace.Entity.isFadingDoor and trace.Entity.fadeActivate then
		if not trace.Entity.fadeActive then
			trace.Entity:fadeActivate()
			timer.Simple(5, function() if trace.Entity.fadeActive then trace.Entity:fadeDeactivate() end end)
		end
	elseif IsValid(trace.Entity) and trace.Entity.Fire then
		trace.Entity:keysUnLock()
		trace.Entity:Fire("open", "", .6)
		trace.Entity:Fire("setanimation","open",.6)
	end
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Fail()
	self.IsLockPicking = false
	self:SetWeaponHoldType("normal")
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Think()
	if self.IsLockPicking and self.EndPick then
		local trace = self.Owner:GetEyeTrace()
		if not IsValid(trace.Entity) then
			self:Fail()
		end
		if trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 or (not trace.Entity:isDoor() and not trace.Entity:IsVehicle() and not string.find(string.lower(trace.Entity:GetClass()), "vehicle") and not trace.Entity.isFadingDoor) then
			self:Fail()
		end
		if self.EndPick <= CurTime() then
			self:Succeed()
		end
	end
end

function SWEP:DrawHUD()
	if self.IsLockPicking and self.EndPick then
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

		draw.SimpleText(DarkRP.getPhrase("picking_lock")..self.Dots, "Trebuchet24", w/2, y + height/2, Color(255,255,255,255), 1, 1)
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end
