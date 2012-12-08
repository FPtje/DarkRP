local VoteVGUI = {}
local QuestionVGUI = {}
local PanelNum = 0
local LetterWritePanel

local function MsgDoVote(msg)
	local _, chatY = chat.GetChatBoxPos()

	local question = msg:ReadString()
	local voteid = msg:ReadString()
	local timeleft = msg:ReadFloat()
	if timeleft == 0 then
		timeleft = 100
	end
	local OldTime = CurTime()
	if string.find(voteid, LocalPlayer():EntIndex()) then return end --If it's about you then go away
	if not IsValid(LocalPlayer()) then return end -- Sent right before player initialisation

	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(3 + PanelNum, chatY - 145)
	panel:SetTitle("Vote")
	panel:SetSize(140, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetDraggable(false)
	function panel:Close()
		PanelNum = PanelNum - 140
		VoteVGUI[voteid .. "vote"] = nil

		local num = 0
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 140
		end

		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 300
		end
		self:Remove()
	end

	function panel:Think()
		self:SetTitle("Time: ".. tostring(math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
		if timeleft - (CurTime() - OldTime) <= 0 then
			panel:Close()
		end
	end

	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)

	for i = 22, string.len(question), 22 do
		if not string.find(string.sub(question, i - 20, i), "\n", 1, true) then
			question = string.sub(question, 1, i) .. "\n".. string.sub(question, i + 1, string.len(question))
		end
	end

	local label = vgui.Create("DLabel")
	label:SetParent(panel)
	label:SetPos(5, 25)
	label:SetText(question)
	label:SizeToContents()
	label:SetVisible(true)

	local nextHeight = label:GetTall() > 78 and label:GetTall() - 78 or 0 // make panel taller for divider and buttons
	panel:SetTall(panel:GetTall() + nextHeight)

	local divider = vgui.Create("Divider")
	divider:SetParent(panel)
	divider:SetPos(2, panel:GetTall() - 30)
	divider:SetSize(180, 2)
	divider:SetVisible(true)

	local ybutton = vgui.Create("Button")
	ybutton:SetParent(panel)
	ybutton:SetPos(25, panel:GetTall() - 25)
	ybutton:SetSize(40, 20)
	ybutton:SetCommand("!")
	ybutton:SetText("Yes")
	ybutton:SetVisible(true)
	ybutton.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " 1\n")
		panel:Close()
	end

	local nbutton = vgui.Create("Button")
	nbutton:SetParent(panel)
	nbutton:SetPos(70, panel:GetTall() - 25)
	nbutton:SetSize(40, 20)
	nbutton:SetCommand("!")
	nbutton:SetText("No")
	nbutton:SetVisible(true)
	nbutton.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " 2\n")
		panel:Close()
	end

	PanelNum = PanelNum + 140
	VoteVGUI[voteid .. "vote"] = panel
	panel:SetSkin("DarkRP")
end
usermessage.Hook("DoVote", MsgDoVote)

local function KillVoteVGUI(msg)
	local id = msg:ReadString()

	if VoteVGUI[id .. "vote"] and VoteVGUI[id .. "vote"]:IsValid() then
		VoteVGUI[id.."vote"]:Close()

	end
end
usermessage.Hook("KillVoteVGUI", KillVoteVGUI)

