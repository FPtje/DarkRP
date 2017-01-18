AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:initVars()

    self:SetModel(self.model)

    self:SetModelScale(1.5, 0)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    phys:Wake()


    self:Activate()

    self.nodupe = true
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    self.damage = (self.damage or 100) - dmg:GetDamage()
    if self.damage <= 0 then
        self:Remove()
    end
end

function ENT:Use(ply)
    net.Start("DarkRP_TipJarUI")
        net.WriteEntity(self)
    net.Send(ply)
end
