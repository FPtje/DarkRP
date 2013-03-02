local StarterGroups = {"superadmin", "admin", "user", "noaccess"}
local ContinueNewGroup

local function RetrievePRIVS(len)
	FAdmin.Access.Groups = net.ReadTable()
end
net.Receive("FADMIN_SendGroups", RetrievePRIVS)

local function addPriv(um)
	FAdmin.Access.Groups[um:ReadString()].PRIVS[um:ReadString()] = true
end
usermessage.Hook("FAdmin_AddPriv", addPriv)

local function removePriv(um)
	FAdmin.Access.Groups[um:ReadString()].PRIVS[um:ReadString()] = nil
end
usermessage.Hook("FAdmin_RemovePriv", removePriv)

FAdmin.StartHooks["1SetAccess"] = function() -- 1 in hook name so it will be executed first.
	FAdmin.Commands.AddCommand("setaccess", nil, "<Player>", "<Group name>", "[new group based on (number)]", "[new group privileges]")

	FAdmin.ScoreBoard.Player:AddActionButton("Set access", "FAdmin/icons/access", Color(255, 0, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetAccess") or LocalPlayer():IsSuperAdmin() end, function(ply)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Set access:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)

		menu:AddPanel(Title)

		for k,v in SortedPairsByMemberValue(FAdmin.Access.Groups, "ADMIN", true) do
			menu:AddOption(k, function()
				if not IsValid(ply) then return end
				RunConsoleCommand("_FAdmin", "setaccess", ply:UserID(), k)
			end)
		end

		menu:AddOption("New...", function()
			local name = ""

			Derma_StringRequest("Set name",
			"What will be the name of the new group?",
			"",
			function(text)
				if text == "" then return end
				name = text
				Derma_Query("On what access will this team be based? (the new group will inherit all the privileges from the group)", "Admin access",
					"user", function() ContinueNewGroup(ply, name, 0) end,
					"admin", function() ContinueNewGroup(ply, name, 1) end,
					"superadmin", function() ContinueNewGroup(ply, name, 2) end)
			end)
		end)
		menu:Open()
	end)

	--Removing groups
	FAdmin.ScoreBoard.Server:AddPlayerAction("Remove custom group", "FAdmin/icons/access", Color(0, 155, 0, 255), true, function(button)
		local Panel = vgui.Create("DListView")
		Panel:AddColumn("Group names:")
		Panel:SetPos(gui.MouseX(), gui.MouseY())
		Panel:SetSize(150, 200)
		function Panel:Think()
			if not FAdmin.ScoreBoard.Visible then self:Remove() return end
			if input.IsMouseDown(MOUSE_FIRST) then
				local X, Y = self:GetPos()
				local W, H = self:GetWide(), self:GetTall()
				local MX, MY = gui.MouseX(), gui.MouseY()
				if MX < X or MY < Y
				or MX > X+W or MY > Y+H then
					self:Remove()
				end
			end
		end

		local NoOthers = Panel:AddLine("No custom groups")
		local RemoveFirst = true
		for name, tbl in pairs(FAdmin.Access.Groups) do
			if table.HasValue(FAdmin.Access.ADMIN, name) then continue end

			-- remove the "Loading/no custom groups" line
			if RemoveFirst then Panel:RemoveLine(1) end
			RemoveFirst = false

			local Line = Panel:AddLine(name)
			function Line:OnSelect()
				RunConsoleCommand("_FAdmin", "RemoveGroup", self:GetValue(1))
				Panel:RemoveLine(self:GetID())
			end
		end
	end)

	-- Admin immunity
	FAdmin.ScoreBoard.Server:AddServerSetting(function()
			return (FAdmin.GlobalSetting.Immunity and "Disable" or "Enable").." Admin immunity"
		end,
		function()
			return "FAdmin/icons/access", FAdmin.GlobalSetting.Immunity and "FAdmin/icons/disable"
		end, Color(0, 0, 155, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetAccess") end, function(button)
			button:SetImage2((not FAdmin.GlobalSetting.Immunity and "FAdmin/icons/disable") or "null")
			button:SetText((not FAdmin.GlobalSetting.Immunity and "Disable" or "Enable").." Admin immunity")
			button:GetParent():InvalidateLayout()

			RunConsoleCommand("_Fadmin", "immunity", (FAdmin.GlobalSetting.Immunity and 0) or 1)
		end
	)
end

ContinueNewGroup = function(ply, name, admin_access)
	local privs = {}

	local Window = vgui.Create("DFrame")
	Window:SetTitle("Set the privileges")
	Window:SetDraggable(false)
	Window:ShowCloseButton(true)
	Window:SetBackgroundBlur(true)
	Window:SetDrawOnTop(true)
	Window:SetSize(120, 400)
	gui.EnableScreenClicker(true)
	function Window:Close()
		gui.EnableScreenClicker(false)
		self:Remove()
	end

	local TickBoxPanel = vgui.Create("DPanelList", Window)
	TickBoxPanel:EnableHorizontal(false)
	TickBoxPanel:EnableVerticalScrollbar()
	TickBoxPanel:SetSpacing(5)

	for Pname, Padmin_access in SortedPairs(FAdmin.Access.Privileges) do
		local chkBox = vgui.Create("DCheckBoxLabel")
		chkBox:SetText(Pname)
		chkBox:SizeToContents()

		if (Padmin_access - 1) <= admin_access then
			chkBox:SetValue(true)
			table.insert(privs, Pname)
		end

		function chkBox.Button:Toggle()
			if not self:GetChecked() then
				self:SetValue(true)
				table.insert(privs, Pname)
			else
				self:SetValue(false)
				for k,v in pairs(privs) do
					if v == Pname then
						table.remove(privs, k)
					end
				end
			end
		end

		TickBoxPanel:AddItem(chkBox)
	end

	Window:SetTall(math.Min(#TickBoxPanel.Items*20 + 30 + 30, ScrH()))
	Window:Center()
	TickBoxPanel:StretchToParent(5, 25, 5, 35)

	local OKButton = vgui.Create("DButton", Window)
	OKButton:SetText("OK")
	OKButton:StretchToParent(5, 30 + TickBoxPanel:GetTall(), Window:GetWide()/2 + 2, 5)
	function OKButton:DoClick()
		RunConsoleCommand("_FAdmin", "setaccess", ply:UserID(), name, admin_access, unpack(privs))
		Window:Close()
	end

	local CancelButton = vgui.Create("DButton", Window)
	CancelButton:SetText("Cancel")
	CancelButton:StretchToParent(Window:GetWide()/2 + 2, 30 + TickBoxPanel:GetTall(), 5, 5)
	function CancelButton:DoClick()
		Window:Close()
	end
end