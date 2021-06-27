FPP = FPP or {}

util.AddNetworkString("FPP_Groups")
util.AddNetworkString("FPP_GroupMembers")
util.AddNetworkString("FPP_RestrictedToolList")
util.AddNetworkString("FPP_BlockedModels")

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
    for _, ply in ipairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCONSOLE, text)
    end
end


local function getSettingsChangedEntities(settingsType, setting)
    local plys, entities = {}, {}

    local blockedString = string.sub(settingsType, 5, 5) .. string.lower(string.sub(settingsType, 6))

    blockedString = blockedString == "Playeruse1" and "PlayerUse1" or blockedString -- dirty hack for stupid naming system.
    blockedString = blockedString == "Entitydamage1" and "EntityDamage1" or blockedString -- dirty hack for stupid naming system.

    if setting == "adminall" then
        for _, v in ipairs(ents.GetAll()) do
            if not IsValid(v) then continue end
            local owner = v:CPPIGetOwner()
            if IsValid(owner) then table.insert(entities, v) end
        end

        for _, v in ipairs(player.GetAll()) do
            v.FPP_Privileges = v.FPP_Privileges or {}
            if v.FPP_Privileges.FPP_TouchOtherPlayersProps then table.insert(plys, v) end
        end

        return plys, entities
    elseif setting == "worldprops" or setting == "adminworldprops" then
        for _, v in ipairs(ents.GetAll()) do
            if FPP.Blocked[blockedString][string.lower(v:GetClass())] then continue end

            local owner = v:CPPIGetOwner()
            if not IsValid(owner) then table.insert(entities, v) end
        end

        for _, v in ipairs(player.GetAll()) do
            v.FPP_Privileges = v.FPP_Privileges or {}
            if v.FPP_Privileges.FPP_TouchOtherPlayersProps then table.insert(plys, v) end
        end
        return setting == "adminworldprops" and plys or player.GetAll(), entities
    elseif setting == "canblocked" or setting == "admincanblocked" then
        for _, v in ipairs(ents.GetAll()) do
            if not FPP.Blocked[blockedString][string.lower(v:GetClass())] then continue end
            table.insert(entities, v)
        end

        for _, v in ipairs(player.GetAll()) do
            v.FPP_Privileges = v.FPP_Privileges or {}
            if v.FPP_Privileges.FPP_TouchOtherPlayersProps then table.insert(plys, v) end
        end
        return setting == "admincanblocked" and plys or player.GetAll(), entities
    elseif setting == "iswhitelist" then
        return player.GetAll(), ents.GetAll()
    end
end

util.AddNetworkString("FPP_Settings")
local function SendSettings(ply)
    net.Start("FPP_Settings")
        FPP.ForAllSettings(function(k, s, v)
            net.WriteDouble(v)
        end)
    net.Send(ply)
end

util.AddNetworkString("FPP_Settings_Update")
local function updateFPPSetting(kind, setting, value)
    local skipKind, skipSetting = 0, 0
    FPP.Settings[kind][setting] = value

    local finalSkipKind
    FPP.ForAllSettings(function(k, s)
        skipKind = skipKind + 1

        if k ~= kind then return true end
        finalSkipKind = skipKind - skipSetting
        skipSetting = skipSetting + 1
        if s ~= setting then return end

        return true
    end)

    net.Start("FPP_Settings_Update")
        net.WriteUInt(finalSkipKind, 8)
        net.WriteUInt(skipSetting, 8)
        net.WriteDouble(value)
    net.Broadcast()
end

local function runIfAccess(priv, f)
    return function(ply, cmd, args)
        CAMI.PlayerHasAccess(ply, priv, function(allowed, _)
            if allowed then return f(ply, cmd, args) end

            FPP.Notify(ply, string.format("You need the '%s' privilege in order to be able to use this command", priv), false)
        end)
    end
end