local function MsgDoQuestion(msg)
	local question = msg:ReadString()
	local quesid = msg:ReadString()
	local timeleft = msg:ReadFloat()
	if timeleft == 0 then
		timeleft = 100
	end
	local OldTime = CurTime()
	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(3 + PanelNum, ScrH() / 2 - 50)--Times 140 because if the quesion is the second screen, the first screen is always a vote screen.
	panel:SetSize(300, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)

	function panel:Close()
		PanelNum = PanelNum - 300
		QuestionVGUI[quesid .. "ques"] = nil
		local num = 0
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 140
		end

		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 300
		end

		self:Remove()
	end

	function panel:Think()
		self:SetTitle("Time: ".. tostring(math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
		if timeleft - (CurTime() - OldTime) <= 0 then
			panel:Close()
		end
	end

	local label = vgui.Create("DLabel")
	label:SetParent(panel)
	label:SetPos(5, 30)
	label:SetSize(380, 40)
	label:SetText(question)
	label:SetVisible(true)

	local divider = vgui.Create("Divider")
	divider:SetParent(panel)
	divider:SetPos(2, 80)
	divider:SetSize(380, 2)
	divider:SetVisible(true)

	local ybutton = vgui.Create("DButton")
	ybutton:SetParent(panel)
	ybutton:SetPos(105, 100)
	ybutton:SetSize(40, 20)
	ybutton:SetText("Yes")
	ybutton:SetVisible(true)
	ybutton.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 1\n")
		panel:Close()
	end

	local nbutton = vgui.Create("DButton")
	nbutton:SetParent(panel)
	nbutton:SetPos(155, 100)
	nbutton:SetSize(40, 20)
	nbutton:SetText("No")
	nbutton:SetVisible(true)
	nbutton.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 2\n")
		panel:Close()
	end

	PanelNum = PanelNum + 300
	QuestionVGUI[quesid .. "ques"] = panel

	panel:SetSkin("DarkRP")
end
usermessage.Hook("DoQuestion", MsgDoQuestion)

local function KillQuestionVGUI(msg)
	local id = msg:ReadString()

	if QuestionVGUI[id .. "ques"] and QuestionVGUI[id .. "ques"]:IsValid() then
		QuestionVGUI[id .. "ques"]:Close()
	end
end
usermessage.Hook("KillQuestionVGUI", KillQuestionVGUI)

local function DoVoteAnswerQuestion(ply, cmd, args)
	if not args[1] then return end

	local vote = 2
	if tonumber(args[1]) == 1 or string.lower(args[1]) == "yes" or string.lower(args[1]) == "true" then vote = 1 end

	for k,v in pairs(VoteVGUI) do
		if ValidPanel(v) then
			local ID = string.sub(k, 1, -5)
			VoteVGUI[k]:Close()
			RunConsoleCommand("vote", ID, vote)
			return
		end
	end

	for k,v in pairs(QuestionVGUI) do
		if ValidPanel(v) then
			local ID = string.sub(k, 1, -5)
			QuestionVGUI[k]:Close()
			RunConsoleCommand("ans", ID, vote)
			return
		end
	end
end
concommand.Add("rp_vote", DoVoteAnswerQuestion)

local function DoLetter(msg)
	LetterWritePanel = vgui.Create("Frame")
	LetterWritePanel:SetPos(ScrW() / 2 - 75, ScrH() / 2 - 100)
	LetterWritePanel:SetSize(150, 200)
	LetterWritePanel:SetMouseInputEnabled(true)
	LetterWritePanel:SetKeyboardInputEnabled(true)
	LetterWritePanel:SetVisible(true)
end
usermessage.Hook("DoLetter", DoLetter)

local F4Menu
local F4MenuTabs
local F4Tabs
local hasReleasedF4 = false
local function ChangeJobVGUI()
	if not F4Menu or not F4Menu:IsValid() then
		F4Menu = vgui.Create("DFrame")
		F4Menu:SetSize(770, 580)
		F4Menu:Center()
		F4Menu:SetVisible( true )
		F4Menu:MakePopup( )
		F4Menu:SetTitle("Options menu")
		F4Tabs = {GAMEMODE:MoneyTab(), GAMEMODE:JobsTab(), GAMEMODE:EntitiesTab(), GAMEMODE:RPHUDTab()}
		F4Menu:SetSkin("DarkRP")
	else
		F4Menu:SetVisible(true)
		F4Menu:SetSkin("DarkRP")
	end

	hasReleasedF4 = false

	function F4Menu:Think()

		if input.IsKeyDown(KEY_F4) and hasReleasedF4 then
			self:Close()
		elseif not input.IsKeyDown(KEY_F4) then
			hasReleasedF4 = true
		end
		if (!self.Dragging) then return end
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]
		x = math.Clamp( x, 0, ScrW() - self:GetWide() )
		y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		self:SetPos( x, y )
	end

	if not F4MenuTabs or not F4MenuTabs:IsValid() then
		F4MenuTabs = vgui.Create("DPropertySheet", F4Menu)
		F4MenuTabs:SetPos(5, 25)
		F4MenuTabs:SetSize(760, 550)
		--The tabs: Look in showteamtabs.lua for more info
		F4MenuTabs:AddSheet("Money/Commands", F4Tabs[1], "icon16/money.png", false, false)
		F4MenuTabs:AddSheet("Jobs", F4Tabs[2], "icon16/user_suit.png", false, false)
		F4MenuTabs:AddSheet("Entities/weapons", F4Tabs[3], "icon16/cart.png", false, false)
		F4MenuTabs:AddSheet("HUD", F4Tabs[4], "icon16/camera.png", false, false)
	end

	for _, panel in pairs(F4Tabs) do panel:Update() panel:SetSkin("DarkRP") end

 	function F4Menu:Close()
		F4Menu:SetVisible(false)
		F4Menu:SetSkin("DarkRP")
	end

	F4Menu:SetSkin("DarkRP")
end
usermessage.Hook("ChangeJobVGUI", ChangeJobVGUI)

local KeyFrameVisible = false
local function KeysMenu(um)
	local Vehicle = um:ReadBool()
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
	local Entiteh = "door"
	if Vehicle then
		Entiteh = "vehicle"
	end
	Frame:SetTitle(Entiteh .. " options")

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
		Owndoor:SetText("Sell " .. Entiteh)
		Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end

		local AddOwner = vgui.Create("DButton", Frame)
		AddOwner:SetPos(10, 140)
		AddOwner:SetSize(180, 100)
		AddOwner:SetText("Add owner")
		AddOwner.DoClick = function()
			local menu = DermaMenu()
			menu.found = false
			for k,v in pairs(player.GetAll()) do
				if not trace.Entity:OwnedBy(v) and not trace.Entity:AllowedToOwn(v) then
					menu.found = true
					menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ao ".. v:UserID()) end)
				end
			end
			if not menu.found then
				menu:AddOption("Noone available", function() end)
			end
			menu:Open()
		end

		local RemoveOwner = vgui.Create("DButton", Frame)
		RemoveOwner:SetPos(10, 250)
		RemoveOwner:SetSize(180, 100)
		RemoveOwner:SetText("Remove owner")
		RemoveOwner.DoClick = function()
			local menu = DermaMenu()
			for k,v in pairs(player.GetAll()) do
				if (trace.Entity:OwnedBy(v) and not trace.Entity:IsMasterOwner(v)) or trace.Entity:AllowedToOwn(v) then
					menu.found = true
					menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ro ".. v:UserID()) end)
				end
			end
			if not menu.found then
				menu:AddOption("Noone available", function() end)
			end
			menu:Open()
		end

		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, 360)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText("Set "..Entiteh.." title")
		if not trace.Entity:IsMasterOwner(LocalPlayer()) then
			RemoveOwner.m_bDisabled = true
		end
		DoorTitle.DoClick = function()
			Derma_StringRequest("Set door title", "Set the title of the "..Entiteh.." you're looking at", "", function(text)
				LocalPlayer():ConCommand("say /title ".. text)
				if ValidPanel(Frame) then
					Frame:Close()
				end
			end,
			function() end, "OK!", "CANCEL!")
		end

		if LocalPlayer():IsSuperAdmin() and not Vehicle then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("Edit Door Group")
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu("Door Groups")
				local teams = menu:AddSubMenu("Jobs")
				local add = teams:AddSubMenu("Add")
				local remove = teams:AddSubMenu("Remove")

				menu:AddOption("None", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end

				if not trace.Entity.DoorData then return end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption( v.name, function() RunConsoleCommand("say", "/toggleteamownable " ..k) Frame:Close() end )
					else
						remove:AddOption( v.name, function() RunConsoleCommand("say", "/toggleteamownable " ..k) Frame:Close() end )
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
			Owndoor:SetText("Buy " .. Entiteh)
			Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end
		end

		if LocalPlayer():IsSuperAdmin() then
			if trace.Entity.DoorData.GroupOwn then
				Frame:SetSize(200, 250)
			else
				Frame:SetSize(200, 360)
			end

			local DisableOwnage = vgui.Create("DButton", Frame)
			DisableOwnage:SetPos(10, Frame:GetTall() - 220)
			DisableOwnage:SetSize(180, 100)
			DisableOwnage:SetText("Disallow ownership")
			DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end

			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("Edit Door Group")
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu("Door Groups")
				local teams = menu:AddSubMenu("Jobs")
				local add = teams:AddSubMenu("Add")
				local remove = teams:AddSubMenu("Remove")

				menu:AddOption("None", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end

				if not trace.Entity.DoorData then return end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption(v.name, function() RunConsoleCommand("say", "/toggleteamownable " .. k) if Frame.Close then Frame:Close() end end)
					else
						remove:AddOption(v.name, function() RunConsoleCommand("say", "/toggleteamownable " .. k) Frame:Close() end)
					end
				end

				menu:Open()
			end
		elseif not trace.Entity.DoorData.GroupOwn then
			RunConsoleCommand("say", "/toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 140)
		local Owndoor = vgui.Create("DButton", Frame)
		Owndoor:SetPos(10, 30)
		Owndoor:SetSize(180, 100)
		Owndoor:SetText("Co-own " .. Entiteh)
		Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end

		if LocalPlayer():IsSuperAdmin() then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("Edit Door Group")
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu("Door Groups")
				local teams = menu:AddSubMenu("Jobs")
				local add = teams:AddSubMenu("Add")
				local remove = teams:AddSubMenu("Remove")

				menu:AddOption("None", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end

				if not trace.Entity.DoorData then return end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption( v.name, function() RunConsoleCommand("say", "/toggleteamownable " ..k) Frame:Close() end )
					else
						remove:AddOption( v.name, function() RunConsoleCommand("say", "/toggleteamownable " ..k) Frame:Close() end )
					end
				end

				menu:Open()
			end
		else
			RunConsoleCommand("say", "/toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif LocalPlayer():IsSuperAdmin() and trace.Entity.DoorData.NonOwnable then
		Frame:SetSize(200, 250)
		local EnableOwnage = vgui.Create("DButton", Frame)
		EnableOwnage:SetPos(10, 30)
		EnableOwnage:SetSize(180, 100)
		EnableOwnage:SetText("Allow ownership")
		EnableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end

		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, Frame:GetTall() - 110)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText("Set "..Entiteh.." title")
		DoorTitle.DoClick = function()
			Derma_StringRequest("Set door title", "Set the title of the "..Entiteh.." you're looking at", "", function(text) LocalPlayer():ConCommand("say /title ".. text) Frame:Close() end, function() end, "OK!", "CANCEL!")
		end
	elseif LocalPlayer():IsSuperAdmin() and not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 250)
		local DisableOwnage = vgui.Create("DButton", Frame)
		DisableOwnage:SetPos(10, 30)
		DisableOwnage:SetSize(180, 100)
		DisableOwnage:SetText("Disallow ownership")
		DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end

		local SetCopsOnly = vgui.Create("DButton", Frame)
		SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
		SetCopsOnly:SetSize(180, 100)
		SetCopsOnly:SetText("Edit Door Group")
			SetCopsOnly.DoClick = function()
				local menu = DermaMenu()
				local groups = menu:AddSubMenu("Door Groups")
				local teams = menu:AddSubMenu("Jobs")
				local add = teams:AddSubMenu("Add")
				local remove = teams:AddSubMenu("Remove")

				if not trace.Entity.DoorData then return end

				menu:AddOption("None", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					groups:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end

				for k,v in pairs(RPExtraTeams) do
					if not trace.Entity.DoorData.TeamOwn or not trace.Entity.DoorData.TeamOwn[k] then
						add:AddOption( v.name, function() RunConsoleCommand("say", "/toggleteamownable " ..k) Frame:Close() end )
					else
						remove:AddOption( v.name, function() RunConsoleCommand("say", "/toggleteamownable " ..k) Frame:Close() end )
					end
				end

				menu:Open()
			end
	else
		Frame:Close()
	end

	Frame:SetSkin("DarkRP")
end
usermessage.Hook("KeysMenu", KeysMenu)