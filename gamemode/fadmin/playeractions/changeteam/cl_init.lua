FAdmin.StartHooks["zzSetTeam"] = function()
	FAdmin.Access.AddPrivilege("SetTeam", 2)
	FAdmin.Commands.AddCommand("SetTeam", nil, "<Player>", "<Team>")
	
	FAdmin.ScoreBoard.Player:AddActionButton("Set team", "FAdmin/icons/changeteam", Color(0, 200, 0, 255), 
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetTeam", ply) end, function(ply, button)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Teams:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		
		menu:AddPanel(Title)
		for k,v in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
			menu:AddOption(v.Name, function() RunConsoleCommand("_FAdmin", "setteam", ply:UserID(), k) end)
		end
		menu:Open()
	end)
end