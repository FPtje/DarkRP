AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("cl_init.lua")

function ENT:Initialize()
    self:SetModel("models/extras/info_speech.mdl")

    self:SetMoveType(MOVETYPE_NOCLIP)
    self:SetSolid(SOLID_NONE)

end

function ENT:Think()
    if not IsValid(self.ply) then -- just in case
        self:Remove()
        return
    end

    self:SetNoDraw(self.ply:GetNoDraw())
    self:SetPos(self.ply:GetPos() + Vector(0, 0, 85))
end

util.AddNetworkString("DarkRP_ToggleChat")
local function ToggleChatIndicator(len, ply)
    if not IsValid(ply.ChatIndicator) then
        ply.ChatIndicator = ents.Create("chatindicator")
        ply.ChatIndicator.ply = ply -- plyception
        ply.ChatIndicator:SetPos(ply:GetPos() + Vector(0, 0, 85))
        ply.ChatIndicator:SetNoDraw(ply:GetNoDraw())
        ply.ChatIndicator:Spawn()
        ply.ChatIndicator:Activate()
    else
        ply.ChatIndicator:Remove()
    end
end
net.Receive("DarkRP_ToggleChat", ToggleChatIndicator)

local function RemoveChatIndicator(ply)
    if IsValid(ply.ChatIndicator) then
        ply.ChatIndicator:Remove()
    end
end
hook.Add("PlayerDisconnected", "Disc_RemoveIndicator", RemoveChatIndicator)
hook.Add("KeyPress", "Move_RemoveIndicator", RemoveChatIndicator) -- so people can't abuse the command.
hook.Add("PlayerDeath", "Die_RemoveIndicator", RemoveChatIndicator)
