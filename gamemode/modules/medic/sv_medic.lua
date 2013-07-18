local function BuyHealth(ply)
	local cost = GAMEMODE.Config.healthcost
	if not tobool(GAMEMODE.Config.enablebuyhealth) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/buyhealth", ""))
		return ""
	end
	if not ply:Alive() then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyhealth", ""))
		return ""
	end
	if not ply:canAfford(cost) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", "/buyhealth"))

		return ""
	end
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].medic then
		local foundMedics = false
		for k,v in pairs(RPExtraTeams) do
			if v.medic and team.NumPlayers(k) > 0 then
				foundMedics = true
				break
			end
		end
		if foundMedics then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyhealth", ""))
			return ""
		end
	end
	if ply.StartHealth and ply:Health() >= ply.StartHealth then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyhealth", ""))
		return ""
	end
	ply.StartHealth = ply.StartHealth or 100
	ply:AddMoney(-cost)
	DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", "health", GAMEMODE.Config.currency, cost))
	ply:SetHealth(ply.StartHealth)
	return ""
end
DarkRP.defineChatCommand("buyhealth", BuyHealth)
