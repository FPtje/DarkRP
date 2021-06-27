FPP = FPP or {}

surface.CreateFont("TabLarge", {
    size = 17,
    weight = 700,
    antialias = true,
    shadow = false,
    font = "Trebuchet MS"})

hook.Add("CanTool", "FPP_CL_CanTool", function(ply, trace, tool) -- Prevent client from SEEING his toolgun shoot while it doesn't shoot serverside.
    if IsValid(trace.Entity) and not FPP.canTouchEnt(trace.Entity, "Toolgun") then
        return false
    end
end)

-- This looks weird, but whenever a client touches an ent he can't touch, without the code it'll look like he picked it up. WITH the code it really looks like he can't
-- besides, when the client CAN pick up a prop, it also looks like he can.
hook.Add("PhysgunPickup", "FPP_CL_PhysgunPickup", function(ply, ent)
    if not FPP.canTouchEnt(ent, "Physgun") then
        return false
    end
end)

-- Makes sure the client doesn't think they can punt props
hook.Add("GravGunPunt", "FPP_CL_GravGunPunt", function(ply, ent)
    if tobool(FPP.Settings.FPP_GRAVGUN1.noshooting) then return false end
    if IsValid(ent) and not FPP.canTouchEnt(ent, "Gravgun") then
        return false
    end
end)

local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetDrawColor = surface.SetDrawColor

local draw_SimpleText = draw.SimpleText
local draw_DrawText = draw.DrawText
local draw_RoundedBox = draw.RoundedBox

local HUDNote_c = 0
local HUDNote_i = 1
local HUDNotes = {}

--Notify ripped off the Sandbox notify, changed to my likings
function FPP.AddNotify( str, type )
    local tab = {}
    tab.text    = str
    tab.recv    = SysTime()
    tab.velx    = 0
    tab.vely    = -5
    surface_SetFont( "TabLarge" )
    local w = surface_GetTextSize( str )

    tab.x       = ScrW() / 2 + w * 0.5 + (ScrW() / 20)
    tab.y       = ScrH()
    tab.a       = 255

    if type then
        tab.type = true
    else
        tab.type = false
    end

    table.insert( HUDNotes, tab )

    HUDNote_c = HUDNote_c + 1
    HUDNote_i = HUDNote_i + 1

    local ply = LocalPlayer()

    if not IsValid(ply) then return end -- I honestly got this error
    ply:EmitSound("npc/turret_floor/click1.wav", 10, 100)
end

usermessage.Hook("FPP_Notify", function(u) FPP.AddNotify(u:ReadString(), u:ReadBool()) end)

local function DrawNotice(k, v, i)

    local H = ScrH() / 1024
    local x = v.x - 75 * H
    local y = v.y - 20 * H - 2

    surface_SetFont( "TabLarge" )
    local w, h = surface_GetTextSize( v.text )

    w = w
    h = h + 10

    if v.type then
        draw_RoundedBox(4, x - w - h + 16, y - 8, w + h, h, Color(30, 100, 30, v.a * 0.4))
    else
        draw_RoundedBox(4, x - w - h + 16, y - 8, w + h, h, Color(100, 30, 30, v.a * 0.4))
    end

    -- Draw Icon

    surface_SetDrawColor( 255, 255, 255, v.a )

    draw_SimpleText(v.text, "TabLarge", x + 1, y + 1, Color(0, 0, 0, v.a * 0.8), TEXT_ALIGN_RIGHT)
    draw_SimpleText(v.text, "TabLarge", x - 1, y - 1, Color(0, 0, 0, v.a * 0.5), TEXT_ALIGN_RIGHT)
    draw_SimpleText(v.text, "TabLarge", x + 1, y - 1, Color(0, 0, 0, v.a * 0.6), TEXT_ALIGN_RIGHT)
    draw_SimpleText(v.text, "TabLarge", x - 1, y + 1, Color(0, 0, 0, v.a * 0.6), TEXT_ALIGN_RIGHT)
    draw_SimpleText(v.text, "TabLarge", x, y, Color(255, 255, 255, v.a), TEXT_ALIGN_RIGHT)

    local ideal_y = ScrH() - (HUDNote_c - i) * h
    local ideal_x = ScrW() / 2 + w * 0.5 + (ScrW() / 20)
    local timeleft = 6 - (SysTime() - v.recv)

    -- Cartoon style about to go thing
    if (timeleft < 0.8) then
        ideal_x = ScrW() / 2 + w * 0.5 + 200
    end

    -- Gone!
    if (timeleft < 0.5) then
        ideal_y = ScrH() + 50
    end

    local spd = RealFrameTime() * 15
    v.y = v.y + v.vely * spd
    v.x = v.x + v.velx * spd
    local dist = ideal_y - v.y
    v.vely = v.vely + dist * spd * 1

    if (math.abs(dist) < 2 and math.abs(v.vely) < 0.1) then
        v.vely = 0
    end

    dist = ideal_x - v.x
    v.velx = v.velx + dist * spd * 1

    if math.abs(dist) < 2 and math.abs(v.velx) < 0.1 then
        v.velx = 0
    end

    -- Friction.. kind of FPS independant.
    v.velx = v.velx * (0.95 - RealFrameTime() * 8)
    v.vely = v.vely * (0.95 - RealFrameTime() * 8)
