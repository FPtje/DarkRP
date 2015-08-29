local function onBought(ply, ent)
    for k,v in pairs(ent.Seats or {}) do
        if not IsValid(v) or not v:isKeysOwnable() then continue end
        v:keysOwn(ply)
    end
end
hook.Add("playerBoughtVehicle", "PassengerModCompatibility", onBought)
hook.Add("playerBoughtCustomVehicle", "PassengerModCompatibility", function(ply, _, ent) onBought(ply, ent) end)


local function onLocked(ent)
    -- Passenger mod
    for k,v in pairs(ent.Seats or {}) do
        v:Fire("lock", "", 0)
    end

    -- VUMod compatibility
    -- Locks passenger seats when the vehicle is locked.
    if ent:IsVehicle() and ent.VehicleTable and ent.VehicleTable.Passengers then
        for k,v in pairs(ent.VehicleTable.Passengers) do
            v.Ent:Fire("lock", "", 0)
        end
    end

    -- Locks the vehicle if you're unlocking a passenger seat:
    if IsValid(ent:GetParent()) and ent:GetParent():IsVehicle() then
        ent:GetParent():keysLock()
    end
end
hook.Add("onKeysLocked", "PassengerModCompatibility", onLocked)

local function onUnlocked(ent)
    -- Passenger mod
    for k,v in pairs(ent.Seats or {}) do
        v:Fire("unlock", "", 0)
    end

    -- VUMod
    if ent:IsVehicle() and ent.VehicleTable and ent.VehicleTable.Passengers then
        for k,v in pairs(ent.VehicleTable.Passengers) do
            v.Ent:Fire("unlock", "", 0)
        end
    end


    -- Unlocks the vehicle if you're unlocking a passenger seat:
    if IsValid(ent:GetParent()) and ent:GetParent():IsVehicle() then
        ent:GetParent():keysUnLock()
    end
end
hook.Add("onKeysUnlocked", "PassengerModCompatibility", onUnlocked)
