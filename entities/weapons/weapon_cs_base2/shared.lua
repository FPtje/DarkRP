if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
end

if CLIENT then
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= true

	-- This is the font that's used to draw the death icons
	surface.CreateFont("CSKillIcons", {
		size = ScreenScale(30),
		weight = 500,
		antialias = true,
		shadow = true,
		font = "csd"})
	surface.CreateFont("CSSelectIcons", {
		size = ScreenScale(60),
		weight = 500,
		antialias = true,
		shadow = true,
		font = "csd"})
end

SWEP.Base = "weapon_base"

SWEP.Author = "Rickster"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.HoldType = "normal"
SWEP.CurHoldType = "normal"

SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 40
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.15

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.LastPrimaryAttack = 0

SWEP.FireMode = "semi"
SWEP.MultiMode = false

/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		self:ResetBones(vm)
	end

	self:SetWeaponHoldType("normal")
	self.CurHoldType = "normal"
	if SERVER then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end

	self.Ironsights = false

	if self.Primary.Automatic then

		self.FireMode = "auto"

	end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	self:NewSetWeaponHoldType("normal")
	self.CurHoldType = "normal"

	self.LASTOWNER = self.Owner

	self:SetIronsights(self:GetIronsights())

	// WORKAROUND: Some models have shit viewmodel positions until they fire
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	return true
end

function SWEP:Holster()
	self.Ironsights = false

	if CLIENT then
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			self:ResetBones(vm)
		end
		return
	end
	hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner)

	return true
end

function SWEP:Remove()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		self:ResetBones(vm)
	end
end

