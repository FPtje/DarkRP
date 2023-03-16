local meta = FindMetaTable("Entity")
local pmeta = FindMetaTable("Player")

--[[---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------]]

function meta:doorIndex()
    return self:CreatedByMap() and self:MapCreationID() or nil
end

function DarkRP.doorToEntIndex(num)
    local ent = ents.GetMapCreatedEntity(num)

    return IsValid(ent) and ent:EntIndex() or nil
end

function DarkRP.doorIndexToEnt(num)
    return ents.GetMapCreatedEntity(num) or NULL
end

function meta:isLocked()
    local save = self:GetSaveTable()
    return save and ((self:isDoor() and save.m_bLocked) or (self:IsVehicle() and save.VehicleLocked))
end

function meta:keysLock()
    self:Fire("lock", "", 0)
    if isfunction(self.Lock) then self:Lock(true) end -- SCars
    if IsValid(self.EntOwner) and self.EntOwner ~= self then return self.EntOwner:keysLock() end -- SCars

    hook.Call("onKeysLocked", nil, self)
end

function meta:keysUnLock()
    self:Fire("unlock", "", 0)
    if isfunction(self.UnLock) then self:UnLock(true) end -- SCars
    if IsValid(self.EntOwner) and self.EntOwner ~= self then return self.EntOwner:keysUnLock() end -- SCars

    hook.Call("onKeysUnlocked", nil, self)
end

function meta:keysOwn(ply)
    if self:isKeysAllowedToOwn(ply) then
        self:addKeysDoorOwner(ply)
        return
    end

    local Owner = self:CPPIGetOwner()

    -- Increase vehicle count
    if self:IsVehicle() then
        if IsValid(ply) then
            ply.Vehicles = ply.Vehicles or 0
            ply.Vehicles = ply.Vehicles + 1

            self.SID = ply.SID
        end

        -- Decrease vehicle count of the original owner
        if IsValid(Owner) and Owner ~= ply then
            Owner.Vehicles = Owner.Vehicles or 1
            Owner.Vehicles = Owner.Vehicles - 1
        end
    end

    if self:IsVehicle() then
        self:CPPISetOwner(ply)
    end

    if not self:isKeysOwned() and not self:isKeysOwnedBy(ply) then
        local doorData = self:getDoorData()
        doorData.owner = ply:UserID()
        DarkRP.updateDoorData(self, "owner")
    end

    ply.OwnedNumz = ply.OwnedNumz or 0
    if ply.OwnedNumz == 0 and GAMEMODE.Config.propertytax then
        timer.Create(ply:SteamID64() .. "propertytax", 270, 0, function() ply.doPropertyTax(ply) end)
    end

    ply.OwnedNumz = ply.OwnedNumz + 1

    ply.Ownedz[self:EntIndex()] = self
end

function meta:keysUnOwn(ply)
    if not ply then
        ply = self:getDoorOwner()

        if not IsValid(ply) then return end
    end

    if self:isMasterOwner(ply) then
        local doorData = self:getDoorData()
        self:removeAllKeysExtraOwners()
        self:setKeysTitle(nil)
        doorData.owner = nil
        DarkRP.updateDoorData(self, "owner")
    else
        self:removeKeysDoorOwner(ply)
    end

    ply.Ownedz[self:EntIndex()] = nil
    ply.OwnedNumz = math.Clamp((ply.OwnedNumz or 1) - 1, 0, math.huge)
end

function pmeta:keysUnOwnAll()
    for entIndex, ent in pairs(self.Ownedz or {}) do
        if not IsValid(ent) or not ent:isKeysOwnable() then self.Ownedz[entIndex] = nil continue end
        if ent:isMasterOwner(self) then
            ent:Fire("unlock", "", 0.6)
        end
        ent:keysUnOwn(self)
    end

    for _, ply in ipairs(player.GetAll()) do
        if ply == self then continue end

        for _, ent in pairs(ply.Ownedz or {}) do
            if IsValid(ent) and ent:isKeysAllowedToOwn(self) then
                ent:removeKeysAllowedToOwn(self)
            end
        end
    end

    self.OwnedNumz = 0
end

local function taxesUnOwnAll(ply, taxables)
    for _, ent in pairs(taxables) do
        if ent:isMasterOwner(ply) then
            ent:Fire("unlock", "", 0.6)
        end

        ent:keysUnOwn(ply)
    end
end

