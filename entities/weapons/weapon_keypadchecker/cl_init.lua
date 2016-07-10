include("shared.lua")

local DrawData = {}
local KeypadCheckerHalos

net.Receive("DarkRP_keypadData", function(len)
    DrawData = net.ReadTable()
    hook.Add("PreDrawHalos", "KeypadCheckerHalos", KeypadCheckerHalos)
end)

local lineMat = Material("cable/chain")

function SWEP:DrawHUD()
    draw.WordBox(2, 10, ScrH() / 2, DarkRP.getPhrase("keypad_checker_shoot_keypad"), "UiBold", Color(0,0,0,120), Color(255, 255, 255, 255))
    draw.WordBox(2, 10, ScrH() / 2 + 20, DarkRP.getPhrase("keypad_checker_shoot_entity"), "UiBold", Color(0,0,0,120), Color(255, 255, 255, 255))
    draw.WordBox(2, 10, ScrH() / 2 + 40, DarkRP.getPhrase("keypad_checker_click_to_clear"), "UiBold", Color(0,0,0,120), Color(255, 255, 255, 255))

    local entMessages = {}
    for k,v in pairs(DrawData or {}) do
        if not IsValid(v.ent) or not IsValid(v.original) then continue end
        entMessages[v.ent] = (entMessages[v.ent] or 0) + 1
        local pos = v.ent:LocalToWorld(v.ent:OBBCenter()):ToScreen()

        local name = v.name and ": " .. v.name:gsub("onDown", DarkRP.getPhrase("keypad_on")):gsub("onUp", DarkRP.getPhrase("keypad_off")) or ""

        draw.WordBox(2, pos.x, pos.y + entMessages[v.ent] * 16, (v.delay and v.delay .. " " .. DarkRP.getPhrase("seconds") .. " " or "") .. v.type .. name, "UiBold", Color(0,0,0,120), Color(255, 255, 255, 255))

        cam.Start3D(EyePos(), EyeAngles())
            render.SetMaterial(lineMat)
            render.DrawBeam(v.original:GetPos(), v.ent:GetPos(), 2, 0.01, 20, Color(0, 255, 0, 255))
        cam.End3D()
    end
end

KeypadCheckerHalos = function()
    local drawEnts = {}
    for k,v in pairs(DrawData) do
        if not IsValid(v.ent) then continue end

        table.insert(drawEnts, v.ent)
    end

    if #drawEnts == 0 then return end
    halo.Add(drawEnts, Color(0, 255, 0, 255), 5, 5, 5, nil, true)
end

function SWEP:SecondaryAttack()
    DrawData = {}
    hook.Remove("PreDrawHalos", "KeypadCheckerHalos")
end
