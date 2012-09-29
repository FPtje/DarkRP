ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "fadmin MOTD"
ENT.Information = "Place this MOTD somewhere, freeze it and it will be saved automatically"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:CanTool(ply, trace, tool)
	if ply:IsAdmin() and tool == "remover" then
		self.CanRemove = true
		if SERVER then FAdmin.MOTD.RemoveMOTD(self, ply) end
		return true
	end
	return false
end

function ENT:PhysgunPickup(ply)
	local PickupPos = Vector(1.8079, -0.6743, -62.3193)
	if ply:IsAdmin() and PickupPos:Distance(self:WorldToLocal(ply:GetEyeTrace().HitPos)) < 7 then return true end
	return false
end