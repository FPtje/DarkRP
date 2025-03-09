local meta = FindMetaTable("Player")

DarkRP.ServerDarkRPVars = DarkRP.ServerDarkRPVars or {}
DarkRP.ServerPrivateDarkRPVars = DarkRP.ServerPrivateDarkRPVars or {}

--[[---------------------------------------------------------------------------
Pooled networking strings
---------------------------------------------------------------------------]]
util.AddNetworkString("DarkRP_InitializeVars")
util.AddNetworkString("DarkRP_PlayerVar")
util.AddNetworkString("DarkRP_PlayerVarRemoval")
util.AddNetworkString("DarkRP_DarkRPVarDisconnect")

--[[---------------------------------------------------------------------------
Player vars
---------------------------------------------------------------------------]]

--[[---------------------------------------------------------------------------
Remove a player's DarkRPVar
---------------------------------------------------------------------------]]
function meta:removeDarkRPVar(var, target)
    local vars = DarkRP.ServerDarkRPVars[self]
    hook.Call("DarkRPVarChanged", nil, self, var, vars and vars[var], nil)
    target = target or player.GetAll()

    DarkRP.ServerDarkRPVars[self] = DarkRP.ServerDarkRPVars[self] or {}
    DarkRP.ServerDarkRPVars[self][var] = nil

    net.Start("DarkRP_PlayerVarRemoval")
        net.WriteUInt(self:UserID(), 16)
        DarkRP.writeNetDarkRPVarRemoval(var)
    net.Send(target)
end

--[[---------------------------------------------------------------------------
Set a player's DarkRPVar
---------------------------------------------------------------------------]]
function meta:setDarkRPVar(var, value, target)
    target = target or player.GetAll()

    if value == nil then return self:removeDarkRPVar(var, target) end

    local vars = DarkRP.ServerDarkRPVars[self]
    hook.Call("DarkRPVarChanged", nil, self, var, vars and vars[var], value)

    DarkRP.ServerDarkRPVars[self] = DarkRP.ServerDarkRPVars[self] or {}
    DarkRP.ServerDarkRPVars[self][var] = value

    net.Start("DarkRP_PlayerVar")
        net.WriteUInt(self:UserID(), 16)
        DarkRP.writeNetDarkRPVar(var, value)
    net.Send(target)
end

--[[---------------------------------------------------------------------------
Set a private DarkRPVar
---------------------------------------------------------------------------]]
function meta:setSelfDarkRPVar(var, value)
    DarkRP.ServerPrivateDarkRPVars[self] = DarkRP.ServerPrivateDarkRPVars[self] or {}
    DarkRP.ServerPrivateDarkRPVars[self][var] = true

    self:setDarkRPVar(var, value, self)
end

--[[---------------------------------------------------------------------------
Get a DarkRPVar
---------------------------------------------------------------------------]]
function meta:getDarkRPVar(var, fallback)
    local vars = DarkRP.ServerDarkRPVars[self]
    if vars == nil then return fallback end

    local results = vars[var]
    if results == nil then return fallback end

    return results
end

--[[---------------------------------------------------------------------------
Backwards compatibility: Set ply.DarkRPVars attribute
---------------------------------------------------------------------------]]
function meta:setDarkRPVarsAttribute()
    DarkRP.ServerDarkRPVars[self] = DarkRP.ServerDarkRPVars[self] or {}
    -- With a reference to the table, ply.DarkRPVars should always remain
    -- up-to-date. One needs only be careful that DarkRP.ServerDarkRPVars[ply]
    -- is never replaced by a different table.
    self.DarkRPVars = DarkRP.ServerDarkRPVars[self]
end


--[[---------------------------------------------------------------------------
Send the DarkRPVars to a client
---------------------------------------------------------------------------]]
function meta:sendDarkRPVars()
    if self:EntIndex() == 0 then return end

    local plys = player.GetAll()

    net.Start("DarkRP_InitializeVars")
        net.WriteUInt(#plys, 8)
        for _, target in ipairs(plys) do
            net.WriteUInt(target:UserID(), 16)

            local vars = {}
            for var, value in pairs(DarkRP.ServerDarkRPVars[target] or {}) do
                if self ~= target and (DarkRP.ServerPrivateDarkRPVars[target] or {})[var] then continue end
                table.insert(vars, var)
            end

            local vars_cnt = #vars
            net.WriteUInt(vars_cnt, DarkRP.DARKRP_ID_BITS + 2) -- Allow for three times as many unknown DarkRPVars than the limit
            for i = 1, vars_cnt, 1 do
                DarkRP.writeNetDarkRPVar(vars[i], DarkRP.ServerDarkRPVars[target][vars[i]])
            end
        end
    net.Send(self)
end
concommand.Add("_sendDarkRPvars", function(ply)
    if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 3) then return end -- prevent spammers
    ply.DarkRPVarsSent = CurTime()
    ply:sendDarkRPVars()
end)

