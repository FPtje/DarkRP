local function doDeathPOV(ply, origin, angles, fov)
	local Ragdoll = ply:GetRagdollEntity()
	if not IsValid(Ragdoll) then return end

	local head = Ragdoll:LookupAttachment("eyes")
	head = Ragdoll:GetAttachment(head)
	if not head or not head.Pos then return end

	local view = {}
	view.origin = head.Pos
	view.angles = head.Ang
	view.fov = fov
	return view
end

local function deathPOV(um)
	local toggle = um:ReadBool()

	if toggle then
		hook.Add("CalcView", "rp_deathPOV", doDeathPOV)
	else
		hook.Remove("CalcView", "rp_deathPOV")
	end
end
usermessage.Hook("DeathPOV", deathPOV)