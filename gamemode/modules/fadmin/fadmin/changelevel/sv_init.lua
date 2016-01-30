util.AddNetworkString("FAdmin_ChangelevelInfo")

local function ChangeLevel(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "changelevel") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local map = args[2] or args[1] -- Changelevel gamemode map OR changelevel map
    local GameMode = args[2] and args[1]

    if GameMode then
        RunConsoleCommand("gamemode", GameMode)
    end

    RunConsoleCommand("changelevel", map)

    return true, map, GameMode
end

local mapPatterns = {}
local ignorePatterns = {
    "^background", "^ep1_background","^ep2_background", "^test_", "^styleguide", "^devtest", "^vst_",

    -- Useless or duplicate maps
    "d3_c17_02_camera.bsp", "ep1_citadel_00_demo.bsp", "credits.bsp", "intro.bsp", "sdk_shader_samples.bsp",
    "d2_coast_02.bsp", "c4a1y.bsp" -- These do not load
}
hook.Add("PlayerInitialSpawn", "FAdmin_ChangelevelInfo", function(ply)
    local rawMapList = file.Find("maps/*.bsp", "GAME")
    local mapList = {}
    for _,map in pairs(rawMapList) do
        for _,ignorePattern in pairs(ignorePatterns) do
            if string.find(map, ignorePattern) then
                goto mapContinue
            end
        end
        local category = "Other"
        local name = string.gsub(map, "%.bsp$", "")
        local lowername = string.lower(name)
        if mapPatterns[name] then
            category = mapPatterns[name]
        else
            for pattern,cat in pairs(mapPatterns) do
                if (string.StartWith(pattern, "^") or string.EndsWith(pattern, "_") or string.EndsWith(pattern, "-")) and string.find(lowername, pattern) then
                    category = cat
                end
            end
        end
        if category == "Counter-Strike" then
            if file.Exists("maps/" .. map, "csgo") then
                if file.Exists("maps/" .. map, "cstrike") then
                    local cat = "CS: Global Offensive"
                    mapList[cat] = mapList[cat] or {}
                    table.insert(mapList[cat], name)
                else
                    category = "CS: Global Offensive"
                end
            end
        end
        mapList[category] = mapList[category] or {}
        table.insert(mapList[category], name)
        ::mapContinue::
    end
    local gamemodeList = engine.GetGamemodes()
    net.Start("FAdmin_ChangelevelInfo")
        net.WriteUInt(table.Count(mapList), 16) -- 65536 should be enough
        for cat,maps in pairs(mapList) do
            net.WriteString(cat)
            net.WriteUInt(#maps, 16)
            for _,map in pairs(maps) do
                net.WriteString(map)
            end
        end
        net.WriteUInt(#gamemodeList, 16)
        for _,gmInfo in pairs(gamemodeList) do
            net.WriteString(gmInfo.name)
            net.WriteString(gmInfo.title)
        end
    net.Send(ply)
end)

FAdmin.StartHooks["ChangeLevel"] = function()
    FAdmin.Commands.AddCommand("changelevel", ChangeLevel)

    FAdmin.Access.AddPrivilege("changelevel", 2)

    mapPatterns = {}

    mapPatterns["^aoc_"] = "Age of Chivalry"
    mapPatterns["^asi-"] = "Alien Swarm"

    mapPatterns["lobby"] = "Alien Swarm"

    mapPatterns["^ar_"] = "Counter-Strike"
    mapPatterns["^cs_"] = "Counter-Strike"
    mapPatterns["^de_"] = "Counter-Strike"
    mapPatterns["^es_"] = "Counter-Strike"
    mapPatterns["^fy_"] = "Counter-Strike"
    mapPatterns["training1"] = "Counter-Strike"

    mapPatterns["^dod_"] = "Day Of Defeat"

    mapPatterns["cp_pacentro"] = "Dino D-Day"
    mapPatterns["cp_snowypark"] = "Dino D-Day"
    mapPatterns["cp_troina"] = "Dino D-Day"
    mapPatterns["dm_canyon"] = "Dino D-Day"
    mapPatterns["dm_depot"] = "Dino D-Day"
    mapPatterns["dm_fortress_trex"] = "Dino D-Day"
    mapPatterns["dm_gela_trex"] = "Dino D-Day"
    mapPatterns["dm_hilltop"] = "Dino D-Day"
    mapPatterns["dm_market"] = "Dino D-Day"
    mapPatterns["dm_pacentro"] = "Dino D-Day"
    mapPatterns["dm_snowypark"] = "Dino D-Day"
    mapPatterns["dm_troina"] = "Dino D-Day"
    mapPatterns["koth_hilltop"] = "Dino D-Day"
    mapPatterns["koth_market"] = "Dino D-Day"
    mapPatterns["koth_pacentro"] = "Dino D-Day"
    mapPatterns["koth_snowypark"] = "Dino D-Day"
    mapPatterns["obj_canyon"] = "Dino D-Day"
    mapPatterns["obj_depot"] = "Dino D-Day"
    mapPatterns["obj_fortress"] = "Dino D-Day"

    mapPatterns["de_dam"] = "DIPRIP"
    mapPatterns["dm_city"] = "DIPRIP"
    mapPatterns["dm_refinery"] = "DIPRIP"
    mapPatterns["dm_supermarket"] = "DIPRIP"
    mapPatterns["dm_village"] = "DIPRIP"
    mapPatterns["^ur_"] = "DIPRIP"

    mapPatterns["^dys_"] = "Dystopia"
    mapPatterns["^pb_"] = "Dystopia"

    mapPatterns["credits"] = "Half-Life 2"
    mapPatterns["^d1_"] = "Half-Life 2"
    mapPatterns["^d2_"] = "Half-Life 2"
    mapPatterns["^d3_"] = "Half-Life 2"
    mapPatterns["intro"] = "Half-Life 2"

    mapPatterns["^dm_"] = "Half-Life 2: Deathmatch"
    mapPatterns["halls3"] = "Half-Life 2: Deathmatch"

    mapPatterns["^ep1_"] = "Half-Life 2: Episode 1"
    mapPatterns["^ep2_"] = "Half-Life 2: Episode 2"
    mapPatterns["^ep3_"] = "Half-Life 2: Episode 3"

    mapPatterns["d2_lostcoast"] = "Half-Life 2: Lost Coast"
    --mapPatterns["vst_lostcoast"] = "Half-Life 2: Lost Coast"

    mapPatterns["^c0a"] = "Half-Life: Source"
    mapPatterns["^c1a"] = "Half-Life: Source"
    mapPatterns["^c2a"] = "Half-Life: Source"
    mapPatterns["^c3a"] = "Half-Life: Source"
    mapPatterns["^c4a"] = "Half-Life: Source"
    mapPatterns["^c5a"] = "Half-Life: Source"
    mapPatterns["^t0a"] = "Half-Life: Source"

    mapPatterns["boot_camp"] = "Half-Life Deathmatch: Source"
    mapPatterns["bounce"] = "Half-Life Deathmatch: Source"
    mapPatterns["crossfire"] = "Half-Life Deathmatch: Source"
    mapPatterns["datacore"] = "Half-Life Deathmatch: Source"
    mapPatterns["frenzy"] = "Half-Life Deathmatch: Source"
    mapPatterns["lambda_bunker"] = "Half-Life Deathmatch: Source"
    mapPatterns["rapidcore"] = "Half-Life Deathmatch: Source"
    mapPatterns["snarkpit"] = "Half-Life Deathmatch: Source"
    mapPatterns["stalkyard"] = "Half-Life Deathmatch: Source"
    mapPatterns["subtransit"] = "Half-Life Deathmatch: Source"
    mapPatterns["undertow"] = "Half-Life Deathmatch: Source"

    mapPatterns["^ins_"] = "Insurgency"

    mapPatterns["^l4d"] = "Left 4 Dead"

    mapPatterns["^c1m"] = "Left 4 Dead 2"
    mapPatterns["^c2m"] = "Left 4 Dead 2"
    mapPatterns["^c3m"] = "Left 4 Dead 2"
    mapPatterns["^c4m"] = "Left 4 Dead 2"
    mapPatterns["^c5m"] = "Left 4 Dead 2"
    mapPatterns["^c6m"] = "Left 4 Dead 2" -- DLCs
    mapPatterns["^c7m"] = "Left 4 Dead 2"
    mapPatterns["^c8m"] = "Left 4 Dead 2"
    mapPatterns["^c9m"] = "Left 4 Dead 2"
    mapPatterns["^c10m"] = "Left 4 Dead 2"
    mapPatterns["^c11m"] = "Left 4 Dead 2"
    mapPatterns["^c12m"] = "Left 4 Dead 2"
    mapPatterns["^c13m"] = "Left 4 Dead 2"
    mapPatterns["curling_stadium"] = "Left 4 Dead 2"
    mapPatterns["tutorial_standards"] = "Left 4 Dead 2"
    mapPatterns["tutorial_standards_vs"] = "Left 4 Dead 2"

    mapPatterns["clocktower"] = "Nuclear Dawn"
    mapPatterns["coast"] = "Nuclear Dawn"
    mapPatterns["downtown"] = "Nuclear Dawn"
    mapPatterns["gate"] = "Nuclear Dawn"
    mapPatterns["hydro"] = "Nuclear Dawn"
    mapPatterns["metro"] = "Nuclear Dawn"
    mapPatterns["metro_training"] = "Nuclear Dawn"
    mapPatterns["oasis"] = "Nuclear Dawn"
    mapPatterns["oilfield"] = "Nuclear Dawn"
    mapPatterns["silo"] = "Nuclear Dawn"
    mapPatterns["sk_metro"] = "Nuclear Dawn"
    mapPatterns["training"] = "Nuclear Dawn"

    mapPatterns["^bt_"] = "Pirates, Vikings, & Knights II"
    mapPatterns["^lts_"] = "Pirates, Vikings, & Knights II"
    mapPatterns["^te_"] = "Pirates, Vikings, & Knights II"
    mapPatterns["^tw_"] = "Pirates, Vikings, & Knights II"

    mapPatterns["^escape_"] = "Portal"
    mapPatterns["^testchmb_"] = "Portal"

    mapPatterns["e1912"] = "Portal 2"
    mapPatterns["^mp_coop_"] = "Portal 2"
    mapPatterns["^sp_a"] = "Portal 2"

    mapPatterns["^arena_"] = "Team Fortress 2"
    mapPatterns["^cp_"] = "Team Fortress 2"
    mapPatterns["^ctf_"] = "Team Fortress 2"
    mapPatterns["itemtest"] = "Team Fortress 2"
    mapPatterns["^koth_"] = "Team Fortress 2"
    mapPatterns["^mvm_"] = "Team Fortress 2"
    mapPatterns["^pl_"] = "Team Fortress 2"
    mapPatterns["^plr_"] = "Team Fortress 2"
    mapPatterns["^sd_"] = "Team Fortress 2"
    mapPatterns["^tc_"] = "Team Fortress 2"
    mapPatterns["^tr_"] = "Team Fortress 2"
    mapPatterns["^rd_"] = "Team Fortress 2"

    mapPatterns["^zpa_"] = "Zombie Panic! Source"
    mapPatterns["^zpl_"] = "Zombie Panic! Source"
    mapPatterns["^zpo_"] = "Zombie Panic! Source"
    mapPatterns["^zps_"] = "Zombie Panic! Source"

    mapPatterns["^achievement_"] = "Achievement"
    mapPatterns["^cinema_"] = "Cinema"
    mapPatterns["^theater_"] = "Cinema"
    mapPatterns["^xc_"] = "Climb"
    mapPatterns["^deathrun_"] = "Deathrun"
    mapPatterns["^dr_"] = "Deathrun"
    mapPatterns["^gmt_"] = "GMod Tower"
    mapPatterns["^jb_"] = "Jailbreak"
    mapPatterns["^ba_jail_"] = "Jailbreak"
    mapPatterns["^mg_"] = "Minigames"
    mapPatterns["^phys_"] = "Physics Maps"
    mapPatterns["^pw_"] = "Pirate Ship Wars"
    mapPatterns["^ph_"] = "Prop Hunt"
    mapPatterns["^rp_"] = "Roleplay"
    mapPatterns["^sb_"] = "Spacebuild"
    mapPatterns["^slender_"] = "Stop it Slender"
    mapPatterns["^gms_"] = "Stranded"
    mapPatterns["^surf_"] = "Surf"
    mapPatterns["^ts_"] = "The Stalker"
    mapPatterns["^zm_"] = "Zombie Survival"
    mapPatterns["^zombiesurvival_"] = "Zombie Survival"
    mapPatterns["^zs_"] = "Zombie Survival"

    local gamemodeList = engine.GetGamemodes()

    for _,gm in pairs(gamemodeList) do
        if gm.maps == "" then continue end

        local name = gm.title or "Unnammed Gamemode"
        local maps = string.Split(gm.maps, "|")

        if maps then
            for _,pattern in pairs(maps) do
                mapPatterns[pattern] = name
            end
        end
    end
end
