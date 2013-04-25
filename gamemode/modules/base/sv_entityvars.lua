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
function meta:setDarkRPVar(var, value, target)
	if not IsValid(self) then return end
	target = target or RecipientFilter():AddAllPlayers()

	hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, value)

	self.DarkRPVars = self.DarkRPVars or {}
	self.DarkRPVars[var] = value

	umsg.Start("DarkRP_PlayerVar", target)
		-- The index because the player handle might not exist clientside yet
		umsg.Short(self:EntIndex())
		umsg.String(var)
		if value == nil then value = "nil" end
		umsg.String(tostring(value))
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
Send the DarkRPVars to a client
---------------------------------------------------------------------------*/
local function SendDarkRPVars(ply)
	if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 1) then return end --prevent spammers
	ply.DarkRPVarsSent = CurTime()

	local sendtable = {}
	for k,v in pairs(player.GetAll()) do
		sendtable[v] = {}
		for a,b in pairs(v.DarkRPVars) do
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
