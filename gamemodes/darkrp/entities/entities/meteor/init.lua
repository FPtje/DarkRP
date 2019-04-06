AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/Rock001a.mdl")
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:Ignite(20, 0)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    phys:EnableMotion(true)
    phys:SetMass(1000)
    phys:EnableGravity(false)
end

function ENT:SetMeteorTarget(ent)
    local foundSky = util.IsInWorld(ent:GetPos())
    local zPos = ent:GetPos().z

    for a = 1, 30, 1 do
        zPos = zPos + 100
        foundSky = util.IsInWorld(Vector(ent:GetPos().x ,ent:GetPos().y ,zPos))
        if (foundSky == false) then
            zPos = zPos - 120
            break
        end
    end

    self:SetPos(Vector(ent:GetPos().x + math.random(-4000,4000),ent:GetPos().y + math.random(-4000,4000), zPos))
    local speed = 100000000
    local VNormal = (Vector(ent:GetPos().x + math.random(-500,500),ent:GetPos().y + math.random(-500,500),ent:GetPos().z) - self:GetPos()):GetNormal()
    self:GetPhysicsObject():ApplyForceCenter(VNormal * speed)
end

function ENT:Destruct(notexplode)
    if not notexplode then
        util.BlastDamage(self, self, self:GetPos(), 200, 60)
    end

    self:Extinguish()
    local vPoint = self:GetPos()
    local effectdata = EffectData()
    effectdata:SetStart(vPoint)
    effectdata:SetOrigin(vPoint)
    effectdata:SetScale(1)
    util.Effect("Explosion", effectdata)
    -- You get warnings about changing collision rule when removing immediately
    -- https://github.com/FPtje/DarkRP/issues/2832
    timer.Simple(0, fp{SafeRemoveEntity, self})
end

function ENT:OnTakeDamage(dmg)
    if (dmg:GetDamage() > 5) then
        self:Destruct(true)
    end
end

function ENT:PhysicsCollide(data, physobj)
    if data.HitEntity:GetClass() == "func_breakable_surf" then self:Remove() return end
    self:Destruct()
end
