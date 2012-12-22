/*---------------------------------------------------------
 Shared part
 ---------------------------------------------------------*/
local meta = FindMetaTable("Entity")

function meta:IsOwnable()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if ((class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") or
			(GAMEMODE.Config.allowvehicleowning and self:IsVehicle() and (not IsValid(self:GetParent()) or not self:GetParent():IsVehicle()))) then
			return true
		end
	return false
end

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function meta:DoorIndex()
	return self:EntIndex() - game.MaxPlayers()
end

function GM:DoorToEntIndex(num)
	return num + game.MaxPlayers()
end

function meta:IsOwned()
	self.DoorData = self.DoorData or {}

	if IsValid(self.DoorData.Owner) then return true end

	return false
end

function meta:GetDoorOwner()
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	return self.DoorData.Owner
end

function meta:IsMasterOwner(ply)
	if ply == self:GetDoorOwner() then
		return true
	end

	return false
end

function meta:OwnedBy(ply)
	if ply == self:GetDoorOwner() then return true end
	self.DoorData = self.DoorData or {}

	if self.DoorData.ExtraOwners then
		local People = string.Explode(";", self.DoorData.ExtraOwners)
		for k,v in pairs(People) do
			if tonumber(v) == ply:UserID() then return true end
		end
	end

	return false
end

function meta:AllowedToOwn(ply)
	self.DoorData = self.DoorData or {}
	if not self.DoorData then return false end
	if self.DoorData.AllowedToOwn and string.find(self.DoorData.AllowedToOwn, ply:UserID()) then
		return true
	end
	return false
end

/*---------------------------------------------------------
 Clientside part
 ---------------------------------------------------------*/
local lastDataRequested = 0 -- Last time doordata was requested
if CLIENT then
	function meta:DrawOwnableInfo()
		if LocalPlayer():InVehicle() then return end

		local pos = {x = ScrW()/2, y = ScrH() / 2}

		local ownerstr = ""

		if self.DoorData == nil and lastDataRequested < (CurTime() - 0.7) then
			RunConsoleCommand("_RefreshDoorData", self:EntIndex())
			lastDataRequested = CurTime()

			return
		end

		for k,v in pairs(player.GetAll()) do
			if self:OwnedBy(v) then
				ownerstr = ownerstr .. v:Nick() .. "\n"
			end
		end

		if type(self.DoorData.AllowedToOwn) == "string" and self.DoorData.AllowedToOwn ~= "" and self.DoorData.AllowedToOwn ~= ";" then
			local names = {}
			for a,b in pairs(string.Explode(";", self.DoorData.AllowedToOwn)) do
				if b ~= "" and IsValid(Player(tonumber(b))) then
					table.insert(names, Player(tonumber(b)):Nick())
				end
			end
			ownerstr = ownerstr .. string.format(LANGUAGE.keys_other_allowed).. table.concat(names, "\n").."\n"
		elseif type(self.DoorData.AllowedToOwn) == "number" and IsValid(Player(self.DoorData.AllowedToOwn)) then
			ownerstr = ownerstr .. string.format(LANGUAGE.keys_other_allowed)..Player(self.DoorData.AllowedToOwn):Nick().."\n"
		end

		self.DoorData.title = self.DoorData.title or ""

		local blocked = self.DoorData.NonOwnable
		local st = self.DoorData.title .. "\n"
		local superadmin = LocalPlayer():IsSuperAdmin()
		local whiteText = true -- false for red, true for white text

		if superadmin and blocked then
			st = st .. LANGUAGE.keys_allow_ownership .. "\n"
		end

		if self.DoorData.TeamOwn then
			st = st .. LANGUAGE.keys_owned_by .."\n"

			for k, v in pairs(self.DoorData.TeamOwn) do
				if v then
					st = st .. RPExtraTeams[k].name .. "\n"
				end
			end
		elseif self.DoorData.GroupOwn then
			st = st .. LANGUAGE.keys_owned_by .."\n"
			st = st .. self.DoorData.GroupOwn .. "\n"
		end

		if self:IsOwned() then
			if superAdmin then
				if ownerstr ~= "" then
					st = st .. LANGUAGE.keys_owned_by .."\n" .. ownerstr
				end
				st = st ..LANGUAGE.keys_disallow_ownership .. "\n"
			elseif not blocked and ownerstr ~= "" then
				st = st .. LANGUAGE.keys_owned_by .. "\n" .. ownerstr
			end
		elseif not blocked then
			if superAdmin then
				st = LANGUAGE.keys_unowned .."\n".. LANGUAGE.keys_disallow_ownership
				if not self:IsVehicle() then
					st = st .. "\n"..LANGUAGE.keys_cops
				end
			elseif not self.DoorData.GroupOwn and not self.DoorData.TeamOwn then
				whiteText = false
				st = LANGUAGE.keys_unowned
			end
		end

		if self:IsVehicle() then
			for k,v in pairs(player.GetAll()) do
				if v:GetVehicle() == self then
					whiteText = true
					st = st .. "\n" .. "Driver: " .. v:Nick()
				end
			end
		end

		if whiteText then
			draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
			draw.DrawText(st, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
		else
			draw.DrawText(st, "TargetID", pos.x , pos.y+1 , Color(0, 0, 0, 255), 1)
			draw.DrawText(st, "TargetID", pos.x, pos.y, Color(128, 30, 30, 255), 1)
		end
	end

	return
end

/*---------------------------------------------------------
 Serverside part
 ---------------------------------------------------------*/

function meta:KeysLock()
	self:Fire("lock", "", 0)

	-- VUMod compatibility
	-- Locks passenger seats when the vehicle is locked.
	if self:IsVehicle() and self.VehicleTable and self.VehicleTable.Passengers then
		for k,v in pairs(self.VehicleTable.Passengers) do
			v.Ent:Fire("lock", "", 0)
		end
	end

	-- Locks the vehicle if you're unlocking a passenger seat:
	if IsValid(self:GetParent()) and self:GetParent():IsVehicle() then
		self:GetParent():KeysLock()
	end
end

function meta:KeysUnLock()
	self:Fire("unlock", "", 0)

	-- VUMod
	if self:IsVehicle() and self.VehicleTable and self.VehicleTable.Passengers then
		for k,v in pairs(self.VehicleTable.Passengers) do
			v.Ent:Fire("unlock", "", 0)
		end
	end

	-- Unlocks the vehicle if you're unlocking a passenger seat:
	if IsValid(self:GetParent()) and self:GetParent():IsVehicle() then
		self:GetParent():KeysUnLock()
	end
end

local time = false
local function SetDoorOwnable(ply)
	if time then return "" end
	time = true
	timer.Simple(0.1, function()  time = false end)
	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	if not ply:IsSuperAdmin() or (not ent:IsDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then return end

	if not IsValid(trace.Entity) then return "" end
	if IsValid( trace.Entity:GetDoorOwner() ) then
		trace.Entity:UnOwn(trace.Entity:GetDoorOwner())
	end
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.NonOwnable = not ent.DoorData.NonOwnable
	-- Save it for future map loads
	DB.StoreDoorOwnability(ent)
	ply.LookingAtDoor = nil -- Send the new data to the client who is looking at the door :D
	return ""
end
AddChatCommand("/toggleownable", SetDoorOwnable)

local time3 = false
local function SetDoorGroupOwnable(ply, arg)
	if time3 then return "" end
	time3 = true
	timer.Simple(0.1, function() time3 = false end)

	local trace = ply:GetEyeTrace()
	if not IsValid(trace.Entity) then return "" end

	local ent = trace.Entity
	if not ply:IsSuperAdmin() or (not ent:IsDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then return end

	if not RPExtraTeamDoors[arg] and arg ~= "" then Notify(ply, 1, 10, "Door group does not exist!") return "" end

	trace.Entity:UnOwn()


	ent.DoorData = ent.DoorData or {}
	ent.DoorData.TeamOwn = nil
	ent.DoorData.GroupOwn = arg

	if arg == "" then
		ent.DoorData.GroupOwn = nil
		ent.DoorData.TeamOwn = nil
	end

	-- Save it for future map loads
	DB.SetDoorGroup(ent, arg)
	DB.StoreTeamDoorOwnability(ent)

	ply.LookingAtDoor = nil

	GAMEMODE:Notify(ply, 0, 8, "Door group set successfully")
	return ""
end
AddChatCommand("/togglegroupownable", SetDoorGroupOwnable)

local time4 = false
local function SetDoorTeamOwnable(ply, arg)
	if time4 then return "" end
	time4 = true
	timer.Simple( 0.1, function() time4 = false end )
	local trace = ply:GetEyeTrace()
	if not IsValid(trace.Entity) then return "" end

	local ent = trace.Entity
	if not ply:IsSuperAdmin() or (not ent:IsDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then return "" end

	arg = tonumber(arg)
	if not RPExtraTeams[arg] and arg ~= nil then GAMEMODE:Notify(ply, 1, 10, "Job does not exist!") return "" end
	if IsValid(trace.Entity:GetDoorOwner()) then
		trace.Entity:UnOwn(trace.Entity:GetDoorOwner())
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
	GAMEMODE:Notify(ply, 0, 8, "Door group set successfully")
	DB.StoreTeamDoorOwnability(ent)

	ent:UnOwn()
	ply.LookingAtDoor = nil
	return ""
end
AddChatCommand("/toggleteamownable", SetDoorTeamOwnable)

local time2 = false
local function OwnDoor(ply)
	if time2 then return "" end
	time2 = true
	timer.Simple(0.1, function() time2 = false end)
	local team = ply:Team()
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 200 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		if ply:isArrested() then
			GAMEMODE:Notify(ply, 1, 5, LANGUAGE.door_unown_arrested)
			return ""
		end

		if not GAMEMODE.Config.hobownership and team == TEAM_HOBO then
			GAMEMODE:Notify(ply, 1, 5, LANGUAGE.door_hobo_unable)
			return ""
		end

		if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
			GAMEMODE:Notify(ply, 1, 5, LANGUAGE.door_unownable)
			return ""
		end

		if trace.Entity:OwnedBy(ply) then
			trace.Entity:Fire("unlock", "", 0)
			trace.Entity:UnOwn(ply)
			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = nil
			ply:GetTable().OwnedNumz = math.abs(ply:GetTable().OwnedNumz - 1)
			local GiveMoneyBack = math.floor((((trace.Entity:IsVehicle() and GAMEMODE.Config.vehiclecost) or GAMEMODE.Config.doorcost) * 0.666) + 0.5)
			hook.Call("PlayerSoldDoor", GAMEMODE, ply, trace.Entity, GiveMoneyBack );
			ply:AddMoney(GiveMoneyBack)
			local bSuppress = hook.Call("HideSellDoorMessage", GAMEMODE, ply, trace.Entity );
			if( !bSuppress ) then
				GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.door_sold,  CUR..(GiveMoneyBack)))
			end

			ply.LookingAtDoor = nil
		else
			if trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(ply) then
				GAMEMODE:Notify(ply, 1, 4, LANGUAGE.door_already_owned)
				return ""
			end

			local iCost = hook.Call("Get"..( trace.Entity:IsVehicle( ) && "Vehicle" || "Door").."Cost", GAMEMODE, ply, trace.Entity );
			if( !ply:CanAfford( iCost ) ) then
				GAMEMODE:Notify( ply, 1, 4, trace.Entity:IsVehicle( ) && LANGUAGE.vehicle_cannot_afford || LANGUAGE.door_cannot_afford );
				return "";
			end

			local bAllowed, strReason, bSuppress = hook.Call("PlayerBuy"..( trace.Entity:IsVehicle( ) && "Vehicle" || "Door"), GAMEMODE, ply, trace.Entity );
			if( bAllowed == false ) then
				if( strReason && strReason != "") then
					GAMEMODE:Notify( ply, 1, 4, strReason );
				end
				return "";
			end

			local bVehicle = trace.Entity:IsVehicle();

			if bVehicle and (ply.Vehicles or 0) >= GAMEMODE.Config.maxvehicles and trace.Entity.Owner ~= ply then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.limit, "vehicle"))
				return ""
			end

			if not bVehicle and (ply.OwnedNumz or 0) >= GAMEMODE.Config.maxdoors then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.limit, "door"))
				return ""
			end

			ply:AddMoney( -( bVehicle && GAMEMODE.Config.vehiclecost || GAMEMODE.Config.doorcost ) );
			if( !bSuppress ) then
				GAMEMODE:Notify( ply, 0, 4, string.format( bVehicle && LANGUAGE.vehicle_bought || LANGUAGE.door_bought, CUR..math.floor( ( bVehicle && GAMEMODE.Config.vehiclecost || GAMEMODE.Config.doorcost ) ) ) );
			end

			trace.Entity:Own(ply)
			hook.Call("PlayerBought"..( bVehicle && "Vehicle" || "Door"), GAMEMODE, ply, trace.Entity, iCost );

			if ply:GetTable().OwnedNumz == 0 then
				timer.Create(ply:UniqueID() .. "propertytax", 270, 0, function() ply.DoPropertyTax(ply) end)
			end

			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz + 1

			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = trace.Entity
		end
		ply.LookingAtDoor = nil
		return ""
	end
	GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "vehicle/door"))
	return ""
