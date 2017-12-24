local function onBought(ply, ent)
    for _, v in pairs(ent.Seats or {}) do
        if not IsValid(v) or not v:isKeysOwnable() then continue end
        v:keysOwn(ply)
    end
end
hook.Add("playerBoughtVehicle", "PassengerModCompatibility", onBought)
hook.Add("playerBoughtCustomVehicle", "PassengerModCompatibility", function(ply, _, ent) onBought(ply, ent) end)


local function onLocked(ent)
    -- Passenger mod
    for _, v in pairs(ent.Seats or {}) do
        v:Fire("lock", "", 0)
    end

    -- VUMod compatibility
    -- Locks passenger seats when the vehicle is locked.
    if ent:IsVehicle() and ent.VehicleTable and ent.VehicleTable.Passengers then
        for _, v in pairs(ent.VehicleTable.Passengers) do
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
    for _, v in pairs(ent.Seats or {}) do
        v:Fire("unlock", "", 0)
    end

    -- VUMod
    if ent:IsVehicle() and ent.VehicleTable and ent.VehicleTable.Passengers then
        for _ ,v in pairs(ent.VehicleTable.Passengers) do
            v.Ent:Fire("unlock", "", 0)
        end
    end


    -- Unlocks the vehicle if you're unlocking a passenger seat:
    if IsValid(ent:GetParent()) and ent:GetParent():IsVehicle() then
        ent:GetParent():keysUnLock()
    end
end
hook.Add("onKeysUnlocked", "PassengerModCompatibility", onUnlocked)

local function ejectOnRam(success, ply, trace)
    local ent = trace.Entity
    if not success or not IsValid(ent) or not ent:IsVehicle() then return end
    if not ent.VehicleTable or not ent.VehicleTable.Passengers then return end

    for _, v in pairs(ent.VehicleTable.Passengers) do
        local passenger = v:GetDriver()
        if IsValid(passenger) then passenger:ExitVehicle() end
    end
end
hook.Add("onDoorRamUsed", "PassengerModCompatibility", ejectOnRam)
