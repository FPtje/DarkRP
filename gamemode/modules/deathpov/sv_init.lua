hook.Add("PlayerDeath", "DeathPOV", function(ply)
	if GAMEMODE.Config.deathpov then
		SendUserMessage("DeathPOV", ply, true)
	end
end)