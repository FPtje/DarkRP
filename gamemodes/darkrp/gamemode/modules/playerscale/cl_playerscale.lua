local function doScale(um)
    local ply = um:ReadEntity()
    local scale = um:ReadFloat()

    if not IsValid(ply) then return end
    ply:SetModelScale(scale, 1)
    ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72 * scale))
end
usermessage.Hook("darkrp_playerscale", doScale)
