AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Stun Stick"
    SWEP.Slot = 0
    SWEP.SlotPos = 5
    SWEP.RenderGroup = RENDERGROUP_BOTH

    killicon.AddAlias("stunstick", "weapon_stunstick")
end

DEFINE_BASECLASS("stick_base")

SWEP.Instructions = "Left click to discipline\nRight click to kill\nHold reload to threaten"

SWEP.Spawnable = true
SWEP.Category = "DarkRP (Utility)"

SWEP.StickColor = Color(0, 0, 255)

function SWEP:Initialize()
    BaseClass.Initialize(self)

    self.Hit = {
        Sound("weapons/stunstick/stunstick_impact1.wav"),
        Sound("weapons/stunstick/stunstick_impact2.wav")
    }

    self.FleshHit = {
        Sound("weapons/stunstick/stunstick_fleshhit1.wav"),
        Sound("weapons/stunstick/stunstick_fleshhit2.wav")
    }

    if SERVER then return end

    CreateMaterial("darkrp/stunstick_beam", "UnlitGeneric", {
        ["$basetexture"] = "sprites/lgtning",
        ["$additive"] = 1
    })
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    -- Float 0 = LastPrimaryAttack
    -- Float 1 = ReloadEndTime
    -- Float 2 = BurstTime
    -- Float 3 = LastNonBurst
    -- Float 4 = SeqIdleTime
    -- Float 5 = HoldTypeChangeTime
    self:NetworkVar("Float", 6, "LastReload")
end

function SWEP:Think()
    BaseClass.Think(self)
    if self.WaitingForAttackEffect and self:GetSeqIdleTime() ~= 0 and CurTime() >= self:GetSeqIdleTime() - 0.35 then
        self.WaitingForAttackEffect = false

        local effectData = EffectData()
        effectData:SetOrigin(self:GetOwner():GetShootPos() + (self:GetOwner():EyeAngles():Forward() * 45))
        effectData:SetNormal(self:GetOwner():EyeAngles():Forward())
        util.Effect("StunstickImpact", effectData)
    end
end

function SWEP:DoFlash(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    ply:ScreenFade(SCREENFADE.IN, color_white, 1.2, 0)
end

function SWEP:PostDrawViewModel(vm)
    if self:GetSeqIdleTime() ~= 0 or self:GetLastReload() >= CurTime() - 0.1 then
        local attachment = vm:GetAttachment(1)
        local pos = attachment.Pos
        cam.Start3D(EyePos(), EyeAngles())
            render.SetMaterial(Material("effects/stunstick"))
            render.DrawSprite(pos, 12, 12, Color(180, 180, 180))
            for i = 1, 3 do
                local randVec = VectorRand() * 3
                local offset = (attachment.Ang:Forward() * randVec.x) + (attachment.Ang:Right() * randVec.y) + (attachment.Ang:Up() * randVec.z)
                render.SetMaterial(Material("!darkrp/stunstick_beam"))
                render.DrawBeam(pos, pos + offset, 3.25 - i, 1, 1.25, Color(180, 180, 180))
                pos = pos + offset
            end
        cam.End3D()
    end
end

function SWEP:DrawWorldModelTranslucent()
    if CurTime() <= self:GetLastReload() + 0.1 then
        local bone = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
        if not bone then self:DrawModel() return end
        local bonePos, boneAng = self:GetOwner():GetBonePosition(bone)
        if bonePos then
            local pos = bonePos + (boneAng:Up() * -16) + (boneAng:Right() * 3) + (boneAng:Forward() * 6.5)
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(pos, 32, 32, Color(255, 255, 255))
        end
    end
    self:DrawModel()
end

local entMeta = FindMetaTable("Entity")
function SWEP:DoAttack(dmg)
    if CLIENT then return end

    self:GetOwner():LagCompensation(true)
    local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
    self:GetOwner():LagCompensation(false)
    if IsValid(trace.Entity) and trace.Entity.onStunStickUsed then
        trace.Entity:onStunStickUsed(self:GetOwner())
        return
    elseif IsValid(trace.Entity) and trace.Entity:GetClass() == "func_breakable_surf" then
        trace.Entity:Fire("Shatter")
        self:GetOwner():EmitSound(self.Hit[math.random(1,#self.Hit)])
        return
    end

    self.WaitingForAttackEffect = true

    local ent = self:GetOwner():getEyeSightHitEntity(100, 15, fn.FAnd{fp{fn.Neq, self:GetOwner()}, fc{IsValid, entMeta.GetPhysicsObject}})

    if not IsValid(ent) then return end
    if ent:IsPlayer() and not ent:Alive() then return end

    if not ent:isDoor() then
        ent:SetVelocity((ent:GetPos() - self:GetOwner():GetPos()) * 7)
    end

    if dmg > 0 then
        ent:TakeDamage(dmg, self:GetOwner(), self)
    end

    if ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() then
        self:DoFlash(ent)
        self:GetOwner():EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
    else
        self:GetOwner():EmitSound(self.Hit[math.random(1,#self.Hit)])
        if FPP and FPP.plyCanTouchEnt(self:GetOwner(), ent, "EntityDamage") then
            if ent.SeizeReward and not ent.beenSeized and not ent.burningup and self:GetOwner():isCP() and ent.Getowning_ent and self:GetOwner() ~= ent:Getowning_ent() then
                self:GetOwner():addMoney(ent.SeizeReward)
                DarkRP.notify(self:GetOwner(), 1, 4, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(ent.SeizeReward), DarkRP.getPhrase("bonus_destroying_entity")))
                ent.beenSeized = true
            end
            ent:TakeDamage(1000-dmg, self:GetOwner(), self) -- for illegal entities
        end
    end
end

function SWEP:PrimaryAttack()
    BaseClass.PrimaryAttack(self)
    self:SetNextSecondaryFire(self:GetNextPrimaryFire())
    self:DoAttack(0)
end

function SWEP:SecondaryAttack()
    BaseClass.PrimaryAttack(self)
    self:SetNextSecondaryFire(self:GetNextPrimaryFire())
    self:DoAttack(10)
end

function SWEP:Reload()
    self:SetHoldType("melee")
    self:SetHoldTypeChangeTime(CurTime() + 0.1)

    if self:GetLastReload() + 0.1 > CurTime() then self:SetLastReload(CurTime()) return end
    self:SetLastReload(CurTime())
    self:EmitSound("weapons/stunstick/spark" .. math.random(1, 3) .. ".wav")
end
