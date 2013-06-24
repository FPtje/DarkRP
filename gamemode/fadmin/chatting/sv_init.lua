local function ToAdmins(ply, cmd, args)
	if not args[1] then return end

	local text = table.concat(args, " ")
	local RP = RecipientFilter()

	RP:AddPlayer(ply)
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			RP:AddPlayer(v)
		end
	end

	umsg.Start("FAdmin_ReceiveAdminMessage", RP)
		umsg.Entity(ply)
		umsg.String(text)
	umsg.End()
end

FAdmin.StartHooks["Chatting"] = function()
	FAdmin.Commands.AddCommand("adminhelp", ToAdmins)
	FAdmin.Commands.AddCommand("//", ToAdmins)
end
