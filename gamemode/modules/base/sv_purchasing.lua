function DarkRP.hooks:canBuyPistol(ply, shipment)
    local price = shipment.getPrice and shipment.getPrice(ply, shipment.pricesep) or shipment.pricesep or 0

    if not GAMEMODE:CustomObjFitsMap(shipment) then
        return false, false, "Custom object does not fit map"
    end

    if ply:isArrested() then
        return false, false, DarkRP.getPhrase("unable", "/buy", "")
    end

    if shipment.customCheck and not shipment.customCheck(ply) then
        local message = isfunction(shipment.CustomCheckFailMsg) and shipment.CustomCheckFailMsg(ply, shipment) or
                shipment.CustomCheckFailMsg or
                DarkRP.getPhrase("not_allowed_to_purchase")
        return false, false, message
    end

    if not ply:canAfford(price) then
        return false, false, DarkRP.getPhrase("cant_afford", "/buy")
    end

    if not GAMEMODE.Config.restrictbuypistol or
    (GAMEMODE.Config.restrictbuypistol and (not shipment.allowed[1] or table.HasValue(shipment.allowed, ply:Team()))) then
        return true
    end

    return false
end

local function BuyPistol(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    if not GAMEMODE.Config.enablebuypistol then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/buy", ""))
        return ""
    end

    if GAMEMODE.Config.noguns then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/buy", ""))
        return ""
    end

    local shipment = DarkRP.getShipmentByName(args)
    if not shipment or not shipment.separate then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", DarkRP.getPhrase("weapon_")))
        return ""
    end

    local canbuy, suppress, message, price = hook.Call("canBuyPistol", DarkRP.hooks, ply, shipment)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or shipment.getPrice and shipment.getPrice(ply, shipment.pricesep) or shipment.pricesep or 0

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    local defaultClip, clipSize
    local wep_tbl = weapons.Get(shipment.entity)
    if wep_tbl and wep_tbl.Primary then
        defaultClip = wep_tbl.Primary.DefaultClip
        clipSize = wep_tbl.Primary.ClipSize
    end

    local weapon = ents.Create("spawned_weapon")
    weapon:SetModel(shipment.model)
    weapon:SetWeaponClass(shipment.entity)
    weapon:SetPos(tr.HitPos)
    weapon.ammoadd = shipment.spareammo or defaultClip
    weapon.clip1 = shipment.clip1 or clipSize
    weapon.clip2 = shipment.clip2
    weapon.nodupe = true
    weapon:Spawn()

    DarkRP.placeEntity(weapon, tr, ply)

    if shipment.onBought then
        shipment.onBought(ply, shipment, weapon)
    end
    hook.Call("playerBoughtPistol", nil, ply, shipment, weapon, cost)

    if IsValid(weapon) then
        ply:addMoney(-cost)
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", args, DarkRP.formatMoney(cost)))
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buy", args))
    end

    return ""
end
DarkRP.defineChatCommand("buy", BuyPistol, 0.2)

function DarkRP.hooks:canBuyShipment(ply, shipment)
    if not GAMEMODE:CustomObjFitsMap(shipment) then
        return false, false, "Custom object does not fit map"
    end

    if ply.LastShipmentSpawn and ply.LastShipmentSpawn > (CurTime() - GAMEMODE.Config.ShipmentSpamTime) then
        return false, false, DarkRP.getPhrase("shipment_antispam_wait")
    end

    if ply:isArrested() then
        return false, false, DarkRP.getPhrase("unable", "/buyshipment", "")
    end

    if shipment.customCheck and not shipment.customCheck(ply) then
        local message = isfunction(shipment.CustomCheckFailMsg) and shipment.CustomCheckFailMsg(ply, shipment) or
                shipment.CustomCheckFailMsg or
                DarkRP.getPhrase("not_allowed_to_purchase")
        return false, false, message
    end

    local canbecome = false
    for _, b in pairs(shipment.allowed) do
        if ply:Team() == b then
            canbecome = true
            break
        end
    end

    if not canbecome then
        return false, false, DarkRP.getPhrase("incorrect_job", "/buyshipment")
    end

    local cost = shipment.getPrice and shipment.getPrice(ply, shipment.price) or shipment.price

    if not ply:canAfford(cost) then
        return false, false, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("shipment"))
    end

    if not shipment.allowPurchaseWhileDead and not ply:Alive() then
        return false, false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("buy_x", DarkRP.getPhrase("shipments")))
    end

    return true
