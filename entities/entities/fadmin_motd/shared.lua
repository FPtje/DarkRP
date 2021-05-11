ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "fadmin MOTD"
ENT.Information = "Place this MOTD somewhere, freeze it and it will be saved automatically"
ENT.Author = "FPtje"
ENT.Spawnable = false

function ENT:CanTool(ply, trace, tool)
    if ply:IsAdmin() and tool == "remover" then
        self.CanRemove = true
        if SERVER then FAdmin.MOTD.RemoveMOTD(self, ply) end
        return true
    end
    return false
end

local PickupPos = Vector(1.8079, -0.6743, -62.3193)
function ENT:PhysgunPickup(ply)
    if ply:IsAdmin() and PickupPos:DistToSqr(self:WorldToLocal(ply:GetEyeTrace().HitPos)) < 49 then return true end
    return false
end
