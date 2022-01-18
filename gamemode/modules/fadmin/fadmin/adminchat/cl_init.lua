
net.Receive("FAdmin_ReceiveAdminMessage", function(len)
    local FromPly = net.ReadEntity()
    local Text = net.ReadString()
    local Team = FromPly:IsPlayer() and FromPly:Team() or 1
    local Nick = FromPly:IsPlayer() and FromPly:Nick() or "Console"
    local prefix = (FAdmin.Access.PlayerHasPrivilege(FromPly, "AdminChat") or FromPly:IsAdmin()) and "[Admin Chat] " or "[To admins] "

    chat.AddNonParsedText(Color(255, 0, 0, 255), prefix, team.GetColor(Team), Nick .. ": ", color_white, Text)
end)

FAdmin.StartHooks["Chatting"] = function()
    FAdmin.Commands.AddCommand("adminhelp", nil, "<text>")
    FAdmin.Commands.AddCommand("//", nil, "<text>")

    FAdmin.Access.AddPrivilege("AdminChat", 2)
end
