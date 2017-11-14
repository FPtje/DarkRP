hook.Add("PlayerBindPress", "Hobo sound", function(ply, bind, pressed)
    if ply == LocalPlayer() and ply:GetActiveWeapon():IsValid() and string.find(string.lower(bind), "attack2") and ply:GetActiveWeapon():GetClass() == "weapon_bugbait" then
        LocalPlayer():ConCommand("_hobo_emitsound")
    end
end)
