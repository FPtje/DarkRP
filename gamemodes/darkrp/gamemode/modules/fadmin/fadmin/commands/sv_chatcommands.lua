local prefix = "/"
hook.Add("PlayerSay", "FAdminChatCommands", function(ply, text, Team, dead)
	if string.sub(text, 1, 1) == prefix then
		local TExplode = string.Explode(" ", string.sub(text, 2))
		if not TExplode then return end

		for k,v in pairs(TExplode) do
			if string.sub(v, -1) == "," and TExplode[k+1] then
				TExplode[k] = (TExplode[k] or "") .. (TExplode[k+1] or "")
				table.remove(TExplode, k+1)
			end
		end
		table.ClearKeys(TExplode, false)

		local Command = string.lower(TExplode[1])
		local Args = table.Copy(TExplode)
		Args[1] = nil
		Args = table.ClearKeys(Args)
		if FAdmin.Commands.List[Command] then
			FAdmin.Commands.List[Command].callback(ply, Command, Args)
			return ""
		end
	end
end)