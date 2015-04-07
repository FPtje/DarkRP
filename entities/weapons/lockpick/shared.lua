AddCSLuaFile();

if CLIENT then
	SWEP.PrintName = "Lock Pick"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "fprp Developers"
SWEP.Instructions = "Left or right click to pick a lock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl");
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl");

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "fprp (Utility)"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav");

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.LockPickCount = 30

--[[-------------------------------------------------------
Name: SWEP:Initialize();
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()
	self:SetHoldType("normal");
end


--[[-------------------------------------------------------
Name: SWEP:PrimaryAttack();
Desc: +attack1 has been pressed
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1);
	if self:GetNWBool("IsLockPicking") then
		if CLIENT then return end
		self.LockPickCount = self.LockPickCount - 1
		self:SetNWInt("LockPickCount",self.LockPickCount);
		return
	end
	local trace = self.Owner:GetEyeTrace();
	local ent = trace.Entity

	if not IsValid(ent) then return end
	local canLockpick = hook.Call("canLockpick", nil, self.Owner, ent);

	if canLockpick == false then return end
	if canLockpick ~= true and (
			trace.HitPos:Distance(self.Owner:GetShootPos()) > 5000 or
			(not GAMEMODE.Config.canforcedooropen and ent:getKeysNonOwnable()) or
			(not ent:isDoor() and not ent:IsVehicle() and not string.find(string.lower(ent:GetClass()), "vehicle") and (not GAMEMODE.Config.lockpickfading or not ent.isFadingDoor))
		) then
		return
	end

	self:SetHoldType("pistol");

	if CLIENT then return end

	local onFail = function(ply) if ply == self.Owner then hook.Call("onLockpickCompleted", nil, ply, false, ent) end end

	-- Lockpick fails when dying or disconnecting
	hook.Add("PlayerDeath", self, fc{onFail, fn.Flip(fn.Const)});
	hook.Add("PlayerDisconnected", self, fc{onFail, fn.Flip(fn.Const)});
	-- Remove hooks when finished
	hook.Add("onLockpickCompleted", self, fc{fp{hook.Remove, "PlayerDisconnected", self}, fp{hook.Remove, "PlayerDeath", self}});

	self:SetNWBool("IsLockPicking",true);
	self:SetNWEntity("LockPickEnt",ent);
	self.StartPick = CurTime();
	self.LockPickCount = hook.Call("lockpickCount", nil, ply, ent) or math.Round(math.Rand(50, 100));
	self:SetNWInt("LockPickCount",self.LockPickCount);
	timer.Create("LockPickSounds", 1, 100, function()
		if not IsValid(self) then return end
		local snd = {1,3,4}
		self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100);
	end);
end

function SWEP:Holster()
	self:SetNWBool("IsLockPicking");
	self:SetNWEntity("LockPickEnt");
	if SERVER then timer.Destroy("LockPickSounds") end
	return true
end

function SWEP:Succeed()
	self:SetHoldType("normal");

	local ent = self:GetNWEntity("LockPickEnt");
	self:SetNWBool("IsLockPicking");
	self:SetNWEntity("LockPickEnt");

	if SERVER then timer.Destroy("LockPickSounds") end

	if not IsValid(ent) then return end

	local override = hook.Call("onLockpickCompleted", nil, self.Owner, true, ent);

	if override then return end

	if ent.isFadingDoor and ent.fadeActivate and not ent.fadeActive then
		ent:fadeActivate();
		timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end)
	elseif ent.Fire then
		ent:keysUnLock();
		ent:Fire("open", "", .6);
		ent:Fire("setanimation", "open", .6);
	end
end

function SWEP:Fail()
	self:SetNWBool("IsLockPicking");
	self:SetHoldType("normal");

	hook.Call("onLockpickCompleted", nil, self.Owner, false, self:GetNWEntity("LockPickEnt"));
	self:SetNWEntity("LockPickEnt");

	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Think()
	if not self:GetNWBool("IsLockPicking") then return end
	local trace = self.Owner:GetEyeTrace();
	if not IsValid(trace.Entity) or trace.Entity ~= self:GetNWEntity("LockPickEnt") or trace.HitPos:Distance(self.Owner:GetShootPos()) > 5000 then
		self:Fail();
	elseif self:GetNWInt( "LockPickCount" ) <= 0 then
		self:Succeed();
	end
end
 
function SWEP:DrawHUD()
	if not self:GetNWBool("IsLockPicking") then return end
	local status = self:GetNWInt("LockPickCount");
	local w = ScrW();
	local h = ScrH();
	local x,y,width,height = w/2-w/10, h/2-60, w/5, h/15
	draw.RoundedBox(8, x, y, width, height, Color(10,10,10,120));

	local BarWidth = (width - 16) - (width/20)*status
	local cornerRadius = math.Min(8, BarWidth/3*2 - BarWidth/3*2%2);
	draw.RoundedBox(cornerRadius, x+8, y+8, BarWidth, height-16, Color(255-(status*255), 0+(status*255), 0, 255));
	draw.DrawNonParsedSimpleText(fprp.getPhrase("picking_lock"), "Trebuchet24", w/2, y + height/2, Color(255,255,255,255), 1, 1);
end
 
function SWEP:SecondaryAttack()
	self:PrimaryAttack();
end


fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
	name = "lockpickCount",
	description = "The amount of times needed to click",
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
			name = "",
			description = "Count of times to open the door",
			type = "number"
		}
	},
	realm = "Server"
}
