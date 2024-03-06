local minHull = Vector(-16, -16, 0)
local vecScale = Vector(16, 16, 72)

local function doScale()
    local ply = net.ReadEntity()
    if not ply:IsValid() then return end
    local scale = net.ReadFloat()

    vecScale[3] = 72*scale

    ply:SetModelScale(scale, 1)
    ply:SetHull(minHull, vecScale)
end
net.Receive("darkrp_playerscale", doScale)
