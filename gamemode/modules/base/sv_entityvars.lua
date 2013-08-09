local meta = FindMetaTable("Player")

/*---------------------------------------------------------------------------
Pooled networking strings
---------------------------------------------------------------------------*/
util.AddNetworkString("DarkRP_InitializeVars")
util.AddNetworkString("DarkRP_DoorData")

/*---------------------------------------------------------------------------
Player vars
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
Set a player's DarkRPVar
---------------------------------------------------------------------------*/
local function formatDarkRPValue(value)
	if value == nil then return "nil" end

	if isentity(value) and not IsValid(value) then return "NULL" end
	if isentity(value) and value:IsPlayer() then return string.format("Entity [%s][Player]", value:EntIndex()) end

	return tostring(value)
end

function meta:setDarkRPVar(var, value, target)
	if not IsValid(self) then return end
	target = target or RecipientFilter():AddAllPlayers()

	hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, value)

	self.DarkRPVars = self.DarkRPVars or {}
	self.DarkRPVars[var] = value

	value = formatDarkRPValue(value)

	umsg.Start("DarkRP_PlayerVar", target)
		-- The index because the player handle might not exist clientside yet
		umsg.Short(self:EntIndex())
		umsg.String(var)
		umsg.String(value)
	umsg.End()
end

/*---------------------------------------------------------------------------
Set a private DarkRPVar
---------------------------------------------------------------------------*/
function meta:setSelfDarkRPVar(var, value)
	self.privateDRPVars = self.privateDRPVars or {}
	self.privateDRPVars[var] = true

	self:setDarkRPVar(var, value, self)
end

/*---------------------------------------------------------------------------
Get a DarkRPVar
---------------------------------------------------------------------------*/
function meta:getDarkRPVar(var)
	self.DarkRPVars = self.DarkRPVars or {}
	return self.DarkRPVars[var]
end

/*---------------------------------------------------------------------------
Send the DarkRPVars to a client
---------------------------------------------------------------------------*/
local function SendDarkRPVars(ply)
	if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 1) then return end --prevent spammers
	ply.DarkRPVarsSent = CurTime()

	local sendtable = {}
	for k,v in pairs(player.GetAll()) do
		sendtable[v] = {}
		for a,b in pairs(v.DarkRPVars or {}) do
			if not (v.privateDRPVars or {})[a] or ply == v then
				sendtable[v][a] = b
			end
		end
	end
	net.Start("DarkRP_InitializeVars")
		net.WriteTable(sendtable)
	net.Send(ply)
end
concommand.Add("_sendDarkRPvars", SendDarkRPVars)

/*---------------------------------------------------------------------------
Admin DarkRPVar commands
---------------------------------------------------------------------------*/
local function setRPName(ply, cmd, args)
	if not args[2] then ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), "")) return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_setname"))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if not args[2] or string.len(args[2]) < 2 or string.len(args[2]) > 30 then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), args[2]))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), args[2]))
		end
	end

	if target then
		local oldname = target:Nick()
		local nick = ""
		DarkRP.storeRPName(target, args[2])
		target:setDarkRPVar("rpname", args[2])

		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("you_set_x_name_to_y", oldname, args[2]))
			nick = "Console"
		else
			ply:PrintMessage(2, DarkRP.getPhrase("you_set_x_name_to_y", oldname, args[2]))
			nick = ply:Nick()
		end
		target:PrintMessage(2, DarkRP.getPhrase("x_set_your_name_to_y", nick, args[2]))
		if ply:EntIndex() == 0 then
			DarkRP.log("Console set "..target:SteamName().."'s name to " .. args[2], Color(30, 30, 30))
		else
			DarkRP.log(ply:Nick().." ("..ply:SteamID()..") set "..target:SteamName().."'s name to " .. args[2], Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		end
	end
end
concommand.Add("rp_setname", setRPName)

local function RPName(ply, args)
	if ply.LastNameChange and ply.LastNameChange > (CurTime() - 5) then
		DarkRP.notify( ply, 1, 4, DarkRP.getPhrase("have_to_wait",  math.ceil(5 - (CurTime() - ply.LastNameChange)), "/rpname"))
		return ""
	end

	if not GAMEMODE.Config.allowrpnames then
		DarkRP.notify(ply, 1, 6,  DarkRP.getPhrase("disabled", "RPname", ""))
		return ""
	end

	local len = string.len(args)
	local low = string.lower(args)

	if len > 30 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", "<=30"))
		return ""
	elseif len < 3 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", ">2"))
		return ""
	end

	local canChangeName = hook.Call("CanChangeRPName", GAMEMODE, ply, low)
	if canChangeName == false then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", ""))
		return ""
	end

	local allowed = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
	'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
	'z', 'x', 'c', 'v', 'b', 'n', 'm', ' ',
	'(', ')', '[', ']', '!', '@', '#', '$', '%', '^', '&', '*', '-', '_', '=', '+', '|', '\\'}

	for k in string.gmatch(args, ".") do
		if not table.HasValue(allowed, string.lower(k)) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", k))
			return ""
		end
	end
	ply:setRPName(args)
	ply.LastNameChange = CurTime()
	return ""
