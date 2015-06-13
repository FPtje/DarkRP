function GM:PlayerNoClip(ply)
	-- Default action for noclip is to disallow it
	return false
end

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
