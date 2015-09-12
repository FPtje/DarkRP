ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "fadmin_jail"
ENT.Author = "FPtje"
ENT.Spawnable = false

function ENT:CanTool()
    return false
end

function ENT:PhysgunPickup(ply)
    return false
end