local function FPP_SetSetting(ply, cmd, args)
    if not args[1] then FPP.Notify(ply, "FPP_setting: First argument (setting name) not given!", false) return end
    if not args[3] then FPP.Notify(ply, "FPP_setting: Third argument (the value of the setting) not given", false) return end
    if not FPP.Settings[args[1]] then
        FPP.Notify(ply, ("FPP_setting: Setting %s does not exist! Settings that DO exist:"):format(args[1]), false)

        for setting, _ in pairs(FPP.Settings) do
            FPP.Notify(ply, setting, false)
        end
        return
    end
    if not FPP.Settings[args[1]][args[2]] then FPP.Notify(ply, ("FPP_setting: Setting %s.%s does not exist!"):format(args[1], args[2]), false) return end

    updateFPPSetting(args[1], args[2], tonumber(args[3]))

    MySQLite.queryValue("SELECT var FROM " .. args[1] .. " WHERE var = " .. sql.SQLStr(args[2]) .. ";", function(data)
        if not data then
            MySQLite.query("INSERT INTO " .. args[1] .. " VALUES(" .. sql.SQLStr(args[2]) .. ", " .. args[3] .. ");")
        elseif tonumber(data) ~= args[3] then
            MySQLite.query("UPDATE " .. args[1] .. " SET setting = " .. args[3] .. " WHERE var = " .. sql.SQLStr(args[2]) .. ";")
        end

        FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " set " .. string.lower(string.gsub(args[1], "FPP_", "")) .. " " .. args[2] .. " to " .. tostring(args[3]), tobool(tonumber(args[3])))
    end)

    FPP.calculatePlayerPrivilege("FPP_TouchOtherPlayersProps", function()
        local plys, entities = getSettingsChangedEntities(args[1], args[2])
        if not plys or not entities or #plys == 0 or #entities == 0 then return end

        FPP.recalculateCanTouch(plys, entities)
    end)
end
concommand.Add("FPP_setting", runIfAccess("FPP_Settings", FPP_SetSetting))

local function AddBlocked(ply, cmd, args)
    if not args[1]              then FPP.Notify(ply, "FPP_AddBlocked: Block list not given", false) return end
    if not args[2]              then FPP.Notify(ply, "FPP_AddBlocked: Entity to block not given", false) return end
    if not FPP.Blocked[args[1]] then FPP.Notify(ply, ("FPP_AddBlocked: Block list %s does not exist"):format(args[1]), false) return end

    args[2] = string.lower(args[2])
    if FPP.Blocked[args[1]][args[2]] then return end
    FPP.Blocked[args[1]][args[2]] = true

    MySQLite.query(string.format("INSERT INTO FPP_BLOCKED1 (var, setting) VALUES(%s, %s);", sql.SQLStr(args[1]), sql.SQLStr(args[2])))

    FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " added " .. args[2] .. " to the " .. args[1] .. " black/whitelist", true)

    FPP.recalculateCanTouch(player.GetAll(), ents.FindByClass(args[2]))
end
concommand.Add("FPP_AddBlocked", runIfAccess("FPP_Settings", AddBlocked))

-- Models can differ between server and client. Famous example being:
-- models/props_phx/cannonball_solid.mdl <-- serverside
-- models/props_phx/cannonball.mdl       <-- clientside
-- Similar problems occur with effects
local function getIntendedBlockedModels(model, ent)
    model = string.Replace(string.lower(model), "\\", "/")

    if not IsValid(ent) then return {model} end
    if ent:GetClass() == "prop_effect" then return {ent.AttachedEntity:GetModel()} end
    if model ~= ent:GetModel() then return {model, ent:GetModel()} end
    return {model}
end

local function AddBlockedModel(ply, cmd, args)
    if not args[1] then FPP.Notify(ply, "FPP_AddBlockedModel: Model not given", false) return end

    local models = getIntendedBlockedModels(args[1], tonumber(args[2]) and Entity(args[2]) or nil)

    for _, model in pairs(models) do
        if FPP.BlockedModels[model] then FPP.Notify(ply, string.format([["%s" is already in the black/whitelist]], model), false) continue end
        FPP.BlockedModels[model] = true
        MySQLite.query("REPLACE INTO FPP_BLOCKEDMODELS1 VALUES(" .. sql.SQLStr(model) .. ");")
        FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " added " .. model .. " to the blocked models black/whitelist", true)
    end
end
concommand.Add("FPP_AddBlockedModel", runIfAccess("FPP_Settings", AddBlockedModel))

local function RemoveBlocked(ply, cmd, args)
    if not args[1]              then FPP.Notify(ply, "FPP_RemoveBlocked: Block list not given", false) return end
    if not args[2]              then FPP.Notify(ply, "FPP_RemoveBlocked: Entity to block not given", false) return end
    if not FPP.Blocked[args[1]] then FPP.Notify(ply, ("FPP_RemoveBlocked: Block list %s does not exist"):format(args[1]), false) return end

    FPP.Blocked[args[1]][args[2]] = nil

    MySQLite.query("DELETE FROM FPP_BLOCKED1 WHERE var = " .. sql.SQLStr(args[1]) .. " AND setting = " .. sql.SQLStr(args[2]) .. ";")
    FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed " .. args[2] .. " from the " .. args[1] .. " black/whitelist", false)
    FPP.recalculateCanTouch(player.GetAll(), ents.FindByClass(args[2]))
end
concommand.Add("FPP_RemoveBlocked", runIfAccess("FPP_Settings", RemoveBlocked))

