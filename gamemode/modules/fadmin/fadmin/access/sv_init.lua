--Immunity
cvars.AddChangeCallback("_FAdmin_immunity", function(Cvar, Previous, New)
	FAdmin.SetGlobalSetting("Immunity", (tonumber(New) == 1 and true) or false)
	FAdmin.SaveSetting("_FAdmin_immunity", tonumber(New))
end)

hook.Add("DatabaseInitialized", "InitializeFAdminGroups", function()
	MySQLite.query("CREATE TABLE IF NOT EXISTS FADMIN_GROUPS(NAME VARCHAR(40) NOT NULL PRIMARY KEY, ADMIN_ACCESS INTEGER NOT NULL);")
	MySQLite.query("CREATE TABLE IF NOT EXISTS FAdmin_PlayerGroup(steamid VARCHAR(40) NOT NULL, groupname VARCHAR(40) NOT NULL, PRIMARY KEY(steamid));")
	MySQLite.query([[CREATE TABLE IF NOT EXISTS FADMIN_PRIVILEGES(
		NAME VARCHAR(40),
		PRIVILEGE VARCHAR(100),
		PRIMARY KEY(NAME, PRIVILEGE),
		FOREIGN KEY(NAME) REFERENCES FADMIN_GROUPS(NAME)
			ON UPDATE CASCADE
			ON DELETE CASCADE
	);]], function()

		MySQLite.query("SELECT g.NAME, g.ADMIN_ACCESS, p.PRIVILEGE FROM FADMIN_GROUPS g LEFT OUTER JOIN FADMIN_PRIVILEGES p ON g.NAME = p.NAME;", function(data)
			if not data then return end

			for _, v in pairs(data) do
				FAdmin.Access.Groups[v.NAME] = FAdmin.Access.Groups[v.NAME] or
					{ADMIN = tonumber(v.ADMIN_ACCESS), PRIVS = {}}

				if v.PRIVILEGE and v.PRIVILEGE ~= "NULL" then
					FAdmin.Access.Groups[v.NAME].PRIVS[v.PRIVILEGE] = true
				end
			end

			-- Send groups to early joiners and listen server hosts
			for k,v in pairs(player.GetAll()) do
				FAdmin.Access.SendGroups(v)
			end
		end)

		FAdmin.Access.AddGroup("superadmin", 2)
		FAdmin.Access.AddGroup("admin", 1)
		FAdmin.Access.AddGroup("user", 0)
		FAdmin.Access.AddGroup("noaccess", 0)
	end)
end)

-- Check if the privileges are loaded when we're sure they're all added
timer.Simple(3, function()
	MySQLite.queryValue("SELECT COUNT(*) FROM FADMIN_PRIVILEGES;", function(val)
		if val ~= "0" then return end

		local hasPrivs = {"noaccess", "user", "admin", "superadmin"}

		for priv, access in pairs(FAdmin.Access.Privileges) do
			for i = access + 1, #hasPrivs, 1 do
				FAdmin.Access.Groups[hasPrivs[i]].PRIVS[priv] = true
				MySQLite.query("INSERT INTO FADMIN_PRIVILEGES VALUES(" .. MySQLite.SQLStr(hasPrivs[i]) .. ", " .. MySQLite.SQLStr(priv) .. ");")
			end
		end
	end)
end)

function FAdmin.Access.PlayerSetGroup(ply, group)
	if not FAdmin.Access.Groups[group] then return end
	ply = isstring(ply) and FAdmin.FindPlayer(ply) and FAdmin.FindPlayer(ply)[1] or ply
	local SteamID = type(ply) ~= "string" and IsValid(ply) and ply:SteamID() or ply

	if type(ply) ~= "string" and IsValid(ply) then
		ply:SetUserGroup(group)
	end

	MySQLite.query("REPLACE INTO FAdmin_PlayerGroup VALUES(" .. MySQLite.SQLStr(SteamID)..", " .. MySQLite.SQLStr(group)..");")
end

function FAdmin.Access.SetRoot(ply, cmd, args) -- FAdmin setroot player. Sets the player to superadmin
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if IsValid(target) then
			FAdmin.Access.PlayerSetGroup(target, "superadmin")
			if ULib and ULib.ucl and ULib.ucl.groups and ULib.ucl.groups["superadmin"] then --Add to ULX
				ULib.ucl.addUser(target:SteamID(), nil, nil, "superadmin")
			end
			FAdmin.Messages.SendMessage(ply, 2, "User set to superadmin!")
		end
	end
end

