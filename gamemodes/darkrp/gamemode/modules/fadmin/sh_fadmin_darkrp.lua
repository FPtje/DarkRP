FAdmin = FAdmin or {}

FAdmin.PlayerActions = FAdmin.PlayerActions or {}
FAdmin.StartHooks = FAdmin.StartHooks or {}

--[[

Utilities!

]]
function FAdmin.FindPlayer(info)
    if not info then return nil end
    local pls = player.GetAll()
    local found = {}

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
            if IsValid(Player(PlayerInfo)) and not found[Player(PlayerInfo)] then
                found[Player(PlayerInfo)] = true
            end
            continue
        end

        for _, v in ipairs(pls) do
            -- Find by Steam ID
            if (PlayerInfo == v:SteamID() or v:SteamID() == "UNKNOWN") and not found[v] then
                found[v] = true
            end

            -- Find by Partial Nick
            if string.find(string.lower(v:Nick()), string.lower(tostring(PlayerInfo)), 1, true) ~= nil and not found[v] then
                found[v] = true
            end

            if v.SteamName and string.find(string.lower(v:SteamName()), string.lower(tostring(PlayerInfo)), 1, true) ~= nil and not found[v] then
                found[v] = true
            end
        end
    end

    local players = {}
    local empty = true
    for k in pairs(found or {}) do
        empty = false
        table.insert(players, k)
    end
    return not empty and players or nil
end

function FAdmin.SteamToProfile(ply) -- Thanks decodaman
    return "https://steamcommunity.com/profiles/" .. (ply:SteamID64() or "BOT")
end

--[[
    FAdmin global settings
]]
FAdmin.GlobalSetting = FAdmin.GlobalSetting or {}


--[[Dependency solver:
    Many plugins are dependant of one another.
    To prevent plugins calling functions from other plugins that haven't been opened yet
    there will be a hook that is called when all plugins are loaded.
    This way there will be no hassle with which plugin loads first, which one next etc.
]]
timer.Simple(0, function()
    for k in pairs(FAdmin.StartHooks) do if not isstring(k) then FAdmin.StartHooks[k] = nil end end
    for _, v in SortedPairs(FAdmin.StartHooks) do
        v()
    end
end)
