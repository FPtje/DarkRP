util.AddNetworkString("FAdmin_ChangelevelInfo")

local function ChangeLevel(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "changelevel") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local map = args[2] or args[1] -- Changelevel gamemode map OR changelevel map
    local gameMode = args[2] and args[1]

    if gameMode then
        RunConsoleCommand("gamemode", gameMode)
    end

    RunConsoleCommand("changelevel", map)

    return true, map, gameMode
end

local mapNames = {}
local mapPatterns = {}

local ignorePatterns = {
    "^asi-", "^background", "^c[%d]m", "^devtest", "^ep1_background", "^ep2_background", "^mp_coop_", "^sp_a", "^styleguide"
}

local ignoreMaps = {
    -- Prefixes
    ["ddd_"] = true,
    ["sdk_"] = true,
    ["test_"] = true,
    ["vst_"] = true,
    -- Maps
    ["c4a1y"] = true,
    ["cp_docks"] = true,
    ["cp_parkour"] = true,
    ["cp_sequence"] = true,
    ["cp_terrace"] = true,
    ["cp_test"] = true,
    ["credits"] = true,
    ["curling_stadium"] = true,
    ["d2_coast_02"] = true,
    ["d3_c17_02_camera"] = true,
    ["duel_"] = true,
    ["e1912"] = true,
    ["ep1_citadel_00_demo"] = true,
    ["ffa_community"] = true,
    ["free_"] = true,
    ["intro"] = true,
    ["lobby"] = true,
    ["practice_box"] = true,
    ["test"] = true,
    ["tut_training"] = true,
    ["tutorial_standards"] = true,
    ["tutorial_standards_vs"] = true
}