function pmeta:doPropertyTax()
    if not GAMEMODE.Config.propertytax then return end
    if self:isCP() and GAMEMODE.Config.cit_propertytax then return end

    local taxables = {}

    for entIndex, ent in pairs(self.Ownedz or {}) do
        if not IsValid(ent) or not ent:isKeysOwnable() then self.Ownedz[entIndex] = nil continue end
        local isAllowed = hook.Call("canTaxEntity", nil, self, ent)
        if isAllowed == false then continue end

        table.insert(taxables, ent)
    end

    -- co-owned doors
    for _, ply in ipairs(player.GetAll()) do
        if ply == self then continue end

        for _, ent in pairs(ply.Ownedz or {}) do
            if not IsValid(ent) or not ent:isKeysOwnedBy(self) then continue end

            local isAllowed = hook.Call("canTaxEntity", nil, self, ent)
            if isAllowed == false then continue end

            table.insert(taxables, ent)
        end
    end

    local numowned = #taxables

    if numowned <= 0 then return end

    local price = 10
    local tax = price * numowned + math.random(-5, 5)

    local shouldTax, taxOverride = hook.Call("canPropertyTax", nil, self, tax)

    if shouldTax == false then return end

    tax = taxOverride or tax
    if tax == 0 then return end

    local canAfford = self:canAfford(tax)

    if canAfford then
        self:addMoney(-tax)
        DarkRP.notify(self, 0, 5, DarkRP.getPhrase("property_tax", DarkRP.formatMoney(tax)))
    else
        taxesUnOwnAll(self, taxables)
        DarkRP.notify(self, 1, 8, DarkRP.getPhrase("property_tax_cant_afford"))
    end

    hook.Call("onPropertyTax", nil, self, tax, canAfford)
end

function pmeta:initiateTax()
    local taxtime = GAMEMODE.Config.wallettaxtime
    local uid = self:SteamID64() -- so we can destroy the timer if the player leaves
    timer.Create("rp_tax_" .. uid, taxtime or 600, 0, function()
        if not IsValid(self) then
            timer.Remove("rp_tax_" .. uid)

            return
        end

        if not GAMEMODE.Config.wallettax then
            return -- Don't remove the hook in case it's turned on afterwards.
        end

        local money = self:getDarkRPVar("money")
        local mintax = GAMEMODE.Config.wallettaxmin / 100
        local maxtax = GAMEMODE.Config.wallettaxmax / 100 -- convert to decimals for percentage calculations
        local startMoney = GAMEMODE.Config.startingmoney


        -- Variate the taxes between twice the starting money ($1000 by default) and 200 - 2 times the starting money (100.000 by default)
        local tax = (money - (startMoney * 2)) / (startMoney * 198)
        tax = math.Min(maxtax, mintax + (maxtax - mintax) * tax)

        local taxAmount = tax * money

        local shouldTax, amount = hook.Call("canTax", GAMEMODE, self, taxAmount)

        if shouldTax == false then return end

        taxAmount = amount or taxAmount
        taxAmount = math.Max(0, taxAmount)

        self:addMoney(-taxAmount)
        DarkRP.notify(self, 3, 7, DarkRP.getPhrase("taxday", math.Round(taxAmount / money * 100, 3)))

        hook.Call("onPaidTax", DarkRP.hooks, self, tax, money)
    end)
end

function GM:canTax(ply)
    -- Don't tax players if they have less than twice the starting amount
    if ply:getDarkRPVar("money") < (GAMEMODE.Config.startingmoney * 2) then return false end
end

--[[---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------]]
local function SetDoorOwnable(ply)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return
    end

    if IsValid(ent:getDoorOwner()) then
        ent:keysUnOwn(ent:getDoorOwner())
    end
    ent:setKeysNonOwnable(not ent:getKeysNonOwnable())
    ent:removeAllKeysExtraOwners()
    ent:removeAllKeysAllowedToOwn()
    ent:removeAllKeysDoorTeams()
    ent:setDoorGroup(nil)
    ent:setKeysTitle(nil)

    -- Save it for future map loads
    DarkRP.storeDoorData(ent)
    DarkRP.storeDoorGroup(ent, nil)
    DarkRP.storeTeamDoorOwnability(ent)

    return ""
end
DarkRP.definePrivilegedChatCommand("toggleownable", "DarkRP_ChangeDoorSettings", SetDoorOwnable)

local function SetDoorGroupOwnable(ply, arg)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return
    end

    if not RPExtraTeamDoors[arg] and arg ~= "" then DarkRP.notify(ply, 1, 10, DarkRP.getPhrase("door_group_doesnt_exist")) return "" end

    ent:keysUnOwn()


    ent:removeAllKeysDoorTeams()
    local group = arg ~= "" and arg or nil
    ent:setDoorGroup(group)

    -- Save it for future map loads
    DarkRP.storeDoorGroup(ent, group)
    DarkRP.storeTeamDoorOwnability(ent)


    DarkRP.notify(ply, 0, 8, DarkRP.getPhrase("door_group_set"))
    return ""
end
DarkRP.definePrivilegedChatCommand("togglegroupownable", "DarkRP_ChangeDoorSettings", SetDoorGroupOwnable)

