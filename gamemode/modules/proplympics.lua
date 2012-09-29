--[[
This is the "main" file of the proplympics
]]

local function main(ply)
	if GetConVarNumber("proplympics") == 0 then GAMEMODE:Notify(ply, 1, 4, "Proplympics is disabled!") return "" end
	if ply:Team() ~= TEAM_MAYOR then GAMEMODE:Notify(ply, 1, 4, "You have to be mayor") return "" end

	local setup = ents.Create("ctrl_racemanager")
	setup:SetPlayer(ply)
	setup:Spawn()
	setup:Activate()
	return ""
end
concommand.Add("proplympics", main)
AddChatCommand("/proplympics", main)

local function cancelRace(ply)
	if not ply:IsAdmin() and ply:Team() ~= TEAM_MAYOR then
		GAMEMODE:Notify(ply, 1, 4, "You have to be admin or mayor")
		return
	end

	for k,v in pairs(ents.FindByClass("ctrl_racegame")) do
		v:Remove()
	end

	for k,v in pairs(ents.FindByClass("ctrl_racemanager")) do
		v:Remove()
	end

	GAMEMODE:NotifyAll(1, 4, ply:Nick() .. " Canceled the proplympics")
end
concommand.Add("cancelproplympics", main)
AddChatCommand("/cancelproplympics", cancelRace)