local function RemoveBlockedModel(ply, cmd, args)
    if not args[1] then FPP.Notify(ply, "FPP_RemoveBlockedModel: Model not given", false) return end
    local models = getIntendedBlockedModels(args[1], tonumber(args[2]) and Entity(args[2]) or nil)

    for _, model in pairs(models) do
        FPP.BlockedModels[model] = nil

        MySQLite.query("DELETE FROM FPP_BLOCKEDMODELS1 WHERE model = " .. sql.SQLStr(model) .. ";")
        FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed " .. model .. " from the blocked models black/whitelist", false)
    end
end
concommand.Add("FPP_RemoveBlockedModel", runIfAccess("FPP_Settings", RemoveBlockedModel))

local allowedShares = {
    SharePhysgun1 = true,
    ShareGravgun1 = true,
    SharePlayerUse1 = true,
    ShareEntityDamage1 = true,
    ShareToolgun1 = true
}
local function ShareProp(ply, cmd, args)
    if not args[1]                  then FPP.Notify(ply, "FPP_ShareProp: Entity not given", false) return end
    if not IsValid(Entity(args[1])) then FPP.Notify(ply, "FPP_ShareProp: Entity not valid", false) return end
    if not args[2]                  then FPP.Notify(ply, "FPP_ShareProp: Player to share with not given", false) return end

    local ent = Entity(args[1])

    if ent:CPPIGetOwner() ~= ply then
        FPP.Notify(ply, "You do not have the right to share this entity.", false)
        return
    end

    if not tonumber(args[2]) or not IsValid(Player(tonumber(args[2]))) then -- This is for sharing prop per utility
        if not allowedShares[args[2]] then
            FPP.Notify(ply, "FPP_ShareProp: Player to share with doesn't exist", false)
            return
        end
        ent[args[2]] = tobool(args[3])
    else -- This is for sharing prop per player
        local target = Player(tonumber(args[2]))
        local toggle = tobool(args[3])
        -- Make the table if it isn't there
        if not ent.AllowedPlayers and toggle then
            ent.AllowedPlayers = {target}
        else
            if toggle and not table.HasValue(ent.AllowedPlayers, target) then
                table.insert(ent.AllowedPlayers, target)
                FPP.Notify(target, ply:Nick() .. " shared an entity with you!", true)
            elseif not toggle then
                for k, v in pairs(ent.AllowedPlayers or {}) do
                    if v == target then
                        table.remove(ent.AllowedPlayers, k)
                        FPP.Notify(target, ply:Nick() .. " unshared an entity with you!", false)
                    end
                end
            end
        end
    end

    FPP.recalculateCanTouch(player.GetAll(), {ent})
end
concommand.Add("FPP_ShareProp", ShareProp)

local function RetrieveSettings()
    MySQLite.begin()
    for k in pairs(FPP.Settings) do
        MySQLite.queueQuery("SELECT setting, var FROM " .. k .. ";", function(data)
            if not data then return end

            for _, value in pairs(data) do
                if FPP.Settings[k][value.var] == nil then
                    -- Likely an old setting that has since been removed from FPP.
                    -- This setting however still exists in the DB. Time to remove it.
                    MySQLite.query("DELETE FROM " .. k .. " WHERE var = " .. sql.SQLStr(value.var) .. ";")
                    continue
                end

                FPP.Settings[k][value.var] = tonumber(value.setting)
            end
        end)
    end
    MySQLite.commit(function()
        SendSettings(player.GetAll())
    end)
end

local defaultBlocked = {
    Physgun1 = {
                ["func_breakable_surf"] = true,
                ["func_brush"] = true,
                ["func_button"] = true,
                ["func_door"] = true,
                ["prop_door_rotating"] = true,
                ["func_door_rotating"] = true
            },
    Spawning1 = {
                    ["func_breakable_surf"] = true,
                    ["player"] = true,
                    ["func_door"] = true,
                    ["prop_door_rotating"] = true,
                    ["func_door_rotating"] = true,
                    ["ent_explosivegrenade"] = true,
                    ["ent_mad_grenade"] = true,
                    ["ent_flashgrenade"] = true,
                    ["gmod_wire_field_device"] = true
                },
    Gravgun1 = {["func_breakable_surf"] = true, ["vehicle_"] = true},
    Toolgun1 = {
                ["func_breakable_surf"] = true,
                ["func_button"] = true,
                ["player"] = true,
                ["func_door"] = true,
                ["prop_door_rotating"] = true,
                ["func_door_rotating"] = true
            },
    PlayerUse1 = {},
    EntityDamage1 = {}
}

