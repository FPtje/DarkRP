AddCSLuaFile();

if CLIENT then
	SWEP.PrintName = "Slow down gun"
	SWEP.Author = "Dannelor"
	SWEP.Slot = 5
	SWEP.SlotPos = 0
end

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "fprp (Utility)"
 
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo	= "none"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo	= "none"

SWEP.Weight = 0
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "slam"

SWEP.Primary.Sound = "ambient/alarms/siren.wav"


function SWEP:Precache() 
	util.PrecacheSound(self.Primtery.Sound);
end

function SWEP:Think()
	if CLIENT || !IsValid(self.Owner) then return end
	local head = self.Owner:LookupBone("ValveBiped.Bip01_Head1");
	if self.Owner:KeyDown(IN_ATTACK) then
			self:EmitSound(Sound(self.Primary.Sound));
			game.SetTimeScale(0.1);
			self.Owner:ManipulateBoneScale( head, Vector(5,5,5) );
	elseif self.Owner:KeyReleased(IN_ATTACK) then
		game.SetTimeScale(1);
		self.Owner:ManipulateBoneScale( head, Vector(1,1,1) );
	end
end