local function SetDoorTeamOwnable(ply, arg)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return ""
    end

    arg = tonumber(arg)
    if not arg then DarkRP.notify(ply, 1, 10, DarkRP.getPhrase("job_doesnt_exist")) return "" end
    if not RPExtraTeams[arg] and arg ~= nil then DarkRP.notify(ply, 1, 10, DarkRP.getPhrase("job_doesnt_exist")) return "" end
    if IsValid(ent:getDoorOwner()) then
        ent:keysUnOwn(ent:getDoorOwner())
    end

    ent:setDoorGroup(nil)
    DarkRP.storeDoorGroup(ent, nil)

    local doorTeams = ent:getKeysDoorTeams()
    if not doorTeams or not doorTeams[arg] then
        ent:addKeysDoorTeam(arg)
    else
        ent:removeKeysDoorTeam(arg)
    end

    DarkRP.notify(ply, 0, 8, DarkRP.getPhrase("door_group_set"))
    DarkRP.storeTeamDoorOwnability(ent)

    ent:keysUnOwn()
    return ""
end
DarkRP.definePrivilegedChatCommand("toggleteamownable", "DarkRP_ChangeDoorSettings", SetDoorTeamOwnable)

local function OwnDoor(ply)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or not ent:isKeysOwnable() or ply:GetPos():DistToSqr(ent:GetPos()) >= 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return ""
    end

    local Owner = ent:CPPIGetOwner()

    if ply:isArrested() then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("door_unown_arrested"))
        return ""
    end

    if ent:getKeysNonOwnable() or ent:getKeysDoorGroup() or not fn.Null(ent:getKeysDoorTeams() or {}) then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("door_unownable"))
        return ""
    end

    if ent:isKeysOwnedBy(ply) then
        local bAllowed, strReason = hook.Call("playerSell" .. (ent:IsVehicle() and "Vehicle" or "Door"), GAMEMODE, ply, ent)

        if bAllowed == false then
            if strReason and strReason ~= "" then
                DarkRP.notify(ply, 1, 4, strReason)
            end

            return ""
        end

        if ent:isMasterOwner(ply) then
            ent:removeAllKeysExtraOwners()
            ent:removeAllKeysAllowedToOwn()
            ent:Fire("unlock", "", 0)
        end

        ent:keysUnOwn(ply)
        ent:setKeysTitle(nil)
        local GiveMoneyBack = math.floor((hook.Call("get" .. (ent:IsVehicle() and "Vehicle" or "Door") .. "Cost", GAMEMODE, ply, ent) * 0.666) + 0.5)
        hook.Call("playerKeysSold", GAMEMODE, ply, ent, GiveMoneyBack)
        ply:addMoney(GiveMoneyBack)
        local bSuppress = hook.Call("hideSellDoorMessage", GAMEMODE, ply, ent)
        if not bSuppress then
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("door_sold", DarkRP.formatMoney(GiveMoneyBack)))
        end

    else
        if ent:isKeysOwned() and not ent:isKeysAllowedToOwn(ply) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("door_already_owned"))
            return ""
        end

        local iCost = hook.Call("get" .. (ent:IsVehicle() and "Vehicle" or "Door") .. "Cost", GAMEMODE, ply, ent)
        if not ply:canAfford(iCost) then
            DarkRP.notify(ply, 1, 4, ent:IsVehicle() and DarkRP.getPhrase("vehicle_cannot_afford") or DarkRP.getPhrase("door_cannot_afford"))
            return ""
        end

        local bAllowed, strReason, bSuppress = hook.Call("playerBuy" .. (ent:IsVehicle() and "Vehicle" or "Door"), GAMEMODE, ply, ent)
        if bAllowed == false then
            if strReason and strReason ~= "" then
                DarkRP.notify(ply, 1, 4, strReason)
            end

            return ""
        end

        local bVehicle = ent:IsVehicle()

        if bVehicle and (ply.Vehicles or 0) >= GAMEMODE.Config.maxvehicles and Owner ~= ply then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", DarkRP.getPhrase("vehicle")))
            return ""
        end

        if not bVehicle and (ply.OwnedNumz or 0) >= GAMEMODE.Config.maxdoors then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", DarkRP.getPhrase("door")))
            return ""
        end

        ply:addMoney(-iCost)
        if not bSuppress then
            DarkRP.notify(ply, 0, 4, bVehicle and DarkRP.getPhrase("vehicle_bought", DarkRP.formatMoney(iCost), "") or DarkRP.getPhrase("door_bought", DarkRP.formatMoney(iCost), ""))
        end

        ent:keysOwn(ply)
        hook.Call("playerBought" .. (bVehicle and "Vehicle" or "Door"), GAMEMODE, ply, ent, iCost)
    end

    return ""
end
DarkRP.defineChatCommand("toggleown", OwnDoor)

