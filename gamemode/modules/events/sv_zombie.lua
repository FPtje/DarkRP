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
			DarkRP.RetrieveZombies(function()
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
	ply:SetSelfDarkRPVar("numPoints", table.getn(zombieSpawns))

	for k, v in pairs(zombieSpawns) do
		ply:SetSelfDarkRPVar("zPoints" .. k, v)
	end
end

local function ReMoveZombie(ply, index)
	if ply:HasPriv("rp_commands") then
		if not index or zombieSpawns[tonumber(index)] == nil then
			GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("zombie_spawn_not_exist", tostring(index)))
		else
			DarkRP.RetrieveZombies(function()
				GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("zombie_spawn_removed"))
				table.remove(zombieSpawns, index)
				DarkRP.StoreZombies()
				if ply:getDarkRPVar("zombieToggle") then
					LoadTable(ply)
				end
			end)
		end
	else
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/removezombie"))
	end
	return ""
end
AddChatCommand("/removezombie", ReMoveZombie)

local function AddZombie(ply)
	if ply:HasPriv("rp_commands") then
		DarkRP.RetrieveZombies(function()
			table.insert(zombieSpawns, ply:GetPos())
			DarkRP.StoreZombies()
			if ply:getDarkRPVar("zombieToggle") then LoadTable(ply) end
			GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("zombie_spawn_added"))
		end)
	else
		GAMEMODE:Notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/addzombie"))
	end
	return ""
end
AddChatCommand("/addzombie", AddZombie)

local function ToggleZombie(ply)
	if ply:HasPriv("rp_commands") then
		if not ply:getDarkRPVar("zombieToggle") then
			DarkRP.RetrieveZombies(function()
				ply:SetSelfDarkRPVar("zombieToggle", true)
				LoadTable(ply)
				GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("zombie_toggled"))
			end)
		else
			ply:SetSelfDarkRPVar("zombieToggle", false)
			GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("zombie_toggled"))
		end
	else
		GAMEMODE:Notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/showzombie"))
	end
	return ""
end
AddChatCommand("/showzombie", ToggleZombie)

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
	Zombie:SetPos(DarkRP.RetrieveRandomZombieSpawnPos())
end

local function ZombieMax(ply, args)
	if ply:HasPriv("rp_commands") then
		if not tonumber(args) then
			GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
		maxZombie = tonumber(args)
		GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("zombie_maxset", args))
	end

	return ""
end
AddChatCommand("/zombiemax", ZombieMax)
AddChatCommand("/maxzombie", ZombieMax)
AddChatCommand("/maxzombies", ZombieMax)

local function StartZombie(ply)
	if ply:HasPriv("rp_commands") then
		timer.Start("zombieControl")
		GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("zombie_enabled"))
	else
		GAMEMODE:Notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/enablezombie"))
	end
	return ""
end
AddChatCommand("/enablezombie", StartZombie)

local function StopZombie(ply)
	if ply:HasPriv("rp_commands") then
		timer.Stop("zombieControl")
		zombieOn = false
		timer.Stop("start2")
		ZombieEnd()
		GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("zombie_disabled"))
	else
		GAMEMODE:Notify(ply, 1, 6, DarkRP.getPhrase("need_admin", "/disablezombie"))
	end
	return ""
end
AddChatCommand("/disablezombie", StopZombie)

timer.Create("start2", 1, 0, SpawnZombie)
timer.Create("zombieControl", 1, 0, ControlZombie)
timer.Stop("start2")
timer.Stop("zombieControl")

/*---------------------------------------------------------------------------
Loading and saving data
---------------------------------------------------------------------------*/
local function createZombiePos()
	if not zombie_spawn_positions then return end
	local map = string.lower(game.GetMap())

	MySQLite.begin()
		for k, v in pairs(zombie_spawn_positions) do
			if map == string.lower(v[1]) then
				MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", \"Z\", " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ");")
			end
		end
	MySQLite.commit()
end

local function loadData()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))

	MySQLite.query([[SELECT * FROM darkrp_position WHERE type = 'Z' AND map = ]] .. map .. [[;]], function(data)
		for k,v in pairs(data or {}) do
			table.insert(zombieSpawns, v)
		end

		if table.Count(zombieSpawns) == 0 then
			createZombiePos()
			return
		end

		jail_positions = nil
	end)
end
hook.Add("DarkRPDBInitialized", "ZombieData", loadData)

function DarkRP.StoreZombies()
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
function DarkRP.RetrieveZombies(callback)
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

function DarkRP.RetrieveRandomZombieSpawnPos()
	if #zombieSpawns < 1 then return end
	local r = table.Random(zombieSpawns)

	local pos = GAMEMODE:FindEmptyPos(r, nil, 200, 10, Vector(2, 2, 2))

	return pos
end
