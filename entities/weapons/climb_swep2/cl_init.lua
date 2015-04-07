include("shared.lua")

CreateClientConVar("climbswep2_showhud", 1, true, false)
SWEP.PrintName       = "Climb SWEP 2"
SWEP.Slot             = 0
SWEP.SlotPos         = 4
SWEP.DrawAmmo         = false
SWEP.DrawCrosshair     = false

local flags = {FCVAR_REPLICATED, FCVAR_ARCHIVE};
CreateConVar("climbswep2_necksnaps", "0", flags);
CreateConVar("climbswep2_wallrun_minheight", "250", flags);
CreateConVar("climbswep2_roll_allweps", "0", flags);
CreateConVar("climbswep2_slide_allweps", "0", flags);
CreateConVar("climbswep2_maxjumps", "3", flags);



if CLIENT then
CreateClientConVar("climbswep2_windsound", 1, true, false)
CreateClientConVar("climbswep2_falleffect_allweps", 0, true, false)
local PrevCurT = 0
local CurAngles = nil
local Rot = 0
local Random
local Snd
local Snd2
hook.Add("CreateMove", "ClimbFall", function(cmd)

    local Ply = LocalPlayer()
	if !Snd then

        Snd = CreateSound(Ply, Sound("player/heartbeat1.wav"))
        Snd:Play()
        Snd:ChangeVolume(0, 0)
        Snd:ChangePitch(100, 0)

        Snd2 = CreateSound(Ply, Sound("ambient/ambience/Wind_Light02_loop.wav"))
        Snd2:Play()
        Snd2:ChangeVolume(0, 0)

    end
    if !IsValid(Ply) or !IsValid(Ply:GetActiveWeapon()) then return
    elseif Ply:GetVelocity().z > -900 or (GetConVarNumber("climbswep2_falleffect_allweps") == 0 and Ply:GetActiveWeapon():GetClass() != "climb_swep2") or !Ply:Alive() or Ply:GetMoveType() != MOVETYPE_WALK then

        if PrevCurT > 0 then

            cmd:SetViewAngles(Angle(CurAngles.p, CurAngles.y, 0))
            CurAngles = nil
            Snd:ChangeVolume(0, 0)
            Snd:ChangePitch(100, 0)
            Snd2:ChangeVolume(0, 0)
			hook.Remove("RenderScreenspaceEffects", "ClimbFallBlur")
			PrevCurT = 0

        end		
        return

    end
    if PrevCurT == 0 then

        PrevCurT = CurTime()
        local function DrawEffect()
            --DrawMotionBlur(0.1, Time/5, 0.01)
            local Time = CurTime() - PrevCurT
            local Colour = {}
            Colour[ "$pp_colour_addr" ] = 0
            Colour[ "$pp_colour_addg" ] = 0
            Colour[ "$pp_colour_addb" ] = 0
            Colour[ "$pp_colour_brightness" ] = 0
            Colour[ "$pp_colour_contrast" ] = (1 - Time/7.5)
            Colour[ "$pp_colour_colour" ] = (1 - Time/7.5)
            Colour[ "$pp_colour_mulr" ] = 0
            Colour[ "$pp_colour_mulg" ] = 0
            Colour[ "$pp_colour_mulb" ] = 0
            DrawColorModify(Colour)
            DrawMotionBlur(math.Clamp(0.75-Time/100, 0.25, 1), math.Clamp(Time/10, 0, 0.75), 0.05)

        end
        hook.Add("RenderScreenspaceEffects", "ClimbFallBlur", DrawEffect)

    end

    if !IsValid(CurAngles) then CurAngles = cmd:GetViewAngles(); end
	

	
    local Time = (CurTime() - PrevCurT) * (8 + (CurTime() - PrevCurT) * 2)
    if Time/25 < 1 then Snd:ChangeVolume(math.Clamp(Time/25, 0, 1), 0) end
    if Time < 101 then Snd:ChangePitch(100 + Time, 0); if GetConVarNumber("climbswep2_windsound") == 1 then Snd2:ChangeVolume(Time/100, 0) else Snd2:ChangeVolume(0, 0) end end

    CurAngles.p = math.Round(CurAngles.p) < 75 and math.Round(CurAngles.p) + 0.5 or math.Round(CurAngles.p) - 0.5

    cmd:SetViewAngles(Angle(CurAngles.p, CurAngles.y + math.sin(Time) * 1.25, 0))

end)

local curPitch = 0
local deg = 0
local inRoll = false

local function rollTo()

	deg = net.ReadInt(16)
	inRoll = true
	curPitch = deg-360

end
net.Receive("ClimbRoll", rollTo)

hook.Add("CalcView", "ClimbRollEffect", function(ply, pos, ang, fov)
	
	if (!inRoll) then return; end
	
	local view = GAMEMODE:CalcView(ply, pos, ang, fov)
	curPitch = math.Approach(curPitch, deg, FrameTime() * 625)
	if curPitch == deg then inRoll = false; end
	view.angles.p = curPitch
	return view
	
end)


end