-- Fills the FPP blocked table with default things that are to be blocked
function FPP.FillDefaultBlocked()
    local count = 0
    MySQLite.begin()

    -- All values that are to be inserted
    local allValues = {}

    for k, v in pairs(defaultBlocked) do
        for a in pairs(v) do
            FPP.Blocked[k][a] = true
            count = count + 1

            if not MySQLite.isMySQL() then
                MySQLite.query("REPLACE INTO FPP_BLOCKED1 VALUES(" .. count .. ", " .. sql.SQLStr(k) .. ", " .. sql.SQLStr(a) .. ");")
            else
                table.insert(allValues, string.format("(%i, %s, %s)", count, sql.SQLStr(k), sql.SQLStr(a)))
            end
        end
    end

    -- Run it all in a single query if using MySQL.
    if MySQLite.isMySQL() then
        MySQLite.query(string.format("INSERT IGNORE INTO FPP_BLOCKED1 VALUES %s", table.concat(allValues, ",")))
    end
    MySQLite.commit()
end

local function RetrieveBlocked()
    MySQLite.query("SELECT * FROM FPP_BLOCKED1;", function(data)
        if istable(data) then
            for _, v in pairs(data) do
                if not FPP.Blocked[v.var] then
                    ErrorNoHalt((v.var or "(nil var)") .. " blocked type does not exist! (Setting: " .. (v.setting or "") .. ")")
                    continue
                end

                FPP.Blocked[v.var][string.lower(v.setting)] = true
            end
        else
            -- Give third party addons 5 seconds to add default blocked items
            timer.Simple(5, FPP.FillDefaultBlocked)
        end
    end)
end

/*---------------------------------------------------------------------------
Default blocked entities
Only save in the database on first start
---------------------------------------------------------------------------*/
function FPP.AddDefaultBlocked(types, classname)
    classname = string.lower(classname)

    if isstring(types) then
        defaultBlocked[types] = defaultBlocked[types] or {}
        defaultBlocked[types][classname] = true
        return
    end

    for _, v in pairs(types) do
        defaultBlocked[v] = defaultBlocked[v] or {}
        defaultBlocked[v][classname] = true
    end
end

local function RetrieveBlockedModels()
    FPP.BlockedModels = FPP.BlockedModels or {}
    -- Sometimes when the database retrieval is corrupt,
    -- only parts of the table will be retrieved
    -- This is a workaround
    if not MySQLite.isMySQL() then
        local count = MySQLite.queryValue("SELECT COUNT(*) FROM FPP_BLOCKEDMODELS1;") or 0
        if tonumber(count) == 0 then
            FPP.AddDefaultBlockedModels() -- Load the default blocked models on first run
        end

        -- Select with offsets of a thousand.
        -- That's about the maximum it can receive properly at once
        for i = 0, count, 1000 do
            MySQLite.query("SELECT * FROM FPP_BLOCKEDMODELS1 LIMIT 1000 OFFSET " .. i .. ";", function(data)
                for _, v in ipairs(data or {}) do
                    FPP.BlockedModels[v.model] = true
                end
            end)
        end

        return
    end

    -- Retrieve the data normally from MySQL
    MySQLite.query("SELECT * FROM FPP_BLOCKEDMODELS1;", function(data)
        if not data or #data == 0 then
            FPP.AddDefaultBlockedModels() -- Load the default blocked models on first run
        end

        for _, v in ipairs(data or {}) do
            if not v.model then continue end
            FPP.BlockedModels[v.model] = true
        end
    end)
end

local function RetrieveRestrictedTools()
    MySQLite.query("SELECT * FROM FPP_TOOLADMINONLY;", function(data)
        if istable(data) then
            for _, v in ipairs(data) do
                FPP.RestrictedTools[v.toolname] = {}
                FPP.RestrictedTools[v.toolname]["admin"] = tonumber(v.adminonly)
            end
        end
    end)

    MySQLite.query("SELECT * FROM FPP_TOOLRESTRICTPERSON1;", function(perplayerData)
        if not istable(perplayerData) then return end
        for _, v in ipairs(perplayerData) do
            FPP.RestrictedToolsPlayers[v.toolname] = FPP.RestrictedToolsPlayers[v.toolname] or {}
            FPP.RestrictedToolsPlayers[v.toolname][v.steamid] = tobool(v.allow)
        end
    end)

    MySQLite.query("SELECT * FROM FPP_TOOLTEAMRESTRICT;", function(data)
        if not data then return end

        for _, v in ipairs(data) do
            FPP.RestrictedTools[v.toolname] = FPP.RestrictedTools[v.toolname] or {}
            FPP.RestrictedTools[v.toolname]["team"] = FPP.RestrictedTools[v.toolname]["team"] or {}

            table.insert(FPP.RestrictedTools[v.toolname]["team"], tonumber(v.team))
        end
    end)
