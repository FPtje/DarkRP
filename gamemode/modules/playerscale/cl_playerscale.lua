local function doScale()
	local ply = net.ReadEntity()
	
	if not IsValid(ply) then return end
	
	local scale = net.ReadFloat()
	
	ply:SetModelScale(scale, 1)
	ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72 * scale))
end
net.Receive("darkrp_playerscale", doScale)
