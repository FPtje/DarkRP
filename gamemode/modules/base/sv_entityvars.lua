local meta = FindMetaTable("Player")

/*---------------------------------------------------------------------------
Pooled networking strings
---------------------------------------------------------------------------*/
util.AddNetworkString("DarkRP_InitializeVars")
util.AddNetworkString("DarkRP_PlayerVar")
util.AddNetworkString("DarkRP_PlayerVarRemoval")
util.AddNetworkString("DarkRP_DarkRPVarDisconnect")

/*---------------------------------------------------------------------------
Player vars
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
Remove a player's DarkRPVar
---------------------------------------------------------------------------*/
function meta:removeDarkRPVar(var, target)
    hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, nil)
    target = target or player.GetAll()
    self.DarkRPVars = self.DarkRPVars or {}
    self.DarkRPVars[var] = nil


    net.Start("DarkRP_PlayerVarRemoval")
        net.WriteUInt(self:UserID(), 16)
        DarkRP.writeNetDarkRPVarRemoval(var)
    net.Send(target)
end

/*---------------------------------------------------------------------------
Set a player's DarkRPVar
---------------------------------------------------------------------------*/
function meta:setDarkRPVar(var, value, target)
    if not IsValid(self) then return end
    target = target or player.GetAll()

    if value == nil then return self:removeDarkRPVar(var, target) end
    hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, value)

    self.DarkRPVars = self.DarkRPVars or {}
    self.DarkRPVars[var] = value

    net.Start("DarkRP_PlayerVar")
        net.WriteUInt(self:UserID(), 16)
        DarkRP.writeNetDarkRPVar(var, value)
    net.Send(target)
end

/*---------------------------------------------------------------------------
Set a private DarkRPVar
---------------------------------------------------------------------------*/
function meta:setSelfDarkRPVar(var, value)
    self.privateDRPVars = self.privateDRPVars or {}
    self.privateDRPVars[var] = true

    self:setDarkRPVar(var, value, self)
end

/*---------------------------------------------------------------------------
Get a DarkRPVar
---------------------------------------------------------------------------*/
function meta:getDarkRPVar(var)
    self.DarkRPVars = self.DarkRPVars or {}
    return self.DarkRPVars[var]
end

/*---------------------------------------------------------------------------
Send the DarkRPVars to a client
---------------------------------------------------------------------------*/
function meta:sendDarkRPVars()
    if self:EntIndex() == 0 then return end

    local plys = player.GetAll()

    net.Start("DarkRP_InitializeVars")
        net.WriteUInt(#plys, 8)
        for _, target in pairs(plys) do
            net.WriteUInt(target:UserID(), 16)

            local DarkRPVars = {}
            for var, value in pairs(target.DarkRPVars) do
                if self ~= target and (target.privateDRPVars or {})[var] then continue end
                table.insert(DarkRPVars, var)
            end

            net.WriteUInt(#DarkRPVars, DarkRP.DARKRP_ID_BITS + 2) -- Allow for three times as many unknown DarkRPVars than the limit
            for i = 1, #DarkRPVars, 1 do
                DarkRP.writeNetDarkRPVar(DarkRPVars[i], target.DarkRPVars[DarkRPVars[i]])
            end
        end
    net.Send(self)
end
concommand.Add("_sendDarkRPvars", function(ply)
    if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 3) then return end -- prevent spammers
    ply.DarkRPVarsSent = CurTime()
    ply:sendDarkRPVars()
end)

/*---------------------------------------------------------------------------
Admin DarkRPVar commands
---------------------------------------------------------------------------*/
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
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait",  math.ceil(5 - (CurTime() - ply.LastNameChange)), "/rpname"))
        return ""
    end

    if not GAMEMODE.Config.allowrpnames then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("disabled", "RPname", ""))
        return ""
    end

    args = args:find"^%s*$" and '' or args:match"^%s*(.*%S)"

    local canChangeName, reason = hook.Call("CanChangeRPName", GAMEMODE, ply, args)
    if canChangeName == false then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", reason or ""))
        return ""
    end

    ply:setRPName(args)
    ply.LastNameChange = CurTime()
    return ""
end
DarkRP.defineChatCommand("rpname", RPName)
DarkRP.defineChatCommand("name", RPName)
DarkRP.defineChatCommand("nick", RPName)

/*---------------------------------------------------------------------------
Setting the RP name
---------------------------------------------------------------------------*/
function meta:setRPName(name, firstRun)
    -- Make sure nobody on this server already has this RP name
    local lowername = string.lower(tostring(name))
    DarkRP.retrieveRPNames(name, function(taken)
        if string.len(lowername) < 2 and not firstrun then return end
        -- If we found that this name exists for another player
        if taken then
            if firstRun then
                -- If we just connected and another player happens to be using our steam name as their RP name
                -- Put a 1 after our steam name
                DarkRP.storeRPName(self, name .. " 1")
                DarkRP.notify(self, 0, 12, DarkRP.getPhrase("someone_stole_steam_name"))
            else
                DarkRP.notify(self, 1, 5, DarkRP.getPhrase("unable", "RPname", DarkRP.getPhrase("already_taken")))
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


/*---------------------------------------------------------------------------
Maximum entity values
---------------------------------------------------------------------------*/
local maxEntities = {}
function meta:addCustomEntity(entTable)
    if not entTable then return end

    maxEntities[self] = maxEntities[self] or {}
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] + 1
end

function meta:removeCustomEntity(entTable)
    if not entTable.cmd then return end

    maxEntities[self] = maxEntities[self] or {}
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] - 1
end

function meta:customEntityLimitReached(entTable)
    maxEntities[self] = maxEntities[self] or {}
    maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0

    return maxEntities[self][entTable.cmd] >= (entTable.getMax and entTable.getMax(self) or entTable.max)
end

hook.Add("PlayerDisconnected", "removeLimits", function(ply)
    maxEntities[ply] = nil
    net.Start("DarkRP_DarkRPVarDisconnect")
        net.WriteUInt(ply:UserID(), 16)
    net.Broadcast()
end)
