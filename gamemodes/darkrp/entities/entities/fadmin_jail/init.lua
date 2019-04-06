AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:EnableMotion(false)
    end

    self.SolidPos = self:GetPos()
    self.SolidAng = self:GetAngles()
end

function ENT:SetCanRemove(bool)
    self.CanRemove = bool
end

function ENT:OnRemove()
    if FAdmin.shuttingDown or self.CanRemove or not IsValid(self.target) then return end

    local Replace = ents.Create("fadmin_jail")
    if (not Replace:IsValid()) then return end

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

function ENT:Think()
    if not IsValid(self.target) then
        self:SetCanRemove(true)
        self:Remove()
        return
    end
end
