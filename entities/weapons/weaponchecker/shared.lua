AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 1
    SWEP.SlotPos = 9
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to weapon check\nRight click to confiscate weapons\nReload to give back the weapons"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IsDarkRPWeaponChecker = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"

SWEP.PrintName = "Weapon Checker"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.MinCheckTime = 5
SWEP.MaxCheckTime = 10

DarkRP.hookStub{
    name = "playerWeaponsChecked",
    description = "Called when a player with a weapon checker has checked another player's weapons. Note: Only called when the player looks at the weapons without confiscating. Please see playerWeaponsConfiscated for when weapons are actually confiscated.",
    parameters = {
        {
            name = "checker",
            description = "The player holding the weapon checker.",
            type = "Player"
        },
        {
            name = "target",
            description = "The player whose weapons have been checked.",
            type = "Player"
        },
        {
            name = "weapons",
            description = "The weapons that have been checked.",
            type = "table"
        },
    },
    returns = {},
    realm = "Shared"
}

DarkRP.hookStub{
    name = "playerWeaponsReturned",
    description = "Called when a player with a weapon checker has returned another player's weapons.",
    parameters = {
        {
            name = "checker",
            description = "The player holding the weapon checker.",
            type = "Player"
        },
        {
            name = "target",
            description = "The player whose weapons have been returned.",
            type = "Player"
        },
        {
            name = "weapons",
            description = "The weapons that have been returned.",
            type = "table"
        },
    },
    returns = {},
    realm = "Server"
}

DarkRP.hookStub{
    name = "playerWeaponsConfiscated",
    description = "Called when a player with a weapon checker has confiscated another player's weapons.",
    parameters = {
        {
            name = "checker",
            description = "The player holding the weapon checker.",
            type = "Player"
        },
        {
            name = "target",
            description = "The player whose weapons have been confiscated.",
            type = "Player"
        },
        {
            name = "weapons",
            description = "The weapons that have been confiscated.",
            type = "table"
        },
    },
    returns = {},
    realm = "Server"
}

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsWeaponChecking")
    self:NetworkVar("Float", 0, "StartCheckTime")
    self:NetworkVar("Float", 1, "EndCheckTime")
    self:NetworkVar("Float", 2, "NextSoundTime")
    self:NetworkVar("Int", 0, "TotalWeaponChecks")
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    return true
end

function SWEP:DrawWorldModel()
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:GetStrippableWeapons(ent, callback)
    CAMI.PlayerHasAccess(ent, "DarkRP_GetAdminWeapons", function(access)
        for _, v in ipairs(ent:GetWeapons()) do
            local class = v:GetClass()

            if GAMEMODE.Config.weaponCheckerHideDefault and (table.HasValue(GAMEMODE.Config.DefaultWeapons, class) or
                access and table.HasValue(GAMEMODE.Config.AdminWeapons, class) or
                ent:getJobTable() and ent:getJobTable().weapons and table.HasValue(ent:getJobTable().weapons, class)) then
                continue
            end

            if (GAMEMODE.Config.weaponCheckerHideNoLicense and GAMEMODE.NoLicense[class]) or GAMEMODE.Config.noStripWeapons[class] then continue end

            callback(v)
        end
    end)
end

function SWEP:PrimaryAttack()
    if self:GetIsWeaponChecking() then return end
    self:SetNextPrimaryFire(CurTime() + 0.3)

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    Owner:LagCompensation(true)
    local trace = Owner:GetEyeTrace()
    Owner:LagCompensation(false)

    local ent = trace.Entity
    if not IsValid(ent) or not ent:IsPlayer() or ent:GetPos():DistToSqr(Owner:GetPos()) > 10000 then
        return
    end

    self:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
    self:SetNextSoundTime(CurTime() + 0.3)

    if not IsFirstTimePredicted() then return end

    local weps = {}
    self:GetStrippableWeapons(ent, function(wep)
        table.insert(weps, wep)
    end)

    hook.Call("playerWeaponsChecked", nil, Owner, ent, weps)

    if not CLIENT then return end

    self:PrintWeapons(ent, DarkRP.getPhrase("persons_weapons", ent:Nick()))