end
AddChatCommand("/toggleown", OwnDoor)

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
	GAMEMODE:Notify(ply, 2, 4, string.format("You have sold "..amount.." doors for " .. CUR .. amount * math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5)) .. "!"))
	return ""
end
AddChatCommand("/unownalldoors", UnOwnAll)

function meta:AddAllowed(ply)
	self.DoorData = self.DoorData or {}
	self.DoorData.AllowedToOwn = self.DoorData.AllowedToOwn and self.DoorData.AllowedToOwn .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
end

function meta:RemoveAllowed(ply)
	self.DoorData = self.DoorData or {}
	if self.DoorData.AllowedToOwn then self.DoorData.AllowedToOwn = string.gsub(self.DoorData.AllowedToOwn, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.AllowedToOwn, -1) == ";" then self.DoorData.AllowedToOwn = string.sub(self.DoorData.AllowedToOwn, 1, -2) end
end

function meta:AddOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	self.DoorData.ExtraOwners = self.DoorData.ExtraOwners and self.DoorData.ExtraOwners .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
	self:RemoveAllowed(ply)
end

function meta:RemoveOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	if self.DoorData.ExtraOwners then self.DoorData.ExtraOwners = string.gsub(self.DoorData.ExtraOwners, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.ExtraOwners or "", -1) == ";" then self.DoorData.ExtraOwners = string.sub(self.DoorData.ExtraOwners, 1, -2) end
end

