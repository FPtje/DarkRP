local meta = FindMetaTable("Player")

function meta:newHungerData()
    self:setSelfDarkRPVar("Energy", 100)
end

function meta:hungerUpdate()
    if not GAMEMODE.Config.hungerspeed then return end

    local energy = self:getDarkRPVar("Energy")
    local override = hook.Call("hungerUpdate", nil, self, energy)

    if override then return end

    self:setSelfDarkRPVar("Energy", energy and math.Clamp(energy - GAMEMODE.Config.hungerspeed, 0, 100) or 100)

    if self:getDarkRPVar("Energy") == 0 then
        local health = self:Health()

        local dmg = DamageInfo()
        dmg:SetDamage(GAMEMODE.Config.starverate)
        dmg:SetInflictor(self)
        dmg:SetAttacker(self)
        dmg:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_NERVEGAS))

        self:TakeDamageInfo(dmg)

        if health - GAMEMODE.Config.starverate <= 0 then
            self.Slayed = true
            hook.Call("playerStarved", nil, self)
        end
    end
end
