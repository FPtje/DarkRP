AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo    = false
SWEP.AutoSwitchFrom    = false

util.AddNetworkString("ClimbRoll")
local flags = {FCVAR_REPLICATED, FCVAR_ARCHIVE}
CreateConVar("climbswep2_necksnaps", "0", flags)
CreateConVar("climbswep2_wallrun_minheight", "250", flags)
CreateConVar("climbswep2_roll_allweps", "0", flags)
CreateConVar("climbswep2_slide_allweps", "0", flags)
CreateConVar("climbswep2_maxjumps", "3", flags)

local function GetWeaponClass(ply)
    if !IsValid(ply) or !IsValid(ply:GetActiveWeapon()) then return "" end
    return ply:GetActiveWeapon():GetClass()
end
hook.Add("OnPlayerHitGround", "ClimbRoll", function(ply, inWater, idc, fallSpeed)
    if !IsValid(ply) or ply:Health() <= 0 then return end
	if (GetWeaponClass(ply) == "climb_swep2" or GetConVarNumber("climbswep2_roll_allweps") > 0) and !ply:GetNWBool("ClimbFalling") and !inWater and fallSpeed > 300 and ply:Crouching() then
	
		net.Start("ClimbRoll")
		net.WriteInt(math.Round(ply:EyeAngles().p), 16)
		net.Send(ply)
		ply:EmitSound("physics/cardboard/cardboard_box_break1.wav", 100, 100)
		ply:SetVelocity(ply:GetVelocity() + ply:GetForward() *  (100 + fallSpeed))
	
	end

end)
hook.Add("PlayerSpawn", "ClimbPlayerSpawn", function(ply)
    ply.ClimbLastVel = Vector(0, 0, 0)
	ply:SetNWBool("ClimbSlide", false)
	ply.ClimbSlideSound = CreateSound(ply, Sound("physics/body/body_medium_scrape_smooth_loop1.wav"))
end)
hook.Add("Think", "ClimbSlide", function()
    local players = player.GetAll()
    for k, ply in pairs(players) do
        if IsValid(ply) and ply:Alive() then
            if !ply:Crouching() then
                ply.ClimbLastVel = ply:GetVelocity()
            elseif ply:OnGround() then
                ply.ClimbLastVel = ply.ClimbLastVel * 0.99
            end
            if (GetWeaponClass(ply) == "climb_swep2" or GetConVarNumber("climbswep2_slide_allweps") > 0) and ply:OnGround() and ply:Crouching() and math.abs(ply.ClimbLastVel:Length()) > 300 and ply.ClimbLastVel.z > -10 then
                ply:SetNWBool("ClimbSlide", true)
                ply.ClimbSlideSound:Play()
                ply.ClimbSlideSound:ChangeVolume(0.5, 0)		
            elseif !ply:OnGround() or !ply:Crouching() then 
                ply:SetNWBool("ClimbSlide", false) 
                ply.ClimbSlideSound:Stop()
            end
            if ply:GetNWBool("ClimbSlide") then
                ply:SetLocalVelocity(ply.ClimbLastVel)	
                ply.ClimbSlideSound:ChangeVolume(0.5 * ply.ClimbLastVel:Length() / 100, 0)					
                ply.ClimbSlideSound:ChangePitch(math.Clamp(ply.ClimbLastVel:Length() * 0.5, 75, 125), 0)
                if math.abs(ply.ClimbLastVel:Length()) < 50 then
                    ply:SetNWBool("ClimbSlide", false)
                    ply.ClimbSlideSound:Stop()
                end
            end
        elseif ply.ClimbSlideSound:IsPlaying() then
            ply.ClimbSlideSound:Stop()
        end
    end
end)

hook.Add("GetFallDamage", "ClimbRollPD", function(ply, fallSpeed)
	if ply:GetNWBool("ClimbFalling") then	
		sound.Play("physics/body/body_medium_break"..math.random(2, 4)..".wav", ply:GetPos())
		ply:SetNWBool("ClimbFalling", false)
	elseif fallSpeed < 900 and ply:Crouching() and (ply:GetActiveWeapon():GetClass() == "climb_swep2" or GetConVarNumber("climbswep2_roll_allweps") > 0) then
		return 0
	end

end)