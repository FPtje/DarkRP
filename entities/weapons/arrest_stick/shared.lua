AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Arrest Baton"
    SWEP.Slot = 1
    SWEP.SlotPos = 3
end

DEFINE_BASECLASS("stick_base")

SWEP.Instructions = "Left click to arrest\nRight click to switch batons"

SWEP.Spawnable = true
SWEP.Category = "DarkRP (Utility)"

SWEP.StickColor = Color(255, 0, 0)

SWEP.Switched = true

DarkRP.hookStub{
    name = "canArrest",
    description = "Whether someone can arrest another player.",
    parameters = {
        {
            name = "arrester",
            description = "The player trying to arrest someone.",
            type = "Player"
        },
        {
            name = "arrestee",
            description = "The player being arrested.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "canArrest",
            description = "A yes or no as to whether the arrester can arrest the arestee.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message that is shown when they can't arrest the player.",
            type = "string"
        }
    },
    realm = "Server"
}

local hookCanArrest = {canArrest = function(_, arrester, arrestee)
    if IsValid(arrestee) and arrestee:IsPlayer() and arrestee:isCP() and not GAMEMODE.Config.cpcanarrestcp then
        return false, DarkRP.getPhrase("cant_arrest_other_cp")
    end

    if arrestee:GetClass() == "prop_ragdoll" then
        for k,v in pairs(player.GetAll()) do
            if arrestee.OwnerINT and arrestee.OwnerINT == v:EntIndex() and GAMEMODE.KnockoutToggle then
                DarkRP.toggleSleep(v, true)
                return false, nil
            end
        end
    end

    if not GAMEMODE.Config.npcarrest and arrestee:IsNPC() then
        return false, DarkRP.getPhrase("unable", "arrest", "NPC")
    end

    if GAMEMODE.Config.needwantedforarrest and not arrestee:IsNPC() and not arrestee:getDarkRPVar("wanted") then
        return false, DarkRP.getPhrase("must_be_wanted_for_arrest")
    end

    if FAdmin and arrestee:IsPlayer() and arrestee:FAdmin_GetGlobal("fadmin_jailed") then
        return false, DarkRP.getPhrase("cant_arrest_fadmin_jailed")
    end

    return true
end}

function SWEP:Deploy()
    self.Switched = true
    return BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    BaseClass.PrimaryAttack(self)

    if CLIENT then return end

    self:GetOwner():LagCompensation(true)
    local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
    self:GetOwner():LagCompensation(false)
    if IsValid(trace.Entity) and trace.Entity.onArrestStickUsed then
        trace.Entity:onArrestStickUsed(self:GetOwner())
        return
    end

    local ent = self:GetOwner():getEyeSightHitEntity(nil, nil, function(p) return p ~= self:GetOwner() and p:IsPlayer() and p:Alive() end)

    if not IsValid(ent) or (self:GetOwner():EyePos():Distance(ent:GetPos()) > 90) or not ent:IsPlayer() then
        return
    end

    local canArrest, message = hook.Call("canArrest", hookCanArrest, self:GetOwner(), ent)
    if not canArrest then
        if message then DarkRP.notify(self:GetOwner(), 1, 5, message) end
        return
    end

    local jpc = DarkRP.jailPosCount()

    if not jpc or jpc == 0 then
        DarkRP.notify(self:GetOwner(), 1, 4, DarkRP.getPhrase("cant_arrest_no_jail_pos"))
    else
        -- Send NPCs to Jail
        if ent:IsNPC() then
            ent:SetPos(DarkRP.retrieveJailPos())
        else
            if not ent.Babygod then
                ent:arrest(nil, self:GetOwner())
                DarkRP.notify(ent, 0, 20, DarkRP.getPhrase("youre_arrested_by", self:GetOwner():Nick()))

                if self:GetOwner().SteamName then
                    DarkRP.log(self:GetOwner():Nick() .. " (" .. self:GetOwner():SteamID() .. ") arrested " .. ent:Nick(), Color(0, 255, 255))
                end
            else
                DarkRP.notify(self:GetOwner(), 1, 4, DarkRP.getPhrase("cant_arrest_spawning_players"))
            end
        end
    end
end

function SWEP:startDarkRPCommand(usrcmd)
    if game.SinglePlayer() and CLIENT then return end
    if usrcmd:KeyDown(IN_ATTACK2) then
        if not self.Switched and self:GetOwner():HasWeapon("unarrest_stick") then
            usrcmd:SelectWeapon(self:GetOwner():GetWeapon("unarrest_stick"))
        end
    else
        self.Switched = false
    end
end
