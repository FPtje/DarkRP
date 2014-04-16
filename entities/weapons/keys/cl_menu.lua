local function AddButtonToFrame(Frame)
	Frame:SetTall(Frame:GetTall() + 110)

	local button = vgui.Create("DButton", Frame)
	button:SetPos(10, Frame:GetTall() - 110)
	button:SetSize(180, 100)
	return button
end

local function AdminMenuAdditions(Frame, ent, entType)
	local DisableOwnage = AddButtonToFrame(Frame)
	DisableOwnage:SetText(DarkRP.getPhrase(ent:getKeysNonOwnable() and "allow_ownership" or "disallow_ownership"))
	DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("darkrp", "toggleownable") end

	if ent:getKeysNonOwnable() and entType then
		local DoorTitle = AddButtonToFrame(Frame)
		DoorTitle:SetText(DarkRP.getPhrase("set_x_title", entType))
		DoorTitle.DoClick = function()
			Derma_StringRequest(DarkRP.getPhrase("set_x_title", entType), DarkRP.getPhrase("set_x_title_long", entType), "", function(text)
				RunConsoleCommand("darkrp", "title", text)
				if ValidPanel(Frame) then
					Frame:Close()
				end
			end,
			function() end, DarkRP.getPhrase("ok"), DarkRP.getPhrase("cancel"))
		end
	else
		local EditDoorGroups = AddButtonToFrame(Frame)
		EditDoorGroups:SetText(DarkRP.getPhrase("edit_door_group"))
		EditDoorGroups.DoClick = function()
			local menu = DermaMenu()
			local groups = menu:AddSubMenu(DarkRP.getPhrase("door_groups"))
			local teams = menu:AddSubMenu(DarkRP.getPhrase("jobs"))
			local add = teams:AddSubMenu(DarkRP.getPhrase("add"))
			local remove = teams:AddSubMenu(DarkRP.getPhrase("remove"))

			menu:AddOption(DarkRP.getPhrase("none"), function() RunConsoleCommand("darkrp", "togglegroupownable") Frame:Close() end)
			for k,v in pairs(RPExtraTeamDoors) do
				groups:AddOption(k, function()
					RunConsoleCommand("darkrp", "togglegroupownable", k)
					if ValidPanel(Frame) then
						Frame:Close()
					end
				end)
			end

			local doorTeams = ent:getKeysDoorTeams()
			for k,v in pairs(RPExtraTeams) do
				if not doorTeams or not doorTeams[k] then
					add:AddOption(v.name, function()
						RunConsoleCommand("darkrp", "toggleteamownable", k)
						if ValidPanel(Frame) then
							Frame:Close()
						end
					end)
				else
					remove:AddOption(v.name, function()
						RunConsoleCommand("darkrp", "toggleteamownable", k)
						if ValidPanel(Frame) then
							Frame:Close()
						end
					end)
				end
			end

			menu:Open()
		end
	end
end

DarkRP.stub{
	name = "openKeysMenu",
	description = "Open the keys/F2 menu.",
	parameters = {},
	returns = {},
	metatable = DarkRP
}

