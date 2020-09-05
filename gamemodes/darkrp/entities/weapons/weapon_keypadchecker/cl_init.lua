include("shared.lua")

local DrawData = {}
local KeypadCheckerHalos

net.Receive("DarkRP_keypadData", function(len)
    DrawData = net.ReadTable()
    hook.Add("PreDrawHalos", "KeypadCheckerHalos", KeypadCheckerHalos)
end)

local lineMat = Material("cable/chain")
local textCol = Color(0, 0, 0, 120)
local haloCol = Color(0, 255, 0, 255)

function SWEP:DrawHUD()
    local screenCenter = ScrH() / 2
    draw.WordBox(2, 10, screenCenter, DarkRP.getPhrase("keypad_checker_shoot_keypad"), "UiBold", textCol, color_white)
    draw.WordBox(2, 10, screenCenter + 20, DarkRP.getPhrase("keypad_checker_shoot_entity"), "UiBold", textCol, color_white)
    draw.WordBox(2, 10, screenCenter + 40, DarkRP.getPhrase("keypad_checker_click_to_clear"), "UiBold", textCol, color_white)

    local eyePos = EyePos()
    local eyeAngles = EyeAngles()

    local entMessages = {}
    for k,v in ipairs(DrawData or {}) do
        if not IsValid(v.ent) or not IsValid(v.original) then continue end
        entMessages[v.ent] = (entMessages[v.ent] or 0) + 1
        local obbCenter = v.ent:OBBCenter()
        local pos = v.ent:LocalToWorld(obbCenter):ToScreen()

        local name = v.name and ": " .. v.name:gsub("onDown", DarkRP.getPhrase("keypad_on")):gsub("onUp", DarkRP.getPhrase("keypad_off")) or ""

        draw.WordBox(2, pos.x, pos.y + entMessages[v.ent] * 16, (v.delay and v.delay .. " " .. DarkRP.getPhrase("seconds") .. " " or "") .. v.type .. name, "UiBold", textCol, color_white)

        cam.Start3D(eyePos, eyeAngles)
            render.SetMaterial(lineMat)
            render.DrawBeam(v.original:GetPos(), v.ent:GetPos(), 2, 0.01, 20, haloCol)
        cam.End3D()
    end
end

KeypadCheckerHalos = function()
    local drawEnts = {}
    local i = 1
    for k,v in ipairs(DrawData) do
        if not IsValid(v.ent) then continue end

        drawEnts[i] = v.ent
        i = i + 1
    end

    if table.IsEmpty(drawEnts) then return end
    halo.Add(drawEnts, haloCol, 5, 5, 5, nil, true)
end

function SWEP:SecondaryAttack()
    DrawData = {}
    hook.Remove("PreDrawHalos", "KeypadCheckerHalos")
end
