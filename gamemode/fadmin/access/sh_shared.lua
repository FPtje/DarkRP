CreateConVar("_FAdmin_immunity", 1, {FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE})

FAdmin.Access = {}
FAdmin.Access.ADMIN = {"user", "admin", "superadmin"}
FAdmin.Access.ADMIN[0] = "noaccess"

FAdmin.Access.Groups = {}
FAdmin.Access.Privileges = {}

function FAdmin.Access.AddGroup(name, admin_access/*0 = not admin, 1 = admin, 2 = superadmin*/, privs)
	FAdmin.Access.Groups[name] = {ADMIN = admin_access, PRIVS = privs or {}}
	if SERVER then
		if privs then
			DB.Query("REPLACE INTO FADMIN_GROUP VALUES(".. sql.SQLStr(name) .. ", " .. admin_access.. ", "..sql.SQLStr(table.concat(privs, ";"))..");")
		else
			DB.Query("REPLACE INTO FADMIN_GROUP VALUES(".. sql.SQLStr(name) .. ", " .. admin_access..", NULL);")
		end
	end
end

FAdmin.Access.AddGroup("superadmin", 2)
FAdmin.Access.AddGroup("admin", 1)
FAdmin.Access.AddGroup("user", 0)
FAdmin.Access.AddGroup("noaccess", 0)

function FAdmin.Access.RemoveGroup(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[1] then return end

	if FAdmin.Access.Groups[args[1]] and not table.HasValue({"superadmin", "admin", "user", "noaccess"}, string.lower(args[1])) then
		DB.Query("DELETE FROM FADMIN_GROUP WHERE NAME = "..sql.SQLStr(args[1])..";")
		FAdmin.Access.Groups[args[1]] = nil
		FAdmin.Messages.SendMessage(ply, 4, "Group succesfully removed")
	end
end

local PLAYER = FindMetaTable("Player")

local oldplyIsAdmin = PLAYER.IsAdmin
function PLAYER:IsAdmin(...)
	local usergroup = self:GetNWString("usergroup")

	if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[usergroup] then return oldplyIsAdmin(self, ...) or game.SinglePlayer() end

	if (FAdmin.Access.Groups[usergroup] and FAdmin.Access.Groups[usergroup].ADMIN >= 1/*1 = admin*/) or (self.IsListenServerHost and self:IsListenServerHost()) then
		return true
	end

	if CLIENT and tonumber(self:FAdmin_GetGlobal("FAdmin_admin")) and self:FAdmin_GetGlobal("FAdmin_admin") >= 1 then return true end

	return oldplyIsAdmin(self, ...) or game.SinglePlayer()
end

local oldplyIsSuperAdmin = PLAYER.IsSuperAdmin
function PLAYER:IsSuperAdmin(...)
	local usergroup = self:GetNWString("usergroup")
	if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[usergroup] then return oldplyIsSuperAdmin(self, ...) or game.SinglePlayer() end
	if (FAdmin.Access.Groups[usergroup] and FAdmin.Access.Groups[usergroup].ADMIN >= 2/*2 = superadmin*/) or (self.IsListenServerHost and self:IsListenServerHost()) then
		return true
	end
	if CLIENT and tonumber(self:FAdmin_GetGlobal("FAdmin_admin")) and self:FAdmin_GetGlobal("FAdmin_admin") >= 2 then return true end
	return oldplyIsSuperAdmin(self, ...) or game.SinglePlayer()
end

--Privileges
function FAdmin.Access.AddPrivilege(Name, admin_access)
	FAdmin.Access.Privileges[Name] = admin_access
end

function FAdmin.Access.PlayerHasPrivilege(ply, priv, target)
	if ply:EntIndex() == 0 or game.SinglePlayer() or (ply.IsListenServerHost and ply:IsListenServerHost()) then return true end -- This is the server console
	if not FAdmin.Access.Privileges[priv] then return ply:IsAdmin() end

	local Usergroup = ply:GetNWString("usergroup")

	if FAdmin.GlobalSetting.Immunity and type(target) ~= "string" and IsValid(target) and target ~= ply and FAdmin.Access.Groups[Usergroup] and
	FAdmin.Access.Groups[target:GetNWString("usergroup")] and FAdmin.Access.Groups[target:GetNWString("usergroup")].ADMIN >= FAdmin.Access.Groups[Usergroup].ADMIN then
		return false
	end

	if FAdmin.Access.Groups[Usergroup] and table.HasValue(FAdmin.Access.Groups[Usergroup].PRIVS, priv) then
		return true
	end

	if FAdmin.Access.Privileges[priv] == 1 and ply:GetNWString("usergroup") ~= "noaccess" then return true -- 0 = no admin access needed
	elseif FAdmin.Access.Privileges[priv] == 2 and ply:IsAdmin() then return true -- Admin access needed
	elseif FAdmin.Access.Privileges[priv] >= 3 and ply:IsSuperAdmin() then return true end --SuperAdmin access required

	if CLIENT and ply.FADMIN_PRIVS and table.HasValue(ply.FADMIN_PRIVS, priv) then return true end

	return false
end

FAdmin.StartHooks["AccessFunctions"] = function()
	FAdmin.Access.AddPrivilege("SetAccess", 3) -- AddPrivilege is shared, run on both client and server
	FAdmin.Commands.AddCommand("RemoveGroup", FAdmin.Access.RemoveGroup)
end