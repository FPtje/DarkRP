local HELP_CATEGORY_ZOMBIE = 3

GM:AddHelpCategory(HELP_CATEGORY_ZOMBIE, "Zombie Chat Commands")

GM:AddHelpLabel(HELP_CATEGORY_ZOMBIE, "/addzombie (creates a zombie spawn)")
GM:AddHelpLabel(HELP_CATEGORY_ZOMBIE, "/zombiemax (maximum amount of zombies that can be alive)")
GM:AddHelpLabel(HELP_CATEGORY_ZOMBIE, "/removezombie index (removes a zombie spawn, index is the number inside ()")
GM:AddHelpLabel(HELP_CATEGORY_ZOMBIE, "/showzombie (shows where the zombie spawns are)")
GM:AddHelpLabel(HELP_CATEGORY_ZOMBIE, "/enablezombie (enables zombiemode)")
GM:AddHelpLabel(HELP_CATEGORY_ZOMBIE, "/disablezombie (disables zombiemode)")
GM:AddHelpLabel(HELP_CATEGORY_ZOMBIE, "/enablestorm (enables meteor storms)")


/*---------------------------------------------------------------------------
Zombie display
---------------------------------------------------------------------------*/
local function DrawZombieInfo()
	local localplayer = LocalPlayer()
	if not IsValid(localplayer) or not localplayer:getDarkRPVar("zombieToggle") then return end
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_ZombieInfo")
	if shouldDraw == false then return end

	for x=1, localplayer:getDarkRPVar("numPoints"), 1 do
		local zPoint = localplayer.DarkRPVars["zPoints".. x]
		if zPoint then
			zPoint = zPoint:ToScreen()
			draw.DrawText("Zombie Spawn (" .. x .. ")", "DarkRPHUD2", zPoint.x, zPoint.y - 20, Color(255, 255, 255, 200), 1)
			draw.DrawText("Zombie Spawn (" .. x .. ")", "DarkRPHUD2", zPoint.x + 1, zPoint.y - 21, Color(255, 0, 0, 255), 1)
		end
	end
end
hook.Add("HUDPaint", "DrawZombieInfo", DrawZombieInfo)