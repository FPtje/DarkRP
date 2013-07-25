FPP = FPP or {}

util.AddNetworkString("FPP_Groups")
util.AddNetworkString("FPP_GroupMembers")

FPP.Blocked = FPP.Blocked or {}
	FPP.Blocked.Physgun1 = FPP.Blocked.Physgun1 or {}
	FPP.Blocked.Spawning1 = FPP.Blocked.Spawning1 or {}
	FPP.Blocked.Gravgun1 = FPP.Blocked.Gravgun1 or {}
	FPP.Blocked.Toolgun1 = FPP.Blocked.Toolgun1 or {}
	FPP.Blocked.PlayerUse1 = FPP.Blocked.PlayerUse1 or {}
	FPP.Blocked.EntityDamage1 = FPP.Blocked.EntityDamage1 or {}

FPP.BlockedModels = FPP.BlockedModels or {}

FPP.RestrictedTools = FPP.RestrictedTools or {}
FPP.RestrictedToolsPlayers = FPP.RestrictedToolsPlayers or {}

FPP.Groups = FPP.Groups or {}
FPP.GroupMembers = FPP.GroupMembers or {}

function FPP.Notify(ply, text, bool)
	if ply:EntIndex() == 0 then
		ServerLog(text)
		return
	end
	umsg.Start("FPP_Notify", ply)
		umsg.String(text)
		umsg.Bool(bool)
	umsg.End()
	ply:PrintMessage(HUD_PRINTCONSOLE, text)
end

function FPP.NotifyAll(text, bool)
	umsg.Start("FPP_Notify")
		umsg.String(text)
		umsg.Bool(bool)
	umsg.End()
	for _,ply in pairs(player.GetAll()) do
		ply:PrintMessage(HUD_PRINTCONSOLE, text)
	end
end

