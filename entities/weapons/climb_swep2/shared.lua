SWEP.Author              = "Jonascone"
SWEP.Contact             = ""
SWEP.Purpose             = "A reiteration of the Climb SWEP."
SWEP.Instructions        = "Refer to the Workshop page!"

SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = false

SWEP.ViewModel                  = "models/weapons/v_pistol.mdl"
SWEP.HoldType                   = "normal"

SWEP.Primary.ClipSize           = -1
SWEP.Primary.DefaultClip        = -1
SWEP.Primary.Automatic          = false
SWEP.Primary.Ammo               = "none"

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo             = "none"


local HitPlayer = { Sound("npc/vort/foot_hit.wav"), Sound("npc/zombie/zombie_hit.wav") }
local MatList = { }
MatList[67] = "concrete"
MatList[68] = "dirt"
MatList[71] = "chainlink"
MatList[76] = "tile"
MatList[77] = "metal"
MatList[78] = "dirt"
MatList[84] = "tile"
MatList[86] = "duct"
MatList[87] = "wood"

function SWEP:DrawWorldModel() return false; end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
    self.Weapon:DrawShadow(false)
	self.nextThink = 0
	self.Jumps = 0
    self.JumpSequence = 0
	self.EasterEgg = false
	self.Released = false
	self.MFC = "male"
	self.WallJumpTrace = nil
	self.CanWallRun = true
	self.WallRunAnim = 0
    return true
end
function SWEP:Deploy()
    self.Owner:DrawViewModel(false)
    if string.find(self.Owner:GetModel(), "female") or string.find(self.Owner:GetModel(), "alyx") or string.find(self.Owner:GetModel(), "mossman") then self.MFC = "female"
    elseif string.find(self.Owner:GetModel(), "combine") or string.find(self.Owner:GetModel(), "metro") then self.MFC = "combine"
    else self.MFC = "male" end

    self.Owner:SetNWBool("ClimbWallJump", false)
    self.Owner:SetNWBool("ClimbFalling", false)
    self.Owner:SetNWBool("ClimbWallRun", false)
    self.Released = false
    self.CanWallRun = true;		
    self.Parent = NULL;
end
function SWEP:Forget()

    if self.Grab then
        if self.Owner:GetMoveType() == MOVETYPE_NONE then self.Owner:SetMoveType(MOVETYPE_WALK) end
        self.Grab = false
        self.Parent = NULL;
    end
    return true

