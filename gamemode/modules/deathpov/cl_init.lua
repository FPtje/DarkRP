hook.Add("CalcView", "rp_deathPOV", function(ply, origin, angles, fov)
	if not GAMEMODE.Config.deathpov or ply:Alive() then return end

	local Ragdoll = ply:GetRagdollEntity()
	if not IsValid(Ragdoll) then return end

	if not Ragdoll.BonesRattled then
		Ragdoll.BonesRattled = true

		Ragdoll:InvalidateBoneCache()
		Ragdoll:SetupBones()

		local matrix

		for bone = 0, (Ragdoll:GetBoneCount() or 1) do
			if Ragdoll:GetBoneName(bone):lower():find("head") then
				matrix = Ragdoll:GetBoneMatrix(bone)
				return
			end
		end

		if IsValid(matrix) then
			matrix:SetScale(Vector(0, 0, 0))
		end
	end

	local head = Ragdoll:LookupAttachment("eyes")
	head = Ragdoll:GetAttachment(head)
	if not head or not head.Pos then return end

	return {
		origin = head.Pos,
		angles = head.Ang,
		fov = fov
	}
end)