function meta:Own(ply)
	self.DoorData = self.DoorData or {}
	if self:AllowedToOwn(ply) then
		self:AddOwner(ply)
		return
	end

 	-- Increase vehicle count
	if self:IsVehicle() then
		if IsValid(ply) then
			ply.Vehicles = ply.Vehicles or 0
			ply.Vehicles = ply.Vehicles + 1
		end

		-- Decrease vehicle count of the original owner
		if IsValid(self.Owner) and self.Owner ~= ply then
			self.Owner.Vehicles = self.Owner.Vehicles or 1
			self.Owner.Vehicles = self.Owner.Vehicles - 1
		end
	end

	if self:IsVehicle() then
		self.Owner = ply
		self.OwnerID = ply:SteamID()
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
		self:RemoveOwner(ply)
	end

	self:RemoveOwner(ply)
	ply.LookingAtDoor = nil
end

local function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		if ply:IsSuperAdmin() then
			if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
				DB.StoreDoorTitle(trace.Entity, args)
				ply.LookingAtDoor = nil
				return ""
			end
		elseif trace.Entity.DoorData.NonOwnable then
			GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.need_admin, "/title"))
		end

		if trace.Entity:OwnedBy(ply) then
			trace.Entity.DoorData.title = args
		else
			GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.door_need_to_own, "/title"))
		end
	end

	ply.LookingAtDoor = nil
	return ""
