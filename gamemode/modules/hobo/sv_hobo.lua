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

local function MakeZombieSoundsAsHobo(pl)
    if pl:EntIndex() == 0 then 
        return 
    end

    if not pl.nospamtime then
        pl.nospamtime = CurTime() - 2
    end

    local team = pl:Team()
    if not RPExtrateams[team] or not RPExtrateams[team].hobo or CurTime() < (pl.nospamtime + 1.3) or (pl:GetActiveWeapon():IsValid() and pl:GetActiveWeapon():GetClass() ~= "weapon_bugbait") then
        return
    end

    pl.nospamtime = CurTime()

    local ran = math.random(1, 3)
    local sound = sounds[ran]
    pl:EmitSound(sound.path .. math.random(1, sound.range) .. ".wav", 100, 100)
end

concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo)
