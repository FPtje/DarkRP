local function setScale(ply, scale)
	ply:SetModelScale(scale, 0)

	ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 64 * scale))
	umsg.Start("darkrp_playerscale")
		umsg.Entity(ply)
		umsg.Float(scale)
	umsg.End()
end

local function onLoadout(ply)
	if not RPExtraTeams[ply:Team()] or not tonumber(RPExtraTeams[ply:Team()].modelScale) then
		setScale(ply, 1)
		return
	end

	local modelScale = tonumber(RPExtraTeams[ply:Team()].modelScale)

	setScale(ply, modelScale)
end
hook.Add("PlayerLoadout", "playerScale", onLoadout)