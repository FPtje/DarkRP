local function AddButtonToFrame(Frame)
	Frame:SetTall(Frame:GetTall() + 110);

	local button = vgui.Create("DButton", Frame);
	button:SetPos(10, Frame:GetTall() - 110);
	button:SetSize(180, 100);
	return button
end

local function AdminMenuAdditions(Frame, ent, entType)
	local DisableOwnage = AddButtonToFrame(Frame);
	DisableOwnage:SetText(fprp.getPhrase(ent:getKeysNonOwnable() and "allow_ownership" or "disallow_ownership"));
	DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("fprp", "toggleownable") end

	if ent:getKeysNonOwnable() and entType then
		local DoorTitle = AddButtonToFrame(Frame);
		DoorTitle:SetText(fprp.getPhrase("set_x_title", entType));
		DoorTitle.DoClick = function()
			Derma_StringRequest(fprp.getPhrase("set_x_title", entType), fprp.getPhrase("set_x_title_long", entType), "", function(text)
				RunConsoleCommand("fprp", "title", text);
				if ValidPanel(Frame) then
					Frame:Close();
				end
			end,
			function() end, fprp.getPhrase("ok"), fprp.getPhrase("cancel"))
		end
	else
		local EditDoorGroups = AddButtonToFrame(Frame);
		EditDoorGroups:SetText(fprp.getPhrase("edit_door_group"));
		EditDoorGroups.DoClick = function()
			local menu = DermaMenu();
			local groups = menu:AddSubMenu(fprp.getPhrase("door_groups"));
			local teams = menu:AddSubMenu(fprp.getPhrase("jobs"));
			local add = teams:AddSubMenu(fprp.getPhrase("add"));
			local remove = teams:AddSubMenu(fprp.getPhrase("remove"));

			menu:AddOption(fprp.getPhrase("none"), function() RunConsoleCommand("fprp", "togglegroupownable") Frame:Close() end)
			for k,v in pairs(RPExtraTeamDoors) do
				groups:AddOption(k, function()
					RunConsoleCommand("fprp", "togglegroupownable", k);
					if ValidPanel(Frame) then
						Frame:Close();
					end
				end);
			end

			local doorTeams = ent:getKeysDoorTeams();
			for k,v in pairs(RPExtraTeams) do
				if not doorTeams or not doorTeams[k] then
					add:AddOption(v.name, function()
						RunConsoleCommand("fprp", "toggleteamownable", k);
						if ValidPanel(Frame) then
							Frame:Close();
						end
					end);
				else
					remove:AddOption(v.name, function()
						RunConsoleCommand("fprp", "toggleteamownable", k);
						if ValidPanel(Frame) then
							Frame:Close();
						end
					end);
				end
			end

			menu:Open();
		end
	end
end

fprp.stub{
	name = "openKeysMenu",
	description = "Open the keys/F2 menu.",
	parameters = {},
	realm = "Client",
	returns = {},
	metatable = fprp
}

