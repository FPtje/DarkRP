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