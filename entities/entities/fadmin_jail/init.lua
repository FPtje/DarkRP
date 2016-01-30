AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    phys:Wake()
    phys:EnableMotion(false)

    self.SolidPos = self:GetPos()
    self.SolidAng = self:GetAngles()
end

function ENT:SetCanRemove(bool)
    self.CanRemove = bool
end

function ENT:OnRemove()
    if not self.CanRemove and IsValid(self.target) then
        local Replace = ents.Create("fadmin_jail")

        Replace:SetPos(self.SolidPos)
        Replace:SetAngles(self.SolidAng)
        Replace:SetModel(self:GetModel())
        Replace:Spawn()
        Replace:Activate()

        Replace.target = self.target
        Replace.targetPos = self.targetPos

        self.target.FAdminJailProps = self.target.FAdminJailProps or {}
        self.target.FAdminJailProps[self] = nil
        self.target.FAdminJailProps[Replace] = true

        if self.targetPos then self.target:SetPos(self.targetPos) end -- Back in jail you! :V
    end
end

function ENT:Think()
    if not IsValid(self.target) then
        self:SetCanRemove(true)
        self:Remove()
        return
    end
end