local KeyFrameVisible = false
function fprp.openKeysMenu(um)
	if KeyFrameVisible then return end

	local ent = LocalPlayer():GetEyeTrace().Entity
	-- Don't open the menu if the entity is not ownable, the entity is too far away or the door settings are not loaded yet
	if not IsValid(ent) or not ent:isKeysOwnable() or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then return end

	KeyFrameVisible = true
	local Frame = vgui.Create("DFrame");
	Frame:SetSize(200, 30) -- base size
	Frame:SetVisible(true);
	Frame:MakePopup();

	function Frame:Think()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) or not ent:isKeysOwnable() or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then
			self:Close();
		end
		if not self.Dragging then return end
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]
		x = math.Clamp(x, 0, ScrW() - self:GetWide());
		y = math.Clamp(y, 0, ScrH() - self:GetTall());
		self:SetPos(x, y);
	end

	local entType = fprp.getPhrase(ent:IsVehicle() and "vehicle" or "door");
	Frame:SetTitle(fprp.getPhrase("x_options", entType:gsub("^%a", string.upper)));

	function Frame:Close()
		KeyFrameVisible = false
		self:SetVisible(false);
		self:Remove();
	end

	if ent:isKeysOwnedBy(LocalPlayer()) then
		local Owndoor = AddButtonToFrame(Frame);
		Owndoor:SetText(fprp.getPhrase("sell_x", entType));
		Owndoor.DoClick = function() RunConsoleCommand("fprp", "toggleown") Frame:Close() end

		local AddOwner = AddButtonToFrame(Frame);
		AddOwner:SetText(fprp.getPhrase("add_owner"));
		AddOwner.DoClick = function()
			local menu = DermaMenu();
			menu.found = false
			for k,v in pairs(fprp.nickSortedPlayers()) do
				if not ent:isKeysOwnedBy(v) and not ent:isKeysAllowedToOwn(v) then
					local steamID = v:SteamID();
					menu.found = true
					menu:AddOption(v:Nick(), function() RunConsoleCommand("fprp", "ao", steamID) end)
				end
			end
			if not menu.found then
				menu:AddOption(fprp.getPhrase("noone_available"), function() end)
			end
			menu:Open();
		end

		local RemoveOwner = AddButtonToFrame(Frame);
		RemoveOwner:SetText(fprp.getPhrase("remove_owner"));
		RemoveOwner.DoClick = function()
			local menu = DermaMenu();
			for k,v in pairs(fprp.nickSortedPlayers()) do
				if (ent:isKeysOwnedBy(v) and not ent:isMasterOwner(v)) or ent:isKeysAllowedToOwn(v) then
					local steamID = v:SteamID();
					menu.found = true
					menu:AddOption(v:Nick(), function() RunConsoleCommand("fprp", "ro", steamID) end)
				end
			end
			if not menu.found then
				menu:AddOption(fprp.getPhrase("noone_available"), function() end)
			end
			menu:Open();
		end
		if not ent:isMasterOwner(LocalPlayer()) then
			RemoveOwner:SetDisabled(true);
		end

		local DoorTitle = AddButtonToFrame(Frame);
		DoorTitle:SetText(fprp.getPhrase("set_x_title", entType));
		DoorTitle.DoClick = function()
			Derma_StringRequest(fprp.getPhrase("set_x_title", entType), fprp.getPhrase("set_x_title_long", entType), "", function(text)
				RunConsoleCommand("fprp", "title", text);
				if ValidPanel(Frame) then
					Frame:Close();
				end
			end,
			function() end, fprp.getPhrase("ok"), fprp.getPhrase("cancel"))
		end
	elseif not ent:isKeysOwnedBy(LocalPlayer()) and not ent:isKeysOwned() and not ent:getKeysNonOwnable() and not ent:getKeysDoorGroup() and not ent:getKeysDoorTeams() then
		if LocalPlayer():hasfprpPrivilege("rp_doorManipulation") then
			local Owndoor = AddButtonToFrame(Frame);
			Owndoor:SetText(fprp.getPhrase("buy_x", entType));
			Owndoor.DoClick = function() RunConsoleCommand("fprp", "toggleown") Frame:Close() end

			AdminMenuAdditions(Frame, ent, entType);
		else
			RunConsoleCommand("fprp", "toggleown");
			Frame:Close();
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif not ent:isKeysOwnedBy(LocalPlayer()) and ent:isKeysAllowedToOwn(LocalPlayer()) then
		if LocalPlayer():hasfprpPrivilege("rp_doorManipulation") then
			local Owndoor = AddButtonToFrame(Frame);
			Owndoor:SetText(fprp.getPhrase("coown_x", entType));
			Owndoor.DoClick = function() RunConsoleCommand("fprp", "toggleown") Frame:Close() end

			AdminMenuAdditions(Frame, ent, entType);
		else
			RunConsoleCommand("fprp", "toggleown");
			Frame:Close();
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif LocalPlayer():hasfprpPrivilege("rp_doorManipulation") then
		AdminMenuAdditions(Frame, ent, entType);
	else
		Frame:Close();
	end

	Frame:Center();
	Frame:SetSkin(GAMEMODE.Config.fprpSkin);
end
usermessage.Hook("KeysMenu", fprp.openKeysMenu);
