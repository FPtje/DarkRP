--Immunity
cvars.AddChangeCallback("_FAdmin_immunity", function(Cvar, Previous, New)
	FAdmin.SetGlobalSetting("Immunity", (tonumber(New) == 1 and true) or false)
	FAdmin.SaveSetting("_FAdmin_immunity", tonumber(New))
end)

hook.Add("InitPostEntity", "InitializeFAdminGroups", function()
	timer.Simple(2, function()
		DB.Query("CREATE TABLE IF NOT EXISTS FADMIN_GROUP(NAME VARCHAR(40) NOT NULL PRIMARY KEY, ADMIN_ACCESS INTEGER NOT NULL, PRIVS VARCHAR(100));")
		DB.Query("CREATE TABLE IF NOT EXISTS FAdmin_PlayerGroup(steamid VARCHAR(40) NOT NULL, groupname VARCHAR(40) NOT NULL, PRIMARY KEY(steamid));")

		DB.Query("SELECT * FROM FADMIN_GROUP", function(data)
			if not data then return end
			for k,v in pairs(data) do
				if v.PRIVS == "NULL" then v.PRIVS = nil else v.PRIVS = string.Explode(";", v.PRIVS) end
				FAdmin.Access.Groups[v.NAME] = {ADMIN = tonumber(v.ADMIN_ACCESS), PRIVS = v.PRIVS or {}}
			end
		end)
	end)
end)

function FAdmin.Access.PlayerSetGroup(ply, group)
	if not FAdmin.Access.Groups[group] then return end
	local SteamID = type(ply) ~= "string" and IsValid(ply) and ply:SteamID() or ply
	if type(ply) ~= "string" and IsValid(ply) then
		ply:SetUserGroup(group)
	end

	DB.Query("REPLACE INTO FAdmin_PlayerGroup VALUES("..sql.SQLStr(SteamID)..", "..sql.SQLStr(group)..");")
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

local nosend = {"user", "admin", "superadmin", "noaccess"}
local function SendCustomGroups(ply)
	for k,v in pairs(FAdmin.Access.Groups) do
		if not table.HasValue(nosend, k) then
			SendUserMessage("FADMIN_SendGroups", ply, k, v.ADMIN)
			local privs = {}
			local SendAmount = 1
			privs[SendAmount] = ""
			for k,v in pairs(v.PRIVS) do
				if string.len(privs[SendAmount]) > 200 then
					SendAmount = SendAmount + 1
					privs[SendAmount] = ""
				end
				privs[SendAmount] = privs[SendAmount].. ((privs[SendAmount] ~= "" and ";") or "")..v
			end
			for i = 1, SendAmount do
				SendUserMessage("FAdmin_SendPrivs", ply, k, privs[SendAmount])
			end
		end
	end
end

function FAdmin.Access.SetAccess(ply, cmd, args) -- FAdmin SetAccess <player> groupname [new_groupadmin, new_groupprivs]
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local targets = FAdmin.FindPlayer(args[1])

	if not args[2] or (not FAdmin.Access.Groups[args[2]] and not tonumber(args[3])) then
		FAdmin.Messages.SendMessage(ply, 1, "Group not found")
		return
	elseif args[2] and not FAdmin.Access.Groups[args[2]] and tonumber(args[3]) then
		local Privs = table.Copy(args)
		Privs[1], Privs[2], Privs[3] = nil, nil, nil, nil
		Privs = table.ClearKeys(Privs)

		FAdmin.Access.AddGroup(args[2], tonumber(args[3]), Privs)-- Add new group
		FAdmin.Messages.SendMessage(ply, 2, "Group created")
		SendCustomGroups()
	end

	if not targets and string.find(args[1], "STEAM_") then
		FAdmin.Access.PlayerSetGroup(args[1], args[2])
		FAdmin.Messages.SendMessage(ply, 2, "User access set!")
		return
	elseif not targets then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if IsValid(target) then
			FAdmin.Access.PlayerSetGroup(target, args[2])
			FAdmin.Messages.SendMessage(ply, 2, "User access set!")
		end
	end
end

--hooks and stuff

hook.Add("PlayerInitialSpawn", "FAdmin_SetAccess", function(ply)
	DB.QueryValue("SELECT groupname FROM FAdmin_PlayerGroup WHERE steamid = "..sql.SQLStr(ply:SteamID())..";", function(Group)
		if not Group then return end
		ply:SetUserGroup(Group)

		if FAdmin.Access.Groups[Group] then
			ply:FAdmin_SetGlobal("FAdmin_admin", FAdmin.Access.Groups[Group].ADMIN_ACCESS)

			for k,v in pairs(FAdmin.Access.Groups[Group].PRIVS) do
				SendUserMessage("FADMIN_RetrievePrivs", ply, tostring(v))
			end
		end
		SendCustomGroups(ply)
	end)
end)

local function SetImmunity(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end -- SetAccess privilege because they can handle immunity settings
	if not args[1] then FAdmin.Messages.SendMessage(ply, 5, "Invalid argument!") return end
	RunConsoleCommand("_FAdmin_immunity", args[1])
	FAdmin.Messages.SendMessage(ply, 4, "turned " .. ((tonumber(args[1]) == 1 and "on") or "off") .. " admin immunity!")
end

FAdmin.StartHooks["Access"] = function() --Run all functions that depend on other plugins
	FAdmin.Commands.AddCommand("setroot", FAdmin.Access.SetRoot)
	FAdmin.Commands.AddCommand("setaccess", FAdmin.Access.SetAccess)

	FAdmin.Commands.AddCommand("immunity", SetImmunity)

	FAdmin.SetGlobalSetting("Immunity", (GetConVarNumber("_FAdmin_immunity") == 1 and true) or false)
end

concommand.Add("_FAdmin_SendUserGroups", function(ply)
	for k,v in SortedPairsByMemberValue(FAdmin.Access.Groups, "ADMIN", true) do
		SendUserMessage("FADMIN_RetrieveGroup", ply, k)
	end
end)