end

local function BuyShipment(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    local found, foundKey = DarkRP.getShipmentByName(args)
    if not found or found.noship or not GAMEMODE:CustomObjFitsMap(found) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", DarkRP.getPhrase("shipment")))
        return ""
    end

    local canbuy, suppress, message, price = hook.Call("canBuyShipment", DarkRP.hooks, ply, found)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or found.getPrice and found.getPrice(ply, found.price) or found.price

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    local crate = ents.Create(found.shipmentClass or "spawned_shipment")
    crate.SID = ply.SID
    crate:Setowning_ent(ply)
    crate:SetContents(foundKey, found.amount)

    crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
    crate.nodupe = true
    crate.ammoadd = found.spareammo
    crate.clip1 = found.clip1
    crate.clip2 = found.clip2
    crate:Spawn()
    crate:SetPlayer(ply)

    DarkRP.placeEntity(crate, tr, ply)

    local phys = crate:GetPhysicsObject()
    phys:Wake()
    if found.weight then
        phys:SetMass(found.weight)
    end

    if CustomShipments[foundKey].onBought then
        CustomShipments[foundKey].onBought(ply, CustomShipments[foundKey], crate)
    end
    hook.Call("playerBoughtShipment", nil, ply, CustomShipments[foundKey], crate, cost)

    if IsValid(crate) then
        ply:addMoney(-cost)
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", args, DarkRP.formatMoney(cost)))
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyshipment", arg))
    end

    ply.LastShipmentSpawn = CurTime()

    return ""
end
DarkRP.defineChatCommand("buyshipment", BuyShipment)

function DarkRP.hooks:canBuyVehicle(ply, vehicle)
    if not vehicle.allowPurchaseWhileDead and not ply:Alive() then
        return false, false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("buy_x", vehicle.name))
    end
    if not GAMEMODE:CustomObjFitsMap(vehicle) then
        return false, false, "Custom object does not fit map"
    end

    if ply:isArrested() then
        return false, false, DarkRP.getPhrase("unable", "/buyvehicle", "")
    end

    if vehicle.allowed and not table.HasValue(vehicle.allowed, ply:Team()) then
        return false, false, DarkRP.getPhrase("incorrect_job", "/buyvehicle")
    end

    if vehicle.customCheck and not vehicle.customCheck(ply) then
        local message = isfunction(vehicle.CustomCheckFailMsg) and vehicle.CustomCheckFailMsg(ply, vehicle) or
                vehicle.CustomCheckFailMsg or
                DarkRP.getPhrase("not_allowed_to_purchase")
        return false, false, message
    end

    ply.Vehicles = ply.Vehicles or 0
    if GAMEMODE.Config.maxvehicles and ply.Vehicles >= GAMEMODE.Config.maxvehicles then
        return false, false, DarkRP.getPhrase("limit", DarkRP.getPhrase("vehicle"))
    end

    local cost = vehicle.getPrice and vehicle.getPrice(ply, vehicle.price) or vehicle.price
    if not ply:canAfford(cost) then
        return false, false, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("vehicle"))
    end

    return true
end

