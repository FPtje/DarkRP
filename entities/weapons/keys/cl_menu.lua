local KeyFrameVisible = false
local function KeysMenu(um)
	local Vehicle = LocalPlayer():GetEyeTrace().Entity
	Vehicle = IsValid(Vehicle) and Vehicle:IsVehicle()
	if KeyFrameVisible then return end
	local trace = LocalPlayer():GetEyeTrace()
	local Frame = vgui.Create("DFrame")
	KeyFrameVisible = true
	Frame:SetSize(200, 470)
	Frame:Center()
	Frame:SetVisible(true)
	Frame:MakePopup()

	function Frame:Think()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) or (not ent:IsDoor() and not string.find(ent:GetClass(), "vehicle")) or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then
			self:Close()
		end
		if (!self.Dragging) then return end
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]
		x = math.Clamp( x, 0, ScrW() - self:GetWide() )
		y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		self:SetPos( x, y )
	end
	local Entiteh = DarkRP.getPhrase("door")
	if Vehicle then
		Entiteh = DarkRP.getPhrase("vehicle")
	end
	Frame:SetTitle(DarkRP.getPhrase("x_options", Entiteh))

	function Frame:Close()
		KeyFrameVisible = false
		self:SetVisible( false )
		self:Remove()
	end

	if trace.Entity:OwnedBy(LocalPlayer()) then
		if not trace.Entity.DoorData then return end -- Don't open the menu when the door settings are not loaded yet
		local Owndoor = vgui.Create("DButton", Frame)
		Owndoor:SetPos(10, 30)
		Owndoor:SetSize(180, 100)
		Owndoor:SetText(DarkRP.getPhrase("sell_x", Entiteh))
		Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end

		local AddOwner = vgui.Create("DButton", Frame)
		AddOwner:SetPos(10, 140)
		AddOwner:SetSize(180, 100)
		AddOwner:SetText(DarkRP.getPhrase("add_owner"))
		AddOwner.DoClick = function()
			local menu = DermaMenu()
			menu.found = false
			for k,v in pairs(player.GetAll()) do
				if not trace.Entity:OwnedBy(v) and not trace.Entity:AllowedToOwn(v) then
					menu.found = true
					menu:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ao", v:SteamID()) end)
				end
			end
			if not menu.found then
				menu:AddOption(DarkRP.getPhrase("noone_available"), function() end)
			end
			menu:Open()
		end

		local RemoveOwner = vgui.Create("DButton", Frame)
		RemoveOwner:SetPos(10, 250)
		RemoveOwner:SetSize(180, 100)
		RemoveOwner:SetText(DarkRP.getPhrase("remove_owner"))
		RemoveOwner.DoClick = function()
			local menu = DermaMenu()
			for k,v in pairs(player.GetAll()) do
				if (trace.Entity:OwnedBy(v) and not trace.Entity:IsMasterOwner(v)) or trace.Entity:AllowedToOwn(v) then
					menu.found = true
					menu:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ro", v:SteamID()) end)
				end
			end
			if not menu.found then
				menu:AddOption(DarkRP.getPhrase("noone_available"), function() end)
			end
			menu:Open()
		end

		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, 360)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText(DarkRP.getPhrase("set_x_title", Entiteh))
		if not trace.Entity:IsMasterOwner(LocalPlayer()) then
			RemoveOwner.m_bDisabled = true
		end
		DoorTitle.DoClick = function()
			Derma_StringRequest(DarkRP.getPhrase("set_x_title", Entiteh), DarkRP.getPhrase("set_x_title_long", Entiteh), "", function(text)
				RunConsoleCommand("darkrp", "title", text)
				if ValidPanel(Frame) then
					Frame:Close()
				end
			end,
			function() end, DarkRP.getPhrase("ok"), DarkRP.getPhrase("cancel"))
		end

		if (FAdmin and FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_doorManipulation") or LocalPlayer():IsAdmin()) and not Vehicle then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText(DarkRP.getPhrase("edit_door_group"))
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu(DarkRP.getPhrase("door_groups"))
				local teams = menu:AddSubMenu(DarkRP.getPhrase("jobs"))
				local add = teams:AddSubMenu(DarkRP.getPhrase("add"))
				local remove = teams:AddSubMenu(DarkRP.getPhrase("remove"))

				menu:AddOption(DarkRP.getPhrase("none"), function() RunConsoleCommand("darkrp", "togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("darkrp", "togglegroupownable", k) Frame:Close() end)
				end

				if not trace.Entity.DoorData then return end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption( v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) Frame:Close() end )
					else
						remove:AddOption( v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) Frame:Close() end )
					end
				end

				menu:Open()
			end
		end
	elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwnable() and not trace.Entity:IsOwned() and not trace.Entity.DoorData.NonOwnable then
		if not trace.Entity.DoorData.GroupOwn then
			Frame:SetSize(200, 140)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText(DarkRP.getPhrase("buy_x", Entiteh))
			Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end
		end

		if (FAdmin and FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_doorManipulation") or LocalPlayer():IsAdmin()) then
			if trace.Entity.DoorData.GroupOwn then
				Frame:SetSize(200, 250)
			else
				Frame:SetSize(200, 360)
			end

			local DisableOwnage = vgui.Create("DButton", Frame)
			DisableOwnage:SetPos(10, Frame:GetTall() - 220)
			DisableOwnage:SetSize(180, 100)
			DisableOwnage:SetText(DarkRP.getPhrase("disallow_ownership"))
			DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("darkrp", "toggleownable") end

			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText(DarkRP.getPhrase("edit_door_group"))
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu(DarkRP.getPhrase("door_groups"))
				local teams = menu:AddSubMenu(DarkRP.getPhrase("jobs"))
				local add = teams:AddSubMenu(DarkRP.getPhrase("add"))
				local remove = teams:AddSubMenu(DarkRP.getPhrase("remove"))

				menu:AddOption(DarkRP.getPhrase("none"), function() RunConsoleCommand("darkrp", "togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("darkrp", "togglegroupownable", k) Frame:Close() end)
				end

				if not trace.Entity.DoorData then return end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption(v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) if Frame.Close then Frame:Close() end end)
					else
						remove:AddOption(v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) Frame:Close() end)
					end
				end

				menu:Open()
			end
		elseif not trace.Entity.DoorData.GroupOwn then
			RunConsoleCommand("darkrp", "toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 140)
		local Owndoor = vgui.Create("DButton", Frame)
		Owndoor:SetPos(10, 30)
		Owndoor:SetSize(180, 100)
		Owndoor:SetText(DarkRP.getPhrase("coown_x", Entiteh))
		Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end

		if (FAdmin and FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_doorManipulation") or LocalPlayer():IsAdmin()) then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText(DarkRP.getPhrase("edit_door_group"))
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu(DarkRP.getPhrase("door_groups"))
				local teams = menu:AddSubMenu(DarkRP.getPhrase("jobs"))
				local add = teams:AddSubMenu(DarkRP.getPhrase("add"))
				local remove = teams:AddSubMenu(DarkRP.getPhrase("remove"))

				menu:AddOption(DarkRP.getPhrase("none"), function() RunConsoleCommand("darkrp", "togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("darkrp", "togglegroupownable", k) Frame:Close() end)
				end

				if not trace.Entity.DoorData then return end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption( v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) Frame:Close() end )
					else
						remove:AddOption( v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) Frame:Close() end )
					end
				end

				menu:Open()
			end
		else
			RunConsoleCommand("darkrp", "toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif (FAdmin and FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_doorManipulation") or LocalPlayer():IsAdmin()) and trace.Entity.DoorData.NonOwnable then
		Frame:SetSize(200, 250)
		local EnableOwnage = vgui.Create("DButton", Frame)
		EnableOwnage:SetPos(10, 30)
		EnableOwnage:SetSize(180, 100)
		EnableOwnage:SetText(DarkRP.getPhrase("allow_ownership"))
		EnableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("darkrp", "toggleownable") end

		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, Frame:GetTall() - 110)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText(DarkRP.getPhrase("set_x_title", Entiteh))
		DoorTitle.DoClick = function()
			Derma_StringRequest(DarkRP.getPhrase("set_x_title", Entiteh), DarkRP.getPhrase("set_x_title_long", Entiteh), "", function(text) RunConsoleCommand("darkrp", "title", text) Frame:Close() end, function() end, DarkRP.getPhrase("ok"), DarkRP.getPhrase("cancel"))
		end
	elseif (FAdmin and FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_doorManipulation") or LocalPlayer():IsAdmin()) and not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 250)
		local DisableOwnage = vgui.Create("DButton", Frame)
		DisableOwnage:SetPos(10, 30)
		DisableOwnage:SetSize(180, 100)
		DisableOwnage:SetText(DarkRP.getPhrase("disallow_ownership"))
		DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("darkrp", "toggleownable") end

		local SetCopsOnly = vgui.Create("DButton", Frame)
		SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
		SetCopsOnly:SetSize(180, 100)
		SetCopsOnly:SetText(DarkRP.getPhrase("edit_door_group"))
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu(DarkRP.getPhrase("door_groups"))
				local teams = menu:AddSubMenu(DarkRP.getPhrase("jobs"))
				local add = teams:AddSubMenu(DarkRP.getPhrase("add"))
				local remove = teams:AddSubMenu(DarkRP.getPhrase("remove"))

				if not trace.Entity.DoorData then return end

				menu:AddOption(DarkRP.getPhrase("none"), function() RunConsoleCommand("darkrp", "togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("darkrp", "togglegroupownable", k) Frame:Close() end)
				end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption( v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) Frame:Close() end )
					else
						remove:AddOption( v.name, function() RunConsoleCommand("darkrp", "toggleteamownable", k) Frame:Close() end )
					end
				end

				menu:Open()
			end
	else
		Frame:Close()
	end

	Frame:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
timer.Simple(0, function() GAMEMODE.ShowTeam = KeysMenu end)
usermessage.Hook("KeysMenu", KeysMenu)
