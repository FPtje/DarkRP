AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Weapon Checker"
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
SWEP.AnimPrefix  = "rpg"

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

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsWeaponChecking")
    self:NetworkVar("Float", 0, "StartCheckTime")
    self:NetworkVar("Float", 1, "EndCheckTime")
    self:NetworkVar("Float", 2, "NextSoundTime")
    self:NetworkVar("Int", 0, "TotalWeaponChecks")
end

function SWEP:Deploy()
    return true
end

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:GetStrippableWeapons(ent, callback)
    CAMI.PlayerHasAccess(ent, "DarkRP_GetAdminWeapons", function(access)
        for k,v in pairs(ent:GetWeapons()) do
            if not v:IsValid() then continue end
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

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():DistToSqr(self:GetOwner():GetPos()) > 10000 then
        return
    end

    self:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
    self:SetNextSoundTime(CurTime() + 0.3)


    if not IsFirstTimePredicted() then return end

    local result = {}
    local weps = {}
    self:GetStrippableWeapons(trace.Entity, function(wep)
        table.insert(weps, wep)
    end)

    hook.Call("playerWeaponsChecked", nil, self:GetOwner(), trace.Entity, weps)

    if SERVER then return end
    for _, wep in pairs(weps) do
        table.insert(result, wep:GetPrintName() and language.GetPhrase(wep:GetPrintName()) or wep:GetClass())
    end

    result = table.concat(result, ", ")

    if result == "" then
        self:GetOwner():ChatPrint(DarkRP.getPhrase("no_illegal_weapons", trace.Entity:Nick()))
        return
    end

    self:GetOwner():ChatPrint(DarkRP.getPhrase("persons_weapons", trace.Entity:Nick()))
    if string.len(result) >= 126 then
        local amount = math.ceil(string.len(result) / 126)
        for i = 1, amount, 1 do
            self:GetOwner():ChatPrint(string.sub(result, (i-1) * 126, i * 126 - 1))
        end
    else
        self:GetOwner():ChatPrint(result)
    end
end

function SWEP:SecondaryAttack()
    if self:GetIsWeaponChecking() then return end
    self:SetNextSecondaryFire(CurTime() + 0.3)

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():DistToSqr(self:GetOwner():GetPos()) > 10000 then
        return
    end

    self:SetIsWeaponChecking(true)
    self:SetStartCheckTime(CurTime())
    self:SetEndCheckTime(CurTime() + util.SharedRandom("DarkRP_WeaponChecker" .. self:EntIndex() .. "_" .. self:GetTotalWeaponChecks(), 5, 10))
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

    local trace = self:GetOwner():GetEyeTrace()

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():DistToSqr(self:GetOwner():GetPos()) > 10000 then
        return
    end

    if not trace.Entity.ConfiscatedWeapons then
        DarkRP.notify(self:GetOwner(), 1, 4, DarkRP.getPhrase("no_weapons_confiscated", trace.Entity:Nick()))
        return
    else
        for k,v in pairs(trace.Entity.ConfiscatedWeapons) do
            local wep = trace.Entity:Give(v.class)
            trace.Entity:RemoveAllAmmo()
            trace.Entity:SetAmmo(v.primaryAmmoCount, v.primaryAmmoType, false)
            trace.Entity:SetAmmo(v.secondaryAmmoCount, v.secondaryAmmoType, false)

            wep:SetClip1(v.clip1)
            wep:SetClip2(v.clip2)

        end
        DarkRP.notify(self:GetOwner(), 2, 4, DarkRP.getPhrase("returned_persons_weapons", trace.Entity:Nick()))

        hook.Call("playerWeaponsReturned", nil, self:GetOwner(), trace.Entity, trace.Entity.ConfiscatedWeapons)
        trace.Entity.ConfiscatedWeapons = nil
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

    if CLIENT then return end
    local result = {}
    local stripped = {}
    local trace = self:GetOwner():GetEyeTrace()
    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() then return end
    self:GetStrippableWeapons(trace.Entity, function(wep)
        trace.Entity:StripWeapon(wep:GetClass())
        table.insert(result, wep:GetClass())
        stripped[wep:GetClass()] = {
            class = wep:GetClass(),
            primaryAmmoCount = trace.Entity:GetAmmoCount(wep:GetPrimaryAmmoType()),
            primaryAmmoType = wep:GetPrimaryAmmoType(),
            secondaryAmmoCount = trace.Entity:GetAmmoCount(wep:GetSecondaryAmmoType()),
            secondaryAmmoType = wep:GetSecondaryAmmoType(),
            clip1 = wep:Clip1(),
            clip2 = wep:Clip2()
        }
    end)
    result = table.concat(result, ", ")

    if not trace.Entity.ConfiscatedWeapons then
        if next(stripped) ~= nil then trace.Entity.ConfiscatedWeapons = stripped end
    else
        -- Merge stripped weapons into confiscated weapons
        for k,v in pairs(stripped) do
            if trace.Entity.ConfiscatedWeapons[k] then continue end

            trace.Entity.ConfiscatedWeapons[k] = v
        end
    end

    hook.Call("playerWeaponsConfiscated", nil, self:GetOwner(), trace.Entity, trace.Entity.ConfiscatedWeapons)

    if result == "" then
        self:GetOwner():ChatPrint(DarkRP.getPhrase("no_illegal_weapons", trace.Entity:Nick()))
        self:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
        self:SetNextSoundTime(CurTime() + 0.3)
    else
        self:EmitSound("ambient/energy/zap1.wav", 50, 100)
        self:GetOwner():ChatPrint(DarkRP.getPhrase("confiscated_these_weapons"))
        if string.len(result) >= 126 then
            local amount = math.ceil(string.len(result) / 126)
            for i = 1, amount, 1 do
                self:GetOwner():ChatPrint(string.sub(result, (i-1) * 126, i * 126 - 1))
            end
        else
            self:GetOwner():ChatPrint(result)
        end
        self:SetNextSoundTime(0)
    end
end

function SWEP:Fail()
    self:SetIsWeaponChecking(false)
    self:SetHoldType("normal")
    self:SetNextSoundTime(0)
end

function SWEP:Think()
    if self:GetIsWeaponChecking() and self:GetEndCheckTime() ~= 0 then
        self:GetOwner():LagCompensation(true)
        local trace = self:GetOwner():GetEyeTrace()
        self:GetOwner():LagCompensation(false)
        if not IsValid(trace.Entity) or trace.HitPos:DistToSqr(self:GetOwner():GetShootPos()) > 10000 or not trace.Entity:IsPlayer() then
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

        draw.RoundedBox(8, x, y, width, height, Color(10, 10, 10, 120))
        draw.RoundedBox(cornerRadius, x + 8, y + 8, BarWidth, height - 16, Color(0, 0 + (status * 255), 255 - (status * 255), 255))
        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("checking_weapons") .. self.Dots, "Trebuchet24", w / 2, y + height / 2, Color(255, 255, 255, 255), 1, 1)
    end
end