end

local function RetrieveGroups()
    MySQLite.query("SELECT * FROM FPP_GROUPS3;", function(data)
        if not istable(data) then
            MySQLite.query("REPLACE INTO FPP_GROUPS3 VALUES('default', 1);")
            FPP.Groups["default"] = {}
            FPP.Groups["default"].tools = {}
            FPP.Groups["default"].allowdefault = true
            return
        end -- if there are no groups then there isn't much to load

        for _, v in ipairs(data) do
            FPP.Groups[v.groupname] = {}
            FPP.Groups[v.groupname].tools = {}
            FPP.Groups[v.groupname].allowdefault = tobool(v.allowdefault)
        end

        MySQLite.query("SELECT * FROM FPP_GROUPTOOL;", function(grouptooldata)
            if not grouptooldata then return end

            for _, v in ipairs(grouptooldata) do
                FPP.Groups[v.groupname] = FPP.Groups[v.groupname] or {}
                FPP.Groups[v.groupname].tools = FPP.Groups[v.groupname].tools or {}

                table.insert(FPP.Groups[v.groupname].tools, v.tool)
            end
        end)

        MySQLite.query("SELECT * FROM FPP_GROUPMEMBERS1;", function(members)
            if not istable(members) then return end
            for _, v in ipairs(members) do
                FPP.GroupMembers[v.steamid] = v.groupname
            end
        end)
    end)
end

hook.Add("PlayerInitialSpawn", "FPP_SendSettings", SendSettings)

local function AddGroup(ply, cmd, args)
    if not args[1] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = name, optional: 2 = allowdefault
    local name = string.lower(args[1])
    local allowdefault = tonumber(args[2]) or 1

    if FPP.Groups[name] then
        FPP.Notify(ply, "Group already exists", false)
        return
    end

    FPP.Groups[name] = {}
    FPP.Groups[name].allowdefault = tobool(allowdefault)
    FPP.Groups[name].tools = {}

    MySQLite.query("REPLACE INTO FPP_GROUPS3 VALUES(" .. sql.SQLStr(name) .. ", " .. sql.SQLStr(allowdefault) .. ");")
    FPP.Notify(ply, "Group added successfully", true)
end
concommand.Add("FPP_AddGroup", runIfAccess("FPP_Settings", AddGroup))

hook.Add("InitPostEntity", "FPP_Load_CAMI", function()
    if not CAMI then return end
    for groupName, _ in pairs(CAMI.GetUsergroups()) do
        if FPP.Groups[groupName] then continue end

        FPP.Groups[groupName] = {}
        FPP.Groups[groupName].allowdefault = true
        FPP.Groups[groupName].tools = {}
    end
end)

local function RemoveGroup(ply, cmd, args)
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
    MySQLite.query("DELETE FROM FPP_GROUPS3 WHERE groupname = " .. sql.SQLStr(name) .. ";")
    MySQLite.query("DELETE FROM FPP_GROUPTOOL WHERE groupname = " .. sql.SQLStr(name) .. ";")

    for k, v in pairs(FPP.GroupMembers) do
        if v == name then
            FPP.GroupMembers[k] = nil -- Set group to standard if group is removed
        end
    end
    FPP.Notify(ply, "Group removed successfully", true)
end
concommand.Add("FPP_RemoveGroup", runIfAccess("FPP_Settings", RemoveGroup))

local function GroupChangeAllowDefault(ply, cmd, args)
    if not args[2] then FPP.Notify(ply, "Invalid argument(s)", false) return end-- Args: 1 = groupname, 2 = new value 1/0

    local name = string.lower(args[1])
    local newval = tonumber(args[2])

    if not FPP.Groups[name] then
        FPP.Notify(ply, "Group does not exists", false)
        return
    end

    FPP.Groups[name].allowdefault = tobool(newval)
    MySQLite.query("REPLACE INTO FPP_GROUPS3 VALUES(" .. sql.SQLStr(name) .. ", " .. sql.SQLStr(newval) .. ");")
    FPP.Notify(ply, "Group status changed successfully", true)
end
concommand.Add("FPP_ChangeGroupStatus", runIfAccess("FPP_Settings", GroupChangeAllowDefault))

local function GroupAddTool(ply, cmd, args)
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

    MySQLite.query("REPLACE INTO FPP_GROUPTOOL VALUES(" .. sql.SQLStr(name) .. ", " .. sql.SQLStr(tool) .. ");")
    FPP.Notify(ply, "Tool added successfully", true)
end
concommand.Add("FPP_AddGroupTool", runIfAccess("FPP_Settings", GroupAddTool))

