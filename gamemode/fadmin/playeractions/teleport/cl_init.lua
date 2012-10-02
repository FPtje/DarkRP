local function EnableDisableNoclip(ply)
	return ply:GetNWBool("FADmin_CanNoclip") or 
		((FAdmin.Access.PlayerHasPrivilege(ply, "Noclip") or util.tobool(GetConVarNumber("sbox_noclip"))) 
			and not ply:GetNWBool("FADmin_DisableNoclip"))
end

FAdmin.StartHooks["zz_Teleport"] = function()
	FAdmin.Access.AddPrivilege("Teleport", 2)
	
	FAdmin.Commands.AddCommand("Teleport", nil, "[Player]")
	FAdmin.Commands.AddCommand("TP", nil, "[Player]")
	FAdmin.Commands.AddCommand("Bring", nil, "<Player>", "[Player]")
	FAdmin.Commands.AddCommand("goto", nil, "<Player>")
	
	
	FAdmin.ScoreBoard.Player:AddActionButton("Teleport", "FAdmin/icons/Teleport", Color(0, 200, 0, 255), 
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport")/* and ply == LocalPlayer()*/ end, 
	function(ply, button)
		RunConsoleCommand("_FAdmin", "Teleport", ply:UserID())
	end)
	
	FAdmin.ScoreBoard.Player:AddActionButton("Goto", "FAdmin/icons/Teleport", Color(0, 200, 0, 255), 
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport") and ply ~= LocalPlayer() end, 
	function(ply, button)
		RunConsoleCommand("_FAdmin", "goto", ply:UserID())
	end)
	
	FAdmin.ScoreBoard.Player:AddActionButton("Bring", "FAdmin/icons/Teleport", Color(0, 200, 0, 255), 
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Teleport") and ply ~= LocalPlayer() end, 
	function(ply, button)
		local menu = DermaMenu()
		
		local Title = vgui.Create("DLabel")
		Title:SetText("  Bring to:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		
		menu:AddPanel(Title)
		
		menu:AddOption("Yourself", function() RunConsoleCommand("_FAdmin", "bring", ply:UserID()) end)
		for k, v in pairs(player.GetAll()) do
			if v ~= LocalPlayer() then
				menu:AddOption(v:Nick(), function() RunConsoleCommand("_FAdmin", "bring", ply:UserID(), v:UserID()) end)
			end
		end
		menu:Open()
	end)
end