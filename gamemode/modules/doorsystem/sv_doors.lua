local meta = FindMetaTable("Entity")

function meta:KeysLock()
	self:Fire("lock", "", 0)

	hook.Call("onKeysLocked", nil, self)
end

function meta:KeysUnLock()
	self:Fire("unlock", "", 0)

	hook.Call("onKeysUnlocked", nil, self)
end

local time = false
local function SetDoorOwnable(ply)
	if time then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/toggleownable"))
		return ""
	end
	time = true
	timer.Simple(0.1, function() time = false end)

	if not ply:HasPriv("rp_doorManipulation") then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("no_privilege"))
		return ""
	end

	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	if not IsValid(ent) or (not ent:IsDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	if IsValid( ent:GetDoorOwner() ) then
		ent:UnOwn(ent:GetDoorOwner())
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
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/togglegroupownable"))
		return ""
	end
	time3 = true
	timer.Simple(0.1, function() time3 = false end)

	local trace = ply:GetEyeTrace()

	if not ply:HasPriv("rp_doorManipulation") then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("no_privilege"))
		return ""
	end

	local ent = trace.Entity

	if not IsValid(ent) or (not ent:IsDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	if not RPExtraTeamDoors[arg] and arg ~= "" then GAMEMODE:Notify(ply, 1, 10, DarkRP.getPhrase("door_group_doesnt_exist")) return "" end

	ent:UnOwn()


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

	GAMEMODE:Notify(ply, 0, 8, DarkRP.getPhrase("door_group_set"))
	return ""
end
DarkRP.defineChatCommand("togglegroupownable", SetDoorGroupOwnable)

local time4 = false
local function SetDoorTeamOwnable(ply, arg)
	if time4 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/toggleteamownable"))
		return ""
	end
	time4 = true
	timer.Simple( 0.1, function() time4 = false end )
	local trace = ply:GetEyeTrace()

	local ent = trace.Entity
	if not ply:HasPriv("rp_doorManipulation") then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("no_prvilege"))
		return ""
	end

	if not IsValid(ent) or (not ent:IsDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	arg = tonumber(arg)
	if not RPExtraTeams[arg] and arg ~= nil then GAMEMODE:Notify(ply, 1, 10, DarkRP.getPhrase("job_doesnt_exist")) return "" end
	if IsValid(ent:GetDoorOwner()) then
		ent:UnOwn(ent:GetDoorOwner())
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
	GAMEMODE:Notify(ply, 0, 8, DarkRP.getPhrase("door_group_set"))
	DarkRP.storeTeamDoorOwnability(ent)

	ent:UnOwn()
	ply.LookingAtDoor = nil
	return ""
end
DarkRP.defineChatCommand("toggleteamownable", SetDoorTeamOwnable)

local time2 = false
local function OwnDoor(ply)
	if time2 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", "0.1", "/toggleteamownable"))
		return ""
	end
	time2 = true
	timer.Simple(0.1, function() time2 = false end)
	local team = ply:Team()
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 200 then
		local Owner = trace.Entity:CPPIGetOwner()

		trace.Entity.DoorData = trace.Entity.DoorData or {}
		if ply:isArrested() then
			GAMEMODE:Notify(ply, 1, 5, DarkRP.getPhrase("door_unown_arrested"))
			return ""
		end

		if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
			GAMEMODE:Notify(ply, 1, 5, DarkRP.getPhrase("door_unownable"))
			return ""
		end

		if trace.Entity:OwnedBy(ply) then
			if trace.Entity:IsMasterOwner(ply) then
				trace.Entity.DoorData.AllowedToOwn = nil
				trace.Entity.DoorData.ExtraOwners = nil
				trace.Entity:Fire("unlock", "", 0)
			end

			trace.Entity:UnOwn(ply)
			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = nil
			ply:GetTable().OwnedNumz = math.abs(ply:GetTable().OwnedNumz - 1)
			local GiveMoneyBack = math.floor((((trace.Entity:IsVehicle() and GAMEMODE.Config.vehiclecost) or GAMEMODE.Config.doorcost) * 0.666) + 0.5)
			hook.Call("PlayerSoldDoor", GAMEMODE, ply, trace.Entity, GiveMoneyBack );
			ply:AddMoney(GiveMoneyBack)
			local bSuppress = hook.Call("HideSellDoorMessage", GAMEMODE, ply, trace.Entity );
			if( !bSuppress ) then
				GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("door_sold",  GAMEMODE.Config.currency..(GiveMoneyBack)))
			end

			ply.LookingAtDoor = nil
		else
			if trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(ply) then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("door_already_owned"))
				return ""
			end

			local iCost = hook.Call("Get".. (trace.Entity:IsVehicle() and "Vehicle" or "Door").."Cost", GAMEMODE, ply, trace.Entity);
			if( !ply:CanAfford( iCost ) ) then
				GAMEMODE:Notify( ply, 1, 4, trace.Entity:IsVehicle() and DarkRP.getPhrase("vehicle_cannot_afford") or DarkRP.getPhrase("door_cannot_afford") );
				return "";
			end

			local bAllowed, strReason, bSuppress = hook.Call("PlayerBuy"..( trace.Entity:IsVehicle() and "Vehicle" or "Door"), GAMEMODE, ply, trace.Entity );
			if( bAllowed == false ) then
				if( strReason and strReason != "") then
					GAMEMODE:Notify( ply, 1, 4, strReason );
				end
				return "";
			end

			local bVehicle = trace.Entity:IsVehicle();

			if bVehicle and (ply.Vehicles or 0) >= GAMEMODE.Config.maxvehicles and Owner ~= ply then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("limit", DarkRP.getPhrase("vehicle")))
				return ""
			end

			if not bVehicle and (ply.OwnedNumz or 0) >= GAMEMODE.Config.maxdoors then
				GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("limit", DarkRP.getPhrase("door")))
				return ""
			end

			ply:AddMoney(-iCost)
			if( !bSuppress ) then
				GAMEMODE:Notify( ply, 0, 4, bVehicle and DarkRP.getPhrase("vehicle_bought", GAMEMODE.Config.currency, iCost) or DarkRP.getPhrase("door_bought", GAMEMODE.Config.currency, iCost))
			end

			trace.Entity:Own(ply)
			hook.Call("PlayerBought"..(bVehicle and "Vehicle" or "Door"), GAMEMODE, ply, trace.Entity, iCost);

			if ply:GetTable().OwnedNumz == 0 then
				timer.Create(ply:UniqueID() .. "propertytax", 270, 0, function() ply.DoPropertyTax(ply) end)
			end

			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz + 1

			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = trace.Entity
		end
		ply.LookingAtDoor = nil
		return ""
	end
	GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
	return ""
