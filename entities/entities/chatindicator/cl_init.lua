include("shared.lua")

function ENT:Initialize()
    self:SetModelScale(0.6, 0)
end

function ENT:Draw()
    self:DrawModel()

    --Going to let the client handle the rotations, less server strain. (Feel free to change back). ~Eusion.
    local angles = self:GetAngles()
    self:SetAngles(Angle(angles.p, angles.y + 5, angles.r))
end

local function ToggleChat()
    net.Start("DarkRP_ToggleChat")
    net.SendToServer()
end
hook.Add("StartChat", "StartChatIndicator", ToggleChat)
hook.Add("FinishChat", "EndChatIndicator", ToggleChat)
