resource.AddFile("sound/earthquake.mp3")
util.PrecacheSound("earthquake.mp3")

--[[---------------------------------------------------------
Variables
---------------------------------------------------------]]
local timeLeft = 10
local stormOn = false


--[[---------------------------------------------------------
Meteor storm
---------------------------------------------------------]]
local function StormStart()
    local phrase = DarkRP.getPhrase("meteor_approaching")
    for _, v in ipairs(player.GetAll()) do
        if v:Alive() then
            v:PrintMessage(HUD_PRINTCENTER, phrase)
            v:PrintMessage(HUD_PRINTTALK, phrase)
        end
    end
end

local function StormEnd()
    local phrase = DarkRP.getPhrase("meteor_passing")
    for _, v in ipairs(player.GetAll()) do
        if v:Alive() then
            v:PrintMessage(HUD_PRINTCENTER, phrase)
            v:PrintMessage(HUD_PRINTTALK, phrase)
        end
    end
end

local function ControlStorm()
    timeLeft = timeLeft - 1

    if timeLeft < 1 then
        if stormOn then
            timeLeft = math.random(300, 500)
            stormOn = false
            timer.Stop("start")
            StormEnd()
        else
            timeLeft = math.random(60, 90)
            stormOn = true
            timer.Start("start")
            StormStart()
        end
    end
end

local function AttackEnt(ent)
    local meteor = ents.Create("meteor")
    meteor.nodupe = true
    meteor:Spawn()
    meteor:SetMeteorTarget(ent)
end

local function StartShower()
    timer.Adjust("start", math.random(0.1, 1), 0, StartShower)
    for _, v in ipairs(player.GetAll()) do
        if math.random(0, 2) == 0 and v:Alive() then
            AttackEnt(v)
        end
    end
end

local function StartStorm(ply)
    timer.Start("stormControl")
    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("meteor_enabled"))
end
DarkRP.definePrivilegedChatCommand("enablestorm", "DarkRP_AdminCommands", StartStorm)

local function StopStorm(ply)
    timer.Stop("stormControl")
    stormOn = false
    timer.Stop("start")
    StormEnd()
    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("meteor_disabled"))
end
DarkRP.definePrivilegedChatCommand("disablestorm", "DarkRP_AdminCommands", StopStorm)

timer.Create("start", 1, 0, StartShower)
timer.Create("stormControl", 1, 0, ControlStorm)

timer.Stop("start")
timer.Stop("stormControl")

--[[---------------------------------------------------------
Earthquake
---------------------------------------------------------]]
local lastmagnitudes = {} -- The magnitudes of the last tremors
local tremor

local function createTremor()
    tremor = ents.Create("env_physexplosion")
    tremor:SetPos(Vector(0, 0, 0))
    tremor:SetKeyValue("radius", 9999999999)
    tremor:SetKeyValue("spawnflags", 7)
    tremor.nodupe = true
    tremor:Spawn()
end

hook.Add("PostCleanupMap", "DarkRP_events", createTremor)

hook.Add("InitPostEntity", "DarkRP_SetupTremor", function()
    createTremor()
end)

local function TremorReport()
    local mag = table.remove(lastmagnitudes, 1)
    if mag then
        if mag < 6.5 then
            DarkRP.notifyAll(0, 3, DarkRP.getPhrase("earthtremor_report", tostring(mag)))
            return
        end
        DarkRP.notifyAll(0, 3, DarkRP.getPhrase("earthquake_report", tostring(mag)))
    end
end

local function EarthQuakeTest()
    if not GAMEMODE.Config.earthquakes then return end

    if GAMEMODE.Config.quakechance and math.random(0, GAMEMODE.Config.quakechance) < 1 then
        local en = ents.FindByClass("prop_physics")
        local plys = player.GetAll()

        local force = math.random(10, 1000)
        tremor:SetKeyValue("magnitude", force / 6)

        for _, v in ipairs(plys) do
            v:EmitSound("earthquake.mp3", force / 6, 100)
        end
        tremor:Fire("explode","",0.5)
        util.ScreenShake(Vector(0, 0, 0), force, math.random(25, 50), math.random(5, 12), 9999999999)
        table.insert(lastmagnitudes, math.floor((force / 10) + .5) / 10)
        timer.Simple(10, function() TremorReport() end)
        for _, e in ipairs(en) do
            local rand = math.random(650, 1000)
            if rand < force and rand % 2 == 0 then
                e:Fire("enablemotion", "", 0)
                constraint.RemoveAll(e)
            end
            if e:IsOnGround() then
                e:TakeDamage((force / 100) + 15, game.GetWorld())
            end
        end
    end
end
timer.Create("EarthquakeTest", 1, 0, EarthQuakeTest)

--[[---------------------------------------------------------
 Flammable
---------------------------------------------------------]]
-- Class names as index
local flammablePropsKV = {
    drug = true,
    drug_lab = true,
    food = true,
    gunlab = true,
    letter = true,
    microwave = true,
    money_printer = true,
    spawned_shipment = true,
    spawned_weapon = true,
    spawned_money = true
}

local flammableProps = {} -- Numbers as index
for k in pairs(flammablePropsKV) do table.insert(flammableProps, k) end


local function IsFlammable(ent)
    return flammablePropsKV[ent:GetClass()] ~= nil
end

-- FireSpread from SeriousRP
local function FireSpread(ent, chanceDiv)
    if not ent:IsOnFire() then return end

    if ent:isMoneyBag() then
        ent:Remove()
    end

    local rand = math.random(0, 300 / chanceDiv)

    if rand > 1 then return end
    local en = ents.FindInSphere(ent:GetPos(), math.random(20, 90))

    for _, v in ipairs(en) do
        if not IsFlammable(v) or v == ent then continue end

        if not v.burned then
            v:Ignite(math.random(5,180), 0)
            v.burned = true
            break -- Don't ignite all entities in sphere at once, just one at a time
        end

        local color = v:GetColor()
        if (color.r - 51) >= 0 then color.r = color.r - 51 end
        if (color.g - 51) >= 0 then color.g = color.g - 51 end
        if (color.b - 51) >= 0 then color.b = color.b - 51 end
        v:SetColor(color)
        if (color.r + color.g + color.b) < 103 and math.random(1, 100) < 35 then
            v:Fire("enablemotion", "", 0)
            constraint.RemoveAll(v)
        end
    end
end

local function FlammablePropThink()
    local class = flammableProps[math.random(#flammableProps)]
    local entities = ents.FindByClass(class)
    local ent = entities[math.random(#entities)]

    if class ~= "letter" then return end

    if not ent then return end

     -- The amount of classes and the amount of entities in a class
     -- affect the chance of fire spreading. This should be minimized.
    FireSpread(ent, #entities * #flammableProps)
end
timer.Create("FlammableProps", 0.1, 0, FlammablePropThink)