local function BuyVehicle(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    local found = false
    -- Allow people to have multiple vehicles with the same name
    -- vehicles are bought through the command
    for k, v in pairs(CustomVehicles) do
        if v.command and string.lower(v.command) == string.lower(args) then
            found = CustomVehicles[k]
            break
        end
    end

    if not found then
        for k,v in pairs(CustomVehicles) do
            if string.lower(v.name) == string.lower(args) then found = CustomVehicles[k] break end
        end
    end

    if not found then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", DarkRP.getPhrase("vehicle")))
        return ""
    end

    local Vehicle = DarkRP.getAvailableVehicles()[found.name]
    if not Vehicle then DarkRP.notify(ply, 1, 4, "Incorrect vehicle, fix your vehicles.") return "" end

    local canbuy, suppress, message, price = hook.Call("canBuyVehicle", DarkRP.hooks, ply, found)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or found.getPrice and found.getPrice(ply, found.price) or found.price

    ply:addMoney(-cost)
    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", found.label or found.name, DarkRP.formatMoney(cost)))

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * (found.distance or 85)
    trace.filter = ply
    local tr = util.TraceLine(trace)

    local ent = ents.Create(Vehicle.Class)
    if not ent:IsValid() then error("Vehicle '" .. Vehicle.Class .. "' does not exist or is not valid.") end

    ent:SetModel(Vehicle.Model)
    if Vehicle.KeyValues then
        for k, v in pairs(Vehicle.KeyValues) do
            ent:SetKeyValue(k, v)
        end
    end

    ent:SetPos(tr.HitPos)
    ent.VehicleName = found.name
    ent.VehicleTable = Vehicle
    ent:Spawn()
    ent:Activate()
    ent.SID = ply.SID
    ent.ClassOverride = Vehicle.Class
    if Vehicle.Members then
        table.Merge(ent, Vehicle.Members)
    end
    ent:CPPISetOwner(ply)
    ent:keysOwn(ply)

    DarkRP.placeEntity(ent, tr, ply)

    local angOff = found.angle or Angle(0, 0, 0)
    ent:SetAngles(ent:GetAngles() + angOff)

    hook.Call("PlayerSpawnedVehicle", GAMEMODE, ply, ent) -- VUMod compatability
    hook.Call("playerBoughtCustomVehicle", nil, ply, found, ent, cost)

    if found.onBought then
        found.onBought(ply, found, ent)
    end

    return ""
end
DarkRP.defineChatCommand("buyvehicle", BuyVehicle)

function DarkRP.hooks:canBuyAmmo(ply, ammo)
    if not GAMEMODE:CustomObjFitsMap(ammo) then
        return false, false, "Custom object does not fit map"
    end

    if ply:isArrested() then
        return false, false, DarkRP.getPhrase("unable", "/buyammo", "")
    end

    if ammo.allowed and not table.HasValue(ammo.allowed, ply:Team()) then
        return false, false, DarkRP.getPhrase("incorrect_job", "/buyammo")
    end

    if ammo.customCheck and not ammo.customCheck(ply) then
        local message = isfunction(ammo.CustomCheckFailMsg) and ammo.CustomCheckFailMsg(ply, ammo) or
            ammo.CustomCheckFailMsg or
            DarkRP.getPhrase("not_allowed_to_purchase")
        return false, false, message
    end

    local cost = ammo.getPrice and ammo.getPrice(ply, ammo.price) or ammo.price
    if not ply:canAfford(cost) then
        return false, false, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("ammo"))
    end

    return true
end

local function BuyAmmo(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    if GAMEMODE.Config.noguns then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", DarkRP.getPhrase("ammo"), ""))
        return ""
    end

    local found
    local num = tonumber(args)
    if num and GAMEMODE.AmmoTypes[num] then
        found = GAMEMODE.AmmoTypes[num]
    else
        for _, v in pairs(GAMEMODE.AmmoTypes) do
            if v.ammoType ~= args then continue end

            found = v
            break
        end
    end

    if not found then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", DarkRP.getPhrase("ammo")))
        return ""
    end

    local canbuy, suppress, message, price = hook.Call("canBuyAmmo", DarkRP.hooks, ply, found)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or found.getPrice and found.getPrice(ply, found.price) or found.price

    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", found.name, DarkRP.formatMoney(cost)))
    ply:addMoney(-cost)

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    local ammo = ents.Create("spawned_ammo")
    ammo:SetModel(found.model)
    ammo:SetPos(tr.HitPos)
    ammo.nodupe = true
    ammo.amountGiven, ammo.ammoType = found.amountGiven, found.ammoType
    ammo:Spawn()

    DarkRP.placeEntity(ammo, tr, ply)

    hook.Call("playerBoughtAmmo", nil, ply, found, ammo, cost)

    return ""
end
DarkRP.defineChatCommand("buyammo", BuyAmmo, 1)

local function SetPrice(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    local price = DarkRP.toInt(args)
    if not price then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end
    price = math.Clamp(price, GAMEMODE.Config.pricemin, (GAMEMODE.Config.pricecap ~= 0 and GAMEMODE.Config.pricecap) or 500)
    local trace = {}

    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    local ent = tr.Entity

    if IsValid(ent) and ent.CanSetPrice and ent.SID == ply.SID then
        ent:Setprice(price)
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("any_lab")))
    end
    return ""
end
DarkRP.defineChatCommand("price", SetPrice)
DarkRP.defineChatCommand("setprice", SetPrice)
