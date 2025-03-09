--[[---------------------------------------------------------------------------
Utility functions
---------------------------------------------------------------------------]]

local vector = FindMetaTable("Vector")
local meta = FindMetaTable("Player")

--[[---------------------------------------------------------------------------
Decides whether the vector could be seen by the player if they were to look at it
---------------------------------------------------------------------------]]
function vector:isInSight(filter, ply)
    ply = ply or LocalPlayer()
    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = self
    trace.filter = filter
    trace.mask = -1
    local TheTrace = util.TraceLine(trace)

    return not TheTrace.Hit, TheTrace.HitPos
end

--[[---------------------------------------------------------------------------
Turn a money amount into a pretty string
---------------------------------------------------------------------------]]
local function attachCurrency(str)
    local config = GAMEMODE.Config
    return config.currencyLeft and config.currency .. str or str .. config.currency
end

function DarkRP.formatMoney(n)
    if not n then return attachCurrency("0") end

    if n >= 1e14 then return attachCurrency(tostring(n)) end
    if n <= -1e14 then return "-" .. attachCurrency(tostring(math.abs(n))) end

    local config = GAMEMODE.Config

    local negative = n < 0

    n = tostring(math.abs(n))

    local dp = string.find(n, ".", 1, true) or #n + 1

    for i = dp - 4, 1, -3 do
        n = n:sub(1, i) .. config.currencyThousandSeparator .. n:sub(i + 1)
    end

    -- Make sure the amount is padded with zeroes
    if n[#n - 1] == "." then
        n = n .. "0"
    end

    return (negative and "-" or "") .. attachCurrency(n)
end

--[[---------------------------------------------------------------------------
Find a player based on given information

Note that there is a searching priority:
  * UserID
  * SteamID64
  * SteamID
  * Nick
  * SteamName

Note also that there are _separate_ loops. This is to make sure the function
gives the same result, regardless of the order in which players are iterated
over.
---------------------------------------------------------------------------]]
function DarkRP.findPlayer(info)
    if not info or info == "" then return nil end
    local pls = player.GetAll()

    local count = #pls
    local numberInfo = tonumber(info)

    -- First check if the input matches a player by UserID or SteamID64. This is
    -- only necessary if the input can be parsed as a number.
    if numberInfo then
        for k = 1, count do
            local v = pls[k]

            if numberInfo == v:UserID() then
                return v
            end
        end

        for k = 1, count do
            local v = pls[k]

            if info == v:SteamID64() then
                return v
            end
        end
    end

    local lowerInfo = string.lower(tostring(info))
    if string.StartsWith(lowerInfo, "steam_") then
        for k = 1, count do
            local v = pls[k]

            if info == v:SteamID() then
                return v
            end
        end
    end

    for k = 1, count do
        local v = pls[k]

        if string.find(string.lower(v:Nick()), lowerInfo, 1, true) ~= nil then
            return v
        end
    end

    for k = 1, count do
        local v = pls[k]

        if string.find(string.lower(v:SteamName()), lowerInfo, 1, true) ~= nil then
            return v
        end
    end

    return nil
end

--[[---------------------------------------------------------------------------
Find multiple players based on a string criterium
Taken from FAdmin]]
---------------------------------------------------------------------------*/
function DarkRP.findPlayers(info)
    if not info then return nil end
    local pls = player.GetAll()
    local found = {}
    local players

    if string.lower(info) == "*" or string.lower(info) == "<all>" then return pls end

    local InfoPlayers = {}
    for A in string.gmatch(info .. ";", "([a-zA-Z0-9:_.]*)[;(,%s)%c]") do
        if A ~= "" then
            table.insert(InfoPlayers, A)
        end
    end

    for _, PlayerInfo in ipairs(InfoPlayers) do
        -- Playerinfo is always to be treated as UserID when it's a number
        -- otherwise people with numbers in their names could get confused with UserID's of other players
        if tonumber(PlayerInfo) then
            local foundPlayer = Player(PlayerInfo)
            if IsValid(foundPlayer) and not found[foundPlayer] then
                found[foundPlayer] = true
                players = players or {}
                table.insert(players, foundPlayer)
            end
            continue
        end

        local stringPlayerInfo = string.lower(PlayerInfo)
        for _, v in ipairs(pls) do
            -- Prevent duplicates
            if found[v] then continue end
            local steamId = v:SteamID()

            -- Find by Steam ID
            if (PlayerInfo == steamId or steamId == "UNKNOWN") or
            -- Find by Partial Nick
            string.find(string.lower(v:Nick()), stringPlayerInfo, 1, true) ~= nil or
            -- Find by steam name
            (v.SteamName and string.find(string.lower(v:SteamName()), stringPlayerInfo, 1, true) ~= nil) then
                found[v] = true
                players = players or {}
                table.insert(players, v)
            end
        end
    end

    return players
end

function meta:getEyeSightHitEntity(searchDistance, hitDistance, filter)
    searchDistance = searchDistance or 100
    hitDistance = (hitDistance or 15) * (hitDistance or 15)

    filter = filter or function(p) return p:IsPlayer() and p ~= self end

    self:LagCompensation(true)

    local shootPos = self:GetShootPos()
    local entities = ents.FindInSphere(shootPos, searchDistance)
    local aimvec = self:GetAimVector()

    local smallestDistance = math.huge
    local foundEnt

    for _, ent in pairs(entities) do
        if not IsValid(ent) or filter(ent) == false then continue end

        local center = ent:GetPos()

        -- project the center vector on the aim vector
        local projected = shootPos + (center - shootPos):Dot(aimvec) * aimvec

        if aimvec:Dot((projected - shootPos):GetNormalized()) < 0 then continue end

        -- the point on the model that has the smallest distance to your line of sight
        local nearestPoint = ent:NearestPoint(projected)
        local distance = nearestPoint:DistToSqr(projected)

        if distance < smallestDistance then
            local trace = {
                start = self:GetShootPos(),
                endpos = nearestPoint,
                filter = {self, ent}
            }
            local traceLine = util.TraceLine(trace)
            if traceLine.Hit then continue end

            smallestDistance = distance
            foundEnt = ent
        end
    end

    self:LagCompensation(false)

    if smallestDistance < hitDistance then
        return foundEnt, math.sqrt(smallestDistance)
    end

    return nil
end

--[[---------------------------------------------------------------------------
Print the currently available vehicles
---------------------------------------------------------------------------]]
local function GetAvailableVehicles(ply)
    if SERVER and IsValid(ply) and not ply:IsAdmin() then return end
    local print = SERVER and ServerLog or Msg

    print(DarkRP.getPhrase("rp_getvehicles") .. "\n")
    for k in pairs(DarkRP.getAvailableVehicles()) do
        print("\"" .. k .. "\"" .. "\n")
    end
end
if SERVER then
    concommand.Add("rp_getvehicles_sv", GetAvailableVehicles)
else
    concommand.Add("rp_getvehicles", GetAvailableVehicles)
end

--[[---------------------------------------------------------------------------
Whether a player has a DarkRP privilege
---------------------------------------------------------------------------]]
function meta:hasDarkRPPrivilege(priv)
    if FAdmin then
        return FAdmin.Access.PlayerHasPrivilege(self, priv)
    end
    return self:IsAdmin()
end

--[[---------------------------------------------------------------------------
Convenience function to return the players sorted by name
---------------------------------------------------------------------------]]
function DarkRP.nickSortedPlayers()
    local plys = player.GetAll()
    table.sort(plys, function(a,b) return a:Nick() < b:Nick() end)
    return plys
end

--[[---------------------------------------------------------------------------
Convert a string to a table of arguments
---------------------------------------------------------------------------]]
local bitlshift, stringgmatch, stringsub, tableinsert = bit.lshift, string.gmatch, string.sub, table.insert
function DarkRP.explodeArg(arg)
    local args = {}

    local from, to, diff = 1, 0, 0
    local inQuotes, wasQuotes = false, false

    for c in stringgmatch(arg, '.') do
        to = to + 1

        if c == '"' then
            inQuotes = not inQuotes
            wasQuotes = true

            continue
        end

        if c == ' ' and not inQuotes then
            diff = wasQuotes and 1 or 0
            wasQuotes = false
            tableinsert(args, stringsub(arg, from + diff, to - 1 - diff))
            from = to + 1
        end
    end
    diff = wasQuotes and 1 or 0

    if from ~= to + 1 then tableinsert(args, stringsub(arg, from + diff, to + 1 - bitlshift(diff, 1))) end

    return args
end

--[[---------------------------------------------------------------------------
Initialize Physics, throw an error on failure
---------------------------------------------------------------------------]]
function DarkRP.ValidatedPhysicsInit(ent, solidType, hint)
    solidType = solidType or SOLID_VPHYSICS

    if ent:PhysicsInit(solidType) then return true end

    local class = ent:GetClass()

    if solidType == SOLID_BSP then
        DarkRP.errorNoHalt(string.format("%s has no physics and will be motionless", class), 2, {
            "Is this a brush model? SOLID_BSP physics cannot initialize on entities that don't have brush models",
            "The physics limit may have been hit",
            hint
        })

        return false
    end

    if solidType == SOLID_VPHYSICS then
        local mdl = ent:GetModel()

        if not mdl or mdl == "" then
            DarkRP.errorNoHalt(string.format("Cannot init physics on entity \"%s\" because it has no model", class), 2, {hint})
            return false
        end

        mdl = string.lower(mdl)

        if util.IsValidProp(mdl) then
            -- Has physics, we must have hit the limit
            DarkRP.errorNoHalt(string.format("physics limit hit - %s will be motionless", class), 2, {hint})

            return false
        end

        if not file.Exists(mdl, "GAME") then
            DarkRP.errorNoHalt(string.format("%s has missing model \"%s\" and will be invisible and motionless", class, mdl), 2, {
                "Is the model path correct?",
                "Is the model from an addon that is not installed?",
                "Is the model from a game that isn't (properly) mounted? E.g. Counter Strike: Source",
                hint
            })

            return false
        end

        DarkRP.errorNoHalt(string.format("%s has model \"%s\" with no physics and will be motionless", class, mdl), 2, {
            "Does this model have an associated physics model (modelname.phy)?",
            "Is this model supposed to have physics? Many models, like effects and view models aren't made to have physics",
            hint
        })

        return false
    end

    DarkRP.errorNoHalt(string.format("Unable to initilize physics on entity \"%s\"", class, {hint}), 2)

    return false
end

--[[---------------------------------------------------------------------------
Like tonumber, but makes sure it's an integer
---------------------------------------------------------------------------]]
function DarkRP.toInt(value)
    value = tonumber(value)
    return value and math.floor(value)
end

--[[-------------------------------------------------------------------------
Check the database for integrity errors. Use in cases when stuff doesn't load
on restart, or you get corruption errors.
---------------------------------------------------------------------------]]
if SERVER then util.AddNetworkString("DarkRP_databaseCheckMessage") end
if CLIENT then net.Receive("DarkRP_databaseCheckMessage", fc{print, net.ReadString}) end

local function checkDatabase(ply)
    local dbFile = SERVER and "sv.db" or "cl.db"
    local display = (CLIENT or not IsValid(ply)) and print or function(msg)
            net.Start("DarkRP_databaseCheckMessage")
            net.WriteString(msg)
            net.Send(ply)
        end

    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        display("You must be superadmin")
        return
    end

    if MySQLite and MySQLite.isMySQL() then
        display(string.format([[WARNING: DarkRP is using MySQL. This only
    checks the local SQLite database stored in the %s file in the
    garrysmod/ folder. The check will continue.]], dbFile))
    end

    local check = sql.QueryValue("PRAGMA INTEGRITY_CHECK")
    if check == false then
        display([[The query to check the database failed. Shit's surely
    fucked, but the cause is unknown.]])
        return
    end

    if check == "ok" then
        display(string.format("Your %s database file is good.", dbFile))
        return
    end

    display(string.format([[There are errors in your %s database file. It's corrupt!

    This can cause the following problems:
    - Data not loading, think of blocked models, doors, players' money and RP names
    - Settings resetting to their default values
    - Lua errors on startup

    The cause of the problem is that the %s file in your garrysmod/ folder on
    %s is corrupt. How this came to be is unknown, but here's what you can do to solve it:

    - Delete %s, and run a file integrity check. Warning: You will lose ALL data stored in it!
    - Take the file and try to repair it. This is sadly something that requires some technical knowledge,
      and may not always succeed.

    The specific error, by the way, is as follows:
    %s
    ]], dbFile, dbFile, SERVER and "the server" or "your own computer", dbFile, check))

end
concommand.Add("darkrp_check_db_" .. (SERVER and "sv" or "cl"), checkDatabase)
