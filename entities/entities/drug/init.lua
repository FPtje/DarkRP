AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function UnDrugPlayer(ply)
    if not IsValid(ply) then return end
    ply.isDrugged = false
    local IDSteam = ply:SteamID64()

    timer.Remove(IDSteam .. "DruggedHealth")

    SendUserMessage("DrugEffects", ply, false)
end

hook.Add("PlayerDeath", "UndrugPlayers", function(ply) if ply.isDrugged then UnDrugPlayer(ply) end end)

local function DrugPlayer(ply)
    if not IsValid(ply) then return end

    SendUserMessage("DrugEffects", ply, true)

    ply.isDrugged = true

    local IDSteam = ply:SteamID64()

    if not timer.Exists(IDSteam .. "DruggedHealth") then
        ply:SetHealth(ply:Health() + 100)

        timer.Create(IDSteam .. "DruggedHealth", 60 / (100 + 5), 100 + 5, function()
            if not IsValid(ply) then return end
            ply:SetHealth(ply:Health() - 1)

            if ply:Health() <= 0 then
                ply:Kill()
            end

            if timer.RepsLeft(IDSteam .. "DruggedHealth") == 0 then
                UnDrugPlayer(ply)
            end
        end)
    end
end

function ENT:Initialize()
    self:SetModel("models/props_lab/jar01a.mdl")
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.CanUse = true

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    self.damage = 10
    self:Setprice(self:Getprice() or 100)
    self.SeizeReward = GAMEMODE.Config.pricemin or 35
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    self.damage = self.damage - dmg:GetDamage()

    if self.damage <= 0 then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetMagnitude(2)
        effectdata:SetScale(2)
        effectdata:SetRadius(3)
        util.Effect("Sparks", effectdata)
        self:Remove()
    end
end

function ENT:Use(activator, caller)
    if not self.CanUse then return end
    local Owner = self:Getowning_ent()
    if not IsValid(Owner) then return end

    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self, caller)
    if canUse == false then
        if reason then DarkRP.notify(activator, 1, 4, reason) end
        return
    end

    if activator ~= Owner then
        if not activator:canAfford(self:Getprice()) then return end
        DarkRP.payPlayer(activator, Owner, self:Getprice())
        DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("you_bought", DarkRP.getPhrase("drugs"), DarkRP.formatMoney(self:Getprice()), ""))
        DarkRP.notify(Owner, 0, 4, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(self:Getprice()), DarkRP.getPhrase("drugs")))
    end
    DrugPlayer(caller)
    self.CanUse = false
    self:Remove()
end

function ENT:OnRemove()
    local ply = self:Getowning_ent()
    if not IsValid(ply) then return end
    ply.maxDrugs = ply.maxDrugs - 1
end