end

function SWEP:SecondaryAttack()
    if self:GetIsWeaponChecking() then return end
    self:SetNextSecondaryFire(CurTime() + 0.3)

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    Owner:LagCompensation(true)
    local trace = Owner:GetEyeTrace()
    Owner:LagCompensation(false)

    local ent = trace.Entity
    if not IsValid(ent) or not ent:IsPlayer() or ent:GetPos():DistToSqr(Owner:GetPos()) > 10000 then
        return
    end

    self:SetIsWeaponChecking(true)
    self:SetStartCheckTime(CurTime())
    self:SetEndCheckTime(CurTime() + util.SharedRandom("DarkRP_WeaponChecker" .. self:EntIndex() .. "_" .. self:GetTotalWeaponChecks(), self.MinCheckTime, self.MaxCheckTime))
    self:SetTotalWeaponChecks(self:GetTotalWeaponChecks() + 1)

    self:SetNextSoundTime(CurTime() + 0.5)

    if CLIENT then
        self.Dots = ""
        self.NextDotsTime = CurTime() + 0.5
    end
end

function SWEP:Reload()
    if CLIENT or CurTime() < (self.NextReloadTime or 0) then return end
    self.NextReloadTime = CurTime() + 1

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    local trace = Owner:GetEyeTrace()

    local ent = trace.Entity
    if not IsValid(ent) or not ent:IsPlayer() or ent:GetPos():DistToSqr(Owner:GetPos()) > 10000 then
        return
    end

    if not ent.ConfiscatedWeapons then
        DarkRP.notify(Owner, 1, 4, DarkRP.getPhrase("no_weapons_confiscated", ent:Nick()))
        return
    else
        ent:RemoveAllAmmo()
        for _, v in pairs(ent.ConfiscatedWeapons) do
            local wep = ent:Give(v.class, true)

            -- :Give returns NULL when the player already has the weapon
            wep = IsValid(wep) and wep or ent:GetWeapon(v.class)
            if not IsValid(wep) then continue end

            ent:GiveAmmo(v.primaryAmmoCount, v.primaryAmmoType, true)
            ent:GiveAmmo(v.secondaryAmmoCount, v.secondaryAmmoType, true)

            wep:SetClip1(v.clip1)
            wep:SetClip2(v.clip2)

        end
        DarkRP.notify(Owner, 2, 4, DarkRP.getPhrase("returned_persons_weapons", ent:Nick()))

        hook.Call("playerWeaponsReturned", nil, Owner, ent, ent.ConfiscatedWeapons)
        ent.ConfiscatedWeapons = nil
    end
end

function SWEP:Holster()
    self:SetIsWeaponChecking(false)
    self:SetNextSoundTime(0)
    return true
end

function SWEP:Succeed()
    if not IsValid(self:GetOwner()) then return end
    self:SetIsWeaponChecking(false)

    local trace = self:GetOwner():GetEyeTrace()
    local ent = trace.Entity
    if not IsValid(ent) or not ent:IsPlayer() then return end

    if CLIENT then
        if not IsFirstTimePredicted() then return end
        self:PrintWeapons(ent, DarkRP.getPhrase("confiscated_these_weapons"))
        return
    end

    local stripped = {}

    self:GetStrippableWeapons(ent, function(wep)
        local class = wep:GetClass()
        ent:StripWeapon(class)
        stripped[class] = {
            class = class,
            primaryAmmoCount = ent:GetAmmoCount(wep:GetPrimaryAmmoType()),
            primaryAmmoType = wep:GetPrimaryAmmoType(),
            secondaryAmmoCount = ent:GetAmmoCount(wep:GetSecondaryAmmoType()),
            secondaryAmmoType = wep:GetSecondaryAmmoType(),
            clip1 = wep:Clip1(),
            clip2 = wep:Clip2()
        }
    end)

    if not ent.ConfiscatedWeapons then
        if next(stripped) ~= nil then ent.ConfiscatedWeapons = stripped end
    else
        -- Merge stripped weapons into confiscated weapons
        for k,v in pairs(stripped) do
            if ent.ConfiscatedWeapons[k] then continue end

            ent.ConfiscatedWeapons[k] = v
        end
    end

    hook.Call("playerWeaponsConfiscated", nil, self:GetOwner(), ent, ent.ConfiscatedWeapons)

    if next(stripped) ~= nil then
        self:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
        self:SetNextSoundTime(CurTime() + 0.3)
    else
        self:EmitSound("ambient/energy/zap1.wav", 50, 100)
        self:SetNextSoundTime(0)
    end
