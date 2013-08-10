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

function meta:addKeysAllowedToOwn(ply)
	self.DoorData = self.DoorData or {}
	self.DoorData.AllowedToOwn = self.DoorData.AllowedToOwn and self.DoorData.AllowedToOwn .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
end

function meta:removeKeysAllowedToOwn(ply)
	self.DoorData = self.DoorData or {}
	if self.DoorData.AllowedToOwn then self.DoorData.AllowedToOwn = string.gsub(self.DoorData.AllowedToOwn, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.AllowedToOwn or "", -1) == ";" then self.DoorData.AllowedToOwn = string.sub(self.DoorData.AllowedToOwn, 1, -2) end
end

function meta:addKeysDoorOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	self.DoorData.ExtraOwners = self.DoorData.ExtraOwners and self.DoorData.ExtraOwners .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
	self:removeKeysAllowedToOwn(ply)
end

function meta:removeKeysDoorOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	if self.DoorData.ExtraOwners then self.DoorData.ExtraOwners = string.gsub(self.DoorData.ExtraOwners, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.ExtraOwners or "", -1) == ";" then self.DoorData.ExtraOwners = string.sub(self.DoorData.ExtraOwners, 1, -2) end
end

function meta:keysOwn(ply)
	self.DoorData = self.DoorData or {}
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
		self.DoorData.Owner = ply
	end
end

function meta:keysUnOwn(ply)
	self.DoorData = self.DoorData or {}
	if not ply then
		ply = self:getDoorOwner()

		if not IsValid(ply) then return end
	end

	if self:isMasterOwner(ply) then
		self.DoorData.Owner = nil
	else
		self:removeKeysDoorOwner(ply)
	end

	self:removeKeysDoorOwner(ply)
	ply.LookingAtDoor = nil
end

function pmeta:keysUnOwnAll()
	for k, v in pairs(ents.GetAll()) do
		if v:isKeysOwnable() and v:isKeysOwnedBy(self) == true then
			v:Fire("unlock", "", 0.6)
		end
	end

	if self:GetTable().Ownedz then
		for k, v in pairs(self:GetTable().Ownedz) do
			v:keysUnOwn(self)
			self:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end

	for k, v in pairs(player.GetAll()) do
		if v:GetTable().Ownedz then
			for n, m in pairs(v:GetTable().Ownedz) do
				if IsValid(m) and m:isKeysAllowedToOwn(self) then
					m:removeKeysAllowedToOwn(self)
				end
			end
		end
	end

	self:GetTable().OwnedNumz = 0
end

function pmeta:doPropertyTax()
	if not GAMEMODE.Config.propertytax then return end
	if self:IsCP() and GAMEMODE.Config.cit_propertytax then return end

	local numowned = self.OwnedNumz

	if not numowned or numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-5, 5)

	if self:canAfford(tax) then
		if tax ~= 0 then
			self:AddMoney(-tax)
			DarkRP.notify(self, 0, 5, DarkRP.getPhrase("property_tax", GAMEMODE.Config.currency .. tax))
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

		self:AddMoney(-tax * money)
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
	if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	if IsValid( ent:getDoorOwner() ) then
		ent:keysUnOwn(ent:getDoorOwner())
	end
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.NonOwnable = not ent.DoorData.NonOwnable
	-- Save it for future map loads
	DarkRP.storeDoorData(ent)
	ply.LookingAtDoor = nil -- Send the new data to the client who is looking at the door :D
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

	if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	if not RPExtraTeamDoors[arg] and arg ~= "" then DarkRP.notify(ply, 1, 10, DarkRP.getPhrase("door_group_doesnt_exist")) return "" end

	ent:keysUnOwn()


	ent.DoorData = ent.DoorData or {}
	ent.DoorData.TeamOwn = nil
	ent.DoorData.GroupOwn = arg

	if arg == "" then
		ent.DoorData.GroupOwn = nil
		ent.DoorData.TeamOwn = nil
	end

	-- Save it for future map loads
	DarkRP.setDoorGroup(ent, arg)
	DarkRP.storeTeamDoorOwnability(ent)

	ply.LookingAtDoor = nil

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

	if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	arg = tonumber(arg)
	if not RPExtraTeams[arg] and arg ~= nil then DarkRP.notify(ply, 1, 10, DarkRP.getPhrase("job_doesnt_exist")) return "" end
	if IsValid(ent:getDoorOwner()) then
		ent:keysUnOwn(ent:getDoorOwner())
	end

	ent.DoorData = ent.DoorData or {}
	ent.DoorData.GroupOwn = nil
	local decoded = {}
	if ent.DoorData.TeamOwn then
		for k, v in pairs(string.Explode("\n", ent.DoorData.TeamOwn)) do
			if v and v != "" then
				decoded[tonumber(v)] = true
			end
		end
	end
	if arg then
		decoded[arg] = not decoded[arg]
		if decoded[arg] == false then
			decoded[arg] = nil
		end
		if table.Count(decoded) == 0 then
			ent.DoorData.TeamOwn = nil
		else
			local encoded = ""
			for k, v in pairs(decoded) do
				if v then
					encoded = encoded .. k .. "\n"
				end
			end
			ent.DoorData.TeamOwn = encoded -- So we can send it to the client, and store it easily
		end
	else
		ent.DoorData.TeamOwn = nil
	end
	DarkRP.notify(ply, 0, 8, DarkRP.getPhrase("door_group_set"))
	DarkRP.storeTeamDoorOwnability(ent)

	ent:keysUnOwn()
	ply.LookingAtDoor = nil
	return ""
