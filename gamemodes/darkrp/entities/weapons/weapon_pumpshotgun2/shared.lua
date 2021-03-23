AddCSLuaFile()

if CLIENT then
    SWEP.Author = "DarkRP Developers"
    SWEP.Slot = 2
    SWEP.SlotPos = 0
    SWEP.IconLetter = "k"

    killicon.AddFont("weapon_pumpshotgun2", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

DEFINE_BASECLASS("weapon_cs_base2")

SWEP.PrintName = "Pump Shotgun"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP (Weapon)"

SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "shotgun"
SWEP.LoweredHoldType = "normal"

SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 8
SWEP.Primary.Cone = 0.08
SWEP.Primary.ClipSize = 8
SWEP.Primary.Delay = 0.95
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector(-7.64, -8, 3.56)
SWEP.IronSightsAng = Vector(-0.1, 0.02, 0)

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    -- Float 0 = IronsightsTime
    -- Float 1 = LastPrimaryAttack
    -- Float 2 = ReloadEndTime
    -- Float 3 = BurstTime
    self:NetworkVar("Float", 4, "QueuedAttackTime")
    -- Bool 0 = IronsightsPredicted
    -- Bool 1 = Reloading
    self:NetworkVar("Bool", 2, "AttackQueued")
end

function SWEP:Deploy()
    self:SetAttackQueued(false)

    return BaseClass.Deploy(self)
end

function SWEP:Holster()
    self:SetAttackQueued(false)

    return BaseClass.Holster(self)
end

function SWEP:PrimaryAttack()
    if self:GetAttackQueued() then return end

    if self:GetReloading() then
        self:SetAttackQueued(true) -- this way it doesn't interupt the reload animation
        return
    end

    BaseClass.PrimaryAttack(self)
end

function SWEP:Reload()
    -- Already reloading
    if self:GetReloading() then return end

    -- Start reloading if we can
    if self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
        self:SetReloading(true)
        self:SetReloadEndTime(CurTime() + 0.3)
        self:SendWeaponAnim(ACT_VM_RELOAD)
        self:SetIronsights(false)
        self:SetHoldType(self.HoldType)
        self.Owner:SetAnimation(PLAYER_RELOAD)
        self:SetHoldType("normal")
    end
end

function SWEP:Think()
    self:CalcViewModel()
    if self:GetReloadEndTime() ~= 0 and CurTime() >= self:GetReloadEndTime() then
        -- Finished reload -
        if self:Clip1() >= self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
            self:SetReloading(false)
            self:SetReloadEndTime(0)
            self:SetAttackQueued(false)
            return
        end

        if self:GetAttackQueued() then
            self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
            self:SetReloading(false)
            self:SetReloadEndTime(0)
            self:SetAttackQueued(false)
            self:SetQueuedAttackTime(CurTime() + 0.8)
            return
        end

        -- Next cycle
        self:SetReloadEndTime(CurTime() + 0.3)
        self:SendWeaponAnim(ACT_VM_RELOAD)

        -- Add ammo
        self:GetOwner():RemoveAmmo(1, self.Primary.Ammo, false)
        self:SetClip1(self:Clip1() + 1)

        -- Finish filling, final pump
        if self:Clip1() >= self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
            self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
        end
    end
    if self:GetQueuedAttackTime() ~= 0 and CurTime() >= self:GetQueuedAttackTime() then
        self:SetQueuedAttackTime(0)
        self:PrimaryAttack()
    end
end
