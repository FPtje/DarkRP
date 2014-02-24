local meta = FindMetaTable("Entity")
local pmeta = FindMetaTable("Player")

/*---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------*/
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
		doorData.owner = ply
		DarkRP.updateDoorData(self, "owner")
	end

	if ply:GetTable().OwnedNumz == 0 then
		timer.Create(ply:UniqueID() .. "propertytax", 270, 0, function() ply.doPropertyTax(ply) end)
	end

	ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz + 1

	ply:GetTable().Ownedz[self:EntIndex()] = self
end

function meta:keysUnOwn(ply)
	if not ply then
		ply = self:getDoorOwner()

		if not IsValid(ply) then return end
	end

	if self:isMasterOwner(ply) then
		local doorData = self:getDoorData()
		doorData.owner = nil
		DarkRP.updateDoorData(self, "owner")
	else
		self:removeKeysDoorOwner(ply)
	end

	ply:GetTable().Ownedz[self:EntIndex()] = nil
	ply:GetTable().OwnedNumz = math.Clamp(ply:GetTable().OwnedNumz - 1, 0, math.huge)
end

function pmeta:keysUnOwnAll()
	for k, v in pairs(ents.GetAll()) do
		if v:isKeysOwnable() and v:isKeysOwnedBy(self) == true then
			v:Fire("unlock", "", 0.6)
		end
	end

	if self:GetTable().Ownedz then
		for k, v in pairs(self.Ownedz) do
			if not v:isKeysOwnable() then self.Ownedz[k] = nil continue end
			v:keysUnOwn(self)
			self.Ownedz[v:EntIndex()] = nil
		end
	end

	for k, v in pairs(player.GetAll()) do
		if v.Ownedz then
			for n, m in pairs(v.Ownedz) do
				if IsValid(m) and m:isKeysAllowedToOwn(self) then
					m:removeKeysAllowedToOwn(self)
				end
			end
		end
	end

	self.OwnedNumz = 0
end

function pmeta:doPropertyTax()
	if not GAMEMODE.Config.propertytax then return end
	if self:isCP() and GAMEMODE.Config.cit_propertytax then return end

	local numowned = self.OwnedNumz

	if not numowned or numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-5, 5)

	if self:canAfford(tax) then
		if tax ~= 0 then
			self:addMoney(-tax)
			DarkRP.notify(self, 0, 5, DarkRP.getPhrase("property_tax", DarkRP.formatMoney(tax)))
		end
	else
		DarkRP.notify(self, 1, 8, DarkRP.getPhrase("property_tax_cant_afford"))
		self:keysUnOwnAll()
	end
end

function pmeta:initiateTax()
	local taxtime = GAMEMODE.Config.wallettaxtime
	local uniqueid = self:UniqueID() -- so we can destroy the timer if the player leaves
	timer.Create("rp_tax_"..uniqueid, taxtime or 600, 0, function()
		if not IsValid(self) then
			timer.Destroy("rp_tax_"..uniqueid)
			return
		end

		if not GAMEMODE.Config.wallettax then
			return -- Don't remove the hook in case it's turned on afterwards.
		end
		local money = self:getDarkRPVar("money")
		local mintax = GAMEMODE.Config.wallettaxmin / 100
		local maxtax = GAMEMODE.Config.wallettaxmax / 100 -- convert to decimals for percentage calculations
		local startMoney = GAMEMODE.Config.startingmoney


		if money < (startMoney * 2) then
			return -- Don't tax players if they have less than twice the starting amount
		end

		-- Variate the taxes between twice the starting money ($1000 by default) and 200 - 2 times the starting money (100.000 by default)
		local tax = (money - (startMoney * 2)) / (startMoney * 198)
			  tax = math.Min(maxtax, mintax + (maxtax - mintax) * tax)

		self:addMoney(-tax * money)
		DarkRP.notify(self, 3, 7, DarkRP.getPhrase("taxday", math.Round(tax * 100, 3)))

	end)
end