-- AddGroup <Groupname> <Adminstatus> <Privileges>
local function AddGroup(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local Privs = {}
	for i = 3, #args, 1 do
		Privs[args[i]] = true
	end

	FAdmin.Access.AddGroup(args[1], tonumber(args[2]), Privs)-- Add new group
	FAdmin.Messages.SendMessage(ply, 4, "Group created")
	FAdmin.Access.SendGroups()
end

local function AddPrivilege(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local group, priv = args[1], args[2]
	if not FAdmin.Access.Groups[group] or not FAdmin.Access.Privileges[priv] then
		FAdmin.Messages.SendMessage(ply, 5, "Invalid arguments")
		return
	end

	FAdmin.Access.Groups[group].PRIVS[priv] = true

	MySQLite.query("REPLACE INTO FADMIN_PRIVILEGES VALUES(" .. MySQLite.SQLStr(group) .. ", " .. MySQLite.SQLStr(priv) .. ");")
	SendUserMessage("FAdmin_AddPriv", player.GetAll(), group, priv)
	FAdmin.Messages.SendMessage(ply, 4, "Privilege Added!")
end

local function RemovePrivilege(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local group, priv = args[1], args[2]
	if not FAdmin.Access.Groups[group] or not FAdmin.Access.Privileges[priv] then
		FAdmin.Messages.SendMessage(ply, 5, "Invalid arguments")
		return
	end

	FAdmin.Access.Groups[group].PRIVS[priv] = nil

	MySQLite.query("DELETE FROM FADMIN_PRIVILEGES WHERE NAME = " .. MySQLite.SQLStr(group) .. " AND PRIVILEGE = " .. MySQLite.SQLStr(priv) .. ";")
	SendUserMessage("FAdmin_RemovePriv", player.GetAll(), group, priv)
	FAdmin.Messages.SendMessage(ply, 4, "Privilege Removed!")
end

function FAdmin.Access.SendGroups(ply)
	if not FAdmin.Access.Groups then return end

	net.Start("FADMIN_SendGroups")
		net.WriteTable(FAdmin.Access.Groups)
	net.Send(ply)
end

-- FAdmin SetAccess <player> <groupname> [new_groupadmin, new_groupprivs]
function FAdmin.Access.SetAccess(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local targets = FAdmin.FindPlayer(args[1])

	if not args[2] or (not FAdmin.Access.Groups[args[2]] and not tonumber(args[3])) then
		FAdmin.Messages.SendMessage(ply, 1, "Group not found")
		return
	elseif args[2] and not FAdmin.Access.Groups[args[2]] and tonumber(args[3]) then
		local Privs = {}
		for i = 4, #args, 1 do
			Privs[args[i]] = true
		end

		FAdmin.Access.AddGroup(args[2], tonumber(args[3]), Privs)-- Add new group
		FAdmin.Messages.SendMessage(ply, 2, "Group created")
		FAdmin.Access.SendGroups()
	end

	if not targets and (string.find(args[1], "STEAM_") or args[1] == "BOT") then
		local target, groupname = args[1], args[2]
		-- The console splits arguments on colons. Very annoying.
		if args[1] == "STEAM_0" then
			target = table.concat(args, "", 1, 5)
			groupname = args[6]
		end
		FAdmin.Access.PlayerSetGroup(target, groupname)
		FAdmin.Messages.SendMessage(ply, 4, "User access set!")
		return
	elseif not targets then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if IsValid(target) then
			FAdmin.Access.PlayerSetGroup(target, args[2])
			FAdmin.Messages.SendMessage(ply, 4, "User access set!")
		end
	end
end

--hooks and stuff

hook.Add("PlayerInitialSpawn", "FAdmin_SetAccess", function(ply)
	MySQLite.queryValue("SELECT groupname FROM FAdmin_PlayerGroup WHERE steamid = " .. MySQLite.SQLStr(ply:SteamID())..";", function(Group)
		if not Group then return end
		ply:SetUserGroup(Group)

		if FAdmin.Access.Groups[Group] then
			ply:FAdmin_SetGlobal("FAdmin_admin", FAdmin.Access.Groups[Group].ADMIN_ACCESS)
		end
	end)
	FAdmin.Access.SendGroups(ply)
end)

local function SetImmunity(ply, cmd, args)
	-- SetAccess privilege because they can handle immunity settings
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	if not args[1] then FAdmin.Messages.SendMessage(ply, 5, "Invalid argument!") return end
	RunConsoleCommand("_FAdmin_immunity", args[1])
	FAdmin.Messages.SendMessage(ply, 4, "turned " .. ((tonumber(args[1]) == 1 and "on") or "off") .. " admin immunity!")
end

FAdmin.StartHooks["Access"] = function() --Run all functions that depend on other plugins
	FAdmin.Commands.AddCommand("setroot", FAdmin.Access.SetRoot)
	FAdmin.Commands.AddCommand("setaccess", FAdmin.Access.SetAccess)

	FAdmin.Commands.AddCommand("AddGroup", AddGroup)

	FAdmin.Commands.AddCommand("AddPrivilege", AddPrivilege)
	FAdmin.Commands.AddCommand("RemovePrivilege", RemovePrivilege)

	FAdmin.Commands.AddCommand("immunity", SetImmunity)

	FAdmin.SetGlobalSetting("Immunity", (GetConVarNumber("_FAdmin_immunity") == 1 and true) or false)
end