local function GroupRemoveTool(ply, cmd, args)
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

    for k, v in pairs(FPP.Groups[name].tools) do
        if v == tool then
            table.remove(FPP.Groups[name].tools, k)
        end
    end

    MySQLite.query("DELETE FROM FPP_GROUPTOOL WHERE groupname = " .. sql.SQLStr(name) .. " AND tool = " .. sql.SQLStr(tool) .. ";")

    FPP.Notify(ply, "Tool removed successfully", true)
end
concommand.Add("FPP_RemoveGroupTool", runIfAccess("FPP_Settings", GroupRemoveTool))

-- Args: 1 = player, 2 = group
local function PlayerSetGroup(ply, cmd, args)
    if not args[2] then FPP.Notify(ply, "Group not given", false) return end

    local name = args[1]
    local group = string.lower(args[2])
    if IsValid(Player(tonumber(name) or 0)) then name = Player(tonumber(name)):SteamID()
    elseif not string.find(name, "STEAM") and name ~= "UNKNOWN" and name ~= "BOT" then FPP.Notify(ply, "Player not found", false) return end

    if not FPP.Groups[group] and (not CAMI or not CAMI.GetUsergroup(group)) then
        FPP.Notify(ply, "Group does not exists", false)
        return
    end

    if group ~= "default" then
        MySQLite.query("REPLACE INTO FPP_GROUPMEMBERS1 VALUES(" .. sql.SQLStr(name) .. ", " .. sql.SQLStr(group) .. ");")
        FPP.GroupMembers[name] = group
    else
        FPP.GroupMembers[name] = nil
        MySQLite.query("DELETE FROM FPP_GROUPMEMBERS1 WHERE steamid = " .. sql.SQLStr(name) .. ";")
    end

    FPP.Notify(ply, "Player group successfully set", true)
end
concommand.Add("FPP_SetPlayerGroup", runIfAccess("FPP_Settings", PlayerSetGroup))

local function SendGroupData(ply, cmd, args)
    net.Start("FPP_Groups")
        net.WriteTable(FPP.Groups)
    net.Send(ply)
end
concommand.Add("FPP_SendGroups", runIfAccess("FPP_Settings", SendGroupData))

local function SendGroupMemberData(ply, cmd, args)
    net.Start("FPP_GroupMembers")
        net.WriteTable(FPP.GroupMembers)
    net.Send(ply)
end
concommand.Add("FPP_SendGroupMembers", runIfAccess("FPP_Settings", SendGroupMemberData))