end
function SWEP:Think()

    if CLIENT or !IsValid(self.Owner) or !self.Owner:Alive() then return false end

    if self.Jumps != self.Owner:GetNWInt("ClimbJumps") then self.Owner:SetNWInt("ClimbJumps", self.Jumps) end
    if !self.Released and !self.Owner:KeyDown(IN_ATTACK2) then
        self.Released = true
    elseif self.Owner:OnGround() and (self.Jumps > 0 or !self.CanWallRun) or self.Owner:GetNWBool("ClimbFalling") then

        self.Jumps, self.JumpSequence = 0, 0
        self.EasterEgg = false
		self.CanWallRun = true
		self.Owner:SetNWBool("ClimbWallJump", false)
        self.Owner:SetNWBool("ClimbFalling", false)

	elseif self.Owner:GetNWBool("ClimbWallRun") and !self.Grab then
	
		local traceData = {};
		traceData.start = self.Owner:GetPos() + Vector(0, 0, 20);
		traceData.endpos = traceData.start + self.Owner:GetForward() * 70;
		traceData.filter = self.Owner;
		local trace = util.TraceLine(traceData);
		
		local vel = self.Owner:GetVelocity();
		if !self.Owner:OnGround() and trace.Hit and self.Owner:KeyDown(IN_FORWARD) and math.abs(vel:Length()) > 100 then
		
			local vel = self.Owner:GetVelocity() + self.Owner:GetForward();
			vel.z = 0;			
			if CurTime() > self.WallRunAnim then
			
				self.WallRunAnim = CurTime() + (0.2 - vel:Length() / 10000);
				self.Owner:ViewPunch(Angle(10, 0, 0));
				if trace.MatType == MAT_GLASS then self.Owner:EmitSound(Sound("physics/glass/glass_sheet_step"..math.random(1, 4)..".wav"), 75, math.random(95, 105))
				elseif trace.MatType and MatList[trace.MatType] then self.Owner:EmitSound(Sound("player/footsteps/"..MatList[trace.MatType]..math.random(1, 4)..".wav"), 75, math.random(95, 105)) end
				vel.z = -(100 + vel:Length());
				
			end
			self.Owner:SetLocalVelocity(vel);
			
		else 
			
			self.Owner:SetNWBool("ClimbWallRun", false); 
			self.CanWallRun = false;
			
		end
    elseif self.Owner:KeyDown(IN_FORWARD) then
		if self.Owner:KeyDown(IN_USE) and !self.Owner:OnGround() and self.CanWallRun and self.Jumps < GetConVarNumber("climbswep2_maxjumps") and !self.Grab then
	
			local traceData = {};
			traceData.start = self.Owner:GetPos();
			traceData.endpos = traceData.start - Vector(0, 0, GetConVarNumber("climbswep2_wallrun_minheight"));
			if !util.TraceLine(traceData).Hit then
			
				self.Owner:SetNWBool("ClimbWallRun", true);
				self.Jumps = self.Jumps + 1
				local vel = self.Owner:GetVelocity() + self.Owner:GetForward() * 100;
				vel.z = 0;
				self.Owner:SetLocalVelocity(vel);
			
			end
		end
	end

    if CurTime() < self.nextThink then return false end

    // For the lulz.
    if self.Owner:GetVelocity().z <= -900 and self.Owner:GetMoveType() == MOVETYPE_WALK then

        if !self.Owner:GetNWBool("ClimbFalling") then self.Owner:SetNWBool("ClimbFalling", true); self.Owner:SetNWBool("ClimbWallJump", false)
        elseif self.Owner:KeyDown(IN_JUMP) then

            self.nextThink = CurTime() + 2.5
            if self.MFC == "combine" then

                self.Owner:EmitSound("npc/metropolice/vo/help.wav", 125, math.random(90, 110))
                return true

            end
            self.Owner:EmitSound("vo/npc/"..self.MFC.."01/help01.wav", 125, math.random(90, 110))
            return true

        elseif !self.EasterEgg and math.random(1, 128) == 1 then

            self.EasterEgg = true
            if self.MFC == "combine" then self.Owner:EmitSound("npc/metropolice/vo/shit.wav", 100)
            else self.Owner:EmitSound("vo/npc/"..self.MFC.."01/gordead_ans19.wav", 100) end
            return true

        end

        return true

    elseif self.Owner:GetNWBool("ClimbFalling") then self.Owner:SetNWBool("ClimbFalling", false)
    end

    // Are we grabbing a ledge?
    if self.Grab then

        // Is it a prop?
		local physObj = NULL;
        if IsValid(self.Parent) then
			
			physObj = self.Parent:GetPhysicsObject();
            if physObj:IsMoveable() then 
				if math.abs(self.OldVelocity - self.Parent:GetVelocity():Length()) >= 500 then 
					return false;
				end
			end

        end
        if !self.Owner:KeyDown(IN_FORWARD) and !self.Owner:KeyDown(IN_MOVELEFT) and !self.Owner:KeyDown(IN_MOVERIGHT) then return false
        elseif self.Owner:KeyDown(IN_FORWARD) then

            if self.Owner:KeyDown(IN_JUMP) then

                self:Forget()
                self.Owner:EmitSound(Sound("npc/combine_soldier/gear"..math.random(1, 6)..".wav"), 75, math.random(95, 105))
                self.Owner:ViewPunch(Angle(-7.5, 0, 0))
                self.Owner:SetLocalVelocity(self.Owner:GetAimVector() * 400)
                return true

            end
            return true

        end

        local Predict
        local Shift = 0
        if self.Owner:KeyDown(IN_SPEED) then Shift = 0.15 end
        self.nextThink = CurTime() + (0.35 - Shift)

        if self.Owner:KeyDown(IN_MOVELEFT) then Predict = -self.Owner:GetRight() * 10
        elseif self.Owner:KeyDown(IN_MOVERIGHT) then Predict = self.Owner:GetRight() * 10 end

        local tracedata = {}
        tracedata.start = self.Owner:GetShootPos() + Predict
        tracedata.endpos = tracedata.start + self.Owner:GetForward() * 40
        tracedata.filter = self.Owner
        local trLo =  util.TraceLine(tracedata)

        local tracedata = {}
        tracedata.start = self.Owner:GetShootPos() + Vector(0, 0, 15) + Predict
        tracedata.endpos = tracedata.start + self.Owner:GetForward() * self.Owner:GetShootPos():Distance(trLo.HitPos)
        tracedata.filter = self.Owner
        local trHi =  util.TraceLine(tracedata)

        if !trHi.Hit and trLo.Hit then

            self.Owner:SetPos(self.Owner:GetPos() + Predict)
			if physObj != NULL then
				self.LocalPos = self.Parent:WorldToLocal(self.Owner:GetPos());
			end
            if trLo.MatType == MAT_GLASS then self.Owner:EmitSound(Sound("physics/glass/glass_sheet_step"..math.random(1, 4)..".wav"), 75, math.random(95, 105))
			elseif trLo.MatType and MatList[trLo.MatType] then self.Owner:EmitSound(Sound("player/footsteps/"..MatList[trLo.MatType]..math.random(1, 4)..".wav"), 75, math.random(95, 105)) end

            if self.Owner:KeyDown(IN_MOVELEFT) then self.Owner:ViewPunch(Angle(0, 0, -2.5))
            else self.Owner:ViewPunch(Angle(0, 0, 2.5)) end
            return true

        end

    end

    // Wall Jumping. (In Think due to HUD Implementation)
    if self.Jumps > 0 then

        // Are we actually against a wall?
        local tracedata = { }
        local ShootPos = self.Owner:GetShootPos()
        local AimVector = self.Owner:GetAimVector()
        tracedata.start = ShootPos
        tracedata.endpos = ShootPos - AimVector*45
        tracedata.filter = self.Owner

        local trace = util.TraceLine(tracedata)

        if trace.Hit and !trace.HitSky and !self.Owner:GetNWBool("ClimbWallJump") then

            self.Owner:SetNWBool("ClimbWallJump", true)

        end

    elseif self.Owner:GetNWBool("ClimbWallJump") then self.Owner:SetNWBool("ClimbWallJump", false)
    end

    return true

