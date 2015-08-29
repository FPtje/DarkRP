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

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():Distance(self:GetOwner():GetPos()) > 100 then
        return
    end

    self:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
    self:SetNextSoundTime(CurTime() + 0.3)

    if SERVER or not IsFirstTimePredicted() then return end

    local result = {}
    self:GetStrippableWeapons(trace.Entity, function(wep)
        table.insert(result, wep:GetPrintName() and language.GetPhrase(wep:GetPrintName()) or wep:GetClass())
    end)
    result = table.concat(result, ", ")

    if result == "" then
        self:GetOwner():ChatPrint(DarkRP.getPhrase("no_illegal_weapons", trace.Entity:Nick()))
    else
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
end

function SWEP:SecondaryAttack()
    if self:GetIsWeaponChecking() then return end
    self:SetNextSecondaryFire(CurTime() + 0.3)

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():Distance(self:GetOwner():GetPos()) > 100 then
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

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():Distance(self:GetOwner():GetPos()) > 100 then
        return
    end

    if not trace.Entity.ConfiscatedWeapons then
        DarkRP.notify(self:GetOwner(), 1, 4, DarkRP.getPhrase("no_weapons_confiscated", trace.Entity:Nick()))
        return
    else
        for k,v in pairs(trace.Entity.ConfiscatedWeapons) do
            local wep = trace.Entity:Give(v[1])
            trace.Entity:RemoveAllAmmo()
            trace.Entity:SetAmmo(v[2], v[3], false)
            trace.Entity:SetAmmo(v[4], v[5], false)

            wep:SetClip1(v[6])
            wep:SetClip2(v[7])

        end
        DarkRP.notify(self:GetOwner(), 2, 4, DarkRP.getPhrase("returned_persons_weapons", trace.Entity:Nick()))
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
        table.insert(stripped, {wep:GetClass(), trace.Entity:GetAmmoCount(wep:GetPrimaryAmmoType()),
        wep:GetPrimaryAmmoType(), trace.Entity:GetAmmoCount(wep:GetSecondaryAmmoType()), wep:GetSecondaryAmmoType(),
        wep:Clip1(), wep:Clip2()})
    end)
    result = table.concat(result, ", ")

    if not trace.Entity.ConfiscatedWeapons then
        if next(stripped) ~= nil then trace.Entity.ConfiscatedWeapons = stripped end
    else
        for k,v in pairs(stripped) do
            local found = false
            for a,b in pairs(trace.Entity.ConfiscatedWeapons) do
                if b[1] == v[1] then
                    found = true
                    break
                end
            end

            if not found then
                table.insert(trace.Entity.ConfiscatedWeapons, v)
            end
        end
    end

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
        if not IsValid(trace.Entity) or trace.HitPos:Distance(self:GetOwner():GetShootPos()) > 100 or not trace.Entity:IsPlayer() then
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
