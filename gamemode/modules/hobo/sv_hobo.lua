local sounds = {
    {
        range = 14,
        path = "npc/zombie/zombie_voice_idle"
    },
    {
        range = 6,
        path = "npc/zombie/zombie_pain"
    },
    {
        range = 3,
        path = "npc/zombie/zombie_alert"
    }
}

local function MakeZombieSoundsAsHobo(ply)
    if ply:EntIndex() == 0 then 
        return 
    end

    if not ply.nospamtime then
        ply.nospamtime = CurTime() - 2
    end

    local team = ply:Team()
    if not RPExtrateams[team] or not RPExtrateams[team].hobo or CurTime() < (ply.nospamtime + 1.3) or (ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() ~= "weapon_bugbait") then
        return
    end

    ply.nospamtime = CurTime()

    local ran = math.random(1, 3)
    local sound = sounds[ran]
    ply:EmitSound(sound.path .. math.random(1, sound.range) .. ".wav", 100, 100)
end

concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo)
