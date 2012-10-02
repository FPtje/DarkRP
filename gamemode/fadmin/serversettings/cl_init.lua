local function SetLimits()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Set Limits")
	frame:SetSize(300, 460)
	frame:Center()
	frame:SetVisible(true)
	frame:MakePopup()

	local PanelList = vgui.Create("DPanelList", frame)
	PanelList:StretchToParent(5, 25, 5, 5)
	PanelList:EnableVerticalScrollbar(true)

	local Form = vgui.Create("DForm", PanelList)
	Form:SetName("")

	local Settings = util.KeyValuesToTable(file.Read("gamemodes/sandbox/sandbox.txt", "GAME")) -- All SBox limits are in here :D
	for k, v in SortedPairs(Settings.settings or {}) do
		if v.type == "Numeric" then
			local left, right = Form:NumberWang(v.text, nil, v.low or 0, v.high or 1000, v.decimals or 0 )
			left:SetFloatValue(GetConVarNumber(v.name))
			left:SetValue(GetConVarNumber(v.name))

			function left:OnValueChanged(val)
				if val == GetConVarNumber(v.name) then
					return
				end
				RunConsoleCommand("_Fadmin", "ServerSetting", v.name, val)
			end
		end
	end
	PanelList:AddItem(Form)
end

FAdmin.StartHooks["ServerSettings"] = function()
	FAdmin.Access.AddPrivilege("ServerSetting", 2)


	FAdmin.ScoreBoard.Server:AddServerSetting(function() return (tobool(GetConVarNumber("sbox_godmode")) and "Disable" or "Enable").." global god mode" end,
	function() return "FAdmin/icons/god", tobool(GetConVarNumber("sbox_godmode")) and "FAdmin/icons/disable" end,
	Color(0, 0, 155, 255), true, function(button)
		button:SetImage2((not tobool(GetConVarNumber("sbox_godmode")) and "FAdmin/icons/disable") or "null")
		button:SetText((not tobool(GetConVarNumber("sbox_godmode")) and "Disable" or "Enable").." global god mode")
		button:GetParent():InvalidateLayout()

		RunConsoleCommand("_Fadmin", "ServerSetting", "sbox_godmode", (tobool(GetConVarNumber("sbox_godmode")) and 0) or 1)
	end)

	FAdmin.ScoreBoard.Server:AddServerSetting(function() return (not tobool(GetConVarNumber("sbox_plpldamage")) and "Disable" or "Enable").." player vs player damage" end,
	function() return "FAdmin/icons/weapon", not tobool(GetConVarNumber("sbox_plpldamage")) and "FAdmin/icons/disable" end,
	Color(0, 0, 155, 255), true, function(button)
		button:SetImage2((tobool(GetConVarNumber("sbox_plpldamage")) and "FAdmin/icons/disable") or "null")
		button:SetText((tobool(GetConVarNumber("sbox_plpldamage")) and "Disable" or "Enable").." player vs player damage")
		button:GetParent():InvalidateLayout()

		RunConsoleCommand("_Fadmin", "ServerSetting", "sbox_plpldamage", (tobool(GetConVarNumber("sbox_plpldamage")) and 0) or 1)
	end)

	FAdmin.ScoreBoard.Server:AddServerSetting(function() return (tobool(GetConVarNumber("sbox_noclip")) and "Disable" or "Enable").." global noclip" end,
	function() return "FAdmin/icons/noclip", tobool(GetConVarNumber("sbox_noclip")) and "FAdmin/icons/disable" end,
	Color(0, 0, 155, 255), true, function(button)
		button:SetImage2((not tobool(GetConVarNumber("sbox_noclip")) and "FAdmin/icons/disable") or "null")
		button:SetText((not tobool(GetConVarNumber("sbox_noclip")) and "Disable" or "Enable").." global noclip")
		button:GetParent():InvalidateLayout()

		RunConsoleCommand("_Fadmin", "ServerSetting", "sbox_noclip", (tobool(GetConVarNumber("sbox_noclip")) and 0) or 1)
	end)


	FAdmin.ScoreBoard.Server:AddServerSetting("Set server limits", "FAdmin/icons/ServerSetting", Color(0, 0, 155, 255), true, SetLimits)
end