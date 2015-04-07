AddCSLuaFile();

if CLIENT then
	SWEP.PrintName = "Battering Ram"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server
SWEP.Base = "weapon_cs_base2"

SWEP.Author = "fprp Developers"
SWEP.Instructions = "Left click to break open doors/unfreeze props or get people out of their vehicles\nRight click to raise"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_rpg.mdl");
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl");
SWEP.AnimPrefix = "rpg"

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
SWEP.Secondary.DefaultClip = 0     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false     -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

/*---------------------------------------------------------
Name: SWEP:Initialize();
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self.LastIron = CurTime();
	self:SetHoldType("normal");
	self.Ready = false
end

/*---------------------------------------------------------------------------
Name: SWEP:Deploy();
Desc: called when the weapon is deployed
---------------------------------------------------------------------------*/
function SWEP:Deploy()
	self.Ready = false
	return true
end

function SWEP:Holster()
	if not self.Ready or not SERVER then return true end
	self.Ironsights = false
	hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner);
	self.Owner:SetJumpPower(200);

	return true
end

-- Check whether an object of this player can be rammed
local function canRam(ply)
	return IsValid(ply) and (ply.warranted == true or ply:isWanted() or ply:isArrested());
end

-- Ram action when ramming a door
local function ramDoor(ply, trace, ent)
	if ply:EyePos():Distance(trace.HitPos) > 45 or (not GAMEMODE.Config.canforcedooropen and ent:getKeysNonOwnable()) then return false end

	local allowed = false

	-- if we need a warrant to get in
	if GAMEMODE.Config.doorwarrants and ent:isKeysOwned() and not ent:isKeysOwnedBy(ply) then
		-- if anyone who owns this door has a warrant for their arrest
		-- allow the police to smash the door in
		for k, v in pairs(player.GetAll()) do
			if ent:isKeysOwnedBy(v) and canRam(v) then
				allowed = true
				break
			end
		end
	else
		-- door warrants not needed, allow warrantless entry
		allowed = true
	end

	-- Be able to open the door if any member of the door group is warranted
	if GAMEMODE.Config.doorwarrants and ent:getKeysDoorGroup() and RPExtraTeamDoors[ent:getKeysDoorGroup()] then
		allowed = false
		for k,v in pairs(player.GetAll()) do
			if table.HasValue(RPExtraTeamDoors[ent:getKeysDoorGroup()], v:Team()) and canRam(v) then
				allowed = true
				break
			end
		end
	end

	-- Do we have a warrant for this player?
	if not allowed then
		fprp.notify(ply, 1, 5, fprp.getPhrase("warrant_required"));

		return false
	end

	ent:keysUnLock();
	ent:Fire("open", "", .6);
	ent:Fire("setanimation", "open", .6);

	return true
end

-- Ram action when ramming a vehicle
local function ramVehicle(ply, trace, ent)
	if ply:EyePos():Distance(trace.HitPos) > 100 then return false end

	local driver = ent:GetDriver();
	if not driver or not driver.ExitVehicle then return false end

	driver:ExitVehicle();
	ent:keysLock();

	return true
end

-- Ram action when ramming a fading door
local function ramFadingDoor(ply, trace, ent)
	if ply:EyePos():Distance(trace.HitPos) > 100 then return false end

	local Owner = ent:CPPIGetOwner();

	if not canRam(Owner) then
		fprp.notify(ply, 1, 5, fprp.getPhrase("warrant_required"));
		return false
	end

	if not ent.fadeActive then
	    ent:fadeActivate();
	    timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end)
	end

	return true
end

-- Ram action when ramming a frozen prop
local function ramProp(ply, trace, ent)
	if ply:EyePos():Distance(trace.HitPos) > 100 then return false end
	if ent:GetClass() ~= "prop_physics" then return false end

	local Owner = ent:CPPIGetOwner();

	if not canRam(Owner) then
	    fprp.notify(ply, 1, 5, fprp.getPhrase(GAMEMODE.Config.copscanunweld and "warrant_required_unweld" or "warrant_required_unfreeze"));
	    return false
	end

	if GAMEMODE.Config.copscanunweld then
		constraint.RemoveConstraints(ent, "Weld");
	end

	if GAMEMODE.Config.copscanunfreeze then
		ent:GetPhysicsObject():EnableMotion(true);
	end

	return true
end

-- Decides the behaviour of the ram function for the given entity
local function getRamFunction(ply, trace)
	local ent = trace.Entity

	if not IsValid(ent) then return fp{fn.Id, false} end

	local override = hook.Call("canDoorRam", nil, ply, trace, ent);

	return
		override ~= nil     and fp{fn.Id, override}								   or
		ent:isDoor() 		and fp{ramDoor, ply, trace, ent} 					   or
		ent:IsVehicle() 	and fp{ramVehicle, ply, trace, ent} 				   or
		ent.fadeActivate 	and fp{ramFadingDoor, ply, trace, ent}  			   or
		ent:GetPhysicsObject():IsValid() and not ent:GetPhysicsObject():IsMoveable()
							and fp{ramProp, ply, trace, ent}   					   or
		fp{fn.Id, false} -- no ramming was performed
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack();
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if CLIENT then return end

	if not self.Ready then return end

	local trace = self.Owner:GetEyeTrace();

	self.Weapon:SetNextPrimaryFire(CurTime() + 2.5);

	local hasRammed = getRamfunction(self.Owner, trace)()

	hook.Call("onDoorRamUsed", GAMEMODE, hasRammed, self.Owner, trace);

	if not hasRammed then return end

	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self.Owner:EmitSound(self.Sound);
	self.Owner:ViewPunch(Angle(-10, math.random(-5, 5), 0));
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	self.LastIron = CurTime();
	self.Ready = not self.Ready
	self.Ironsights = not self.Ironsights
	if self.Ready then
		self:SetHoldType("rpg");
		if SERVER then
			-- Prevent them from being able to run and jump
			hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner);
			self.Owner:SetJumpPower(0);
		end
	else
		self:SetHoldType("normal");
		if SERVER then
			hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner);
			self.Owner:SetJumpPower(200);
		end
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	local Mul = 1

	if self.LastIron > CurTime() - 0.25 then
		Mul = math.Clamp((CurTime() - self.LastIron) / 0.25, 0, 1);
	end

	if self.Ready then
		Mul = 1-Mul
	end

	ang:RotateAroundAxis(ang:Right(), - 15 * Mul);
	return pos,ang
end

if SERVER then
	fprp.hookStub{
		name = "canDoorRam",
		description = "Called when a player attempts to ram something. Use this to override ram behaviour or to disallow ramming.",
		parameters = {
			{
				name = "ply",
				description = "The player using the door ram.",
				type = "Player"
			},
			{
				name = "trace",
				description = "The trace containing information about the hit position and ram entity.",
				type = "table"
			},
			{
				name = "ent",
				description = "Short for the entity that is about to be hit by the door ram.",
				type = "Entity"
			}
		},
		returns = {
			{
				name = "override",
				description = "Return true to override behaviour, false to disallow ramming and nil (or no value) to defer the decision.",
				type = "boolean"
			}
		}
	}

	fprp.hookStub{
		name = "onDoorRamUsed",
		description = "Called when the door ram has been used.",
		parameters = {
			{
				name = "success",
				description = "Whether the door ram has been successful in ramming.",
				type = "boolean"
			},
			{
				name = "ply",
				description = "The player that used the door ram.",
				type = "Player"
			},
			{
				name = "trace",
				description = "The trace containing information about the hit position and ram entity.",
				type = "table"
			}
		},
		returns = {

		}
	}
end