hook.Add("PlayerInitialSpawn", "FAdmin_ChangelevelInfo", function(ply)
    local mapList = {}
    local maps = file.Find("maps/*.bsp", "GAME")

    for _, v in ipairs(maps) do
        local name = string.lower(string.gsub(v, "%.bsp$", ""))
        if ignoreMaps[name] then continue end

        local prefix = string.match(name, "^(.-_)")
        if ignoreMaps[prefix] then continue end

        for _, ignore in ipairs(ignorePatterns) do
            if string.find(name, ignore) then
                goto mapContinue
            end
        end

        -- Check if the map has a simple name or prefix
        local mapCategory = mapNames[name] or mapNames[prefix]

        -- Check if the map has an embedded prefix, or is TTT/Sandbox
        if not mapCategory then
            for pattern, category in pairs(mapPatterns) do
                if string.find(name, pattern) then
                    mapCategory = category
                end
            end
        end

        -- Throw all uncategorized maps into Other
        mapCategory = mapCategory or "Other"
        -- Don't show CS:GO maps
        if mapCategory == "Counter-Strike" and not file.Exists("maps/" .. name .. ".bsp", "cstrike") then
            continue
        end

        if not mapList[mapCategory] then
            mapList[mapCategory] = {}
        end

        table.insert(mapList[mapCategory], name)
        ::mapContinue::
    end

    local gamemodeList = engine.GetGamemodes()
    net.Start("FAdmin_ChangelevelInfo")
        net.WriteUInt(table.Count(mapList), 16) -- 65536 should be enough
        for cat, mps in pairs(mapList) do
            net.WriteString(cat)
            net.WriteUInt(#mps, 16)
            for _, map in pairs(mps) do
                net.WriteString(map)
            end
        end
        net.WriteUInt(#gamemodeList, 16)
        for _, gmInfo in pairs(gamemodeList) do
            net.WriteString(gmInfo.name)
            net.WriteString(gmInfo.title)
        end
    net.Send(ply)
end)

FAdmin.StartHooks["ChangeLevel"] = function()
    FAdmin.Commands.AddCommand("changelevel", ChangeLevel)

    FAdmin.Access.AddPrivilege("changelevel", 2)

    mapNames = {}
    mapPatterns = {}

    mapNames["aoc_"] = "Age of Chivalry"

    mapNames["ar_"] = "Counter-Strike"
    mapNames["cs_"] = "Counter-Strike"
    mapNames["de_"] = "Counter-Strike"
    mapNames["es_"] = "Counter-Strike"
    mapNames["fy_"] = "Counter-Strike"
    mapNames["gd_"] = "Counter-Strike"
    mapNames["training1"] = "Counter-Strike"

    mapNames["dod_"] = "Day Of Defeat"

    mapNames["de_dam"] = "DIPRIP"
    mapNames["dm_city"] = "DIPRIP"
    mapNames["dm_refinery"] = "DIPRIP"
    mapNames["dm_supermarket"] = "DIPRIP"
    mapNames["dm_village"] = "DIPRIP"
    mapNames["ur_city"] = "DIPRIP"
    mapNames["ur_refinery"] = "DIPRIP"
    mapNames["ur_supermarket"] = "DIPRIP"
    mapNames["ur_village"] = "DIPRIP"

    mapNames["dys_"] = "Dystopia"
    mapNames["pb_dojo"] = "Dystopia"
    mapNames["pb_rooftop"] = "Dystopia"
    mapNames["pb_round"] = "Dystopia"
    mapNames["pb_urbandome"] = "Dystopia"
    mapNames["sav_dojo6"] = "Dystopia"
    mapNames["varena"] = "Dystopia"

    mapNames["d1_"] = "Half-Life 2"
    mapNames["d2_"] = "Half-Life 2"
    mapNames["d3_"] = "Half-Life 2"

    mapNames["dm_"] = "Half-Life 2: Deathmatch"
    mapNames["halls3"] = "Half-Life 2: Deathmatch"

    mapNames["ep1_"] = "Half-Life 2: Episode 1"
    mapNames["ep2_"] = "Half-Life 2: Episode 2"
    mapNames["ep3_"] = "Half-Life 2: Episode 3"

    mapNames["d2_lostcoast"] = "Half-Life 2: Lost Coast"

    mapPatterns["^c[%d]a"] = "Half-Life"
    mapPatterns["^t0a"] = "Half-Life"

    mapNames["boot_camp"] = "Half-Life Deathmatch"
    mapNames["bounce"] = "Half-Life Deathmatch"
    mapNames["crossfire"] = "Half-Life Deathmatch"
    mapNames["datacore"] = "Half-Life Deathmatch"
    mapNames["frenzy"] = "Half-Life Deathmatch"
    mapNames["lambda_bunker"] = "Half-Life Deathmatch"
    mapNames["rapidcore"] = "Half-Life Deathmatch"
    mapNames["snarkpit"] = "Half-Life Deathmatch"
    mapNames["stalkyard"] = "Half-Life Deathmatch"
    mapNames["subtransit"] = "Half-Life Deathmatch"
    mapNames["undertow"] = "Half-Life Deathmatch"

    mapNames["ins_"] = "Insurgency"

    mapNames["l4d_"] = "Left 4 Dead"

    mapNames["clocktower"] = "Nuclear Dawn"
    mapNames["coast"] = "Nuclear Dawn"
    mapNames["downtown"] = "Nuclear Dawn"
    mapNames["gate"] = "Nuclear Dawn"
    mapNames["hydro"] = "Nuclear Dawn"
    mapNames["metro"] = "Nuclear Dawn"
    mapNames["metro_training"] = "Nuclear Dawn"
    mapNames["oasis"] = "Nuclear Dawn"
    mapNames["oilfield"] = "Nuclear Dawn"
    mapNames["silo"] = "Nuclear Dawn"
    mapNames["sk_metro"] = "Nuclear Dawn"
    mapNames["training"] = "Nuclear Dawn"

    mapNames["bt_"] = "Pirates, Vikings, & Knights II"
    mapNames["lts_"] = "Pirates, Vikings, & Knights II"
    mapNames["te_"] = "Pirates, Vikings, & Knights II"
    mapNames["tw_"] = "Pirates, Vikings, & Knights II"

    mapNames["escape_"] = "Portal"
    mapNames["testchmb_"] = "Portal"

    mapNames["achievement_"] = "Team Fortress 2"
    mapNames["arena_"] = "Team Fortress 2"
    mapNames["cp_"] = "Team Fortress 2"
    mapNames["ctf_"] = "Team Fortress 2"
    mapNames["itemtest"] = "Team Fortress 2"
    mapNames["koth_"] = "Team Fortress 2"
    mapNames["mvm_"] = "Team Fortress 2"
    mapNames["pl_"] = "Team Fortress 2"
    mapNames["plr_"] = "Team Fortress 2"
    mapNames["rd_"] = "Team Fortress 2"
    mapNames["pd_"] = "Team Fortress 2"
    mapNames["sd_"] = "Team Fortress 2"
    mapNames["tc_"] = "Team Fortress 2"
    mapNames["tr_"] = "Team Fortress 2"
    mapNames["trade_"] = "Team Fortress 2"
    mapNames["pass_"] = "Team Fortress 2"

    mapNames["zpa_"] = "Zombie Panic! Source"
    mapNames["zpl_"] = "Zombie Panic! Source"
    mapNames["zpo_"] = "Zombie Panic! Source"
    mapNames["zps_"] = "Zombie Panic! Source"

    mapNames["bhop_"] = "Bunny Hop"
    mapNames["cinema_"] = "Cinema"
    mapNames["theater_"] = "Cinema"
    mapNames["xc_"] = "Climb"
    mapNames["deathrun_"] = "Deathrun"
    mapNames["dr_"] = "Deathrun"
    mapNames["fm_"] = "Flood"
    mapNames["gmt_"] = "GMod Tower"
    mapNames["gg_"] = "Gun Game"
    mapNames["scoutzknivez"] = "Gun Game"
    mapNames["ba_"] = "Jailbreak"
    mapNames["jail_"] = "Jailbreak"
    mapNames["jb_"] = "Jailbreak"
    mapNames["mg_"] = "Minigames"
    mapNames["pw_"] = "Pirate Ship Wars"
    mapNames["ph_"] = "Prop Hunt"
    mapNames["rp_"] = "Roleplay"
    mapNames["slb_"] = "Sled Build"
    mapNames["sb_"] = "Spacebuild"
    mapNames["slender_"] = "Stop it Slender"
    mapNames["gms_"] = "Stranded"
    mapNames["surf_"] = "Surf"
    mapNames["ts_"] = "The Stalker"
    mapNames["zm_"] = "Zombie Survival"
    mapNames["zombiesurvival_"] = "Zombie Survival"
    mapNames["zs_"] = "Zombie Survival"

    for _, gm in ipairs(engine.GetGamemodes()) do
        if gm.maps ~= "" then
            for _, pattern in ipairs(string.Split(gm.maps, "|")) do
                -- When in doubt, just try to match it with string.find later
                mapPatterns[string.lower(pattern)] = gm.title or "Unnammed Gamemode"
            end
        end
    end
end
