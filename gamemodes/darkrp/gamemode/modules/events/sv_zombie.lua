local timeLeft2 = 10
local maxZombie = 10
local zombieOn = false
local zombieSpawns = {}

/*---------------------------------------------------------
 Zombie
 ---------------------------------------------------------*/
local ZombieStart, ZombieEnd
local function ControlZombie()
	timeLeft2 = timeLeft2 - 1

	if timeLeft2 < 1 then
		if zombieOn then
			timeLeft2 = math.random(300,500)
			zombieOn = false
			timer.Stop("start2")
			ZombieEnd()
		else
			timeLeft2 = math.random(150,300)
			zombieOn = true
			timer.Start("start2")
			DarkRP.retrieveZombies(function()
				ZombieStart()
			end)
		end
	end
end

ZombieStart = function()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("zombie_approaching"))
			v:PrintMessage(HUD_PRINTTALK, DarkRP.getPhrase("zombie_approaching"))
		end
	end
end

ZombieEnd = function()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("zombie_leaving"))
			v:PrintMessage(HUD_PRINTTALK, DarkRP.getPhrase("zombie_leaving"))
		end
	end
end

local function LoadTable(ply)
	ply:setSelfDarkRPVar("zPoints", zombieSpawns)
end

local function ReMoveZombie(ply, index)
	if ply:hasDarkRPPrivilege("rp_commands") then
		if not index or zombieSpawns[tonumber(index)] == nil then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("zombie_spawn_not_exist", tostring(index)))
		else
			DarkRP.retrieveZombies(function()
				DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("zombie_spawn_removed"))
				table.remove(zombieSpawns, index)
				DarkRP.storeZombies()
				if ply:getDarkRPVar("zombieToggle") then
					LoadTable(ply)
				end
			end)
		end
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/removezombie"))
	end
	return ""
end
DarkRP.defineChatCommand("removezombie", ReMoveZombie)

local function AddZombie(ply)
	if ply:hasDarkRPPrivilege("rp_commands") then
		DarkRP.retrieveZombies(function()
			table.insert(zombieSpawns, ply:GetPos())
			DarkRP.storeZombies()
			if ply:getDarkRPVar("zombieToggle") then LoadTable(ply) end
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("zombie_spawn_added"))
		end)
	else
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/addzombie"))
	end
	return ""
end
DarkRP.defineChatCommand("addzombie", AddZombie)

local function ToggleZombie(ply)
	if ply:hasDarkRPPrivilege("rp_commands") then
		if not ply:getDarkRPVar("zombieToggle") then
			DarkRP.retrieveZombies(function()
				ply:setSelfDarkRPVar("zombieToggle", true)
				LoadTable(ply)
				DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("zombie_toggled"))
			end)
		else
			ply:setSelfDarkRPVar("zombieToggle", nil)
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("zombie_toggled"))
		end
	else
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/showzombie"))
	end
	return ""
end
DarkRP.defineChatCommand("showzombie", ToggleZombie)

local function GetAliveZombie()
	local zombieCount = 0

	local ZombieTypes = {"npc_zombie", "npc_fastzombie", "npc_antlion", "npc_headcrab_fast"}
	for _, Type in pairs(ZombieTypes) do
		zombieCount = zombieCount + #ents.FindByClass(Type)
	end

	return zombieCount
end

local function SpawnZombie()
	timer.Start("move")
	if GetAliveZombie() >= maxZombie then return end
	if table.getn(zombieSpawns) <= 0 then return end

	local ZombieTypes = {"npc_zombie", "npc_fastzombie", "npc_antlion", "npc_headcrab_fast"}
	local zombieType = math.random(1, #ZombieTypes)

	local Zombie = ents.Create(ZombieTypes[zombieType])
	Zombie.nodupe = true
	Zombie:Spawn()
	Zombie:Activate()
	Zombie:SetPos(DarkRP.retrieveRandomZombieSpawnPos())
end

local function ZombieMax(ply, args)
	if ply:hasDarkRPPrivilege("rp_commands") then
		if not tonumber(args) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
		maxZombie = tonumber(args)
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("zombie_maxset", args))
	end

	return ""
end
DarkRP.defineChatCommand("zombiemax", ZombieMax)
DarkRP.defineChatCommand("maxzombie", ZombieMax)
DarkRP.defineChatCommand("maxzombies", ZombieMax)

local function StartZombie(ply)
	if ply:hasDarkRPPrivilege("rp_commands") then
		timer.Start("zombieControl")
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("zombie_enabled"))
	else
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/enablezombie"))
	end
	return ""
end
DarkRP.defineChatCommand("enablezombie", StartZombie)

local function StopZombie(ply)
	if ply:hasDarkRPPrivilege("rp_commands") then
		timer.Stop("zombieControl")
		zombieOn = false
		timer.Stop("start2")
		ZombieEnd()
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("zombie_disabled"))
	else
		DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/disablezombie"))
	end
	return ""
end
DarkRP.defineChatCommand("disablezombie", StopZombie)

timer.Create("start2", 1, 0, SpawnZombie)
timer.Create("zombieControl", 1, 0, ControlZombie)
timer.Stop("start2")
timer.Stop("zombieControl")

/*---------------------------------------------------------------------------
Loading and saving data
---------------------------------------------------------------------------*/

local function loadData()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))

	MySQLite.query([[SELECT * FROM darkrp_position WHERE type = 'Z' AND map = ]] .. map .. [[;]], function(data)
		for k,v in pairs(data or {}) do
			table.insert(zombieSpawns, v)
		end
	end)
end
hook.Add("DarkRPDBInitialized", "ZombieData", loadData)

function DarkRP.storeZombies()
	local map = string.lower(game.GetMap())
	MySQLite.begin()
	MySQLite.query([[DELETE FROM darkrp_position WHERE type = 'Z' AND map = ]] .. MySQLite.SQLStr(map) .. ";", function()
		for k, v in pairs(zombieSpawns) do
			MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'Z', " .. v.x .. ", " .. v.y .. ", " .. v.z .. ");")
		end
	end)
	MySQLite.commit()
end

local FirstZombieSpawn = true
function DarkRP.retrieveZombies(callback)
	if zombieSpawns and table.Count(zombieSpawns) > 0 and not FirstZombieSpawn then callback() return zombieSpawns end
	FirstZombieSpawn = false
	zombieSpawns = {}
	MySQLite.query([[SELECT * FROM darkrp_position WHERE type = 'Z' AND map = ]] .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then callback() return end
		for k,v in pairs(r) do
			zombieSpawns[k] = Vector(v.x, v.y, v.z)
		end
		callback()
	end)
end

function DarkRP.retrieveRandomZombieSpawnPos()
	if #zombieSpawns < 1 then return end
	local r = table.Random(zombieSpawns)

	local pos = DarkRP.findEmptyPos(r, nil, 200, 10, Vector(2, 2, 2))

	return pos
end