local function SendBlocked(ply, cmd, args)
    if not args[1] or not FPP.Blocked[args[1]] then return end

    ply.FPPUmsg1 = ply.FPPUmsg1 or {}
    ply.FPPUmsg1[args[1]] = ply.FPPUmsg1[args[1]] or 0
    if ply.FPPUmsg1[args[1]] > CurTime() - 5 then return end
    ply.FPPUmsg1[args[1]] = CurTime()

    for k in pairs(FPP.Blocked[args[1]]) do
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

    local models = {}

    for k in pairs(FPP.BlockedModels) do table.insert(models, k) end

    local data = util.Compress(table.concat(models, "\0"))

    if not data then return end

    net.Start("FPP_BlockedModels")
        net.WriteData(data, #data)
    net.Send(ply)
end
concommand.Add("FPP_sendblockedmodels", SendBlockedModels)

local function SendRestrictedTools(ply, cmd, args)
    ply.FPPUmsg3 = ply.FPPUmsg3 or 0
    if ply.FPPUmsg3 > CurTime() - 5 then return end
    ply.FPPUmsg3 = CurTime()

    if not args[1] then return end
    net.Start("FPP_RestrictedToolList")
        net.WriteString(args[1]) -- tool name
        net.WriteUInt(FPP.RestrictedTools[args[1]] and FPP.RestrictedTools[args[1]].admin or 0, 2) -- user, admin or superadmin

        local teams = FPP.RestrictedTools[args[1]] and FPP.RestrictedTools[args[1]].team or {}
        net.WriteUInt(#teams, 10)
        for _, t in pairs(teams) do
            net.WriteUInt(t, 10)
        end
    net.Send(ply)
end
concommand.Add("FPP_SendRestrictTool", SendRestrictedTools)

-- Fallback owner, will own entities after disconnect
local function setFallbackOwner(ply, fallback)
    ply.FPPFallbackOwner = fallback:SteamID()
end

local function changeFallbackOwner(ply, _, args)
    local fallback = tonumber(args[1]) and Player(tonumber(args[1]))

    if tonumber(args[1]) == -1 then
        ply.FPPFallbackOwner = nil
        FPP.Notify(ply, "Fallback owner set", true)
        return
    end

    if not IsValid(fallback) or not fallback:IsPlayer() or fallback == ply then FPP.Notify(ply, "Player invalid", false) return end

    setFallbackOwner(ply, fallback)
    FPP.Notify(ply, "Fallback owner set", true)
end
concommand.Add("FPP_FallbackOwner", changeFallbackOwner)

--Buddies!
local function changeBuddies(ply, buddy, settings)
    if not IsValid(ply) then return end

    ply.Buddies = ply.Buddies or {}
    ply.Buddies[buddy] = settings

    local CPPIBuddies = {}
    for k, v in pairs(ply.Buddies) do if table.HasValue(v, true) then table.insert(CPPIBuddies, k) end end
    -- Also run at player spawn because clients send their buddies through this command
    hook.Run("CPPIFriendsChanged", ply, CPPIBuddies)

    -- Update the prop protection
    local affectedProps = {}
    for _, v in ipairs(ents.GetAll()) do
        local owner = v:CPPIGetOwner()
        if owner ~= ply then continue end
        table.insert(affectedProps, v)
    end

    FPP.recalculateCanTouch({buddy}, affectedProps)
    FPP.RecalculateConstrainedEntities({buddy}, affectedProps)
end

local function SetBuddy(ply, cmd, args)
    if not args[6] then FPP.Notify(ply, "FPP_SetBuddy: Not enough arguments given!", false) return end
    local buddy = tonumber(args[1]) and Player(tonumber(args[1]))
    if not IsValid(buddy) then FPP.Notify(ply, "Player invalid", false) return end

    for k, v in pairs(args) do args[k] = tonumber(v) end
    local settings = {Physgun = tobool(args[2]), Gravgun = tobool(args[3]), Toolgun = tobool(args[4]), PlayerUse = tobool(args[5]), EntityDamage = tobool(args[6])}

    -- Antispam measure
    timer.Create("FPP_BuddiesUpdate" .. ply:UserID() .. ", " .. buddy:UserID(), 1, 1, function() changeBuddies(ply, buddy, settings) end)
end
concommand.Add("FPP_SetBuddy", SetBuddy)

local function CleanupDisconnected(ply, cmd, args)
    if not args[1] then FPP.Notify(ply, "Invalid argument", false) return end
    if args[1] == "disconnected" then
        for _, v in ipairs(ents.GetAll()) do
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

    for _, v in ipairs(ents.GetAll()) do
        local Owner = v:CPPIGetOwner()
        if Owner == Player(args[1]) and not v:IsWeapon() then
            v:Remove()
        end
    end
    FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed " .. Player(args[1]):Nick() .. "'s entities", true)
end
concommand.Add("FPP_Cleanup", runIfAccess("FPP_Cleanup", CleanupDisconnected))

local function SetToolRestrict(ply, cmd, args)
    if not args[3] then FPP.Notify(ply, "Invalid argument(s)", false) return end--FPP_restricttool <toolname> <type(admin/team)> <toggle(1/0)>
    local toolname = args[1]
    local RestrictWho = tonumber(args[2]) or args[2]-- "team" or "admin"
    local teamtoggle = tonumber(args[4]) --this argument only exists when restricting a tool for a team

    FPP.RestrictedTools[toolname] = FPP.RestrictedTools[toolname] or {}

    if RestrictWho == "admin" then
        FPP.RestrictedTools[toolname].admin = args[3] --weapons.Get("gmod_tool").Tool

        --Save to database!
        MySQLite.query("REPLACE INTO FPP_TOOLADMINONLY VALUES(" .. sql.SQLStr(toolname) .. ", " .. sql.SQLStr(args[3]) .. ");")
        FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " changed the admin status of " .. toolname , true)
    elseif RestrictWho == "team" then
        FPP.RestrictedTools[toolname]["team"] = FPP.RestrictedTools[toolname]["team"] or {}
        if teamtoggle == 0 then
            for k, v in pairs(FPP.RestrictedTools[toolname]["team"]) do
                if v == tonumber(args[3]) then
                    table.remove(FPP.RestrictedTools[toolname]["team"], k)
                    break
                end
            end
        elseif not table.HasValue(FPP.RestrictedTools[toolname]["team"], tonumber(args[3])) and teamtoggle == 1 then
            table.insert(FPP.RestrictedTools[toolname]["team"], tonumber(args[3]))
        end --Remove from the table if it's in there AND it's 0 otherwise do nothing

        if tobool(teamtoggle) then -- if the team restrict is enabled
            FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " restricted " .. toolname .. " to certain teams", true)
            MySQLite.query("REPLACE INTO FPP_TOOLTEAMRESTRICT VALUES(" .. sql.SQLStr(toolname) .. ", " .. tonumber(args[3]) .. ");")
        else -- otherwise if the restriction for the team is being removed
            FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed teamrestrictions from " .. toolname, true)
            MySQLite.query("DELETE FROM FPP_TOOLTEAMRESTRICT WHERE toolname = " .. sql.SQLStr(toolname) .. " AND team = " .. tonumber(args[3]))
        end
    end
