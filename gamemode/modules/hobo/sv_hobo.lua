local function MakeZombieSoundsAsHobo(ply)
    if ply:EntIndex() == 0 then return end
    if not ply.nospamtime then
        ply.nospamtime = CurTime() - 2
    end

    local Team = ply:Team()
    if not RPExtraTeams[Team] or not RPExtraTeams[Team].hobo or CurTime() < (ply.nospamtime + 1.3) or (ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() ~= "weapon_bugbait") then
        return
    end
    ply.nospamtime = CurTime()
    local ran = math.random(1,3)
    if ran == 1 then
        ply:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 14) .. ".wav", 100, 100)
    elseif ran == 2 then
        ply:EmitSound("npc/zombie/zombie_pain" .. math.random(1, 6) .. ".wav", 100, 100)
    elseif ran == 3 then
        ply:EmitSound("npc/zombie/zombie_alert" .. math.random(1, 3) .. ".wav", 100, 100)
    end
end
concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo)
