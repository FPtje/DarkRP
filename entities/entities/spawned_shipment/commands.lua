--[[---------------------------------------------------------------------------
Create a shipment from a spawned_weapon
---------------------------------------------------------------------------]]
local function createShipment(ply, args)
    local id = tonumber(args) or -1
    local ent = Entity(id)

    ent = IsValid(ent) and ent or ply:GetEyeTrace().Entity

    if not IsValid(ent) or not ent.IsSpawnedWeapon or ent.PlayerUse == false then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    local pos = ent:GetPos()

    if pos:DistToSqr(ply:GetShootPos()) > 16900 or not pos:isInSight({ent, ply} , ply) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("distance_too_big"))
        return
    end

    local playerUse = ent.PlayerUse
    ent.PlayerUse = false

    local shipID
    for k, v in pairs(CustomShipments) do
        if v.entity == ent:GetWeaponClass() then
            shipID = k
            break
        end
    end

    if not shipID or ent.USED then
        ent.PlayerUse = playerUse
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/makeshipment", ""))
        return
    end

    local crate = ents.Create(CustomShipments[shipID].shipmentClass or "spawned_shipment")
    if not IsValid(crate) then
        ent.PlayerUse = playerUse
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/makeshipment", ""))
        return
    end

    crate.SID = ply.SID
    crate:SetPos(ent:GetPos())
    crate.nodupe = true
    crate:SetContents(shipID, ent:Getamount())
    crate:Spawn()
    crate:SetPlayer(ply)
    crate.clip1 = ent.clip1
    crate.clip2 = ent.clip2
    crate.ammoadd = ent.ammoadd or 0

    SafeRemoveEntity(ent)

    local phys = crate:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end
end
DarkRP.defineChatCommand("makeshipment", createShipment, 0.3)

--[[---------------------------------------------------------------------------
Split a shipment in two
---------------------------------------------------------------------------]]
local function splitShipment(ply, args)
    local id = tonumber(args) or -1
    local ent = Entity(id)

    ent = IsValid(ent) and ent or ply:GetEyeTrace().Entity

    if not IsValid(ent) or not ent.IsSpawnedShipment then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    if ent:Getcount() < 2 or ent.locked or ent.USED then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("shipment_cannot_split"))
        return
    end

    local pos = ent:GetPos()

    if pos:DistToSqr(ply:GetShootPos()) > 16900 or not pos:isInSight({ent, ply} , ply) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("distance_too_big"))
        return
    end

    local count = math.floor(ent:Getcount() / 2)
    ent:Setcount(ent:Getcount() - count)

    local crate = ents.Create("spawned_shipment")
    if not IsValid(crate) then
        ent:Setcount(ent:Getcount() + count)
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/splitshipment", ""))
        return
    end

    ent:StartSpawning()

    crate.locked = true
    crate.SID = ply.SID
    crate:SetPos(ent:GetPos())
    crate.nodupe = true
    crate:SetContents(ent:Getcontents(), count)
    crate:SetPlayer(ply)

    crate.clip1 = ent.clip1
    crate.clip2 = ent.clip2
    crate.ammoadd = ent.ammoadd

    crate:Spawn()

    local phys = crate:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end
end
DarkRP.defineChatCommand("splitshipment", splitShipment, 0.3)
