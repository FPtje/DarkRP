AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("commands.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/paper01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
    local phys = self:GetPhysicsObject()

    phys:Wake()
    hook.Add("PlayerDisconnected", self, self.onPlayerDisconnected)
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    local typ = dmg:GetDamageType()
    if bit.band(typ, DMG_BULLET) ~= DMG_BULLET then return end

    self:Remove()
end

function ENT:OnRemove()
    local ply = self:Getowning_ent()
    if not IsValid(ply) then return end
    if not ply.maxletters then
        ply.maxletters = 0
    end
    ply.maxletters = ply.maxletters - 1
end

function ENT:Use(ply)
    if not ply:KeyDown(IN_ATTACK) then
        umsg.Start("ShowLetter", ply)
            umsg.Entity(self)
            umsg.Short(self.type)
            umsg.Vector(self:GetPos())
            local numParts = self.numPts
            umsg.Short(numParts)
            for a,b in pairs(self.Parts) do umsg.String(b) end
        umsg.End()
    else
        umsg.Start("KillLetter", ply)
        umsg.End()
    end
end

function ENT:SignLetter(ply)
    self:Setsigned(ply)
end

function ENT:onPlayerDisconnected(ply)
    if self.dt.owning_ent == ply then
        self:Remove()
    end
end

concommand.Add("_DarkRP_SignLetter", function(ply, cmd, args)
    if not args[1] or ply:EntIndex() == 0 then return end
    local letter = ents.GetByIndex(tonumber(args[1]))
    if not IsValid(letter) or letter:GetClass() ~= "letter" then return end
    letter:SignLetter(ply)
end)

local function removeLetters(ply, args)
    local target = DarkRP.findPlayer(args)

    if target then
        for k, v in pairs(ents.FindByClass("letter")) do
            if v.SID == target.SID then v:Remove() end
        end
    else
        -- Remove ALL letters
        for k, v in pairs(ents.FindByClass("letter")) do
            v:Remove()
        end
    end

    if ply:EntIndex() == 0 then
        DarkRP.log("Console force-removed all letters", Color(30, 30, 30))
    else
        DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-removed all letters", Color(30, 30, 30))
    end

    DarkRP.notify(ply, 0, 4, "All letters removed")
end
DarkRP.definePrivilegedChatCommand("removeletters", "DarkRP_AdminCommands", removeLetters)
