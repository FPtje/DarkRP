SWEP.PrintName			= "Chair Thrower"			
SWEP.Author			= "(your name)"
SWEP.Instructions		= "Left mouse to fire a chair!"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
local ShootSound = Sound( "Metal.SawbladeStick" )

--
-- Called when the left mouse button is pressed
--
function SWEP:PrimaryAttack()

	-- This weapon is 'automatic'. This function call below defines
	-- the rate of fire. Here we set it to shoot every 0.5 seconds.
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )	

	-- Call 'ThrowChair' on self with this model
	self:ThrowChair( "models/props/cs_office/Chair_office.mdl" )

end
 

--
-- Called when the rightmouse button is pressed
--
function SWEP:SecondaryAttack()

	-- Note we don't call SetNextSecondaryFire here because it's not
	-- automatic and so we let them fire as fast as they can click.	

	-- Call 'ThrowChair' on self with this model
	self:ThrowChair( "models/props_c17/FurnitureChair001a.mdl" )

end

--
-- A custom function we added. When you call this the player will fire a chair!
--
function SWEP:ThrowChair( model_file )

	-- 
	-- Play the shoot sound we precached earlier!
	--
	self:EmitSound( ShootSound )

 
	--
	-- If we're the client then this is as much as we want to do.
	-- We play the sound above on the client due to prediction.
	-- ( if we didn't they would feel a ping delay during multiplayer )
	--
	if ( CLIENT ) then return end

	--
	-- Create a prop_physics entity
	--
	local ent = ents.Create( "prop_physics" )

	--
	-- Always make sure that created entities are actually created!
	--
	if ( !IsValid( ent ) ) then return end

	--
	-- Set the entity's model to the passed in model
	--
	ent:SetModel( model_file )
 
	--
	-- Set the position to the player's eye position plus 16 units forward.
	-- Set the angles to the player'e eye angles. Then spawn it.
	--
	ent:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 16) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()
 

	--
	-- Now get the physics object. Whenever we get a physics object
	-- we need to test to make sure its valid before using it.
	-- If it isn't then we'll remove the entity.
	--
	local phys = ent:GetPhysicsObject()
	if ( !IsValid( phys ) ) then ent:Remove() return end
 
 
	--
	-- Now we apply the force - so the chair actually throws instead 
	-- of just falling to the ground. You can play with this value here
	-- to adjust how fast we throw it.
	--
	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 100 
	velocity = velocity + (VectorRand() * 10) -- a random element
	phys:ApplyForceCenter( velocity )
 
	--
	-- Assuming we're playing in Sandbox mode we want to add this
	-- entity to the cleanup and undo lists. This is done like so.
	--
	cleanup.Add( self.Owner, "props", ent )
 
	undo.Create( "Thrown_Chair" )
		undo.AddEntity( ent )
		undo.SetPlayer( self.Owner )
	undo.Finish()
end