end
DarkRP.defineChatCommand("toggleteamownable", SetDoorTeamOwnable)

local time2 = false
local function OwnDoor(ply)
	if time2 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/toggleteamownable"))
		return ""
	end
	time2 = true
	timer.Simple(0.1, function() time2 = false end)
	local team = ply:Team()
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:isKeysOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 200 then
		local Owner = trace.Entity:CPPIGetOwner()

		trace.Entity.DoorData = trace.Entity.DoorData or {}
		if ply:isArrested() then
			DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("door_unown_arrested"))
			return ""
		end

		if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
			DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("door_unownable"))
			return ""
		end

		if trace.Entity:isKeysOwnedBy(ply) then
			if trace.Entity:isMasterOwner(ply) then
				trace.Entity.DoorData.AllowedToOwn = nil
				trace.Entity.DoorData.ExtraOwners = nil
				trace.Entity:Fire("unlock", "", 0)
			end

			trace.Entity:keysUnOwn(ply)
			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = nil
			ply:GetTable().OwnedNumz = math.abs(ply:GetTable().OwnedNumz - 1)
			local GiveMoneyBack = math.floor((((trace.Entity:IsVehicle() and GAMEMODE.Config.vehiclecost) or GAMEMODE.Config.doorcost) * 0.666) + 0.5)
			hook.Call("playerKeysSold", GAMEMODE, ply, trace.Entity, GiveMoneyBack)
			ply:AddMoney(GiveMoneyBack)
			local bSuppress = hook.Call("hideSellDoorMessage", GAMEMODE, ply, trace.Entity)
			if( !bSuppress ) then
				DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("door_sold",  GAMEMODE.Config.currency..(GiveMoneyBack)))
			end

			ply.LookingAtDoor = nil
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

			ply:AddMoney(-iCost)
			if( !bSuppress ) then
				DarkRP.notify( ply, 0, 4, bVehicle and DarkRP.getPhrase("vehicle_bought", GAMEMODE.Config.currency, iCost) or DarkRP.getPhrase("door_bought", GAMEMODE.Config.currency, iCost))
			end

			trace.Entity:keysOwn(ply)
			hook.Call("playerBought"..(bVehicle and "Vehicle" or "Door"), GAMEMODE, ply, trace.Entity, iCost);

			if ply:GetTable().OwnedNumz == 0 then
				timer.Create(ply:UniqueID() .. "propertytax", 270, 0, function() ply.doPropertyTax(ply) end)
			end

			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz + 1

			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = trace.Entity
		end
		ply.LookingAtDoor = nil
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
			ply:AddMoney(math.floor(cost))
			ply:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end
	ply:GetTable().OwnedNumz = 0
	DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("sold_x_doors_for_y", amount, GAMEMODE.Config.currency, amount * math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5))))
	return ""
end
DarkRP.defineChatCommand("unownalldoors", UnOwnAll)



local function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	if ply:IsSuperAdmin() then
		if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
			DarkRP.storeDoorTitle(trace.Entity, args)
			ply.LookingAtDoor = nil
			return ""
		end
	elseif trace.Entity.DoorData.NonOwnable then
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/title"))
	end

	if not trace.Entity:isKeysOwnedBy(ply) then
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("door_need_to_own", "/title"))
		return ""
	end
	trace.Entity.DoorData.title = args

	ply.LookingAtDoor = nil
	return ""
end
DarkRP.defineChatCommand("title", SetDoorTitle)

local function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	target = DarkRP.findPlayer(args)

	if trace.Entity.DoorData.NonOwnable then
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

	if trace.Entity:isKeysAllowedToOwn(target) then
		trace.Entity:removeKeysAllowedToOwn(target)
	end

	if trace.Entity:isKeysOwnedBy(target) then
		trace.Entity:removeKeysDoorOwner(target)
	end

	ply.LookingAtDoor = nil
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

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	target = DarkRP.findPlayer(args)

	if trace.Entity.DoorData.NonOwnable then
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

	trace.Entity:addKeysAllowedToOwn(target)

	ply.LookingAtDoor = nil

	return ""
end
DarkRP.defineChatCommand("addowner", AddDoorOwner)
DarkRP.defineChatCommand("ao", AddDoorOwner)

