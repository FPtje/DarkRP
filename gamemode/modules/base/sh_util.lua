-----------------------------------------------------------------------------[[
/*---------------------------------------------------------------------------
Utility functions
---------------------------------------------------------------------------*/
-----------------------------------------------------------------------------]]

local vector = FindMetaTable("Vector")
local meta = FindMetaTable("Player")

/*---------------------------------------------------------------------------
Decides whether the vector could be seen by the player if they were to look at it
---------------------------------------------------------------------------*/
function vector:isInSight(filter, ply)
	ply = ply or LocalPlayer()
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = self
	trace.filter = filter
	trace.mask = -1
	local TheTrace = util.TraceLine(trace)

	return not TheTrace.Hit, TheTrace.HitPos
end

/*---------------------------------------------------------------------------
Find a player based on given information
---------------------------------------------------------------------------*/
function DarkRP.findPlayer(info)
	if not info or info == "" then return nil end
	local pls = player.GetAll()

	for k = 1, #pls do -- Proven to be faster than pairs loop.
		local v = pls[k]
		if tonumber(info) == v:UserID() then
			return v
		end

		if info == v:SteamID() then
			return v
		end

		if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) ~= nil then
			return v
		end

		if string.find(string.lower(v:Name()), string.lower(tostring(info)), 1, true) ~= nil then
			return v
		end
	end
	return nil
end

/*---------------------------------------------------------------------------
Print the currently available vehicles
---------------------------------------------------------------------------*/
local function GetAvailableVehicles(ply)
	if SERVER and IsValid(ply) and not ply:IsAdmin() then return end
	local print = SERVER and ServerLog or Msg

	print(DarkRP.getPhrase("rp_getvehicles") .. "\n")
	for k,v in pairs(list.Get("Vehicles")) do
		print("\""..k.."\"" .. "\n")
	end
end
if SERVER then
	concommand.Add("rp_getvehicles_sv", GetAvailableVehicles)
else
	concommand.Add("rp_getvehicles", GetAvailableVehicles)
end

function meta:hasDarkRPPrivilege(priv)
	if FAdmin then
		return FAdmin.Access.PlayerHasPrivilege(self, priv)
	end
	return self:IsAdmin()
end
