AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_wasteland/interior_fence002d.mdl")
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:EnableMotion(false)
    end

    self.SolidPos = self:GetPos()
    self.SolidAng = self:GetAngles()
    self:SetMaterial("models/props_lab/warp_sheet")
end

function ENT:OnRemove()
    if not self.CanRemove and IsValid(self.target) then
        local Replace = ents.Create("fadmin_motd")

        Replace:SetPos(self.SolidPos)
        Replace:SetAngles(self.SolidAng)
        Replace:Spawn()
        Replace:SetModel(self:GetModel())
    end
end

function ENT:OnPhysgunFreeze(Weapon, PhysObj, ent, ply)
    FAdmin.MOTD.SaveMOTD(ent, ply)
end

function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    for _, v in ipairs(ents.FindByClass("fadmin_motd")) do
        v.CanRemove = true
        v:Remove() --There can only be one motd per level
    end

    local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)

    local ent = ents.Create("fadmin_motd")
    ent:SetPos(SpawnPos)
    local Ang = ply:EyeAngles()
    ent:SetAngles(Angle(0, Ang.y-180, Ang.r))

    ent:Spawn()
    ent:Activate()
end
