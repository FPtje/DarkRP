local function doScale()
    local ply = net.ReadEntity()
    local scale = net.ReadFloat()

    if not IsValid(ply) then return end
    ply:SetModelScale(scale, 1)
    ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72 * scale))
end
net.Receive('darkrp_playerscale', doScale)