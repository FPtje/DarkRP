/*---------------------------------------------------------------------------
Create the tables used for banning
---------------------------------------------------------------------------*/
hook.Add("InitPostEntity", "FAdmin_CreateMySQLTables", function()
	if not RP_MySQLConfig.EnableMySQL then return end
	timer.Simple(2, function()
		DB.Query("CREATE TABLE IF NOT EXISTS FAdminBans(SteamID VARCHAR(25) NOT NULL PRIMARY KEY, Nick VARCHAR(40), BanDate DATETIME, UnbanDate DATETIME, Reason VARCHAR(100), AdminName VARCHAR(40), Admin_steam VARCHAR(25));")

		hook.Call("FAdmin_RetrieveBans", nil)
	end)
end)

/*---------------------------------------------------------------------------
Store a ban in the MySQL tables
---------------------------------------------------------------------------*/
hook.Add("FAdmin_StoreBan", "MySQLBans", function(SteamID, Nick, Duration, Reason, AdminName, Admin_steam)
	if not RP_MySQLConfig.EnableMySQL then return end

	local steam = SQLStr(SteamID)
	local nick = Nick and SQLStr(Nick) or "NULL"
	local bandate = "NOW()"
	local duration = Duration == 0 and "NULL" or "DATE_ADD(NOW(), INTERVAL ".. tonumber(Duration or 60) .. " MINUTE)"
	local reason = Reason and SQLStr(Reason) or "NULL"
	local admin = AdminName and SQLStr(AdminName) or "NULL"
	local adminsteam = Admin_steam and SQLStr(Admin_steam) or "NULL"

	DB.Query("REPLACE INTO FAdminBans VALUES(".. steam .. ", ".. nick .. ", " .. bandate .. ", " .. duration .. ", ".. reason .. ", ".. admin .. ", ".. adminsteam .. ");")

	return true
end)

/*---------------------------------------------------------------------------
Unban someone
---------------------------------------------------------------------------*/
hook.Add("FAdmin_UnBan", "FAdmin_MySQLUnban", function(ply, steamID)
	DB.Query("DELETE FROM FAdminBans WHERE steamID = ".. SQLStr(steamID))
end)

/*---------------------------------------------------------------------------
Retrieve the bans from the MySQL server and put them into effect

Note: Must be called more than two seconds after InitPostEntity, because
that's when the database initializes
---------------------------------------------------------------------------*/
hook.Add("FAdmin_RetrieveBans", "getMySQLBans", function()
	if not RP_MySQLConfig.EnableMySQL or not CONNECTED_TO_MYSQL then return end

	FAdmin.BANS = FAdmin.BANS or {}

	DB.Query("SELECT SteamID, Nick, TIMESTAMPDIFF(SECOND, NOW(), UnbanDate) AS duration, Reason, AdminName, Admin_steam FROM FAdminBans WHERE (UnbanDate > NOW() OR UnbanDate IS NULL);", function(data)
		if not data then return end

		for k, v in pairs(data) do
			if tonumber(v.SteamID) or not v.SteamID then continue end

			FAdmin.BANS[string.upper(v.SteamID)] = {
				time = os.time() + (v.duration or 0),
				name = v.Nick,
				reason = v.Reason,
				adminname = v.AdminName,
				adminsteam = v.Admin_steam
			}

			game.ConsoleCommand("banid ".. (v.duration or 0) * 60 .." " .. v.SteamID.. "\n")
			game.ConsoleCommand("kickid2 " .. v.SteamID .. " bannedzors\n")
		end
	end)
end)