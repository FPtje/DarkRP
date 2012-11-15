/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local timeLeft = 10
local timeLeft2 = 10
local stormOn = false
local zombieOn = false
local maxZombie = 10

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
			DB.RetrieveZombies(function()
				ZombieStart()
			end)
		end
	end
end

ZombieStart = function()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.zombie_approaching)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.zombie_approaching)
		end
	end
end

ZombieEnd = function()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.zombie_leaving)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.zombie_leaving)
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
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.zombie_spawn_not_exist, tostring(index)))
		else
			DB.RetrieveZombies(function()
				GAMEMODE:Notify(ply, 0, 4, LANGUAGE.zombie_spawn_removed)
				table.remove(zombieSpawns, index)
				DB.StoreZombies()
				if ply.DarkRPVars.zombieToggle then
					LoadTable(ply)
				end
			end)
		end
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/removezombie"))
	end
	return ""
end
AddChatCommand("/removezombie", ReMoveZombie)

local function AddZombie(ply)
	if ply:HasPriv("rp_commands") then
		DB.RetrieveZombies(function()
			table.insert(zombieSpawns, ply:GetPos())
			DB.StoreZombies()
			if ply.DarkRPVars.zombieToggle then LoadTable(ply) end
			GAMEMODE:Notify(ply, 0, 4, LANGUAGE.zombie_spawn_added)
		end)
	else
		GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.need_admin, "/addzombie"))
	end
	return ""
end
AddChatCommand("/addzombie", AddZombie)

local function ToggleZombie(ply)
	if ply:HasPriv("rp_commands") then
		if not ply.DarkRPVars.zombieToggle then
			DB.RetrieveZombies(function()
				ply:SetSelfDarkRPVar("zombieToggle", true)
				LoadTable(ply)
			end)
		else
			ply:SetSelfDarkRPVar("zombieToggle", false)
		end
	else
		GAMEMODE:Notify(ply, 1, 6, LANGUAGE.string.format(LANGUAGE.need_admin, "/showzombie"))
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
	Zombie:SetPos(DB.RetrieveRandomZombieSpawnPos())
end

local function ZombieMax(ply, args)
	if ply:HasPriv("rp_commands") then
		if not tonumber(args) then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""))
			return ""
		end
		maxZombie = tonumber(args)
		GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.zombie_maxset, args))
	end

	return ""
end
AddChatCommand("/zombiemax", ZombieMax)
AddChatCommand("/maxzombie", ZombieMax)
AddChatCommand("/maxzombies", ZombieMax)

local function StartZombie(ply)
	if ply:HasPriv("rp_commands") then
		timer.Start("zombieControl")
		GAMEMODE:Notify(ply, 0, 4, LANGUAGE.zombie_enabled)
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
		GAMEMODE:Notify(ply, 0, 4, LANGUAGE.zombie_disabled)
	end
	return ""
end
AddChatCommand("/disablezombie", StopZombie)

timer.Create("start2", 1, 0, SpawnZombie)
timer.Create("zombieControl", 1, 0, ControlZombie)
timer.Stop("start2")
timer.Stop("zombieControl")

/*---------------------------------------------------------
 Meteor storm
 ---------------------------------------------------------*/
local function StormStart()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.meteor_approaching)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.meteor_approaching)
		end
	end
end

local function StormEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, LANGUAGE.meteor_passing)
			v:PrintMessage(HUD_PRINTTALK, LANGUAGE.meteor_passing)
		end
	end
end

local function ControlStorm()
	timeLeft = timeLeft - 1

	if timeLeft < 1 then
		if stormOn then
			timeLeft = math.random(300,500)
			stormOn = false
			timer.Stop("start")
			StormEnd()
		else
			timeLeft = math.random(60,90)
			stormOn = true
			timer.Start("start")
			StormStart()
		end
	end
end

local function AttackEnt(ent)
	meteor = ents.Create("meteor")
	meteor.nodupe = true
	meteor:Spawn()
	meteor:SetMeteorTarget(ent)
end

local function StartShower()
	timer.Adjust("start", math.random(.1,1), 0, StartShower)
	for k, v in pairs(player.GetAll()) do
		if math.random(0, 2) == 0 and v:Alive() then
			AttackEnt(v)
		end
	end
end

local function StartStorm(ply)
	if ply:HasPriv("rp_commands") then
		timer.Start("stormControl")
		GAMEMODE:Notify(ply, 0, 4, LANGUAGE.meteor_enabled)
	end
	return ""
end
AddChatCommand("/enablestorm", StartStorm)

local function StopStorm(ply)
	if ply:HasPriv("rp_commands") then
		timer.Stop("stormControl")
		stormOn = false
		timer.Stop("start")
		StormEnd()
		GAMEMODE:Notify(ply, 0, 4, LANGUAGE.meteor_disabled)
	end
	return ""
end
AddChatCommand("/disablestorm", StopStorm)

timer.Create("start", 1, 0, StartShower)
timer.Create("stormControl", 1, 0, ControlStorm)

timer.Stop("start")
timer.Stop("stormControl")

/*---------------------------------------------------------
 Earthquake
 ---------------------------------------------------------*/
local lastmagnitudes = {} -- The magnitudes of the last tremors

local tremor = ents.Create("env_physexplosion")
tremor:SetPos(Vector(0,0,0))
tremor:SetKeyValue("radius",9999999999)
tremor:SetKeyValue("spawnflags", 7)
tremor.nodupe = true
tremor:Spawn()

local function TremorReport(mag)
	local mag = table.remove(lastmagnitudes, 1)
	if mag then
		if mag < 6.5 then
			GAMEMODE:NotifyAll(0, 3, string.format(LANGUAGE.earthtremor_report, tostring(mag)))
			return
		end
		GAMEMODE:NotifyAll(0, 3, string.format(LANGUAGE.earthquake_report, tostring(mag)))
	end
end

local function EarthQuakeTest()
	if not GAMEMODE.Config.earthquakes then return end

	if GAMEMODE.Config.quakechance and math.random(0, GAMEMODE.Config.quakechance) < 1 then
		local en = ents.FindByClass("prop_physics")
		local plys = player.GetAll()

		local force = math.random(10,1000)
		tremor:SetKeyValue("magnitude",force/6)
		for k,v in pairs(plys) do
			v:EmitSound("earthquake.mp3", force/6, 100)
		end
		tremor:Fire("explode","",0.5)
		util.ScreenShake(Vector(0,0,0), force, math.random(25,50), math.random(5,12), 9999999999)
		table.insert(lastmagnitudes, math.floor((force / 10) + .5) / 10)
		timer.Simple(10, function() TremorReport(alert) end)
		for k,e in pairs(en) do
			local rand = math.random(650,1000)
			if rand < force and rand % 2 == 0 then
				e:Fire("enablemotion","",0)
				constraint.RemoveAll(e)
			end
			if e:IsOnGround() then
				e:TakeDamage((force / 100) + 15, game.GetWorld())
			end
		end
	end
end
timer.Create("EarthquakeTest", 1, 0, EarthQuakeTest)