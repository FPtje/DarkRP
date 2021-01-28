--[[---------------------------------------------------------------------------
Create the tables used for banning
---------------------------------------------------------------------------]]
hook.Add("DatabaseInitialized", "FAdmin_CreateMySQLTables", function()
    MySQLite.query("CREATE TABLE IF NOT EXISTS FAdminBans(SteamID VARCHAR(25) NOT NULL PRIMARY KEY, Nick VARCHAR(40), BanDate DATETIME, UnbanDate DATETIME, Reason VARCHAR(100), AdminName VARCHAR(40), Admin_steam VARCHAR(25));", function()

        hook.Call("FAdmin_RetrieveBans", nil)
    end)
end)

--[[---------------------------------------------------------------------------
Store a ban in the MySQL tables
---------------------------------------------------------------------------]]
hook.Add("FAdmin_StoreBan", "MySQLBans", function(SteamID, Nick, Duration, Reason, AdminName, Admin_steam)
    local steam = MySQLite.SQLStr(SteamID)
    local nick = Nick and MySQLite.SQLStr(Nick) or "NULL"
    local bandate = MySQLite.isMySQL() and "NOW()" or "datetime('now')"
    local reason = Reason and MySQLite.SQLStr(Reason) or "NULL"
    local admin = AdminName and MySQLite.SQLStr(AdminName) or "NULL"
    local adminsteam = Admin_steam and MySQLite.SQLStr(Admin_steam) or "NULL"

    local duration
    if MySQLite.isMySQL() then
        duration = Duration == 0 and "NULL" or "DATE_ADD(NOW(), INTERVAL " .. tonumber(Duration or 60) .. " MINUTE)"
    else
        duration = Duration == 0 and "NULL" or "datetime('now', '+" .. tonumber(Duration or 60) .. " minutes')"
    end

    MySQLite.query("REPLACE INTO FAdminBans VALUES(" .. steam .. ", " .. nick .. ", " .. bandate .. ", " .. duration .. ", " .. reason .. ", " .. admin .. ", " .. adminsteam .. ");")
end)

--[[---------------------------------------------------------------------------
Unban someone
---------------------------------------------------------------------------]]
hook.Add("FAdmin_UnBan", "FAdmin_MySQLUnban", function(ply, steamID)
    MySQLite.query("DELETE FROM FAdminBans WHERE steamID = " .. MySQLite.SQLStr(steamID))
end)

--[[---------------------------------------------------------------------------
Retrieve the bans from the MySQL server and put them into effect

Note: Must be called more than two seconds after InitPostEntity, because
that's when the database initializes
---------------------------------------------------------------------------]]
hook.Add("FAdmin_RetrieveBans", "getMySQLBans", function()
    FAdmin.BANS = FAdmin.BANS or {}

    -- Small SQLite and MySQL syntax difference
    local diffSeconds = MySQLite.isMySQL() and "TIMESTAMPDIFF(SECOND, NOW(), UnbanDate)" or
        "strftime('%s', UnbanDate) - strftime('%s','now')"

    local now = MySQLite.isMySQL() and "NOW()" or "datetime('now')"

    MySQLite.query("SELECT SteamID, Nick, " .. diffSeconds .. " AS duration, Reason, AdminName, Admin_steam FROM FAdminBans WHERE (UnbanDate > " .. now .. " OR UnbanDate IS NULL);", function(data)
        if not data then return end

        for _, v in ipairs(data) do
            if tonumber(v.SteamID) or not v.SteamID then continue end
            local duration = (not v.duration or v.duration == "NULL") and 0 or (os.time() + v.duration)

            FAdmin.BANS[string.upper(v.SteamID)] = {
                time = duration,
                name = v.Nick,
                reason = v.Reason,
                adminname = v.AdminName,
                adminsteam = v.Admin_steam
            }
        end

        for _, v in ipairs(player.GetAll()) do
            if not FAdmin.BANS[string.upper(v:SteamID())] then continue end

            v:Kick("FAdmin ban evasion")
        end
    end)
end)