local function FPP_SetSetting(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[1] or not args[3] or not FPP.Settings[args[1]] then FPP.Notify(ply, "Argument(s) invalid", false) return end
	if not FPP.Settings[args[1]][args[2]] then FPP.Notify(ply, "Argument invalid",false) return end

	FPP.Settings[args[1]][args[2]] = tonumber(args[3])
	RunConsoleCommand("_"..args[1].."_"..args[2], tonumber(args[3]))

	MySQLite.queryValue("SELECT var FROM ".. args[1] .. " WHERE var = "..sql.SQLStr(args[2])..";", function(data)
		if not data then
			MySQLite.query("INSERT INTO ".. args[1] .. " VALUES(" .. sql.SQLStr(args[2]) .. ", " .. args[3] .. ");")
		elseif tonumber(data) ~= args[3] then
			MySQLite.query("UPDATE ".. args[1] .. " SET setting = " .. args[3] .. " WHERE var = " .. sql.SQLStr(args[2]) .. ";")
		end

		FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console").. " set ".. string.lower(string.gsub(args[1], "FPP_", "")) .. " "..args[2].." to " .. tostring(args[3]), util.tobool(tonumber(args[3])))
	end)
end
concommand.Add("FPP_setting", FPP_SetSetting)

local function AddBlocked(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[1] or not args[2] or not FPP.Blocked[args[1]] then FPP.Notify(ply, "Argument(s) invalid", false) return end
	args[2] = string.lower(args[2])
	if FPP.Blocked[args[1]][args[2]] then return end
	FPP.Blocked[args[1]][args[2]] = true

	MySQLite.query("SELECT * FROM FPP_BLOCKED1;", function(data)
		if type(data) == "table" then
			local found = false
			local highest = 0
			for k,v in pairs(data) do
				if tonumber(v.id) > highest then
					highest = tonumber(v.id)
				end
				if v.var == args[1] and v.setting == args[2] then
					found = true
				end
			end
			if not found then
				MySQLite.query("INSERT INTO FPP_BLOCKED1 VALUES("..highest + 1 ..", " .. sql.SQLStr(args[1]) .. ", " .. sql.SQLStr(args[2]) .. ");")
			end
		else
			--insert
			MySQLite.query("INSERT INTO FPP_BLOCKED1 VALUES(1, " .. sql.SQLStr(args[1]) .. ", " .. sql.SQLStr(args[2]) .. ");")
		end

		FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console").. " added ".. args[2] .. " to the "..args[1] .. " black/whitelist", true)
	end)
end
concommand.Add("FPP_AddBlocked", AddBlocked)

local function AddBlockedModel(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[1] then FPP.Notify(ply, "Argument(s) invalid", false) return end

	local model = string.lower(args[1])
	model = string.Replace(model, "\\", "/")

	if FPP.BlockedModels[model] then FPP.Notify(ply, "This model is already in the black/whitelist", false) return end

	FPP.BlockedModels[model] = true
	MySQLite.query("REPLACE INTO FPP_BLOCKEDMODELS1 VALUES("..sql.SQLStr(model)..");")

	FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console").. " added ".. model .. " to the blocked models black/whitelist", true)
end
concommand.Add("FPP_AddBlockedModel", AddBlockedModel)

local function RemoveBlocked(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[1] or not args[2] or not FPP.Blocked[args[1]] then FPP.Notify(ply, "Argument(s) invalid", false) return end

	FPP.Blocked[args[1]][args[2]] = nil

	MySQLite.query("DELETE FROM FPP_BLOCKED1 WHERE var = "..sql.SQLStr(args[1]) .. " AND setting = "..sql.SQLStr(args[2])..";")
	FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console").. " removed ".. args[2] .. " from the "..args[1] .. " black/whitelist", false)
end
concommand.Add("FPP_RemoveBlocked", RemoveBlocked)

local function RemoveBlockedModel(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[1] then FPP.Notify(ply, "Argument(s) invalid", false) return end
	local model = string.lower(args[1])

	model = string.lower(model or "")
	model = string.Replace(model, "\\", "/")

	FPP.BlockedModels[model] = nil

	MySQLite.query("DELETE FROM FPP_BLOCKEDMODELS1 WHERE model = "..sql.SQLStr(model)..";")
	FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console").. " removed ".. model .. " from the blocked models black/whitelist", false)
end
concommand.Add("FPP_RemoveBlockedModel", RemoveBlockedModel)

local allowedShares = {
	SharePhysgun1 = true,
	ShareGravgun1 = true,
	SharePlayerUse1 = true,
	ShareEntityDamage1 = true,
	ShareToolgun1 = true
}
local function ShareProp(ply, cmd, args)
	if not args[1] or not IsValid(Entity(args[1])) or not args[2] then FPP.Notify(ply, "Argument(s) invalid", false) return end
	local ent = Entity(args[1])

	if not FPP.PlayerCanTouchEnt(ply, ent, "Toolgun1", "FPP_TOOLGUN1", true) then --Note: This returns false when it's someone elses shared entity, so that's not a glitch
		FPP.Notify(ply, "You do not have the right to share this entity.", false)
		return
	end

	if not tonumber(args[2]) or not IsValid(Player(tonumber(args[2]))) then -- This is for sharing prop per utility
		if not allowedShares[args[2]] then
			FPP.Notify(ply, "Argument(s) invalid", false)
			return
		end
		ent[args[2]] = util.tobool(args[3])
	else -- This is for sharing prop per player
		local target = Player(tonumber(args[2]))
		local toggle = util.tobool(args[3])
		if not ent.AllowedPlayers and toggle then -- Make the table if it isn't there
			ent.AllowedPlayers = {target}
		else
			if toggle and not table.HasValue(ent.AllowedPlayers, target) then
				table.insert(ent.AllowedPlayers, target)
				FPP.Notify(target, ply:Nick().. " shared an entity with you!", true)
			elseif not toggle then
				for k,v in pairs(ent.AllowedPlayers) do
					if v == target then
						table.remove(ent.AllowedPlayers, k)
						FPP.Notify(target, ply:Nick().. " unshared an entity with you!", false)
					end
				end
			end
		end
	end
end
concommand.Add("FPP_ShareProp", ShareProp)

local function RetrieveSettings()
	for k,v in pairs(FPP.Settings) do
		MySQLite.query("SELECT setting, var FROM "..k..";", function(data)

			if data then
				local i = 0
				for key, value in pairs(data) do
					FPP.Settings[k][value.var] = tonumber(value.setting)
					i = i + 0.05
					timer.Simple(i, function() RunConsoleCommand("_"..k.."_"..value.var, tonumber(value.setting)) end)
				end
			end
		end)
	end
end

local function RetrieveBlocked()
	MySQLite.query("SELECT * FROM FPP_BLOCKED1;", function(data)
		if type(data) == "table" then
			for k,v in pairs(data) do
				if not FPP.Blocked[v.var] then
					ErrorNoHalt((v.var or "(nil var)") .. " blocked type does not exist! (Setting: " .. (v.setting or "") .. ")")
					continue
				end

				FPP.Blocked[v.var][string.lower(v.setting)] = true
			end
		else
			data = MySQLite.query("CREATE TABLE IF NOT EXISTS FPP_BLOCKED1(id INTEGER NOT NULL, var TEXT NOT NULL, setting TEXT NOT NULL, PRIMARY KEY(id));")

			FPP.Blocked.Physgun1 = {
				["func_breakable_surf"] = true,
				["func_brush"] = true,
				["func_door"] = true,
				["prop_door_rotating"] = true,
				["func_door_rotating"] = true
			}
			FPP.Blocked.Spawning1 = {
				["func_breakable_surf"] = true,
				["player"] = true,
				["func_door"] = true,
				["prop_door_rotating"] = true,
				["func_door_rotating"] = true,
				["ent_explosivegrenade"] = true,
				["ent_mad_grenade"] = true,
				["ent_flashgrenade"] = true,
				["gmod_wire_field_device"] = true
			}
			FPP.Blocked.Gravgun1 = {["func_breakable_surf"] = true, ["vehicle_"] = true}
			FPP.Blocked.Toolgun1 = {
				["func_breakable_surf"] = true,
				["player"] = true,
				["func_door"] = true,
				["prop_door_rotating"] = true,
				["func_door_rotating"] = true
			}
			FPP.Blocked.PlayerUse1 = {}
			FPP.Blocked.EntityDamage1 = {}

			local count = 0
			MySQLite.begin()
			for k,v in pairs(FPP.Blocked) do
				for a,b in pairs(v) do
					count = count + 1
					MySQLite.query("REPLACE INTO FPP_BLOCKED1 VALUES(".. count ..", " .. sql.SQLStr(k) .. ", " .. sql.SQLStr(a) .. ");")
				end
			end
			MySQLite.commit()
		end
	end)
end

/*---------------------------------------------------------------------------
Default blocked entities
Don't save them in the database, but always block them.
---------------------------------------------------------------------------*/
function FPP.AddDefaultBlocked(types, classname)
	classname = string.lower(classname)

	if type(types) == "string" then
		FPP.Blocked[types][classname] = true
		return
	end

	for k,v in pairs(types) do
		FPP.Blocked[v][classname] = true
	end
end

local function RetrieveBlockedModels()
	FPP.BlockedModels = FPP.BlockedModels or {}
	-- Sometimes when the database retrieval is corrupt,
	-- only parts of the table will be retrieved
	-- This is a workaround
	if not MySQLite.databaseObject then
		local count = MySQLite.queryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS1;") or 0

		-- Select with offsets of a thousand.
		-- That's about the maximum it can receive properly at once
		for i=0, count, 1000 do
			MySQLite.query("SELECT * FROM FPP_BLOCKEDMODELS1 LIMIT 1000 OFFSET "..i..";", function(data)
				for k,v in pairs(data or {}) do
					FPP.BlockedModels[v.model] = true
				end
			end)
		end

		return
	end

	-- Retrieve the data normally from MySQL
	MySQLite.query("SELECT * FROM FPP_BLOCKEDMODELS1;", function(data)
		for k,v in pairs(data or {}) do
			if not v.model then continue end
			FPP.BlockedModels[v.model] = true
		end
	end)
end

local function RetrieveRestrictedTools()
	MySQLite.query("SELECT * FROM FPP_TOOLADMINONLY;", function(data)
		if type(data) == "table" then
			for k,v in pairs(data) do
				FPP.RestrictedTools[v.toolname] = {}
				FPP.RestrictedTools[v.toolname]["admin"] = tonumber(v.adminonly)
			end
		end
	end)

	MySQLite.query("SELECT * FROM FPP_TOOLRESTRICTPERSON1;", function(perplayerData)
		if type(perplayerData) ~= "table" then return end
		for k,v in pairs(perplayerData) do
			FPP.RestrictedToolsPlayers[v.toolname] = FPP.RestrictedToolsPlayers[v.toolname] or {}
			local convert = {}
			convert["1"] = true
			convert["0"] = false
			FPP.RestrictedToolsPlayers[v.toolname][v.steamid] = convert[v.allow]
		end
	end)

	MySQLite.query("SELECT * FROM FPP_TOOLTEAMRESTRICT;", function(data)
		if not data then return end

		for k,v in pairs(data) do
			FPP.RestrictedTools[v.toolname] = FPP.RestrictedTools[v.toolname] or {}
			FPP.RestrictedTools[v.toolname]["team"] = FPP.RestrictedTools[v.toolname]["team"] or {}

			table.insert(FPP.RestrictedTools[v.toolname]["team"], tonumber(v.team))
		end
	end)
end

local function RetrieveGroups()
	MySQLite.query("SELECT * FROM FPP_GROUPS3;", function(data)
		if type(data) ~= "table" then
			MySQLite.query("REPLACE INTO FPP_GROUPS3 VALUES('default', 1);")
			FPP.Groups['default'] = {}
			FPP.Groups['default'].tools = {}
			FPP.Groups['default'].allowdefault = true
			return
		end -- if there are no groups then there isn't much to load

		for k,v in pairs(data) do
			FPP.Groups[v.groupname] = {}
			FPP.Groups[v.groupname].tools = {}
			FPP.Groups[v.groupname].allowdefault = util.tobool(v.allowdefault)
		end

		MySQLite.query("SELECT * FROM FPP_GROUPTOOL;", function(data)
			if not data then return end

			for k,v in pairs(data) do
				FPP.Groups[v.groupname] = FPP.Groups[v.groupname] or {}
				FPP.Groups[v.groupname].tools = FPP.Groups[v.groupname].tools or {}

				table.insert(FPP.Groups[v.groupname].tools, v.tool)
			end
		end)

		MySQLite.query("SELECT * FROM FPP_GROUPMEMBERS1;", function(members)
			if type(members) ~= "table" then return end
			for _,v in pairs(members) do
				FPP.GroupMembers[v.steamid] = v.groupname
			end
		end)
	end)
end

local function SendSettings(ply)
	timer.Simple(10, function()
		local i = 0
		for k,v in pairs(FPP.Settings) do
			for a,b in pairs(v) do
				i = i + FrameTime()*2
				timer.Simple(i, function()
					RunConsoleCommand("_"..k.."_"..a, (b and b + 1) or 0)
					timer.Simple(i, function() RunConsoleCommand("_"..k.."_"..a, b or "") end)
				end)
			end
		end
	end)
end
hook.Add("PlayerInitialSpawn", "FPP_SendSettings", SendSettings)

local function AddGroup(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[1] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = name, optional: 2 = allowdefault
	local name = string.lower(args[1])
	local allowdefault = tonumber(args[2]) or 1

	if FPP.Groups[name] then
		FPP.Notify(ply, "Group already exists", false)
		return
	end

	FPP.Groups[name] = {}
	FPP.Groups[name].allowdefault = util.tobool(allowdefault)
	FPP.Groups[name].tools = {}

	MySQLite.query("REPLACE INTO FPP_GROUPS3 VALUES("..sql.SQLStr(name)..", "..sql.SQLStr(allowdefault)..");")
	FPP.Notify(ply, "Group added succesfully", true)
end
concommand.Add("FPP_AddGroup", AddGroup)

hook.Add("InitPostEntity", "FPP_Load_FAdmin", function()
	if FAdmin then
		for k,v in pairs(FAdmin.Access.Groups) do
			if not FPP.Groups[k] then AddGroup(Entity(0), "", {k, 1}) end
		end
	end
end)

local function RemoveGroup(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[1] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = name
	local name = string.lower(args[1])

	if not FPP.Groups[name] then
		FPP.Notify(ply, "Group does not exists", false)
		return
	end

	if name == "default" then
	FPP.Notify(ply, "Can not remove default group", false)
		return
	end

	FPP.Groups[name] = nil
	MySQLite.query("DELETE FROM FPP_GROUPS3 WHERE groupname = "..sql.SQLStr(name)..";")
	MySQLite.query("DELETE FROM FPP_GROUPTOOL WHERE groupname = "..sql.SQLStr(name)..";")

	for k,v in pairs(FPP.GroupMembers) do
		if v == name then
			FPP.GroupMembers[k] = nil -- Set group to standard if group is removed
		end
	end
	FPP.Notify(ply, "Group removed succesfully", true)
end
concommand.Add("FPP_RemoveGroup", RemoveGroup)

local function GroupChangeAllowDefault(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[2] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = groupname, 2 = new value 1/0

	local name = string.lower(args[1])
	local newval = tonumber(args[2])

	if not FPP.Groups[name] then
		FPP.Notify(ply, "Group does not exists", false)
		return
	end

	FPP.Groups[name].allowdefault = util.tobool(newval)
	MySQLite.query("UPDATE FPP_GROUPS3 SET allowdefault = "..sql.SQLStr(newval).." WHERE groupname = "..sql.SQLStr(name)..";")
	FPP.Notify(ply, "Group status changed succesfully", true)
end
concommand.Add("FPP_ChangeGroupStatus", GroupChangeAllowDefault)

local function GroupAddTool(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[2] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = groupname, 2 = tool

	local name = args[1]
	local tool = string.lower(args[2])

	if not FPP.Groups[name] then
		FPP.Notify(ply, "Group does not exists", false)
		return
	end

	FPP.Groups[name].tools = FPP.Groups[name].tools or {}

	if table.HasValue(FPP.Groups[name].tools, tool) then
		FPP.Notify(ply, "Tool is already in group!", false)
		return
	end

	table.insert(FPP.Groups[name].tools, tool)

	MySQLite.query("REPLACE INTO FPP_GROUPTOOL VALUES("..sql.SQLStr(name)..", "..sql.SQLStr(tool)..");")
	FPP.Notify(ply, "Tool added succesfully", true)
end
concommand.Add("FPP_AddGroupTool", GroupAddTool)

local function GroupRemoveTool(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[2] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = groupname, 2 = tool

	local name = args[1]
	local tool = string.lower(args[2])

	if not FPP.Groups[name] then
		FPP.Notify(ply, "Group does not exists", false)
		return
	end

	if not table.HasValue(FPP.Groups[name].tools, tool) then
		FPP.Notify(ply, "Tool does not exist in group!", false)
		return
	end

	for k,v in pairs(FPP.Groups[name].tools) do
		if v == tool then
			table.remove(FPP.Groups[name].tools, k)
		end
	end

	MySQLite.query("DELETE FROM FPP_GROUPTOOL WHERE groupname = "..sql.SQLStr(name).." AND tool = "..sql.SQLStr(tool)..";")

	FPP.Notify(ply, "Tool removed succesfully", true)
end
concommand.Add("FPP_RemoveGroupTool", GroupRemoveTool)

local function PlayerSetGroup(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	if not args[2] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = player, 2 = group

	local name = args[1]
	local group = string.lower(args[2])
	if IsValid(Player(tonumber(name) or 0)) then name = Player(tonumber(name)):SteamID()
	elseif not string.find(name, "STEAM") and name ~= "UNKNOWN" then FPP.Notify(ply, "Invalid argument(s)", false) return end

	if not FPP.Groups[group] and (not FAdmin or not FAdmin.Access.Groups[group]) then
		FPP.Notify(ply, "Group does not exists", false)
		return
	end

	if group ~= "default" then
		MySQLite.query("REPLACE INTO FPP_GROUPMEMBERS1 VALUES(".. sql.SQLStr(name)..", " .. sql.SQLStr(group) ..");")
		FPP.GroupMembers[name] = group
	else
		FPP.GroupMembers[name] = nil
		MySQLite.query("DELETE FROM FPP_GROUPMEMBERS1 WHERE steamid = "..sql.SQLStr(name)..";")
	end

	FPP.Notify(ply, "Player group succesfully set", true)
end
concommand.Add("FPP_SetPlayerGroup", PlayerSetGroup)

local function SendGroupData(ply, cmd, args)
	-- Need superadmin so clients can't spam this on server
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end
	net.Start("FPP_Groups")
		net.WriteTable(FPP.Groups)
	net.Send(ply)
end
concommand.Add("FPP_SendGroups", SendGroupData)

local function SendGroupMemberData(ply, cmd, args)
	-- Need superadmin so clients can't spam this on server
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You need superadmin privileges in order to be able to use this command", false) return end

	net.Start("FPP_GroupMembers")
		net.WriteTable(FPP.GroupMembers)
	net.Send(ply)
end
concommand.Add("FPP_SendGroupMembers", SendGroupMemberData)

local function SendBlocked(ply, cmd, args)
	if not args[1] or not FPP.Blocked[args[1]] then return end

	ply.FPPUmsg1 = ply.FPPUmsg1 or {}
	ply.FPPUmsg1[args[1]] = ply.FPPUmsg1[args[1]] or 0
	if ply.FPPUmsg1[args[1]] > CurTime() - 5 then return end
	ply.FPPUmsg1[args[1]] = CurTime()

	for k,v in pairs(FPP.Blocked[args[1]]) do
		umsg.Start("FPP_blockedlist", ply)
			umsg.String(args[1])
			umsg.String(k)
		umsg.End()
	end
end
concommand.Add("FPP_sendblocked", SendBlocked)

local function SendBlockedModels(ply, cmd, args)
	ply.FPPUmsg2 = ply.FPPUmsg2 or 0
	if ply.FPPUmsg2 > CurTime() - 10 then return end
	ply.FPPUmsg2 = CurTime()

	local i = 0
	for k,v in pairs(FPP.BlockedModels) do
		timer.Simple(i*0.01, function()
			umsg.Start("FPP_BlockedModel", ply)
				umsg.String(k)
			umsg.End()
		end)
	end
end
concommand.Add("FPP_sendblockedmodels", SendBlockedModels)

local function SendRestrictedTools(ply, cmd, args)
	ply.FPPUmsg3 = ply.FPPUmsg3 or 0
	if ply.FPPUmsg3 > CurTime() - 5 then return end
	ply.FPPUmsg3 = CurTime()

	if not args[1] then return end
	umsg.Start("FPP_RestrictedToolList", ply)
		umsg.String(args[1])
		if FPP.RestrictedTools[args[1]] and FPP.RestrictedTools[args[1]].admin then
			umsg.Long(FPP.RestrictedTools[args[1]].admin)
		else
			umsg.Long(0)
		end

		local teamrestrict = "nil"
		if FPP.RestrictedTools[args[1]] and FPP.RestrictedTools[args[1]].team then
			teamrestrict = table.concat(FPP.RestrictedTools[args[1]]["team"], ";")
		end
		if teamrestrict == "" then teamrestrict = "nil" end
		umsg.String(teamrestrict)

	umsg.End()
end
concommand.Add("FPP_SendRestrictTool", SendRestrictedTools)

--Buddies!
local function SetBuddy(ply, cmd, args)
	if not args[6] then FPP.Notify(ply, "Argument(s) invalid", false) return end
	local buddy = tonumber(args[1]) and Player(tonumber(args[1]))
	if not IsValid(buddy) then FPP.Notify(ply, "Player invalid", false) return end

	ply.Buddies = ply.Buddies or {}
	for k,v in pairs(args) do args[k] = tonumber(v) end
	ply.Buddies[buddy] = {physgun1 = util.tobool(args[2]), gravgun1 = util.tobool(args[3]), toolgun1 = util.tobool(args[4]), playeruse1 = util.tobool(args[5]), entitydamage1 = util.tobool(args[6])}
end
concommand.Add("FPP_SetBuddy", SetBuddy)

local function CleanupDisconnected(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsAdmin() then FPP.Notify(ply, "You can't clean up", false) return end
	if not args[1] then FPP.Notify(ply, "Invalid argument", false) return end
	if args[1] == "disconnected" then
		for k,v in pairs(ents.GetAll()) do
			local Owner = v:CPPIGetOwner()
			if Owner and not IsValid(Owner) then
				v:Remove()
			end
		end
		FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed all disconnected players' props", true)
		return
	elseif not tonumber(args[1]) or not IsValid(Player(tonumber(args[1]))) then
		FPP.Notify(ply, "Invalid player", false)
		return
	end

	for k,v in pairs(ents.GetAll()) do
		local Owner = v:CPPIGetOwner()
		if Owner == Player(args[1]) and not v:IsWeapon() then
			v:Remove()
		end
	end
	FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed "..Player(args[1]):Nick().. "'s entities", true)
end
concommand.Add("FPP_Cleanup", CleanupDisconnected)

local function SetToolRestrict(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then FPP.Notify(ply, "You can't set tool restrictions", false) return end
	if not args[3] then FPP.Notify(ply, "Invalid argument(s)", false) return end--FPP_restricttool <toolname> <type(admin/team)> <toggle(1/0)>
	local toolname = args[1]
	local RestrictWho = tonumber(args[2]) or args[2]-- "team" or "admin"
	local teamtoggle = tonumber(args[4]) --this argument only exists when restricting a tool for a team

	FPP.RestrictedTools[toolname] = FPP.RestrictedTools[toolname] or {}

	if RestrictWho == "admin" then
		FPP.RestrictedTools[toolname].admin = args[3] --weapons.Get("gmod_tool").Tool

		--Save to database!
		MySQLite.query("REPLACE INTO FPP_TOOLADMINONLY VALUES("..sql.SQLStr(toolname)..", "..sql.SQLStr(args[3])..");")
		FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " changed the admin status of " .. toolname , true)
	elseif RestrictWho == "team" then
		FPP.RestrictedTools[toolname]["team"] = FPP.RestrictedTools[toolname]["team"] or {}
		if teamtoggle == 0 then
			for k,v in pairs(FPP.RestrictedTools[toolname]["team"]) do
				if v == tonumber(args[3]) then
					table.remove(FPP.RestrictedTools[toolname]["team"], k)
					break
				end
			end
		elseif not table.HasValue(FPP.RestrictedTools[toolname]["team"], tonumber(args[3])) and teamtoggle == 1 then
			table.insert(FPP.RestrictedTools[toolname]["team"], tonumber(args[3]))
		end--Remove from the table if it's in there AND it's 0 otherwise do nothing

		if tobool(teamtoggle) then -- if the team restrict is enabled
			FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " restricted " .. toolname .. " to certain teams", true)
			MySQLite.query("REPLACE INTO FPP_TOOLTEAMRESTRICT VALUES("..sql.SQLStr(toolname) ..", "..tonumber(args[3])..");")
		else -- otherwise if the restriction for the team is being removed
			FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed teamrestrictions from " .. toolname, true)
			MySQLite.query("DELETE FROM FPP_TOOLTEAMRESTRICT WHERE toolname = "..sql.SQLStr(toolname).. " AND team = ".. tonumber(args[3]))
		end
	end
end
concommand.Add("FPP_restricttool", SetToolRestrict)

local function RestrictToolPerson(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
	if not args[3] then FPP.Notify(ply, "Invalid argument(s)", false) return end--FPP_restricttoolperson <toolname> <userid> <disallow, allow, remove(0,1,2)>

	local toolname = args[1]
	local target = Player(tonumber(args[2]))
	local access = tonumber(args[3])
	if not target:IsValid() then FPP.Notify(ply, "Invalid argument(s)", false) return end
	if access < 0 or access > 2 then FPP.Notify(ply, "Invalid argument(s)", false) return end

	FPP.RestrictedToolsPlayers[toolname] = FPP.RestrictedToolsPlayers[toolname] or {}

	if access == 0 or access == 1 then -- Disallow, even if other people can use it
		FPP.RestrictedToolsPlayers[toolname][target:SteamID()] = access == 1

		MySQLite.query("REPLACE INTO FPP_TOOLRESTRICTPERSON1 VALUES("..sql.SQLStr(toolname)..", "..sql.SQLStr(target:SteamID())..", ".. access ..");")
	elseif access == 2 then -- reset tool status(make him like everyone else)
		FPP.RestrictedToolsPlayers[toolname][target:SteamID()] = nil
		MySQLite.query("DELETE FROM FPP_TOOLRESTRICTPERSON1 WHERE toolname = "..sql.SQLStr(toolname).." AND steamid = "..sql.SQLStr(target:SteamID())..";")
	end
end
concommand.Add("FPP_restricttoolplayer", RestrictToolPerson)

/*---------------------------------------------------------------------------
Load all FPP settings
---------------------------------------------------------------------------*/
function FPP.Init()
	MySQLite.begin()
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_BLOCKED1(id INTEGER NOT NULL, var VARCHAR(40) NOT NULL, setting VARCHAR(100) NOT NULL, PRIMARY KEY(id));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_PHYSGUN1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_GRAVGUN1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_TOOLGUN1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_PLAYERUSE1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_ENTITYDAMAGE1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_GLOBALSETTINGS1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_BLOCKMODELSETTINGS1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")

		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_ANTISPAM1(var VARCHAR(40) NOT NULL, setting INTEGER NOT NULL, PRIMARY KEY(var));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_TOOLADMINONLY(toolname VARCHAR(40) NOT NULL, adminonly INTEGER NOT NULL, PRIMARY KEY(toolname));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_TOOLTEAMRESTRICT(toolname VARCHAR(40) NOT NULL, team INTEGER NOT NULL, PRIMARY KEY(toolname, team));")

		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_TOOLRESTRICTPERSON1(toolname VARCHAR(40) NOT NULL, steamid VARCHAR(40) NOT NULL, allow INTEGER NOT NULL, PRIMARY KEY(steamid, toolname));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_GROUPS3(groupname VARCHAR(40) NOT NULL, allowdefault INTEGER NOT NULL, PRIMARY KEY(groupname));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_GROUPTOOL(groupname VARCHAR(40) NOT NULL, tool VARCHAR(45) NOT NULL, PRIMARY KEY(groupname, tool));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_GROUPMEMBERS1(steamid VARCHAR(40) NOT NULL, groupname VARCHAR(40) NOT NULL, PRIMARY KEY(steamid));")
		MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS FPP_BLOCKEDMODELS1(model VARCHAR(140) NOT NULL PRIMARY KEY);")
	MySQLite.commit(function()
		RetrieveBlocked()
		RetrieveBlockedModels()
		RetrieveRestrictedTools()
		RetrieveGroups()
		RetrieveSettings()
	end)
end

local assbackup = ASS_RegisterPlugin -- Suddenly after witing this code, ASS spamprotection and propprotection broke. I have no clue why. I guess you should use FPP then
if assbackup then
	function ASS_RegisterPlugin(plugin, ...)
		if plugin.Name == "Sandbox Spam Protection" or plugin.Name == "Sandbox Prop Protection" then
			return
		end
		return assbackup(plugin, ...)
	end
end