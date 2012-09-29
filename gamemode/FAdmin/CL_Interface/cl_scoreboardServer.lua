FAdmin.ScoreBoard.Server.Information = FAdmin.ScoreBoard.Server.Information or {}
FAdmin.ScoreBoard.Server.ActionButtons = FAdmin.ScoreBoard.Server.ActionButtons or {}

local function MakeServerOptions()
	local XPos, YPos, Width = 20, FAdmin.ScoreBoard.Y + 120 + FAdmin.ScoreBoard.Height / 5 + 20, (FAdmin.ScoreBoard.Width - 40)/3

	FAdmin.ScoreBoard.Server.Controls.ServerActions = FAdmin.ScoreBoard.Server.Controls.ServerActions or vgui.Create("FAdminPlayerCatagory")
	FAdmin.ScoreBoard.Server.Controls.ServerActions:SetLabel("  Server Actions")
	FAdmin.ScoreBoard.Server.Controls.ServerActions.CatagoryColor = Color(155, 0, 0, 255)
	FAdmin.ScoreBoard.Server.Controls.ServerActions:SetSize(Width-5, FAdmin.ScoreBoard.Height - 20 - YPos)
	FAdmin.ScoreBoard.Server.Controls.ServerActions:SetPos(FAdmin.ScoreBoard.X + 20, YPos)
	FAdmin.ScoreBoard.Server.Controls.ServerActions:SetVisible(true)
	function FAdmin.ScoreBoard.Server.Controls.ServerActions:Toggle()
	end


	local ActionPanels = {}
	ActionPanels.ServerActions = vgui.Create("FAdminPanelList")
	FAdmin.ScoreBoard.Server.Controls.ServerActions:SetContents(ActionPanels.ServerActions)
	ActionPanels.ServerActions:SetTall(FAdmin.ScoreBoard.Height - 20 - YPos)

	FAdmin.ScoreBoard.Server.Controls.PlayerActions = FAdmin.ScoreBoard.Server.Controls.PlayerActions or vgui.Create("FAdminPlayerCatagory")
	FAdmin.ScoreBoard.Server.Controls.PlayerActions:SetLabel("  Player Actions")
	FAdmin.ScoreBoard.Server.Controls.PlayerActions.CatagoryColor = Color(0, 155, 0, 255)
	FAdmin.ScoreBoard.Server.Controls.PlayerActions:SetSize(Width-5, FAdmin.ScoreBoard.Height - 20 - YPos)
	FAdmin.ScoreBoard.Server.Controls.PlayerActions:SetPos(FAdmin.ScoreBoard.X + 20 + Width, YPos)
	FAdmin.ScoreBoard.Server.Controls.PlayerActions:SetVisible(true)
	function FAdmin.ScoreBoard.Server.Controls.PlayerActions:Toggle()
	end

	ActionPanels.PlayerActions = vgui.Create("FAdminPanelList")
	FAdmin.ScoreBoard.Server.Controls.PlayerActions:SetContents(ActionPanels.PlayerActions)
	ActionPanels.PlayerActions:SetTall(FAdmin.ScoreBoard.Height - 20 - YPos)

	FAdmin.ScoreBoard.Server.Controls.ServerSettings = FAdmin.ScoreBoard.Server.Controls.ServerSettings or vgui.Create("FAdminPlayerCatagory")
	FAdmin.ScoreBoard.Server.Controls.ServerSettings:SetLabel("  Server Settings")
	FAdmin.ScoreBoard.Server.Controls.ServerSettings.CatagoryColor = Color(0, 0, 155, 255)
	FAdmin.ScoreBoard.Server.Controls.ServerSettings:SetSize(Width-5, FAdmin.ScoreBoard.Height - 20 - YPos)
	FAdmin.ScoreBoard.Server.Controls.ServerSettings:SetPos(FAdmin.ScoreBoard.X + 20 + Width*2, YPos)
	FAdmin.ScoreBoard.Server.Controls.ServerSettings:SetVisible(true)
	function FAdmin.ScoreBoard.Server.Controls.ServerSettings:Toggle()
	end

	ActionPanels.ServerSettings = vgui.Create("FAdminPanelList")
	FAdmin.ScoreBoard.Server.Controls.ServerSettings:SetContents(ActionPanels.ServerSettings)
	ActionPanels.ServerSettings:SetTall(FAdmin.ScoreBoard.Height - 20 - YPos)

	for k, v in ipairs(FAdmin.ScoreBoard.Server.ActionButtons) do
		if v.Visible == true or (type(v.Visible) == "function" and v.Visible(FAdmin.ScoreBoard.Player.Player) == true) then
			local ActionButton = vgui.Create("FAdminActionButton")
			if type(v.Image) == "string" then
				ActionButton:SetImage(v.Image or "icon16/exclamation")
			elseif type(v.Image) == "table" then
				ActionButton:SetImage(v.Image[1])
				if v.Image[2] then ActionButton:SetImage2(v.Image[2]) end
			elseif type(v.Image) == "function" then
				local img1, img2 = v.Image(ply)
				ActionButton:SetImage(img1)
				if img2 then ActionButton:SetImage2(img2) end
			else
				ActionButton:SetImage("icon16/exclamation")
			end
			local name = v.Name
			if type(name) == "function" then name = name() end
			ActionButton:SetText(name)
			ActionButton:SetBorderColor(v.color)
			ActionButton:Dock(TOP)

			function ActionButton:DoClick()
				return v.Action(self)
			end

			ActionPanels[v.TYPE]:Add(ActionButton)
			if v.OnButtonCreated then
				v.OnButtonCreated(ActionButton)
			end
		end
	end