end
DarkRP.defineChatCommand("toggleown", OwnDoor)

local function UnOwnAll(ply, cmd, args)
	local amount = 0
	for k,v in pairs(ents.GetAll()) do
		if v:OwnedBy(ply) then
			amount = amount + 1
			v:Fire("unlock", "", 0)
			v:UnOwn(ply)
			ply:AddMoney(math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5)))
			ply:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end
	ply:GetTable().OwnedNumz = 0
	GAMEMODE:Notify(ply, 2, 4, DarkRP.getPhrase("sold_x_doors_for_y", amount, GAMEMODE.Config.currency, amount * math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5))))
	return ""
end
DarkRP.defineChatCommand("unownalldoors", UnOwnAll)

function meta:AddAllowed(ply)
	self.DoorData = self.DoorData or {}
	self.DoorData.AllowedToOwn = self.DoorData.AllowedToOwn and self.DoorData.AllowedToOwn .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
end

function meta:RemoveAllowed(ply)
	self.DoorData = self.DoorData or {}
	if self.DoorData.AllowedToOwn then self.DoorData.AllowedToOwn = string.gsub(self.DoorData.AllowedToOwn, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.AllowedToOwn or "", -1) == ";" then self.DoorData.AllowedToOwn = string.sub(self.DoorData.AllowedToOwn, 1, -2) end
end

function meta:addDoorOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	self.DoorData.ExtraOwners = self.DoorData.ExtraOwners and self.DoorData.ExtraOwners .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
	self:RemoveAllowed(ply)
end

function meta:removeDoorOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	if self.DoorData.ExtraOwners then self.DoorData.ExtraOwners = string.gsub(self.DoorData.ExtraOwners, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.ExtraOwners or "", -1) == ";" then self.DoorData.ExtraOwners = string.sub(self.DoorData.ExtraOwners, 1, -2) end
end

function meta:Own(ply)
	self.DoorData = self.DoorData or {}
	if self:AllowedToOwn(ply) then
		self:addDoorOwner(ply)
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

	if not self:IsOwned() and not self:OwnedBy(ply) then
		self.DoorData.Owner = ply
	end
end

function meta:UnOwn(ply)
	self.DoorData = self.DoorData or {}
	if not ply then
		ply = self:GetDoorOwner()

		if not IsValid(ply) then return end
	end

	if self:IsMasterOwner(ply) then
		self.DoorData.Owner = nil
	else
		self:removeDoorOwner(ply)
	end

	self:removeDoorOwner(ply)
	ply.LookingAtDoor = nil
end

local function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
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
		GAMEMODE:Notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/title"))
	end

	if not trace.Entity:OwnedBy(ply) then
		GAMEMODE:Notify(ply, 1, 6, DarkRP.getPhrase("door_need_to_own", "/title"))
		return ""
	end
	trace.Entity.DoorData.title = args

	ply.LookingAtDoor = nil
	return ""
end
DarkRP.defineChatCommand("title", SetDoorTitle)

local function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	target = DarkRP.findPlayer(args)

	if trace.Entity.DoorData.NonOwnable then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("door_rem_owners_unownable"))
		return ""
	end

	if not target then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
		return ""
	end

	if not trace.Entity:OwnedBy(ply) then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("do_not_own_ent"))
		return ""
	end

	if trace.Entity:AllowedToOwn(target) then
		trace.Entity:RemoveAllowed(target)
	end

	if trace.Entity:OwnedBy(target) then
		trace.Entity:removeDoorOwner(target)
	end

	ply.LookingAtDoor = nil
	return ""
end
DarkRP.defineChatCommand("removeowner", RemoveDoorOwner)
DarkRP.defineChatCommand("ro", RemoveDoorOwner)

local function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:GetPos():Distance(trace.Entity:GetPos()) >= 110 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return ""
	end

	trace.Entity.DoorData = trace.Entity.DoorData or {}
	target = DarkRP.findPlayer(args)

	if trace.Entity.DoorData.NonOwnable then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("door_add_owners_unownable"))
		return ""
	end

	if not target then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
		return ""
	end

	if not trace.Entity:OwnedBy(ply) then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("do_not_own_ent"))
		return ""
	end

	if trace.Entity:OwnedBy(target) or trace.Entity:AllowedToOwn(target) then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("rp_addowner_already_owns_door", ply:Nick()))
		return ""
	end

	trace.Entity:AddAllowed(target)

	ply.LookingAtDoor = nil

	return ""
end
DarkRP.defineChatCommand("addowner", AddDoorOwner)
DarkRP.defineChatCommand("ao", AddDoorOwner)