end
concommand.Add("FPP_restricttool", runIfAccess("FPP_Settings", SetToolRestrict))

local function RestrictToolPerson(ply, cmd, args)
    if not args[3] then FPP.Notify(ply, "Invalid argument(s)", false) return end--FPP_restricttoolperson <toolname> <userid> <disallow, allow, remove(0,1,2)>

    local toolname = args[1]
    local target = Player(tonumber(args[2]))
    local access = tonumber(args[3])
    if not target:IsValid() then FPP.Notify(ply, "Invalid argument(s)", false) return end
    if access < 0 or access > 2 then FPP.Notify(ply, "Invalid argument(s)", false) return end

    FPP.RestrictedToolsPlayers[toolname] = FPP.RestrictedToolsPlayers[toolname] or {}

    -- Disallow, even if other people can use it
    if access == 0 or access == 1 then
        FPP.RestrictedToolsPlayers[toolname][target:SteamID()] = access == 1
        MySQLite.query("REPLACE INTO FPP_TOOLRESTRICTPERSON1 VALUES(" .. sql.SQLStr(toolname) .. ", " .. sql.SQLStr(target:SteamID()) .. ", " .. access .. ");")
    elseif access == 2 then
        -- reset tool status(make him like everyone else)
        FPP.RestrictedToolsPlayers[toolname][target:SteamID()] = nil
        MySQLite.query("DELETE FROM FPP_TOOLRESTRICTPERSON1 WHERE toolname = " .. sql.SQLStr(toolname) .. " AND steamid = " .. sql.SQLStr(target:SteamID()) .. ";")
    end
    FPP.Notify(ply, "Tool restrictions set successfully", true)
end
concommand.Add("FPP_restricttoolplayer", runIfAccess("FPP_Settings", RestrictToolPerson))

local function resetAllSetting(ply)
    MySQLite.begin()
    MySQLite.queueQuery("DELETE FROM FPP_PHYSGUN1")
    MySQLite.queueQuery("DELETE FROM FPP_GRAVGUN1")
    MySQLite.queueQuery("DELETE FROM FPP_TOOLGUN1")
    MySQLite.queueQuery("DELETE FROM FPP_PLAYERUSE1")
    MySQLite.queueQuery("DELETE FROM FPP_ENTITYDAMAGE1")
    MySQLite.queueQuery("DELETE FROM FPP_GLOBALSETTINGS1")
    MySQLite.queueQuery("DELETE FROM FPP_ANTISPAM1")
    MySQLite.queueQuery("DELETE FROM FPP_BLOCKMODELSETTINGS1")
    MySQLite.commit(function()
        FPP.Settings = nil
        FPP.Settings = table.Copy(FPP.InitialSettings)
        SendSettings(player.GetAll())

        if not IsValid(ply) then return end
        FPP.Notify(ply, "Settings successfully reset.", true)
    end)
end
concommand.Add("FPP_ResetAllSettings", runIfAccess("FPP_Settings", resetAllSetting))

local function resetBlockedModels(ply)
    FPP.BlockedModels = {}

    MySQLite.query("DELETE FROM FPP_BLOCKEDMODELS1", FPP.AddDefaultBlockedModels)
    FPP.Notify(ply, "Settings successfully reset.", true)
end
concommand.Add("FPP_ResetBlockedModels", runIfAccess("FPP_Settings", resetBlockedModels))

local function refreshPrivatePlayerSettings(ply)
    timer.Remove("FPP_RefreshPrivatePlayerSettings" .. ply:EntIndex())

    timer.Create("FPP_RefreshPrivatePlayerSettings" .. ply:EntIndex(), 4, 1, function() FPP.recalculateCanTouch({ply}, ents.GetAll()) end)
end
concommand.Add("_FPP_RefreshPrivatePlayerSettings", refreshPrivatePlayerSettings)

/*---------------------------------------------------------------------------
Load all FPP settings
---------------------------------------------------------------------------*/
function FPP.Init(callback)
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

        if MySQLite.isMySQL() then
            MySQLite.queueQuery("ALTER TABLE FPP_BLOCKED1 CHANGE id id INTEGER AUTO_INCREMENT;")
        end

    MySQLite.commit(function()

        RetrieveBlocked()
        RetrieveBlockedModels()
        RetrieveRestrictedTools()
        RetrieveGroups()
        RetrieveSettings()

        -- Callback when FPP is done creating the tables
        if callback then callback() end
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
