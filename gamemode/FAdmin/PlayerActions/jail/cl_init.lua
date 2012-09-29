FAdmin.StartHooks["Jail"] = function()
	FAdmin.Access.AddPrivilege("Jail", 2)
	FAdmin.Commands.AddCommand("Jail", nil, "<Player>", "[Small/Normal/Big]", "[Time]")
	FAdmin.Commands.AddCommand("UnJail", nil, "<Player>")
	
	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Jail", function(ply) 
		LocalPlayer():ConCommand("FAdmin jail "..ply:UserID())
	end)
	
	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if ply:FAdmin_GetGlobal("fadmin_jailed") then return "Unjail" end
		return "Jail"
	end, 
	function(ply) 
		if ply:FAdmin_GetGlobal("fadmin_jailed") then return "FAdmin/icons/jail", "FAdmin/icons/disable" end
		return "FAdmin/icons/jail" 
	end,
	Color(255, 130, 0, 255), 
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Jail", ply) end, 
	function(ply, button)
		if ply:FAdmin_GetGlobal("fadmin_jailed") then RunConsoleCommand("_FAdmin", "unjail", ply:UserID()) button:SetImage2("null") button:SetText("Jail") button:GetParent():InvalidateLayout() return end
		
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jail Type:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		
		menu:AddPanel(Title)
		
		for k,v in pairs(FAdmin.PlayerActions.JailTypes) do
			if v ~= "Unjail" then
				local SubMenu = menu:AddSubMenu(v .. " jail", function() 
					RunConsoleCommand("_FAdmin", "Jail", ply:UserID(), k)
					button:SetText("Unjail") button:GetParent():InvalidateLayout() 
					button:SetImage2("FAdmin/icons/disable") end)
				
				local SubMenuTitle = vgui.Create("DLabel")
				SubMenuTitle:SetText("  "..v .. " time:\n")
				SubMenuTitle:SetFont("UiBold")
				SubMenuTitle:SizeToContents()
				SubMenuTitle:SetTextColor(color_black)
				
				SubMenu:AddPanel(SubMenuTitle)
				
				for secs,Time in SortedPairs(FAdmin.PlayerActions.JailTimes) do
					SubMenu:AddOption(Time, function() RunConsoleCommand("_FAdmin", "Jail", ply:UserID(), k, secs)
					button:SetText("Unjail")
					button:GetParent():InvalidateLayout()
					button:SetImage2("FAdmin/icons/disable") end)
				end
			end
		end
		
		menu:Open()
	end)
end