end

function FAdmin.ScoreBoard.Server:AddServerAction(Name, Image, color, Visible, Action, OnButtonCreated)
	table.insert(FAdmin.ScoreBoard.Server.ActionButtons, {TYPE = "ServerActions", Name = Name, Image = Image, color = color, Visible = Visible, Action = Action, OnButtonCreated = OnButtonCreated})
end

function FAdmin.ScoreBoard.Server:AddPlayerAction(Name, Image, color, Visible, Action, OnButtonCreated)
	table.insert(FAdmin.ScoreBoard.Server.ActionButtons, {TYPE = "PlayerActions", Name = Name, Image = Image, color = color, Visible = Visible, Action = Action, OnButtonCreated = OnButtonCreated})
end

function FAdmin.ScoreBoard.Server:AddServerSetting(Name, Image, color, Visible, Action, OnButtonCreated)
	table.insert(FAdmin.ScoreBoard.Server.ActionButtons, {TYPE = "ServerSettings", Name = Name, Image = Image, color = color, Visible = Visible, Action = Action, OnButtonCreated = OnButtonCreated})
end

function FAdmin.ScoreBoard.Server.Show(ply)
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()

	FAdmin.ScoreBoard.Server.Controls.InfoPanel = FAdmin.ScoreBoard.Server.Controls.InfoPanel or vgui.Create("FAdminPanelList")
	FAdmin.ScoreBoard.Server.Controls.InfoPanel:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 120)
	FAdmin.ScoreBoard.Server.Controls.InfoPanel:SetSize(FAdmin.ScoreBoard.Width - 40, FAdmin.ScoreBoard.Height / 5)
	FAdmin.ScoreBoard.Server.Controls.InfoPanel:SetVisible(true)
	FAdmin.ScoreBoard.Server.Controls.InfoPanel:Clear(true)

	local InfoPanels = {}
	local function AddInfoPanel()
		local pan = vgui.Create("FAdminPanelList")
		pan:SetSize(1, FAdmin.ScoreBoard.Server.Controls.InfoPanel:GetTall())
		FAdmin.ScoreBoard.Server.Controls.InfoPanel:Add(pan)

		table.insert(InfoPanels, pan)
		return pan
	end

	local SelectedPanel = AddInfoPanel() -- Make first panel to put the first things in

	for k, v in pairs(FAdmin.ScoreBoard.Server.Information) do
		local Text = vgui.Create("DLabel")
		Text:SetFont("TabLarge")
		Text:SetColor(Color(255,255,255,200))

		local EndText
		local function RefreshText()
			local Value = v.func()
			if not Value or Value == "" then Value = "N/A" end
			EndText = v.name.. ":  "..Value
			local strLen = string.len(EndText)
			if strLen > 40 then
				local NewLinePoint = math.floor(strLen / 40)
				local NewValue = string.sub(EndText, 1, 40)
				for i = 40, strLen, 34 do
					NewValue = NewValue.."\n        "..string.sub(EndText, i + 1, i + 34)
				end
				EndText = NewValue
			else
				local SpaceSize = 3
				local MaxWidth = 240
				surface.SetFont("TabLarge")
				local TextWidth = surface.GetTextSize(v.name..": "..Value)
				if TextWidth <= MaxWidth then
					local SpacesAmount = (MaxWidth - TextWidth) / 3
					local Spaces = ""
					for i=1, SpacesAmount do Spaces = Spaces.." " end
					EndText = v.name..":"..Spaces..Value
				end
			end
			Text:SetText(EndText)
			Text:SizeToContents()
			Text:SetToolTip("Click to copy "..v.name.." to clipboard")
			Text:SetMouseInputEnabled(true)
		end
		RefreshText()
		function Text:OnMousePressed(mcode)
			self:SetToolTip(v.name.." copied to clipboard!")
			ChangeTooltip(self)
			SetClipboardText(v.func())
			self:SetToolTip("Click to copy "..v.name.." to clipboard")
		end

		timer.Create("FAdmin_Scoreboard_text_update_"..v.name, 1, 0, function()
			if not ValidPanel(Text) then
				timer.Destroy("FAdmin_Scoreboard_text_update_"..v.name)
				FAdmin.ScoreBoard.ChangeView("Main")
				return
			end
			RefreshText()
		end)

		if #SelectedPanel:GetChildren()*17 + 17 >= SelectedPanel:GetTall() or v.NewPanel then
			SelectedPanel = AddInfoPanel() -- Add new panel if the last one is full
		end
		SelectedPanel:Add(Text)
		if Text:GetWide() > SelectedPanel:GetWide() then
			SelectedPanel:SetWide(Text:GetWide() + 40)
		end
	end

	MakeServerOptions()