end
function SWEP:ShakeEffect()
    if self.JumpSequence == 0 then
        self.Owner:ViewPunch(Angle(0, 5, 0))
    elseif self.JumpSequence == 1 then
        self.Owner:ViewPunch(Angle(0, -5, 0))
    elseif self.JumpSequence == 2 then
        self.Owner:ViewPunch(Angle(-5, 0, 0))
    end
    self.JumpSequence = self.JumpSequence < 3 and self.JumpSequence + 1 or 0
end
function SWEP:PrimaryAttack()

    if CLIENT or self.Owner:GetNWBool("ClimbWallRun") then return true end

    // We'll use this trace for determining whether we're looking at a Wall!
    local tracedata = { }
    local ShootPos = self.Owner:GetShootPos()
    local AimVector = self.Owner:GetAimVector()
    tracedata.start = ShootPos
    tracedata.endpos = ShootPos + AimVector*45
    tracedata.filter = self.Owner
    local trace = util.TraceLine(tracedata)

    // We'll have to be off the ground to start climbing!
    if self.Owner:OnGround() then

        // General Melee Functionality

        self:SetNextPrimaryFire(CurTime() + 0.4)

        if !trace.Hit or trace.HitWorld or trace.HitSky then

            self.Owner:EmitSound(Sound("npc/fast_zombie/claw_miss"..math.random(1, 2)..".wav"), 75)
            return false

        end

        if IsValid(trace.Entity) then

            if !trace.Entity:IsWorld() then

                if GetConVarNumber("climbswep2_necksnaps") == 1 and (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) and trace.Entity:GetAimVector():DotProduct(self.Owner:GetAimVector()) > 0.6 then

                    if trace.Entity:IsPlayer() then

                        if GetConVarNumber("sbox_playershurtplayers") <= 0 then return false end
                        trace.Entity:Kill()
                        self.Owner:AddFrags(1)
                        self.Owner:EmitSound(Sound("physics/body/body_medium_break"..math.random(3, 4)..".wav"), 80, math.random(95, 105))
                        return true

                    else

                        trace.Entity:TakeDamage(trace.Entity:Health(), self.Owner, self)
                        self.Owner:AddFrags(1)
                        self.Owner:EmitSound(Sound("physics/body/body_medium_break"..math.random(3, 4)..".wav"), 80, math.random(95, 105))
                        return true

                    end

                    return true

                elseif trace.Entity:IsPlayer() then

                    trace.Entity:ViewPunch(Angle(-25, 20, 0))
					if trace.Entity:GetActiveWeapon().Grab then trace.Entity:GetActiveWeapon().Grab = false end
					
                elseif trace.Entity:IsNPC() then
                    trace.Entity:TakeDamage(10, self.Owner, self)
                end
                if (IsValid(trace.Entity:GetPhysicsObject())) then
                    trace.Entity:GetPhysicsObject():ApplyForceOffset((trace.HitPos-self.Owner:EyePos())*128, trace.HitPos)
                end
                self.Owner:EmitSound(table.Random(HitPlayer), 80, math.random(95, 105))
                return true

            end

        end

        return false

    end

    // Are we grabbing?
    if self.Grab then

        // If so, we'll want to reset our variables!
        self:Forget()

        // Now, run up that wall!
        self.Owner:ViewPunch(Angle(-15, self.Owner:EyeAngles().yaw/32, 0))
        self.Owner:EmitSound(Sound("player/suit_sprint.wav"), 80, math.random(95, 105))
        self.Owner:SetVelocity(-self.Owner:GetVelocity() + Vector(0, 0, 250))
        self:SetNextPrimaryFire(CurTime() + 0.15)
        return true

    end

    // Wall Jumping. (Code in Think due to HUD Implementation)
    if self.Owner:GetNWBool("ClimbWallJump") then

        // We can Wall Jump!
        self.CanWallRun = true;
		self.Jumps = 0
        self.Owner:SetLocalVelocity(self.Owner:GetAimVector() * 300)
        self.Owner:EmitSound(Sound("npc/combine_soldier/gear"..math.random(1, 6)..".wav"), 75, math.random(95, 105))
        self.Owner:ViewPunch(Angle(-7.5, 0, 0))
        return true

    end

    // Are we close enough to start climbing?
    if ( (self.Jumps == 0 and trace.HitPos:Distance(ShootPos) > 40) or self.Jumps > (GetConVarNumber("climbswep2_maxjumps") - 1) or trace.HitSky) then return false end

    // If we've mysteriously lost the wall we'll want to stop climbing!
    if !trace.Hit then return false end

    if self.Owner:GetVelocity().z <= -750 then

        self:SetNextPrimaryFire(CurTime() + 1)
        self.Owner:EmitSound("ambient/levels/canals/toxic_slime_sizzle4.wav", 50, 200)

        if self.MFC == "combine" then self.Owner:EmitSound("npc/metropolice/knockout2.wav", 125)
        else self.Owner:EmitSound("vo/npc/"..self.MFC.."01/ow0"..math.random(1, 2)..".wav", 125) end

        return true

    end

    // Add some effects.
    if trace.MatType == MAT_GLASS then self.Owner:EmitSound(Sound("physics/glass/glass_sheet_step"..math.random(1, 4)..".wav"), 75, math.random(95, 105))
	elseif trace.MatType and MatList[trace.MatType] then self.Owner:EmitSound(Sound("player/footsteps/"..MatList[trace.MatType]..math.random(1, 4)..".wav"), 75, math.random(95, 105))
    else self.Owner:EmitSound(Sound("npc/fast_zombie/claw_miss"..math.random(1, 2)..".wav"), 75, math.random(95, 105)) end

    // Climb the wall and modify our jump count.

    local Vel = self.Owner:GetVelocity()
    self.Owner:SetVelocity(Vector(0, 0, 240 - 15 * 1 + self.JumpSequence - Vel.z))
    self:SetNextPrimaryFire(CurTime() + 0.15)
    self.Jumps = self.Jumps + 1
    self:ShakeEffect()
    return true

