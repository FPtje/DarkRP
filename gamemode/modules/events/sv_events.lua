/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local timeLeft = 10
local stormOn = false


/*---------------------------------------------------------
 Meteor storm
 ---------------------------------------------------------*/
local function StormStart()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("meteor_approaching"))
			v:PrintMessage(HUD_PRINTTALK, DarkRP.getPhrase("meteor_approaching"))
		end
	end
end

local function StormEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("meteor_passing"))
			v:PrintMessage(HUD_PRINTTALK, DarkRP.getPhrase("meteor_passing"))
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
		GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("meteor_enabled"))
	else
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/enablestorm"))
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
		GAMEMODE:Notify(ply, 0, 4, DarkRP.getPhrase("meteor_disabled"))
	else
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/disablestorm"))
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
			GAMEMODE:NotifyAll(0, 3, DarkRP.getPhrase("earthtremor_report", tostring(mag)))
			return
		end
		GAMEMODE:NotifyAll(0, 3, DarkRP.getPhrase("earthquake_report", tostring(mag)))
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