end

function FAdmin.ScoreBoard.Server:AddInformation(name, func, ForceNewPanel) -- ForeNewPanel is to start a new column
	table.insert(FAdmin.ScoreBoard.Server.Information, {name = name, func = func, NewPanel = ForceNewPanel})
end


/*
Server IP (Thanks chrisaster)
*/

local hex2dec = {
	["a"] = 10,
	["b"] = 11,
	["c"] = 12,
	["d"] = 13,
	["e"] = 14,
	["f"] = 15,
}

FAdmin.ScoreBoard.Server:AddInformation("Hostname", GetHostName)
FAdmin.ScoreBoard.Server:AddInformation("Gamemode", function() return GAMEMODE.Name end)
FAdmin.ScoreBoard.Server:AddInformation("Author", function() return GAMEMODE.Author end)
FAdmin.ScoreBoard.Server:AddInformation("Server IP", function()
	if FAdmin.GlobalSetting.FAdmin_ServerIP and FAdmin.GlobalSetting.FAdmin_ServerIP ~= "" then return FAdmin.GlobalSetting.FAdmin_ServerIP end
	/*local dec = tonumber(string.format("%u", GetConVarString("hostip")))
	local split = string.ToTable(string.format("%x", dec))
	local ip = ""

	for i=1, #split, 2 do
		local a = split[i]
		local b = split[i+1]

		ip = ip..((hex2dec[a] || tonumber(a))*16)+(hex2dec[b] || tonumber(b))

		if (i < (#split-2)) then
			ip = ip.."."
		end
	end

	return ip*/
end)
FAdmin.ScoreBoard.Server:AddInformation("Server FPS", function() return FAdmin.GlobalSetting.FAdmin_ServerFPS end)
FAdmin.ScoreBoard.Server:AddInformation("Map", game.GetMap)
FAdmin.ScoreBoard.Server:AddInformation("Players", function() return #player.GetAll().."/"..GetConVarString("maxplayers") end)

FAdmin.ScoreBoard.Server:AddInformation("Ping", function() return LocalPlayer():Ping() end, true)

