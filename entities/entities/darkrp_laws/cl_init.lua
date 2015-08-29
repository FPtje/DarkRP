include("shared.lua")

local Laws = {}

function ENT:Draw()
    self:DrawModel()

    local DrawPos = self:LocalToWorld(Vector(1, -111, 58))

    local DrawAngles = self:GetAngles()
    DrawAngles:RotateAroundAxis(self:GetAngles():Forward(), 90)
    DrawAngles:RotateAroundAxis(self:GetAngles():Up(), 90)

    cam.Start3D2D(DrawPos, DrawAngles, 0.4)

        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, 558, 290)

        draw.RoundedBox(4, 0, 0, 558, 30, Color(0, 0, 70, 200))

        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("laws_of_the_land"), "TargetID", 279, 5, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)

        local col = Color(255, 255, 255, 255)
        local lastHeight = 0
        for k,v in ipairs(Laws) do
            draw.DrawNonParsedText(string.format("%u. %s", k, v), "TargetID", 5, 35 + lastHeight, col)
            lastHeight = lastHeight + ((fn.ReverseArgs(string.gsub(v, "\n", ""))) + 1) * 21
        end

    cam.End3D2D()
end

local function addLaw(inLaw)
    local law = DarkRP.textWrap(inLaw, "TargetID", 522)

    Laws[#Laws + 1] = law
end

local function umAddLaw(um)
    local law = um:ReadString()
    timer.Simple(0, fn.Curry(addLaw, 2)(law))
    hook.Run("addLaw", #Laws + 1, law)
end
usermessage.Hook("DRP_AddLaw", umAddLaw)

local function umRemoveLaw(um)
    local i = um:ReadShort()

    hook.Run("removeLaw", i, Laws[i])

    while i < #Laws do
        Laws[i] = Laws[i + 1]
        i = i + 1
    end
    Laws[i] = nil
end
usermessage.Hook("DRP_RemoveLaw", umRemoveLaw)

local function umResetLaws(um)
    Laws = {}
    fn.Foldl(function(val,v) addLaw(v) end, nil, GAMEMODE.Config.DefaultLaws)
    hook.Run("resetLaws")
end
usermessage.Hook("DRP_ResetLaws", umResetLaws)

function DarkRP.getLaws()
    return Laws
end

timer.Simple(0, function()
    fn.Foldl(function(val,v) addLaw(v) end, nil, GAMEMODE.Config.DefaultLaws)
end)
