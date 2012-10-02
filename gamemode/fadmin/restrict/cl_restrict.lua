local function FillMenu(menu, func)
	for k,v in SortedPairsByMemberValue(FAdmin.Access.Groups, "ADMIN", true) do
		menu:AddOption(k, function() func(k) end)
	end
	
	RunConsoleCommand("_FAdmin_SendUserGroups")
	
	local Other = menu:AddSubMenu("Other")
	local NoOthers = Other:AddOption("Loading/no other groups")
	local function ReceiveGroup(um)
		local GroupName = um:ReadString()
		if not FAdmin.Access.Groups[GroupName] then
			Other:AddOption(GroupName, function() func(k) end)
			
			for k,v in pairs(Other.Panels) do
				if v:GetValue() == "Loading/no other groups" then Other.Panels[k] = nil v:Remove() break end
			end
		end
	end
	usermessage.Hook("FADMIN_RetrieveGroup", ReceiveGroup)
end

local function RestrictWeaponMenu()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Restrict weapons")
	frame:SetSize(ScrW() / 2, ScrH() - 50) 
	frame:Center()
	frame:SetVisible(true)
	frame:MakePopup()
	
	local WeaponMenu = vgui.Create("FAdmin_weaponPanel", frame)
	WeaponMenu.HideAmmo = true
	function WeaponMenu:DoGiveWeapon(SpawnName)
		local menu = DermaMenu()
		menu:SetPos(gui.MouseX(), gui.MouseY())
		FillMenu(menu, function(GroupName)
			RunConsoleCommand("_FAdmin", "RestrictWeapon", SpawnName, GroupName)
		end)
		menu:Open()
	end
	WeaponMenu:BuildList()
	WeaponMenu:StretchToParent(0,25,0,0)
end

FAdmin.StartHooks["Restrict"] = function()
	FAdmin.ScoreBoard.Server:AddPlayerAction("Restrict weapons", "FAdmin/icons/weapon", Color(0, 155, 0, 255), true, RestrictWeaponMenu)
end