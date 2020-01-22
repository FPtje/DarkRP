local kickMessage = [[You cannot join these server(s) twice with the same account.
If you're a developer, please disable antimultirun in the DarkRP config.
]]

local function clearServerEntries()
    MySQLite.query(string.format([[
        DELETE FROM darkrp_serverplayer WHERE serverid = %s
    ]], MySQLite.SQLStr(DarkRP.serverId)))
end

local function insertUid(uid)
    MySQLite.query(string.format([[
        INSERT INTO darkrp_serverplayer VALUES(%s, %s)
    ]], uid, MySQLite.SQLStr(DarkRP.serverId)))
end

local function insertPlayer(ply)
    insertUid(ply:SteamID64())
end


local function removePlayer(ply)
    MySQLite.query(string.format([[
        DELETE FROM darkrp_serverplayer WHERE uid = %s AND serverid = %s
    ]], ply:SteamID64(), MySQLite.SQLStr(DarkRP.serverId)))
end

local function addHooks()
    hook.Add("PlayerAuthed", "DarkRP_antimultirun", function(ply, steamId)
        local uid = util.SteamIDTo64(steamId)
        local userid = ply:UserID()

        MySQLite.queryValue(string.format([[
            SELECT serverid FROM darkrp_serverplayer WHERE uid = %s
        ]], uid), function(sid)
            if sid then
                game.KickID(userid, kickMessage)
            else
                insertUid(uid)
            end
        end, error)
    end)

    hook.Add("PlayerDisconnected", "DarkRP_antimultirun", removePlayer)
    hook.Add("ShutDown", "DarkRP_antimultirun", clearServerEntries)
end

hook.Add("DarkRPDBInitialized", "DarkRP_antimultirun", function()
    if not GAMEMODE.Config.antimultirun then return end
    if not MySQLite.isMySQL() then return end
    if not game.IsDedicated() then return end

    -- Wait until game.GetIPAddress() returns a sensible value
    -- https://github.com/FPtje/DarkRP/issues/2982
    -- https://github.com/Facepunch/garrysmod-issues/issues/3001
    hook.Add("Think", "DarkRP_antimultirun", function()
        DarkRP.serverId = game.GetIPAddress()
        if string.sub(DarkRP.serverId, 0, 8) == "0.0.0.0:" then return end
        hook.Remove("Think", "DarkRP_antimultirun")

        MySQLite.query([[
            CREATE TABLE IF NOT EXISTS darkrp_serverplayer(
                uid BIGINT NOT NULL,
                serverid VARCHAR(32) NOT NULL,
                PRIMARY KEY(uid, serverid)
            );
        ]])

        -- Clear this server's entries in case the server wasn't cleanly shut down
        clearServerEntries()

        -- Re-insert players currently in the game
        fn.Map(insertPlayer, player.GetAll())

        addHooks()
    end)
end)
