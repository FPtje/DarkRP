local function drawIndicator(ply)
    if not ply:IsTyping() then
        if ply.indicator then
            ply.indicator:Remove()
            ply.indicator = nil
        end
        return
    end

    ply.indicator = ply.indicator or ClientsideModel("models/extras/info_speech.mdl", RENDERGROUP_OPAQUE)
    ply.indicator:SetNoDraw(true)
    ply.indicator:SetModelScale(0.6)

    local ragdoll = ply:GetRagdollEntity()
    if IsValid(ragdoll) then
        local maxs = ragdoll:OBBMaxs()
        ply.indicator:SetPos(ragdoll:GetPos() + Vector(0, 0, maxs.z) + Vector(0, 0, 12))
    else
        ply.indicator:SetPos(ply:GetPos() + Vector(0, 0, 72 * ply:GetModelScale()) + Vector(0, 0, 12))
    end

    local angle = ply.indicator:GetAngles()
    local curTime = CurTime()
    ply.indicator:SetAngles(Angle(angle.p, (angle.y + (360 * (curTime - (ply.indicator.lastDraw or 0)))) % 360, angle.r))
    ply.indicator.lastDraw = curTime

    ply.indicator:SetupBones()
    ply.indicator:DrawModel()
end

hook.Add("PostPlayerDraw", "DarkRP_ChatIndicator", drawIndicator)
hook.Add("CreateClientsideRagdoll", "DarkRP_ChatIndicator", function(ent, ragdoll)
    if not ent:IsPlayer() then return end

    local oldRenderOverride = ragdoll.RenderOverride -- Just in case - best be safe
    ragdoll.RenderOverride = function(self)
        if ent:IsValid() then
            drawIndicator(ent)
        end

        if oldRenderOverride then
            oldRenderOverride(self)
        else
            self:DrawModel()
        end
    end
end)

-- CSEnts aren't GC'd.
-- https://github.com/Facepunch/garrysmod-issues/issues/1387
gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "DarkRP_ChatIndicator", function(data)
    local ply = Player(data.userid)

    if not IsValid(ply) then return end -- disconnected while joining

    if ply.indicator then
        ply.indicator:Remove()
        ply.indicator = nil
    end
end)