end
function SWEP:CanGrab() -- This too, but modified it somewhat.

    // We'll detect whether we can grab onto the ledge.
    local trace = {}
    trace.start = self.Owner:GetShootPos() + Vector( 0, 0, 15 )
    trace.endpos = trace.start + self.Owner:GetAimVector() * 30
    trace.filter = self.Owner

    local trHi = util.TraceLine(trace)

    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = trace.start + self.Owner:GetAimVector() * 30
    trace.filter = self.Owner

    local trLo = util.TraceLine(trace)

    // Is the ledge actually grabbable?
    if trLo and trHi and trLo.Hit and !trHi.Hit then
        return {true, trLo}
    else
        return {false, trLo}
    end

end
function SWEP:SecondaryAttack()

    if CLIENT then return true end

    if !self.Released then return end

    if self.Owner:OnGround() then return false end // We don't want to grab onto a ledge if we're on the ground!

    // If we're already grabbing something, we want to let go!
    if self.Grab then
        self:Forget()
        self.Released = false
        return false
    end

    // Returns whether we can grab(boolean) and a traceres.
    local Grab = self:CanGrab()

    // If we can't grab we're done here.
    if !Grab[1] then 
        return false 
    end

    // Otherwise reset our jumps and enter ledge holding mode!
    self.Jumps = 0
    self.Grab  = true
    self.Released = false
    local VelZ = self.Owner:GetVelocity().z;
	self.Owner:ViewPunch(Angle(math.max(15, math.min(30, VelZ)) * (VelZ > 0 and 1 or -1), 0, 0));
    self.Owner:SetLocalVelocity(Vector(0, 0, 0))
    self.Owner:SetMoveType(MOVETYPE_NONE)
    self.Owner:EmitSound(Sound("physics/flesh/flesh_impact_hard"..math.random(1, 3)..".wav"), 75)
	
    // Are we looking at a valid entity?
    if IsValid(Grab[2].Entity) then

        // Does the prop/entity use valid prop-like behaviour?
        if Grab[2].Entity:GetMoveType() == MOVETYPE_VPHYSICS then

            // Then we can grab onto it!
            self.OldVelocity      = Grab[2].Entity:GetVelocity():Length()
            self.Parent           = Grab[2].Entity
            self.LocalPos      	= Grab[2].Entity:WorldToLocal(self.Owner:GetPos())
        end

    end

    local ClimbSwep = self
	local Ply = self.Owner;
    local Forget = function()
        self:Forget();
		hook.Remove("Think", "ClimbGrab"..Ply:UniqueID())
    end
    local IsOneHanded = function()

        if !IsValid(Ply:GetActiveWeapon()) then return false end

        local Weps = {climb_swep2 = true, weapon_pistol = true, weapon_357 = true, weapon_crowbar = true, weapon_frag = true}
        local HoldTypes = {pistol = true, grenade = true, knife = true}
        local Wep = Ply:GetActiveWeapon()
        if Weps[Wep:GetClass()] then return true
        elseif HoldTypes[Wep.HoldType] then return true end
        return false

    end


    local ThinkFunction = function()

		if !Ply:Alive() then hook.Remove("Think", "ClimbGrab"..Ply:UniqueID());
	    elseif !ClimbSwep.Grab or Ply:GetMoveType() != MOVETYPE_NONE then Forget(); return
        elseif !IsOneHanded() then Forget(); 
            return
        elseif IsValid(ClimbSwep.Parent) then

            if ClimbSwep.Parent:GetPhysicsObject():IsMoveable() then
            
                if math.abs(ClimbSwep.OldVelocity - ClimbSwep.Parent:GetVelocity():Length()) >= 500 then Forget()
                else

                    ClimbSwep.OldVelocity = ClimbSwep.Parent:GetVelocity():Length()
                    Ply:SetLocalVelocity(Vector(0, 0, 0))
                    Ply:SetPos(ClimbSwep.Parent:LocalToWorld(ClimbSwep.LocalPos))
                    return

                end

            end

        end

    end
    hook.Add("Think", "ClimbGrab"..Ply:UniqueID(), ThinkFunction)
    return true

