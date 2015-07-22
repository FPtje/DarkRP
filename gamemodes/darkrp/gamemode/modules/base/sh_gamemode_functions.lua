function GM:UpdatePlayerSpeed(ply)
	if ply:isArrested() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
	elseif ply:isCP() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeedcp)
	else
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed)
	end
end

function GM:StartCommand(ply, usrcmd)
	-- Used in arrest_stick and unarrest_stick but addons can use it too!
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and isfunction(wep.startDarkRPCommand) then
		wep:startDarkRPCommand(usrcmd)
	end
end

function GM:OnPlayerChangedTeam(ply, oldTeam, newTeam)
	if RPExtraTeams[newTeam] and RPExtraTeams[newTeam].OnPlayerChangedTeam then
		RPExtraTeams[newTeam].OnPlayerChangedTeam(ply, oldTeam, newTeam)
	end

	if CLIENT then return end

	local agenda = ply:getAgendaTable()

	-- Remove agenda text when last manager left
	if agenda and agenda.ManagersByKey[oldTeam] then
		local found = false
		for man, _ in pairs(agenda.ManagersByKey) do
			if team.NumPlayers(man) > 0 then found = true break end
		end
		if not found then agenda.text = nil end
	end

	ply:setSelfDarkRPVar("agenda", agenda and agenda.text or nil)
end
