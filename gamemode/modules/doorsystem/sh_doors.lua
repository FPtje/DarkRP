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

local playerMeta = FindMetaTable("Player")
function playerMeta:IsCP()
	if not IsValid(self) then return false end
	local Team = self:Team()
	return GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[Team]
end

function playerMeta:CanAfford(amount)
	if not amount or self.DarkRPUnInitialized then return false end
	return math.floor(amount) >= 0 and (self:getDarkRPVar("money") or 0) - math.floor(amount) >= 0
end