end
DarkRP.defineChatCommand("rpname", RPName)
DarkRP.defineChatCommand("name", RPName)
DarkRP.defineChatCommand("nick", RPName)

/*---------------------------------------------------------------------------
Nickname override to show RP name
---------------------------------------------------------------------------*/
meta.SteamName = meta.SteamName or meta.Name
function meta:Name()
	return GAMEMODE.Config.allowrpnames and self.DarkRPVars and self:getDarkRPVar("rpname")
		or self:SteamName()
end
meta.Nick = meta.Name
meta.GetName = meta.Name

/*---------------------------------------------------------------------------
Setting the RP name
---------------------------------------------------------------------------*/
function meta:setRPName(name, firstRun)
	-- Make sure nobody on this server already has this RP name
	local lowername = string.lower(tostring(name))
	DarkRP.retrieveRPNames(name, function(taken)
		if string.len(lowername) < 2 and not firstrun then return end
		-- If we found that this name exists for another player
		if taken then
			if firstRun then
				-- If we just connected and another player happens to be using our steam name as their RP name
				-- Put a 1 after our steam name
				DarkRP.storeRPName(self, name .. " 1")
				DarkRP.notify(self, 0, 12, DarkRP.getPhrase("someone_stole_steam_name"))
			else
				DarkRP.notify(self, 1, 5, DarkRP.getPhrase("unable", "RPname", DarkRP.getPhrase("already_taken")))
				return ""
			end
		else
			if not firstRun then -- Don't save the steam name in the database
				DarkRP.notifyAll(2, 6, DarkRP.getPhrase("rpname_changed", self:SteamName(), name))
				DarkRP.storeRPName(self, name)
			end
		end
	end)
end

/*---------------------------------------------------------------------------
Doors
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
Send door data to players
---------------------------------------------------------------------------*/
local function PlayerDoorCheck()
	for k, ply in pairs(player.GetAll()) do
		local trace = ply:GetEyeTrace()
		if IsValid(trace.Entity) and (trace.Entity:IsDoor() or trace.Entity:IsVehicle()) and ply.LookingAtDoor ~= trace.Entity and trace.HitPos:Distance(ply:GetShootPos()) < 410 then
			ply.LookingAtDoor = trace.Entity -- Variable that prevents streaming to clients every frame

			trace.Entity.DoorData = trace.Entity.DoorData or {}

			if not ply.DRP_DoorMemory or not ply.DRP_DoorMemory[trace.Entity] then
				net.Start("DarkRP_DoorData")
					net.WriteEntity(trace.Entity)
					net.WriteTable(trace.Entity.DoorData)
				net.Send(ply)
				ply.DRP_DoorMemory = ply.DRP_DoorMemory or {}
				ply.DRP_DoorMemory[trace.Entity] = table.Copy(trace.Entity.DoorData)
			else
				for key, v in pairs(trace.Entity.DoorData) do
					if not ply.DRP_DoorMemory[trace.Entity][key] or ply.DRP_DoorMemory[trace.Entity][key] ~= v then
						ply.DRP_DoorMemory[trace.Entity][key] = v
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String(tostring(v))
						umsg.End()
					end
				end

				for key, v in pairs(ply.DRP_DoorMemory[trace.Entity]) do
					if not trace.Entity.DoorData[key] then
						ply.DRP_DoorMemory[trace.Entity][key] = nil
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String("nil")
						umsg.End()
					end
				end
			end
		elseif ply.LookingAtDoor ~= trace.Entity then
			ply.LookingAtDoor = nil
		end
	end
end
timer.Create("RP_DoorCheck", 0.1, 0, PlayerDoorCheck)

/*---------------------------------------------------------------------------
Refresh the door data
---------------------------------------------------------------------------*/
local function refreshDoorData(ply, _, args)
	if ply.DoorDataSent and ply.DoorDataSent > (CurTime() - 0.5) then return end
	ply.DoorDataSent = CurTime()

	local ent = Entity(tonumber(args[1]) or -1)
	if not IsValid(ent) or not ent.DoorData then return end

	net.Start("DarkRP_DoorData")
		net.WriteEntity(ent)
		net.WriteTable(ent.DoorData)
	net.Send(ply)
	ply.DRP_DoorMemory = ply.DRP_DoorMemory or {}
	ply.DRP_DoorMemory[ent] = table.Copy(ent.DoorData)
end
concommand.Add("_RefreshDoorData", refreshDoorData)
