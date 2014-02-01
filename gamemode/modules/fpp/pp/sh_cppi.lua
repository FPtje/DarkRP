CPPI = CPPI or {}
CPPI.CPPI_DEFER = 102112 --\102\112 = fp
CPPI.CPPI_NOTIMPLEMENTED = 7080// FP

function CPPI:GetName()
	return "Falco's prop protection"
end

function CPPI:GetVersion()
	return "universal.1"
end

function CPPI:GetInterfaceVersion()
	return 1.1
end

function CPPI:GetNameFromUID(uid)
	return CPPI.CPPI_NOTIMPLEMENTED
end

local PLAYER = FindMetaTable("Player")
function PLAYER:CPPIGetFriends()
	if not self.Buddies then return CPPI.CPPI_DEFER end
	local FriendsTable = {}
	for k,v in pairs(self.Buddies) do
		for _,ply in pairs(player.GetAll()) do
			if ply:SteamID() == k then
				table.insert(FriendsTable, ply)
				break
			end
		end
	end
	return FriendsTable
end

local ENTITY = FindMetaTable("Entity")
function ENTITY:CPPIGetOwner()
	if CLIENT then return nil, CPPI.CPPI_NOTIMPLEMENTED end
	local Owner = self.FPPOwner
	if not IsValid(Owner) or not Owner:IsPlayer() then return Owner, self.FPPOwnerID end
	return Owner, Owner:UniqueID()
end

if SERVER then
	function ENTITY:CPPISetOwner(ply)
		self.FPPOwner = ply
		self.FPPOwnerID = ply:SteamID()
		if constraint.HasConstraints( self ) then
			local ConstrainedEntities = constraint.GetAllConstrainedEntities( self )
			for _,ent in pairs(ConstrainedEntities) do
				if IsValid(ent) then
					ent.FPPOwner = ply
					ent.FPPOwnerID = ply:SteamID()
				end
			end
		end
		return true
	end

	function ENTITY:CPPISetOwnerUID(UID)
		local ply = player.GetByUniqueID(tostring(UID))
		if self.FPPOwner and ply:IsValid() then
			if self.AllowedPlayers then
				table.insert(self.AllowedPlayers, ply)
			else
				self.AllowedPlayers = {ply}
			end
			return true
		elseif ply:IsValid() then
			self.FPPOwner = ply
			self.FPPOwnerID = ply:SteamID()
			return true
		end
		return false
	end

	function ENTITY:CPPICanTool(ply, tool)
		local Value = FPP.Protect.CanTool(ply, nil, tool, self)
		if Value ~= false and Value ~= true then Value = true end
		return Value-- fourth argument is entity, to avoid traces.
	end

	function ENTITY:CPPICanPhysgun(ply)
		return FPP.PlayerCanTouchEnt(ply, self, "Physgun1", "FPP_PHYSGUN1")
	end

	function ENTITY:CPPICanPickup(ply)
		return FPP.PlayerCanTouchEnt(ply, self, "Gravgun1", "FPP_GRAVGUN1")
	end

	function ENTITY:CPPICanPunt(ply)
		return FPP.PlayerCanTouchEnt(ply, self, "Gravgun1", "FPP_GRAVGUN1")
	end
end
