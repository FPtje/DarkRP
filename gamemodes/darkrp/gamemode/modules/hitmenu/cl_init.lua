local localplayer
local hudText
local textCol1, textCol2 = Color(0, 0, 0, 200), Color(128, 30, 30, 255)
local plyMeta = FindMetaTable("Player")
local activeHitmen = {}
local postPlayerDraw
local minHitDistanceSqr = GM.Config.minHitDistance * GM.Config.minHitDistance

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function plyMeta:drawHitInfo()
    activeHitmen[self] = true

    hook.Add("PostPlayerDraw", "drawHitInfo", postPlayerDraw)
end

function plyMeta:stopHitInfo()
    activeHitmen[self] = nil
    if table.IsEmpty(activeHitmen) then
        hook.Remove("PostPlayerDraw", "drawHitInfo")
    end
end

--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
function DarkRP.hooks:onHitAccepted(hitman, target, customer)
    if not IsValid(hitman) then return end
    hitman:drawHitInfo()
end

function DarkRP.hooks:onHitCompleted(hitman, target, customer)
    if not IsValid(hitman) then return end
    hitman:stopHitInfo()
end

function DarkRP.hooks:onHitFailed(hitman, target, reason)
    if not IsValid(hitman) then return end
    hitman:stopHitInfo()
end

hook.Add("EntityRemoved", "hitmenu", function(ent)
    activeHitmen[ent] = nil
end)

hook.Add("HUDPaint", "DrawHitOption", function()
    localplayer = localplayer or LocalPlayer()
    hudText = hudText or GAMEMODE.Config.hudText
    local x, y
    local ply = localplayer:GetEyeTrace().Entity

    if IsValid(ply) and ply:IsPlayer() and ply:isHitman() and not ply:hasHit() and localplayer:GetPos():DistToSqr(ply:GetPos()) < minHitDistanceSqr then
        x, y = ScrW() / 2, ScrH() / 2 + 30

        draw.DrawNonParsedText(hudText, "Roboto20", x + 1, y + 1, textCol1, 1)
        draw.DrawNonParsedText(hudText, "Roboto20", x, y, textCol2, 1)
    end

    if localplayer:isHitman() and localplayer:hasHit() and IsValid(localplayer:getHitTarget()) then
        x, y = chat.GetChatBoxPos()
        local text = DarkRP.getPhrase("current_hit", localplayer:getHitTarget():Nick())
        draw.DrawNonParsedText(text, "HUDNumber5", x + 1, y + 1, textCol1, 0)
        draw.DrawNonParsedText(text, "HUDNumber5", x, y, textCol2, 0)
    end
end)

local lastKeyPress = 0
hook.Add("KeyPress", "openHitMenu", function(ply, key)
    if key ~= IN_USE or lastKeyPress > CurTime() - 0.2 then return end
    lastKeyPress = CurTime()
    localplayer = localplayer or LocalPlayer()
    local hitman = localplayer:GetEyeTrace().Entity

    if not IsValid(hitman) or not hitman:IsPlayer() or not hitman:isHitman() or localplayer:GetPos():DistToSqr(hitman:GetPos()) > minHitDistanceSqr then return end

    local canRequest, message = hook.Call("canRequestHit", DarkRP.hooks, hitman, ply, nil, hitman:getHitPrice())

    if not canRequest then
        GAMEMODE:AddNotify(DarkRP.getPhrase("cannot_request_hit", message or ""), 1, 4)
        surface.PlaySound("buttons/lightswitch2.wav")
        return
    end

    DarkRP.openHitMenu(hitman)
end)

hook.Add("InitPostEntity", "HitmanMenu", function()
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v:isHitman() and v:hasHit() then
            v:drawHitInfo()
        end
    end
end)

function postPlayerDraw(ply)
    if not activeHitmen[ply] then return end
    local pos, ang = ply:GetShootPos(), ply:EyeAngles()
    ang.p = 0
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(pos, ang, 0.3)
        draw.DrawNonParsedText(GAMEMODE.Config.hitmanText, "Roboto20", 1, -100, textCol1, 1)
        draw.DrawNonParsedText(GAMEMODE.Config.hitmanText, "Roboto20", 0, -101, textCol2, 1)
    cam.End3D2D()
end

--[[---------------------------------------------------------------------------
Networking
---------------------------------------------------------------------------]]
net.Receive("onHitAccepted", function(len)
    hook.Call("onHitAccepted", DarkRP.hooks, net.ReadEntity(), net.ReadEntity(), net.ReadEntity())
end)

net.Receive("onHitCompleted", function(len)
    hook.Call("onHitCompleted", DarkRP.hooks, net.ReadEntity(), net.ReadEntity(), net.ReadEntity())
end)

net.Receive("onHitFailed", function(len)
    hook.Call("onHitFailed", DarkRP.hooks, net.ReadEntity(), net.ReadEntity(), net.ReadString())
end)