end
function SWEP:DrawHUD()

    if SERVER or GetConVarNumber("climbswep2_showhud") == 0 then return false end

    /*
        We can't make use of the variables the SERVER has indexed.
        Instead we'll make use of Networked Variables, available to both
        the CLIENT and the SERVER.
    */

    local Jumps, MaxJumps = LocalPlayer():GetNWInt("ClimbJumps"), GetConVarNumber("climbswep2_maxjumps")
    local Width, Height = 256, 18


    // Draw Jump-Monitor
    draw.RoundedBox(4, ScrW() / 2 - Width / 2, ScrH() - Height * 2, Width, Height, Color(51, 181, 229, 122))
    if (MaxJumps - Jumps) > 0 then draw.RoundedBox(4, ScrW() / 2 - Width / 2, ScrH() - Height * 2, Width * (MaxJumps - Jumps) / MaxJumps, Height, Color(51, 181, 229, 255)) end
    draw.DrawText("Jumps: "..(MaxJumps - Jumps).." of "..GetConVarNumber("climbswep2_maxjumps"), "Default", ScrW() / 2, ScrH() - 33, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

    // Draw Custom HUD Icons
    if LocalPlayer():GetNWBool("ClimbWallJump") then

        surface.SetDrawColor(Color(51, 181, 229, 255))
        surface.DrawRect(ScrW() / 2 - 8, ScrH() - Height * 2 - 36, 8, 32)
        surface.SetTexture(surface.GetTextureID("gui/arrow.vmt"))
        surface.DrawTexturedRectRotated(ScrW() / 2 + 9, ScrH() - Height * 2 - 22, 30, 30, -60)
        surface.SetDrawColor(Color(255, 255, 255, 255))

    elseif LocalPlayer():GetNWBool("ClimbFalling") then

        surface.SetDrawColor(Color(51, 181, 229, 255))
        surface.DrawRect(ScrW() / 2 - 16, ScrH() - Height * 2 - 12, 32, 8)
        surface.SetTexture(surface.GetTextureID("gui/arrow.vmt"))
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() - Height * 2 - 28, 30, 30, 180)
        surface.SetDrawColor(Color(255, 255, 255, 255))

    end

end