FPP_MySQLConfig = {} -- Ignore this line
--[[
Welcome to MySQL for FPP!
Shamelessly copied from DarkRP!
In this file you can find a manual for MySQL configuration and the MySQL config settings.
]]


FPP_MySQLConfig.EnableMySQL = false -- Set to true if you want to use an external MySQL database, false if you want to use the built in SQLite database (garrysmod/sv.db) of Garry's mod.
FPP_MySQLConfig.Host = "127.0.0.1" -- This is the IP address of the MySQL host. Make sure the IP address is correct and in quotation marks (" ")
FPP_MySQLConfig.Username = "user" -- This is the username to log in on the MySQL server.
								-- contact the owner of the server about the username and password. Make sure it's in quotation marks! (" ")
FPP_MySQLConfig.Password = "password" -- This is the Password to log in on the MySQL server,
									-- Everyone who has access to FTP on the server can read this password.
									-- Make sure you know who to trust. Make sure it's in quotation marks (" ")
FPP_MySQLConfig.Database_name = "FPP" -- This is the name of the Database on the MySQL server. Contact the MySQL server host to find out what this is
FPP_MySQLConfig.Database_port = 3306 -- This is the port of the MySQL server. Again, contact the MySQL server host if you don't know this.


--[[
MANUAL!
HOW TO USE MySQL FOR FPP!
Download andyvincent's gm_MySQL OO module to your hard drive:
http://www.facepunch.com/showthread.php?t=933647

Unpack it

on the SERVER:
	- Put libmySQL.dll in the same folder as HL2.exe OR srcds.exe (e.g srcds\orangebox OR steamapps\username\garrysmod)
	- Put gmsv_mysqloo.dll in garrysmod\lua\includes\modules\. If any of those folders don't exist, create them.
		You can also copy and paste the lua folder from the download to garrysmod/
	- Make sure the configurations in this file (_MySQL.lua) are set up correctly
	- TIP: Make this file read-only so it doesn't get changed in an SVN update!
		But if you get problems with the MySQL database, remove this file, update from SVN and set it up again, things might change in the SVN!



WHAT TO DO IF YOU CAN'T GET IT TO WORK!
	- There are always errors on the server, try if you can see those (with HLDS)
	- make sure the settings in this file (_MySQL.lua) are correct
	- make sure the MySQL server is accessible from the outside
]]