usermessage.Hook("FAdmin_ReceiveAdminMessage", function(um)
	local FromPly = um:ReadEntity()
	local Team = FromPly:IsPlayer() and FromPly:Team() or 1
	local Nick = FromPly:IsPlayer() and FromPly:Nick() or "Console"
	local Text = um:ReadString()

	chat.AddNonParsedText(Color(255,0,0,255), "[To admins] ", team.GetColor(Team), Nick..": ", Color(255, 255, 255, 255), Text)
end)

FAdmin.StartHooks["Chatting"] = function()
	FAdmin.Commands.AddCommand("adminhelp", nil, "<text>")
	FAdmin.Commands.AddCommand("//", nil, "<text>")
end