/*---------------------------------------------------------
Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
	if not self.Weapon:DefaultReload(ACT_VM_RELOAD) then return end
	self.Reloading = true
	self:SetIronsights(false)
	self:NewSetWeaponHoldType(self.HoldType)
	self.CurHoldType = self.HoldType
	self.Owner:SetAnimation(PLAYER_RELOAD)
	timer.Simple(2, function()
		if not IsValid(self) then return end
		self.Reloading = false
		self:NewSetWeaponHoldType("normal")
		self.CurHoldType = "normal"
	end)
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack( partofburst )

	if not partofburst and ( self.LastNonBurst or 0 ) > CurTime() - 0.6 then return end

	if self.Weapon.MultiMode and self.Owner:KeyDown( IN_USE ) then

		if self.FireMode == "semi" then

			self.FireMode = "burst"
			self.Primary.Automatic = false
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to burst-fire mode.")

		elseif self.FireMode == "burst" then

			self.FireMode = "auto"
			self.Primary.Automatic = true
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to fully automatic fire mode.")

		elseif self.FireMode == "auto" then

			self.FireMode = "semi"
			self.Primary.Automatic = false
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to semi-automatic fire mode.")

		end

		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )

		return
	end

	if self.CurHoldType == "normal" and not GAMEMODE.Config.ironshoot then
		self:NewSetWeaponHoldType(self.HoldType)
		self.CurHoldType = self.HoldType
	end

	if self.FireMode != "burst" then

		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	end

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	if self:Clip1() <= 0 then
		self:EmitSound("weapons/clipempty_rifle.wav")
		self:SetNextPrimaryFire(CurTime() + 2)
		return
	end

	if not self:CanPrimaryAttack() then self:SetIronsights(false) return end
	if not self.Ironsights and GAMEMODE.Config.ironshoot then return end
	-- Play shoot sound
	self.Weapon:EmitSound(self.Primary.Sound)

	-- Shoot the bullet
	self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil + 3, self.Primary.NumShots, self.Primary.Cone + .05)

	if self.FireMode == "burst" and not partofburst then

		timer.Simple( 0.1, function() self:PrimaryAttack(true) end)
		timer.Simple( 0.2, function() self:PrimaryAttack(true) end)

		self.LastNonBurst = CurTime()

	end

	-- Remove 1 bullet from our clip
	self:TakePrimaryAmmo(1)

	if ( self.Owner:IsNPC() ) then return end

	-- Punch the player's view
	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))

	self.LastPrimaryAttack = CurTime()
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:CSShootBullet(dmg, recoil, numbul, cone)
	if not IsValid(self.Owner) then return end
	numbul = numbul or 1
	cone = cone or 0.01

	local bullet = {}
	bullet.Num = numbul or 1
	bullet.Src = self.Owner:GetShootPos()       -- Source
	bullet.Dir = self.Owner:GetAimVector()      -- Dir of bullet
	bullet.Spread = Vector(cone, cone, 0)     -- Aim Cone
	bullet.Tracer = 4       -- Show a tracer on every x bullets
	bullet.Force = 5        -- Amount of force to give to phys objects
	bullet.Damage = dmg

	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)      -- View model animation
	self.Owner:MuzzleFlash()        -- Crappy muzzle light
	self.Owner:SetAnimation(PLAYER_ATTACK1)       -- 3rd Person Animation

	if ( self.Owner:IsNPC() ) then return end

	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	end
end

/*---------------------------------------------------------
Checks the objects before any action is taken
This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	local iconletters = {"x", "w", "b", "k", "u", "f", "d", "l", "z", "c"}
	if self.IconLetter and table.HasValue(iconletters, self.IconLetter) then
		draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)

		-- try to fool them into thinking they're playing a Tony Hawks game
		draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color(255, 210, 0, math.Rand(10, 120)), TEXT_ALIGN_CENTER)
		draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color(255, 210, 0, math.Rand(10, 120)), TEXT_ALIGN_CENTER)
	else
		// Set us up the texture
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( self.WepSelectIcon )

		// Lets get a sin wave to make it bounce
		local fsin = 0

		if self.BounceWeaponIcon then
			fsin = math.sin( CurTime() * 10 ) * 5
		end

		// Borders
		y = y + 10
		x = x + 10
		wide = wide - 20

		// Draw that motherfucker
		surface.DrawTexturedRect( x + (fsin), y - (fsin),  wide-fsin*2 , ( wide / 2 ) + (fsin) )

		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end

local IRONSIGHT_TIME = 0.25

/*---------------------------------------------------------
Name: GetViewModelPosition
Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition(pos, ang)
	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Ironsights

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if (bIron) then
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	end

	local fIronTime = self.fIronTime or 0

	pos = pos + ang:Forward() * -5
	if GAMEMODE.Config.ironshoot then
		ang:RotateAroundAxis(ang:Right(), -15)
	end

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 	self.IronSightsAng.x		* Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	if GAMEMODE.Config.ironshoot then
		ang:RotateAroundAxis(ang:Right(), Mul * 15)
	else
		ang:RotateAroundAxis(ang:Right(), Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end


/*---------------------------------------------------------
SetIronsights
---------------------------------------------------------*/

function SWEP:SetIronsights(b)
	if game.SinglePlayer() then -- Make ironsights work on SP
		self.Owner:SendLua("LocalPlayer():GetActiveWeapon().Ironsights = "..tostring(b))
	end
	self.Ironsights = b
	if b then
		self:NewSetWeaponHoldType(self.HoldType)
		self.CurHoldType = self.HoldType
		if SERVER then
			hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner)
		end
	else
		self:NewSetWeaponHoldType("normal")
		self.CurHoldType = "normal"
		if SERVER then
			hook.Call("UpdatePlayerSpeed", GAMEMODE, self.Owner)
		end
	end
end

function SWEP:GetIronsights()
	return self.Ironsights
end

SWEP.NextSecondaryAttack = 0
/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if not self.IronSightsPos then return end

	if (self.NextSecondaryAttack > CurTime()) then return end

	local bIronsights = not self.Ironsights

	self:SetIronsights(bIronsights)
	self.NextSecondaryAttack = CurTime() + 0.3
end

/*---------------------------------------------------------
onRestore
	Loaded a saved game
---------------------------------------------------------*/
function SWEP:OnRestore()
	self.NextSecondaryAttack = 0
	self.Ironsights = false
end

