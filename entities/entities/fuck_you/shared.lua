resource.AddFile("sound/kiss_my_ass.wav");

AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true

local FuckYouSound = Sound("kiss_my_ass.wav")

function ENT:Initialize()

	self:SetModel( "models/Humans/Group01/male_02.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	self.SearchRadius 	= 1000	-- How far to search for enemies
	self.FuckYouTime = CurTime()
end

----------------------------------------------------
-- ENT:Get/SetEnemy()
-- Simple functions used in keeping our enemy saved
----------------------------------------------------
function ENT:SetEnemy( ent )
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end

----------------------------------------------------
-- ENT:HaveEnemy()
-- Returns true if we have a enemy
----------------------------------------------------
function ENT:HaveEnemy()
	-- If our current enemy is valid
	if ( self:GetEnemy() and IsValid( self:GetEnemy() ) ) then
		return true
	end
end

----------------------------------------------------
-- ENT:RunBehaviour()
-- This is where the meat of our AI is
----------------------------------------------------
function ENT:RunBehaviour()
	-- This function is called when the entity is first spawned. It acts as a giant loop that will run as long as the NPC exists
	while ( true ) do
		-- Lets use the above mentioned functions to see if we have/can find a enemy
		if ( self:HaveEnemy() ) then
			-- Now that we have an enemy, the code in this block will run
			self.loco:FaceTowards( self:GetEnemy():GetPos() )	-- Face our enemy
			self:StartActivity( ACT_WALK )			-- Set the animation
			self.loco:SetDesiredSpeed( 450 )		-- Set the speed that we will be moving at. Don't worry, the animation will speed up/slow down to match
			self.loco:SetAcceleration( 900 )			-- We are going to run at the enemy quickly, so we want to accelerate really fast
			self:ChaseEnemy(	) 						-- The new function like MoveToPos.
			self.loco:SetAcceleration( 400 )			-- Set this back to its default since we are done chasing the enemy
			self:PlaySequenceAndWait( "fear_reaction" )	-- Lets play a fancy animation when we stop moving
			self:StartActivity( ACT_IDLE )			--We are done so go back to idle
			-- Now once the above function is finished doing what it needs to do, the code will loop back to the start
			-- unless you put stuff after the if statement. Then that will be run before it loops
		else
			-- Since we can't find an enemy, lets wander
			-- Its the same code used in Garry's test bot
			self:StartActivity( ACT_WALK )			-- Walk anmimation
			self.loco:SetDesiredSpeed( 200 )		-- Walk speed
			self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400 ) -- Walk to a random place within about 400 units ( yielding )
			self:StartActivity( ACT_IDLE )
		end
		-- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
		-- Using this next function we are going to wait 2 seconds until we go ahead and repeat it
		coroutine.wait( 2 )

	end

end

function ENT:FuckYou()
	if(CurTime() - self.FuckYouTime > 2) then
		self:EmitSound(FuckYouSound)
		self.FuckYouTime = CurTime()
		self:GetEnemy():PrintMessage(HUD_PRINTTALK,"FUCK YOU")
		end
end

----------------------------------------------------
-- ENT:ChaseEnemy()
-- Works similarly to Garry's MoveToPos function
-- except it will constantly follow the
-- position of the enemy until there no longer
-- is one.
----------------------------------------------------
function ENT:ChaseEnemy( options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemies position

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:HaveEnemy() ) do
		if(path:GetLength() < 50) then
			self:FuckYou()
		end
		if ( path:GetAge() > 0.1 ) then					-- Since we are following the player we have to constantly remake the path
			path:Compute( self, self:GetEnemy():GetPos() )-- Compute the path towards the enemy's position again
		end
		path:Update( self )								-- This function moves the bot along the path

		if ( options.draw ) then path:Draw() end
		-- If we're stuck, then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"

end

list.Set( "NPC", "fuck_you", {
	Name = "FUCK YOU",
	Class = "fuck_you",
	Category = "FUCK YOU"
} )