local KeyFrameVisible = false
function DarkRP.openKeysMenu(um)
	if KeyFrameVisible then return end

	local ent = LocalPlayer():GetEyeTrace().Entity
	-- Don't open the menu if the entity is not ownable, the entity is too far away or the door settings are not loaded yet
	if not IsValid(ent) or not ent:isKeysOwnable() or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then return end

	KeyFrameVisible = true
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(200, 30) -- base size
	Frame:SetVisible(true)
	Frame:MakePopup()

	function Frame:Think()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) or not ent:isKeysOwnable() or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then
			self:Close()
		end
		if not self.Dragging then return end
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]
		x = math.Clamp(x, 0, ScrW() - self:GetWide())
		y = math.Clamp(y, 0, ScrH() - self:GetTall())
		self:SetPos(x, y)
	end

	local entType = DarkRP.getPhrase(ent:IsVehicle() and "vehicle" or "door")
	Frame:SetTitle(DarkRP.getPhrase("x_options", entType:gsub("^%a", string.upper)))

	function Frame:Close()
		KeyFrameVisible = false
		self:SetVisible(false)
		self:Remove()
	end

	if ent:isKeysOwnedBy(LocalPlayer()) then
		local Owndoor = AddButtonToFrame(Frame)
		Owndoor:SetText(DarkRP.getPhrase("sell_x", entType))
		Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end

		local AddOwner = AddButtonToFrame(Frame)
		AddOwner:SetText(DarkRP.getPhrase("add_owner"))
		AddOwner.DoClick = function()
			local menu = DermaMenu()
			menu.found = false
			for k,v in pairs(DarkRP.nickSortedPlayers()) do
				if not ent:isKeysOwnedBy(v) and not ent:isKeysAllowedToOwn(v) then
					local steamID = v:SteamID()
					menu.found = true
					menu:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ao", steamID) end)
				end
			end
			if not menu.found then
				menu:AddOption(DarkRP.getPhrase("noone_available"), function() end)
			end
			menu:Open()
		end

		local RemoveOwner = AddButtonToFrame(Frame)
		RemoveOwner:SetText(DarkRP.getPhrase("remove_owner"))
		RemoveOwner.DoClick = function()
			local menu = DermaMenu()
			for k,v in pairs(DarkRP.nickSortedPlayers()) do
				if (ent:isKeysOwnedBy(v) and not ent:isMasterOwner(v)) or ent:isKeysAllowedToOwn(v) then
					local steamID = v:SteamID()
					menu.found = true
					menu:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ro", steamID) end)
				end
			end
			if not menu.found then
				menu:AddOption(DarkRP.getPhrase("noone_available"), function() end)
			end
			menu:Open()
		end
		if not ent:isMasterOwner(LocalPlayer()) then
			RemoveOwner:SetDisabled(true)
		end

		local DoorTitle = AddButtonToFrame(Frame)
		DoorTitle:SetText(DarkRP.getPhrase("set_x_title", entType))
		DoorTitle.DoClick = function()
			Derma_StringRequest(DarkRP.getPhrase("set_x_title", entType), DarkRP.getPhrase("set_x_title_long", entType), "", function(text)
				RunConsoleCommand("darkrp", "title", text)
				if ValidPanel(Frame) then
					Frame:Close()
				end
			end,
			function() end, DarkRP.getPhrase("ok"), DarkRP.getPhrase("cancel"))
		end
	elseif not ent:isKeysOwnedBy(LocalPlayer()) and not ent:isKeysOwned() and not ent:getKeysNonOwnable() and not ent:getKeysDoorGroup() and not ent:getKeysDoorTeams() then
		if LocalPlayer():hasDarkRPPrivilege("rp_doorManipulation") then
			local Owndoor = AddButtonToFrame(Frame)
			Owndoor:SetText(DarkRP.getPhrase("buy_x", entType))
			Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end

			AdminMenuAdditions(Frame, ent, entType)
		else
			RunConsoleCommand("darkrp", "toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif not ent:isKeysOwnedBy(LocalPlayer()) and ent:isKeysAllowedToOwn(LocalPlayer()) then
		if LocalPlayer():hasDarkRPPrivilege("rp_doorManipulation") then
			local Owndoor = AddButtonToFrame(Frame)
			Owndoor:SetText(DarkRP.getPhrase("coown_x", entType))
			Owndoor.DoClick = function() RunConsoleCommand("darkrp", "toggleown") Frame:Close() end

			AdminMenuAdditions(Frame, ent, entType)
		else
			RunConsoleCommand("darkrp", "toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif LocalPlayer():hasDarkRPPrivilege("rp_doorManipulation") then
		AdminMenuAdditions(Frame, ent, entType)
	else
		Frame:Close()
	end

	Frame:Center()
	Frame:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
usermessage.Hook("KeysMenu", DarkRP.openKeysMenu)