end

local weaponClassTouchTypes = {
    ["weapon_physgun"] = "Physgun",
    ["weapon_physcannon"] = "Gravgun",
    ["gmod_tool"] = "Toolgun",
}

local function FilterEntityTable(t)
    local filtered = {}

    for i, ent in ipairs(t) do
        if (not ent:IsWeapon()) and (not ent:IsPlayer()) then table.insert(filtered, ent) end
    end

    return filtered
end

local boxBackground = Color(0, 0, 0, 110)
local canTouchTextColor = Color(0, 255, 0, 255)
local cannotTouchTextColor = Color(255, 0, 0, 255)
local function HUDPaint()
    local i = 0
    for k, v in pairs(HUDNotes) do
        if v ~= 0 then
            i = i + 1
            DrawNotice(k, v, i)
        end
    end

    for k, v in pairs(HUDNotes) do
        if v ~= 0 and v.recv + 6 < SysTime() then
            HUDNotes[ k ] = 0
            HUDNote_c = HUDNote_c - 1
            if (HUDNote_c == 0) then HUDNotes = {} end
        end
    end

    if FPP.getPrivateSetting("HideOwner") then return end

    --Show the owner:
    local ply = LocalPlayer()

    local LAEnt2 = ents.FindAlongRay(ply:EyePos(), ply:EyePos() + EyeAngles():Forward() * 16384)

    local LAEnt = FilterEntityTable(LAEnt2)[1]
    if not IsValid(LAEnt) then return end
    -- Prevent being able to see ownership through walls
    local eyeTrace = ply:GetEyeTrace()
    -- GetEyeTrace can return nil before InitPostEntity
    if eyeTrace == nil then return end
    if eyeTrace.HitPos:DistToSqr(eyeTrace.StartPos) < LAEnt:NearestPoint(eyeTrace.StartPos):DistToSqr(eyeTrace.StartPos) then return end

    local weapon = ply:GetActiveWeapon()
    local class = weapon:IsValid() and weapon:GetClass() or ""

    local touchType = weaponClassTouchTypes[class] or "EntityDamage"
    local reason = FPP.entGetTouchReason(LAEnt, touchType)
    if not reason then return end
    local originalOwner = LAEnt:GetNW2String("FPP_OriginalOwner")
    originalOwner = originalOwner ~= "" and (" (previous owner: %s)"):format(originalOwner) or ""
    reason = reason .. originalOwner

    surface_SetFont("Default")
    local w,h = surface_GetTextSize(reason)
    local col = FPP.canTouchEnt(LAEnt, touchType) and canTouchTextColor or cannotTouchTextColor
    local scrH = ScrH()

    draw_RoundedBox(4, 0, scrH / 2 - h - 2, w + 10, 20, boxBackground)
    draw_DrawText(reason, "Default", 5, scrH / 2 - h, col, 0)
    surface_SetDrawColor(255, 255, 255, 255)
end
hook.Add("HUDPaint", "FPP_HUDPaint", HUDPaint)