end
AddChatCommand("/title", SetDoorTitle)

local function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		target = GAMEMODE:FindPlayer(args)

		if trace.Entity.DoorData.NonOwnable then
			GAMEMODE:Notify(ply, 1, 4, LANGUAGE.door_rem_owners_unownable)
		end

		if target then
			if trace.Entity:OwnedBy(ply) then
				if trace.Entity:AllowedToOwn(target) then
					trace.Entity:RemoveAllowed(target)
				end

				if trace.Entity:OwnedBy(target) then
					trace.Entity:RemoveOwner(target)
				end
			else
				GAMEMODE:Notify(ply, 1, 4, LANGUAGE.do_not_own_ent)
			end
		else
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end

	ply.LookingAtDoor = nil
	return ""
end
AddChatCommand("/removeowner", RemoveDoorOwner)
AddChatCommand("/ro", RemoveDoorOwner)

local function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		target = GAMEMODE:FindPlayer(args)
		if target then
			if trace.Entity.DoorData.NonOwnable then
				GAMEMODE:Notify(ply, 1, 4, LANGUAGE.door_add_owners_unownable)
				return ""
			end

			if trace.Entity:OwnedBy(ply) then
				if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
					trace.Entity:AddAllowed(target)
				else
					GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.rp_addowner_already_owns_door, ply:Nick()))
				end
			else
				GAMEMODE:Notify(ply, 1, 4, LANGUAGE.do_not_own_ent)
			end
		else
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end

	ply.LookingAtDoor = nil
	return ""
end
AddChatCommand("/addowner", AddDoorOwner)
AddChatCommand("/ao", AddDoorOwner)