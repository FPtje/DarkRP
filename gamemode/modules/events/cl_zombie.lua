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
			draw.DrawNonParsedText(DarkRP.getPhrase("zombie_spawn") .. " (" .. x .. ")", "DarkRPHUD2", zPoint.x, zPoint.y - 20, Color(255, 255, 255, 200), 1)
			draw.DrawNonParsedText(DarkRP.getPhrase("zombie_spawn") .. " (" .. x .. ")", "DarkRPHUD2", zPoint.x + 1, zPoint.y - 21, Color(255, 0, 0, 255), 1)
		end
	end
end
hook.Add("HUDPaint", "DrawZombieInfo", DrawZombieInfo)
