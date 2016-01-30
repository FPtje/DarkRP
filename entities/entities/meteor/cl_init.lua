ENT.Spawnable = false
ENT.AdminSpawnable = false

include("shared.lua")

language.Add("meteor", "meteor")

function ENT:Initialize()
    local mx, mn = self:GetRenderBounds()
    self:SetRenderBounds(mn + Vector(0,0,128), mx, 0)
    self.emitter = ParticleEmitter(LocalPlayer():GetShootPos())
end

function ENT:Think()
    local vOffset = self:LocalToWorld(Vector(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-3, 3))) + Vector(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-3, 3))
    local vNormal = (vOffset - self:GetPos()):GetNormalized()

    if not self.emitter then return end

    local particle = self.emitter:Add(Model("particles/smokey"), vOffset)
    particle:SetVelocity(vNormal * math.Rand(10, 30))
    particle:SetDieTime(2.0)
    particle:SetStartAlpha(math.Rand(50, 150))
    particle:SetStartSize(math.Rand(8, 16))
    particle:SetEndSize(math.Rand(32, 64))
    particle:SetRoll(math.Rand(-0.2, 0.2))
    particle:SetColor(Color(200, 200, 210))
end

function ENT:OnRemove()
    if IsValid(self.emitter) then
        self.emitter:Finish()
    end
end