end

function SWEP:PrintWeapons(ent, weaponsFoundPhrase)
    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    local result = {}
    local weps = {}
    self:GetStrippableWeapons(ent, function(wep)
        table.insert(weps, wep)
    end)

    for _, wep in ipairs(weps) do
        table.insert(result, wep:GetPrintName() and language.GetPhrase(wep:GetPrintName()) or wep:GetClass())
    end

    result = table.concat(result, ", ")

    if result == "" then
        Owner:ChatPrint(DarkRP.getPhrase("no_illegal_weapons", ent:Nick()))
        return
    end

    Owner:ChatPrint(weaponsFoundPhrase)
    if string.len(result) >= 126 then
        local amount = math.ceil(string.len(result) / 126)
        for i = 1, amount, 1 do
            Owner:ChatPrint(string.sub(result, (i-1) * 126, i * 126 - 1))
        end
    else
        Owner:ChatPrint(result)
    end
end

function SWEP:Fail()
    self:SetIsWeaponChecking(false)
    self:SetHoldType("normal")
    self:SetNextSoundTime(0)
end

function SWEP:Think()
    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    if self:GetIsWeaponChecking() and self:GetEndCheckTime() ~= 0 then
        Owner:LagCompensation(true)
        local trace = Owner:GetEyeTrace()
        Owner:LagCompensation(false)
        if not IsValid(trace.Entity) or trace.HitPos:DistToSqr(Owner:GetShootPos()) > 10000 or not trace.Entity:IsPlayer() then
            self:Fail()
        end
        if self:GetEndCheckTime() <= CurTime() then
            self:Succeed()
        end
    end
    if self:GetNextSoundTime() ~= 0 and CurTime() >= self:GetNextSoundTime() then
        if self:GetIsWeaponChecking() then
            self:SetNextSoundTime(CurTime() + 0.5)
            self:EmitSound("npc/combine_soldier/gear5.wav", 100, 100)
        else
            self:SetNextSoundTime(0)
            self:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
        end
    end
    if CLIENT and self.NextDotsTime and CurTime() >= self.NextDotsTime then
        self.NextDotsTime = CurTime() + 0.5
        self.Dots = self.Dots or ""
        local len = string.len(self.Dots)
        local dots = {
            [0] = ".",
            [1] = "..",
            [2] = "...",
            [3] = ""
        }
        self.Dots = dots[len]
    end
end

local colorBackground = Color(10, 10, 10, 120)

function SWEP:DrawHUD()
    if self:GetIsWeaponChecking() and self:GetEndCheckTime() ~= 0 then
        self.Dots = self.Dots or ""
        local w = ScrW()
        local h = ScrH()
        local x, y, width, height = w / 2 - w / 10, h / 2, w / 5, h / 15
        local time = self:GetEndCheckTime() - self:GetStartCheckTime()
        local curtime = CurTime() - self:GetStartCheckTime()
        local status = math.Clamp(curtime / time, 0, 1)
        local BarWidth = status * (width - 16)
        local cornerRadius = math.Min(8, BarWidth / 3 * 2 - BarWidth / 3 * 2 % 2)

        draw.RoundedBox(8, x, y, width, height, colorBackground)
        draw.RoundedBox(cornerRadius, x + 8, y + 8, BarWidth, height - 16, Color(0, 0 + (status * 255), 255 - (status * 255), 255))
        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("checking_weapons") .. self.Dots, "Trebuchet24", w / 2, y + height / 2, color_white, 1, 1)
    end
end