/*---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------*/
local time = false
local function SetDoorOwnable(ply)
	if time then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/toggleownable"))
		return ""
	end
	time = true
	timer.Simple(0.1, function() time = false end)

	if not ply:hasDarkRPPrivilege("rp_doorManipulation") then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_privilege"))
		return ""
	end

	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 200 then
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
	return ""
end
DarkRP.defineChatCommand("toggleownable", SetDoorOwnable)

local time3 = false
local function SetDoorGroupOwnable(ply, arg)
	if time3 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/togglegroupownable"))
		return ""
	end
	time3 = true
	timer.Simple(0.1, function() time3 = false end)

	local trace = ply:GetEyeTrace()

	if not ply:hasDarkRPPrivilege("rp_doorManipulation") then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_privilege"))
		return ""
	end

	local ent = trace.Entity

	if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 200 then
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
DarkRP.defineChatCommand("togglegroupownable", SetDoorGroupOwnable)

local time4 = false
local function SetDoorTeamOwnable(ply, arg)
	if time4 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/toggleteamownable"))
		return ""
	end
	time4 = true
	timer.Simple( 0.1, function() time4 = false end )
	local trace = ply:GetEyeTrace()

	local ent = trace.Entity
	if not ply:hasDarkRPPrivilege("rp_doorManipulation") then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_privilege"))
		return ""
	end

	if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 200 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	arg = tonumber(arg)
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
DarkRP.defineChatCommand("toggleteamownable", SetDoorTeamOwnable)

local time2 = false
local function OwnDoor(ply)
	if time2 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/toggleown"))
		return ""
	end
	time2 = true
	timer.Simple(0.1, function() time2 = false end)
	local team = ply:Team()
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:isKeysOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 200 then
		local Owner = trace.Entity:CPPIGetOwner()

		if ply:isArrested() then
			DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("door_unown_arrested"))
			return ""
		end

		if trace.Entity:getKeysNonOwnable() or trace.Entity:getKeysDoorGroup() or not fn.Null(trace.Entity:getKeysDoorTeams() or {}) then
			DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("door_unownable"))
			return ""
		end

		if trace.Entity:isKeysOwnedBy(ply) then
			if trace.Entity:isMasterOwner(ply) then
				trace.Entity:removeAllKeysExtraOwners()
				trace.Entity:removeAllKeysAllowedToOwn()
				trace.Entity:Fire("unlock", "", 0)
			end

			trace.Entity:keysUnOwn(ply)
			trace.Entity:setKeysTitle(nil)
			local GiveMoneyBack = math.floor((((trace.Entity:IsVehicle() and GAMEMODE.Config.vehiclecost) or GAMEMODE.Config.doorcost) * 0.666) + 0.5)
			hook.Call("playerKeysSold", GAMEMODE, ply, trace.Entity, GiveMoneyBack)
			ply:addMoney(GiveMoneyBack)
			local bSuppress = hook.Call("hideSellDoorMessage", GAMEMODE, ply, trace.Entity)
			if( !bSuppress ) then
				DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("door_sold",  DarkRP.formatMoney(GiveMoneyBack)))
			end

		else
			if trace.Entity:isKeysOwned() and not trace.Entity:isKeysAllowedToOwn(ply) then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("door_already_owned"))
				return ""
			end

			local iCost = hook.Call("get".. (trace.Entity:IsVehicle() and "Vehicle" or "Door").."Cost", GAMEMODE, ply, trace.Entity);
			if( !ply:canAfford( iCost ) ) then
				DarkRP.notify( ply, 1, 4, trace.Entity:IsVehicle() and DarkRP.getPhrase("vehicle_cannot_afford") or DarkRP.getPhrase("door_cannot_afford"))
				return "";
			end

			local bAllowed, strReason, bSuppress = hook.Call("playerBuy"..( trace.Entity:IsVehicle() and "Vehicle" or "Door"), GAMEMODE, ply, trace.Entity)
			if( bAllowed == false ) then
				if( strReason and strReason != "") then
					DarkRP.notify( ply, 1, 4, strReason)
				end
				return "";
			end

			local bVehicle = trace.Entity:IsVehicle();

			if bVehicle and (ply.Vehicles or 0) >= GAMEMODE.Config.maxvehicles and Owner ~= ply then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", DarkRP.getPhrase("vehicle")))
				return ""
			end

			if not bVehicle and (ply.OwnedNumz or 0) >= GAMEMODE.Config.maxdoors then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", DarkRP.getPhrase("door")))
				return ""
			end

			ply:addMoney(-iCost)
			if( !bSuppress ) then
				DarkRP.notify( ply, 0, 4, bVehicle and DarkRP.getPhrase("vehicle_bought", DarkRP.formatMoney(iCost), "") or DarkRP.getPhrase("door_bought", DarkRP.formatMoney(iCost), ""))
			end

			trace.Entity:keysOwn(ply)
			hook.Call("playerBought"..(bVehicle and "Vehicle" or "Door"), GAMEMODE, ply, trace.Entity, iCost);
		end

		return ""
	end
	DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
	return ""