--[[---------------------------------------------------------------------------
Admin DarkRPVar commands
---------------------------------------------------------------------------]]
local function setRPName(ply, args)
    if not args[2] or string.len(args[2]) < 2 or string.len(args[2]) > 30 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), "<2/>30"))
        return
    end

    local name = table.concat(args, " ", 2)

    local target = DarkRP.findPlayer(args[1])

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args[1]))
        return
    end

    local oldname = target:Nick()

    DarkRP.retrieveRPNames(name, function(taken)
        if not IsValid(target) then return end

        if taken then
            DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("unable", "RPname", DarkRP.getPhrase("already_taken")))
            return
        end

        DarkRP.storeRPName(target, name)
        target:setDarkRPVar("rpname", name)

        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_set_x_name", oldname, name))

        local nick = ""
        if ply:EntIndex() == 0 then
            nick = "Console"
        else
            nick = ply:Nick()
        end
        DarkRP.notify(target, 0, 4, DarkRP.getPhrase("x_set_your_name", nick, name))
        if ply:EntIndex() == 0 then
            DarkRP.log("Console set " .. target:SteamName() .. "'s name to " .. name, Color(30, 30, 30))
        else
            DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s name to " .. name, Color(30, 30, 30))
        end
    end)
end
DarkRP.definePrivilegedChatCommand("forcerpname", "DarkRP_AdminCommands", setRPName)

local function freerpname(ply, args)
    local name = args ~= "" and args or IsValid(ply) and ply:Nick() or ""

    MySQLite.query(("UPDATE darkrp_player SET rpname = NULL WHERE rpname = %s"):format(MySQLite.SQLStr(name)))

    local nick = IsValid(ply) and ply:Nick() or "Console"
    DarkRP.log(("%s has freed the rp name '%s'"):format(nick, name), Color(30, 30, 30))
    DarkRP.notify(ply, 0, 4, ("'%s' has been freed"):format(name))
end
DarkRP.definePrivilegedChatCommand("freerpname", "DarkRP_AdminCommands", freerpname)

local function RPName(ply, args)
    if ply.LastNameChange and ply.LastNameChange > (CurTime() - 5) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(5 - (CurTime() - ply.LastNameChange)), "/rpname"))
        return ""
    end

    if not GAMEMODE.Config.allowrpnames then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("disabled", "/rpname", ""))
        return ""
    end

    args = args:find"^%s*$" and '' or args:match"^%s*(.*%S)"

    local canChangeName, reason = hook.Call("CanChangeRPName", GAMEMODE, ply, args)
    if canChangeName == false then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/rpname", reason or ""))
        return ""
    end

    ply:setRPName(args)
    ply.LastNameChange = CurTime()
    return ""
end
DarkRP.defineChatCommand("rpname", RPName)
DarkRP.defineChatCommand("name", RPName)
DarkRP.defineChatCommand("nick", RPName)

--[[---------------------------------------------------------------------------
Setting the RP name
---------------------------------------------------------------------------]]
function meta:setRPName(name, firstRun)
    -- Make sure nobody on this server already has this RP name
    local lowername = string.lower(tostring(name))
    DarkRP.retrieveRPNames(name, function(taken)
        if not IsValid(self) or string.len(lowername) < 2 and not firstrun then return end
        -- If we found that this name exists for another player
        if taken then
            if firstRun then
                -- If we just connected and another player happens to be using our steam name as their RP name
                -- Put a 1 after our steam name
                DarkRP.storeRPName(self, name .. " 1")
                DarkRP.notify(self, 0, 12, DarkRP.getPhrase("someone_stole_steam_name"))
            else
                DarkRP.notify(self, 1, 5, DarkRP.getPhrase("unable", "/rpname", DarkRP.getPhrase("already_taken")))
                return ""
            end
        else
            if not firstRun then -- Don't save the steam name in the database
                DarkRP.notifyAll(2, 6, DarkRP.getPhrase("rpname_changed", self:SteamName(), name))
                DarkRP.storeRPName(self, name)
            end
        end
    end)
end

--[[---------------------------------------------------------------------------
Maximum entity values
---------------------------------------------------------------------------]]
local maxEntities = {}
function meta:addCustomEntity(entTable)
    maxEntities[self] = maxEntities[self] or {}
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] + 1
end

function meta:removeCustomEntity(entTable)
    maxEntities[self] = maxEntities[self] or {}
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] - 1
end

function meta:customEntityLimitReached(entTable)
    maxEntities[self] = maxEntities[self] or {}
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
    local max = entTable.getMax and entTable.getMax(self) or entTable.max

    return max ~= 0 and maxEntities[self][entTable.cmd] >= max
end

function meta:customEntityCount(entTable)
    local entities = maxEntities[self]
    if entities == nil then return 0 end

    entities = entities[entTable.cmd]
    if entities == nil then return 0 end

    return entities
end

-- We use EntityRemoved to clear players of tables, because it is always called
-- after the PlayerDisconnected hook. This is called _after_ the GAMEMODE
-- function, to make sure that all regular hooks can still use DarkRPVars until
-- the very end. See https://github.com/FPtje/DarkRP/pull/3270
(GAMEMODE or GM).DarkRPPostEntityRemoved = function(_gm, ent)
    if not ent:IsPlayer() then return end

    maxEntities[ent] = nil
    DarkRP.ServerDarkRPVars[ent] = nil
    DarkRP.ServerPrivateDarkRPVars[ent] = nil

    net.Start("DarkRP_DarkRPVarDisconnect")
        net.WriteUInt(ent:UserID(), 16)
    net.Broadcast()
end