local function UnOwnAll(ply, cmd, args)
    local amount = 0
    local cost = 0

    local unownables = {}
    for entIndex, ent in pairs(ply.Ownedz or {}) do
        if not IsValid(ent) or not ent:isKeysOwnable() then ply.Ownedz[entIndex] = nil continue end
        table.insert(unownables, ent)
    end

    for _, otherPly in ipairs(player.GetAll()) do
        if ply == otherPly then continue end

        for _, ent in pairs(otherPly.Ownedz or {}) do
            if IsValid(ent) and ent:isKeysOwnedBy(ply) then
                table.insert(unownables, ent)
            end
        end
    end

    for entIndex, ent in pairs(unownables) do
        local bAllowed, _strReason = hook.Call("playerSell" .. (ent:IsVehicle() and "Vehicle" or "Door"), GAMEMODE, ply, ent)

        if bAllowed == false then continue end

        if ent:isMasterOwner(ply) then
            ent:Fire("unlock", "", 0)
        end

        ent:keysUnOwn(ply)
        amount = amount + 1

        local GiveMoneyBack = math.floor((hook.Call("get" .. (ent:IsVehicle() and "Vehicle" or "Door") .. "Cost", GAMEMODE, ply, ent) * 0.666) + 0.5)
        hook.Call("playerKeysSold", GAMEMODE, ply, ent, GiveMoneyBack)
        cost = cost + GiveMoneyBack
    end

    if amount == 0 then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_doors_owned")) return "" end

    ply:addMoney(math.floor(cost))

    DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("sold_x_doors", amount, DarkRP.formatMoney(math.floor(cost))))
    return ""
end
DarkRP.defineChatCommand("unownalldoors", UnOwnAll)

local function SetDoorTitle(ply, args)
    local trace = ply:GetEyeTrace()

    local ent = trace.Entity
    if not IsValid(ent) or not ent:isKeysOwnable() or ply:GetPos():DistToSqr(ent:GetPos()) >= 12100 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return ""
    end

    if ent:isKeysOwnedBy(ply) then
        ent:setKeysTitle(args)
        return ""
    end

    local function onCAMIResult(allowed)
        if not allowed then
            DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("no_privilege"))
            return
        end

        local hasTeams = not fn.Null(ent:getKeysDoorTeams() or {})
        if ent:isKeysOwned() or ent:getKeysNonOwnable() or ent:getKeysDoorGroup() or hasTeams then
            ent:setKeysTitle(args)
        end

        if ent:getKeysNonOwnable() or ent:getKeysDoorGroup() or hasTeams then
            DarkRP.storeDoorData(trace.Entity)
        end
    end

    CAMI.PlayerHasAccess(ply, "DarkRP_ChangeDoorSettings", onCAMIResult)

    return ""
end
DarkRP.defineChatCommand("title", SetDoorTitle)

local function RemoveDoorOwner(ply, args)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or not ent:isKeysOwnable() or ply:GetPos():DistToSqr(ent:GetPos()) >= 12100 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return ""
    end

    local target = DarkRP.findPlayer(args)

    if ent:getKeysNonOwnable() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("door_rem_owners_unownable"))
        return ""
    end

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
        return ""
    end

    if not ent:isKeysOwnedBy(ply) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("do_not_own_ent"))
        return ""
    end


    local canDo = hook.Call("onAllowedToOwnRemoved", nil, ply, ent, target)
    if canDo == false then return "" end

    if ent:isKeysAllowedToOwn(target) then
        ent:removeKeysAllowedToOwn(target)
    end

    if ent:isKeysOwnedBy(target) then
        ent:removeKeysDoorOwner(target)
    end

    return ""
end
DarkRP.defineChatCommand("removeowner", RemoveDoorOwner)
DarkRP.defineChatCommand("ro", RemoveDoorOwner)

local function AddDoorOwner(ply, args)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or not ent:isKeysOwnable() or ply:GetPos():DistToSqr(ent:GetPos()) >= 12100 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return ""
    end

    local target = DarkRP.findPlayer(args)

    if ent:getKeysNonOwnable() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("door_add_owners_unownable"))
        return ""
    end

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
        return ""
    end

    if not ent:isKeysOwnedBy(ply) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("do_not_own_ent"))
        return ""
    end

    if ent:isKeysOwnedBy(target) or ent:isKeysAllowedToOwn(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("rp_addowner_already_owns_door", target:Nick()))
        return ""
    end

    local canDo = hook.Call("onAllowedToOwnAdded", nil, ply, ent, target)
    if canDo == false then return "" end

    ent:addKeysAllowedToOwn(target)


    return ""
end
DarkRP.defineChatCommand("addowner", AddDoorOwner)
DarkRP.defineChatCommand("ao", AddDoorOwner)