end
DarkRP.defineChatCommand("toggleown", OwnDoor)

local function UnOwnAll(ply, cmd, args)
	local amount = 0
	for k,v in pairs(ents.GetAll()) do
		if v:isKeysOwnedBy(ply) and not IsValid(v.EntOwner) --[[SCars]]then
			amount = amount + 1
			v:Fire("unlock", "", 0)
			v:keysUnOwn(ply)
			local cost = (v:IsVehicle() and GAMEMODE.Config.vehiclecost or GAMEMODE.Config.doorcost) * 2/3 + 0.5
			ply:addMoney(math.floor(cost))
			ply:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end
	ply:GetTable().OwnedNumz = 0
	DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("sold_x_doors", amount,DarkRP.formatMoney(amount * math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5)))))
	return ""
end
DarkRP.defineChatCommand("unownalldoors", UnOwnAll)


local function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	if ply:IsSuperAdmin() then
		if trace.Entity:getKeysNonOwnable() or trace.Entity:getKeysDoorGroup() or not fn.Null(trace.Entity:getKeysDoorTeams() or {}) then
			trace.Entity:setKeysTitle(args)
			DarkRP.storeDoorData(trace.Entity)
			return ""
		end
	elseif trace.Entity:getKeysNonOwnable() then
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/title"))
	end

	if not trace.Entity:isKeysOwnedBy(ply) then
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("door_need_to_own", "/title"))
		return ""
	end
	trace.Entity:setKeysTitle(args)

	return ""
end
DarkRP.defineChatCommand("title", SetDoorTitle)

local function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end
	target = DarkRP.findPlayer(args)

	if trace.Entity:getKeysNonOwnable() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("door_rem_owners_unownable"))
		return ""
	end

	if not target then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
		return ""
	end

	if not trace.Entity:isKeysOwnedBy(ply) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("do_not_own_ent"))
		return ""
	end


	local canDo = hook.Call("onAllowedToOwnRemoved", nil, ply, trace.Entity, target)
	if canDo == false then return "" end

	if trace.Entity:isKeysAllowedToOwn(target) then
		trace.Entity:removeKeysAllowedToOwn(target)
	end

	if trace.Entity:isKeysOwnedBy(target) then
		trace.Entity:removeKeysDoorOwner(target)
	end

	return ""
end
DarkRP.defineChatCommand("removeowner", RemoveDoorOwner)
DarkRP.defineChatCommand("ro", RemoveDoorOwner)

local function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	target = DarkRP.findPlayer(args)

	if trace.Entity:getKeysNonOwnable() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("door_add_owners_unownable"))
		return ""
	end

	if not target then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
		return ""
	end

	if not trace.Entity:isKeysOwnedBy(ply) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("do_not_own_ent"))
		return ""
	end

	if trace.Entity:isKeysOwnedBy(target) or trace.Entity:isKeysAllowedToOwn(target) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("rp_addowner_already_owns_door", ply:Nick()))
		return ""
	end

	local canDo = hook.Call("onAllowedToOwnAdded", nil, ply, trace.Entity, target)
	if canDo == false then return "" end

	trace.Entity:addKeysAllowedToOwn(target)


	return ""
end
DarkRP.defineChatCommand("addowner", AddDoorOwner)
DarkRP.defineChatCommand("ao", AddDoorOwner)

