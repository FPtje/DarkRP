CreateConVar("_FAdmin_immunity", 1, {FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE});

FAdmin.Access = FAdmin.Access or {}
FAdmin.Access.ADMIN = {"user", "admin", "superadmin"}
FAdmin.Access.ADMIN[0] = "noaccess"

FAdmin.Access.Groups = FAdmin.Access.Groups or {}
FAdmin.Access.Privileges = FAdmin.Access.Privileges or {}

function FAdmin.Access.AddGroup(name, admin_access/*0 = not admin, 1 = admin, 2 = superadmin*/, privs, immunity)
	FAdmin.Access.Groups[name] = FAdmin.Access.Groups[name] or {ADMIN = admin_access, PRIVS = privs or {}, immunity = immunity}
	if not SERVER then return end

	MySQLite.queryValue("SELECT COUNT(*) FROM FADMIN_GROUPS WHERE NAME = " .. MySQLite.SQLStr(name) .. ";", function(val)
		if tonumber(val or 0) > 0 then return end

		MySQLite.query("REPLACE INTO FADMIN_GROUPS VALUES(".. MySQLite.SQLStr(name) .. ", " .. tonumber(admin_access) .. ");");

		for priv, _ in pairs(privs or {}) do
			MySQLite.query("REPLACE INTO FADMIN_PRIVILEGES VALUES(" .. MySQLite.SQLStr(name) .. ", " .. MySQLite.SQLStr(priv) .. ");");
		end
	end);

	if immunity then
		MySQLite.query("REPLACE INTO FAdmin_Immunity VALUES(" .. MySQLite.SQLStr(name) .. ", " .. tonumber(immunity) .. ");");
	end

	if FAdmin.Access.SendGroups and privs then
		for k,v in pairs(player.GetAll()) do
			FAdmin.Access.SendGroups(v);
		end
	end
end

function FAdmin.Access.RemoveGroup(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
	if not args[1] then return false end

	if FAdmin.Access.Groups[args[1]] and not table.HasValue({"superadmin", "admin", "user", "noaccess"}, string.lower(args[1])) then
		MySQLite.query("DELETE FROM FADMIN_GROUPS WHERE NAME = ".. MySQLite.SQLStr(args[1])..";");
		FAdmin.Access.Groups[args[1]] = nil
		FAdmin.Messages.SendMessage(ply, 4, "Group succesfully removed");

		for k,v in pairs(player.GetAll()) do
			FAdmin.Access.SendGroups(v);
		end
	end
	return true, args[1]
end

local PLAYER = FindMetaTable("Player");

local oldplyIsAdmin = PLAYER.IsAdmin
function PLAYER:IsAdmin(...)
	local usergroup = self:GetUserGroup();

	if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[usergroup] then return oldplyIsAdmin(self, ...) or game.SinglePlayer() end

	if (FAdmin.Access.Groups[usergroup] and FAdmin.Access.Groups[usergroup].ADMIN >= 1/*1 = admin*/) or (self.IsListenServerHost and self:IsListenServerHost()) then
		return true
	end

	if CLIENT and tonumber(self:FAdmin_GetGlobal("FAdmin_admin")) and self:FAdmin_GetGlobal("FAdmin_admin") >= 1 then return true end

	return oldplyIsAdmin(self, ...) or game.SinglePlayer();
end

local oldplyIsSuperAdmin = PLAYER.IsSuperAdmin
function PLAYER:IsSuperAdmin(...)
	local usergroup = self:GetUserGroup();
	if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[usergroup] then return oldplyIsSuperAdmin(self, ...) or game.SinglePlayer() end
	if (FAdmin.Access.Groups[usergroup] and FAdmin.Access.Groups[usergroup].ADMIN >= 2/*2 = superadmin*/) or (self.IsListenServerHost and self:IsListenServerHost()) then
		return true
	end
	if CLIENT and tonumber(self:FAdmin_GetGlobal("FAdmin_admin")) and self:FAdmin_GetGlobal("FAdmin_admin") >= 2 then return true end
	return oldplyIsSuperAdmin(self, ...) or game.SinglePlayer();
end

--Privileges
function FAdmin.Access.AddPrivilege(Name, admin_access)
	FAdmin.Access.Privileges[Name] = admin_access
end

function FAdmin.Access.PlayerHasPrivilege(ply, priv, target)
	-- This is the server console
	if ply:EntIndex() == 0 or game.SinglePlayer() or (ply.IsListenServerHost and ply:IsListenServerHost()) then return true end
	-- Privilege does not exist
	if not FAdmin.Access.Privileges[priv] then return ply:IsAdmin() end

	local Usergroup = ply:GetUserGroup();

	local canTarget = hook.Call("FAdmin_CanTarget", nil, ply, priv, target);
	if canTarget ~= nil then
		return canTarget
	end

	if FAdmin.GlobalSetting.Immunity and
		not isstring(target) and IsValid(target) and target ~= ply and
		FAdmin.Access.Groups[Usergroup] and	FAdmin.Access.Groups[target:GetUserGroup()] and
		FAdmin.Access.Groups[Usergroup].immunity and FAdmin.Access.Groups[target:GetUserGroup()].immunity and
		FAdmin.Access.Groups[target:GetUserGroup()].immunity >= FAdmin.Access.Groups[Usergroup].immunity then
		return false
	end

	if not FAdmin.Access.Groups[Usergroup] then
		return ply:IsAdmin() -- solution until CAMI exists
	end

	if FAdmin.Access.Groups[Usergroup].PRIVS[priv] then
		return true
	end

	if CLIENT and ply.FADMIN_PRIVS and ply.FADMIN_PRIVS[priv] then return true end

	return false
end

FAdmin.StartHooks["Accessfunctions"] = function()
	FAdmin.Access.AddPrivilege("SetAccess", 3) -- AddPrivilege is shared, run on both client and server
	FAdmin.Access.AddPrivilege("SeeAdmins", 1);
	FAdmin.Commands.AddCommand("RemoveGroup", FAdmin.Access.RemoveGroup);

	local printPlyGroup = function(ply) print(ply:Nick(), "\t|\t", ply:GetUserGroup()) end
	FAdmin.Commands.AddCommand("Admins", function(ply)
		if not FAdmin.Access.PlayerHasPrivilege(ply, "SeeAdmins") then return false end
		for k,v in pairs(player.GetAll()) do
			ply:PrintMessage(HUD_PRINTCONSOLE, v:Nick() .. "\t|\t" .. v:GetUserGroup());
		end
		return true
	end
	);
end