function SWEP:OnDrop()
	self.PrimaryClipLeft = self:Clip1()
	self.SecondaryClipLeft = self:Clip2()

	if not self.LASTOWNER then return end
	self.PrimaryAmmoLeft = self.LASTOWNER:GetAmmoCount(self:GetPrimaryAmmoType())
	self.SecondaryAmmoLeft = self.LASTOWNER:GetAmmoCount(self:GetSecondaryAmmoType())
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
end

function SWEP:Equip(NewOwner)
	if self.PrimaryClipLeft and self.SecondaryClipLeft and self.PrimaryAmmoLeft and self.SecondaryAmmoLeft then
		NewOwner:SetAmmo(self.PrimaryAmmoLeft, self:GetPrimaryAmmoType())
		NewOwner:SetAmmo(self.SecondaryAmmoLeft, self:GetSecondaryAmmoType())

		self:SetClip1(self.PrimaryClipLeft)
		self:SetClip2(self.SecondaryClipLeft)
	end
end

function SWEP:Think()
	if self.Primary.ClipSize ~= -1 and not self.Reloading and not self.Ironsights and self.LastPrimaryAttack + 1 < CurTime() and self.CurHoldType == self.HoldType then
		self.CurHoldType = "normal"
		self:NewSetWeaponHoldType("normal")
	end
end

function SWEP:NewSetWeaponHoldType(holdtype)
	if SERVER then
		umsg.Start("DRP_HoldType")
			umsg.Entity(self)
			umsg.String(holdtype)
		umsg.End()
	end

	self:SetWeaponHoldType(holdtype)

end

if CLIENT then
	function SWEP:ViewModelDrawn()
		if not IsValid(self.Owner) then return end
		local vm = self.Owner:GetViewModel()
		
		if self.ViewModelBoneManipulations then
			self:UpdateBones(vm, self.ViewModelBoneManipulations)
		else
			self:ResetBones(vm)
		end
	end

	function SWEP:UpdateBones(vm, manipulations)
		if not IsValid(vm) or not vm:GetBoneCount() then return end

		-- Fill in missing bone names. Things fuck up when we workaround the scale bug and bones are missing.
		local bones = {}
		for i = 0, vm:GetBoneCount() - 1 do
			local bonename = vm:GetBoneName(i)
			if manipulations[bonename] then 
				bones[bonename] = manipulations[bonename]
			else
				bones[bonename] = { 
					scale = Vector(1,1,1),
					pos = Vector(0,0,0),
					angle = Angle(0,0,0)
				}
			end
		end
			
		for k, v in pairs(bones) do
			local bone = vm:LookupBone(k)
			if not bone then continue end
				
			-- Bone scaling seems to be buggy. Workaround.
			local scale = Vector(v.scale.x, v.scale.y, v.scale.z)
			local ms = Vector(1,1,1)
			local cur = vm:GetBoneParent(bone)
			while cur >= 0 do
				local pscale = bones[vm:GetBoneName(cur)].scale
				ms = ms * pscale
				cur = vm:GetBoneParent(cur)
			end
			scale = scale * ms
				
			if vm:GetManipulateBoneScale(bone) ~= scale then
				vm:ManipulateBoneScale(bone, scale)
			end
			if vm:GetManipulateBonePosition(bone) ~= v.pos then
				vm:ManipulateBonePosition(bone, v.pos)
			end
			if vm:GetManipulateBoneAngles(bone) ~= v.angle then
				vm:ManipulateBoneAngles(bone, v.angle)
			end
		end 
	end
	
	function SWEP:ResetBones(vm)	
		if not IsValid(vm) or not vm:GetBoneCount() then return end
		for i = 0, vm:GetBoneCount() - 1 do
			vm:ManipulateBoneScale(i, Vector(1, 1, 1))
			vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			vm:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end

	usermessage.Hook("DRP_HoldType", function(um)
		local wep = um:ReadEntity()
		local holdtype = um:ReadString()

		if not IsValid(wep) or not wep:IsWeapon() or not wep.SetWeaponHoldType then return end

		wep:SetWeaponHoldType(holdtype)
	end)
end

hook.Add("UpdatePlayerSpeed", "DarkRP_WeaponSpeed", function(ply)
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or not wep.Ironsights then return end

	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed / 3, GAMEMODE.Config.runspeed / 3)

	return true
end)