local function YellAsHobo(ply)
    if ply:EntIndex() == 0 then return end
    if not ply.nospamtime then
        ply.nospamtime = CurTime() - 2
    end
    if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].hobo or CurTime() < (ply.nospamtime + 1.3) or (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "weapon_bugbait") then
        return
    end
    ply.nospamtime = CurTime()
    local ran = math.random(1,4)
    if ran == 1 then
        ply:EmitSound("vo/npc/male01/gethellout.wav", 100, 100)
    elseif ran == 2 then
        ply:EmitSound("vo/npc/male01/no02.wav", 100, 100)
    elseif ran == 3 then
        ply:EmitSound("vo/npc/male01/watchout.wav", 100, 100)
    elseif ran == 4 then
        ply:EmitSound("vo/npc/male01/runforyourlife01.wav", 100, 100)
    end
end
concommand.Add("_hobo_emitsound", YellAsHobo)
