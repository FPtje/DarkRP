CreateClientConVar("rp_playermodel", "", true, true)

local function MayorOptns()
	local MayCat = vgui.Create("DCollapsibleCategory")
	function MayCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MayCat:SetLabel("Mayor options")
		local maypanel = vgui.Create("DPanelList")
		maypanel:SetSpacing(5)
		maypanel:SetSize(740,170)
		maypanel:EnableHorizontal(false)
		maypanel:EnableVerticalScrollbar(true)
			local SearchWarrant = vgui.Create("DButton")
			SearchWarrant:SetText(LANGUAGE.give_money)
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply.DarkRPVars.warrant and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("Warrant", "Why would you warrant "..ply:Nick().."?", nil,
								function(a)
								LocalPlayer():ConCommand("say /warrant ".. tostring(ply:UserID()).." ".. a)
								end, function() end ) end)
					end
				end
				if #menu.Items == 0 then
					menu:AddOption(LANGUAGE.noone_available, function() end)
				end
				menu:Open()
			end
			maypanel:AddItem(SearchWarrant)

			local Warrant = vgui.Create("DButton")
			Warrant:SetText(LANGUAGE.make_wanted)
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply.DarkRPVars.wanted and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() Derma_StringRequest("wanted", "Why would you make "..ply:Nick().." wanted?", nil,
								function(a)
								LocalPlayer():ConCommand("say /wanted ".. tostring(ply:UserID()).." ".. a)
								end, function() end ) end)
					end
				end
				if #menu.Items == 0 then
					menu:AddOption("Noone available", function() end)
				end
				menu:Open()
			end
			maypanel:AddItem(Warrant)

			local UnWarrant = vgui.Create("DButton")
			UnWarrant:SetText(LANGUAGE.make_unwanted)
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply.DarkRPVars.wanted and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /unwanted " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Items == 0 then
					menu:AddOption(LANGUAGE.noone_available, function() end)
				end
				menu:Open()
			end
			maypanel:AddItem(UnWarrant)

			local Lockdown = vgui.Create("DButton")
			Lockdown:SetText(LANGUAGE.initiate_lockdown)
			Lockdown.DoClick = function()
				LocalPlayer():ConCommand("say /lockdown")
			end
			maypanel:AddItem(Lockdown)


			local UnLockdown = vgui.Create("DButton")
			UnLockdown:SetText(LANGUAGE.stop_lockdown)
			UnLockdown.DoClick = function()
				LocalPlayer():ConCommand("say /unlockdown")
			end
			maypanel:AddItem(UnLockdown)

			local Lottery = vgui.Create("DButton")
			Lottery:SetText(LANGUAGE.start_lottery)
			Lottery.DoClick = function()
				LocalPlayer():ConCommand("say /lottery")
			end
			maypanel:AddItem(Lottery)

			local GiveLicense = vgui.Create("DButton")
			GiveLicense:SetText(LANGUAGE.give_license_lookingat)
			GiveLicense.DoClick = function()
				LocalPlayer():ConCommand("say /givelicense")
			end
			maypanel:AddItem(GiveLicense)

			local Proplympics = vgui.Create("DButton")
			Proplympics:SetText("Organize proplympics!")
			Proplympics.DoClick = function()
				LocalPlayer():ConCommand("say /proplympics")
			end
			maypanel:AddItem(Proplympics)

			local PlaceLaws = vgui.Create("DButton")
			PlaceLaws:SetText("Place a screen containing the laws.")
			PlaceLaws.DoClick = function()
				LocalPlayer():ConCommand("say /placelaws")
			end
			maypanel:AddItem(PlaceLaws)

			local AddLaws = vgui.Create("DButton")
			AddLaws:SetText("Add a law.")
			AddLaws.DoClick = function()
				Derma_StringRequest("Add a law", "Type the law you would like to add here.", "", function(law)
					LocalPlayer():ConCommand("say /addlaw " .. law)
				end)
			end
			maypanel:AddItem(AddLaws)

			local RemLaws = vgui.Create("DButton")
			RemLaws:SetText("Remove a law.")
			RemLaws.DoClick = function()
				Derma_StringRequest("Remove a law", "Enter the number of the law you would like to remove here.", "", function(num)
					LocalPlayer():ConCommand("say /removelaw " .. num)
				end)
			end
			maypanel:AddItem(RemLaws)
	MayCat:SetContents(maypanel)
	MayCat:SetSkin("DarkRP")
	return MayCat
end

local function CPOptns()
	local CPCat = vgui.Create("DCollapsibleCategory")
	function CPCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CPCat:SetLabel("Police options")
		local CPpanel = vgui.Create("DPanelList")
		CPpanel:SetSpacing(5)
		CPpanel:SetSize(740,170)
		CPpanel:EnableHorizontal(false)
		CPpanel:EnableVerticalScrollbar(true)
			local SearchWarrant = vgui.Create("DButton")
			SearchWarrant:SetText(LANGUAGE.request_warrant)
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply.DarkRPVars.warrant and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("Warrant", "Why would you warrant "..ply:Nick().."?", nil,
								function(a)
								LocalPlayer():ConCommand("say /warrant ".. tostring(ply:UserID()).." ".. a)
								end, function() end ) end)
					end
				end
				if #menu.Items == 0 then
					menu:AddOption(LANGUAGE.noone_available, function() end)
				end
				menu:Open()
			end
			CPpanel:AddItem(SearchWarrant)

			local Warrant = vgui.Create("DButton")
			Warrant:SetText(LANGUAGE.searchwarrantbutton)
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply.DarkRPVars.wanted and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() Derma_StringRequest("wanted", "Why would you make "..ply:Nick().." wanted?", nil,
								function(a)
								LocalPlayer():ConCommand("say /wanted ".. tostring(ply:UserID()).." ".. a)
								end, function() end ) end)
					end
				end
				if #menu.Items == 0 then
					menu:AddOption(LANGUAGE.noone_available, function() end)
				end
				menu:Open()
			end
			CPpanel:AddItem(Warrant)

			local UnWarrant = vgui.Create("DButton")
			UnWarrant:SetText(LANGUAGE.unwarrantbutton)
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply.DarkRPVars.wanted and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("say /unwanted " .. tostring(ply:UserID())) end)
					end
				end
				if #menu.Items == 0 then
					menu:AddOption(LANGUAGE.noone_available, function() end)
				end
				menu:Open()
			end
			CPpanel:AddItem(UnWarrant)

			if LocalPlayer():Team() == TEAM_CHIEF or LocalPlayer():IsAdmin() then
				local SetJailPos = vgui.Create("DButton")
				SetJailPos:SetText(LANGUAGE.set_jailpos)
				SetJailPos.DoClick = function() LocalPlayer():ConCommand("say /jailpos") end
				CPpanel:AddItem(SetJailPos)

				local AddJailPos = vgui.Create("DButton")
				AddJailPos:SetText(LANGUAGE.add_jailpos)
				AddJailPos.DoClick = function() LocalPlayer():ConCommand("say /addjailpos") end
				CPpanel:AddItem(AddJailPos)
			end

			local ismayor -- Firstly look if there's a mayor
			local ischief -- Then if there's a chief
			for k,v in pairs(player.GetAll()) do
				if v:Team() == TEAM_MAYOR then
					ismayor = true
					break
				end
			end

			if not ismayor then
				for k,v in pairs(player.GetAll()) do
					if v:Team() == TEAM_CHIEF then
						ischief = true
						break
					end
				end
			end

			local Team = LocalPlayer():Team()
			if not ismayor and (Team == TEAM_CHIEF or (not ischief and Team == TEAM_POLICE)) then
				local GiveLicense = vgui.Create("DButton")
				GiveLicense:SetText(LANGUAGE.give_license_lookingat)
				GiveLicense.DoClick = function()
					LocalPlayer():ConCommand("say /givelicense")
				end
				CPpanel:AddItem(GiveLicense)
			end
	CPCat:SetContents(CPpanel)
	CPCat:SetSkin("DarkRP")
	return CPCat
end


local function CitOptns()
	local CitCat = vgui.Create("DCollapsibleCategory")
	function CitCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CitCat:SetLabel("Citizen options")
		local Citpanel = vgui.Create("DPanelList")
		Citpanel:SetSpacing(5)
		Citpanel:SetSize(740,110)
		Citpanel:EnableHorizontal(false)
		Citpanel:EnableVerticalScrollbar(true)

		local joblabel = vgui.Create("DLabel")
		joblabel:SetText(LANGUAGE.set_custom_job)
		Citpanel:AddItem(joblabel)

		local jobentry = vgui.Create("DTextEntry")
		jobentry:SetValue(LocalPlayer().DarkRPVars.job or "")
		jobentry.OnEnter = function()
			LocalPlayer():ConCommand("say /job " .. tostring(jobentry:GetValue()))
		end
		jobentry.OnLoseFocus = jobentry.OnEnter
		Citpanel:AddItem(jobentry)

	CitCat:SetContents(Citpanel)
	CitCat:SetSkin("DarkRP")
	return CitCat
end


local function MobOptns()
	local MobCat = vgui.Create("DCollapsibleCategory")
	function MobCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MobCat:SetLabel("Mobboss options")
		local Mobpanel = vgui.Create("DPanelList")
		Mobpanel:SetSpacing(5)
		Mobpanel:SetSize(740,110)
		Mobpanel:EnableHorizontal(false)
		Mobpanel:EnableVerticalScrollbar(true)

		local agendalabel = vgui.Create("DLabel")
		agendalabel:SetText(LANGUAGE.set_agenda)
		Mobpanel:AddItem(agendalabel)

		local agendaentry = vgui.Create("DTextEntry")
		agendaentry:SetValue(LocalPlayer().DarkRPVars.agenda or "")
		agendaentry.OnEnter = function()
			LocalPlayer():ConCommand("say /agenda " .. tostring(agendaentry:GetValue()))
		end
		agendaentry.OnLoseFocus = agendaentry.OnEnter
		Mobpanel:AddItem(agendaentry)

	MobCat:SetContents(Mobpanel)
	MobCat:SetSkin("DarkRP")
	return MobCat
end

function GM:MoneyTab()
	local FirstTabPanel = vgui.Create("DPanelList")
	FirstTabPanel:EnableVerticalScrollbar( true )
		function FirstTabPanel:Update()
			self:Clear(true)
			local MoneyCat = vgui.Create("DCollapsibleCategory")
			MoneyCat:SetLabel("Money")
				local MoneyPanel = vgui.Create("DPanelList")
				MoneyPanel:SetSpacing(5)
				MoneyPanel:SetSize(740,60)
				MoneyPanel:EnableHorizontal(false)
				MoneyPanel:EnableVerticalScrollbar(true)

				local GiveMoneyButton = vgui.Create("DButton")
				GiveMoneyButton:SetText(LANGUAGE.give_money)
				GiveMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to give?", "", function(a) LocalPlayer():ConCommand("say /give " .. tostring(a)) end)
				end
				MoneyPanel:AddItem(GiveMoneyButton)
				local SpawnMoneyButton = vgui.Create("DButton")
				SpawnMoneyButton:SetText(LANGUAGE.drop_money)
				SpawnMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to drop?", "", function(a) LocalPlayer():ConCommand("say /dropmoney " .. tostring(a)) end)
				end

				MoneyPanel:AddItem(SpawnMoneyButton)
			MoneyCat:SetContents(MoneyPanel)
			MoneyCat:SetSkin("DarkRP")


			local Commands = vgui.Create("DCollapsibleCategory")
			Commands:SetLabel("Actions")
				local ActionsPanel = vgui.Create("DPanelList")
				ActionsPanel:SetSpacing(5)
				ActionsPanel:SetSize(740,210)
				ActionsPanel:EnableHorizontal( false )
				ActionsPanel:EnableVerticalScrollbar(true)
					local rpnamelabel = vgui.Create("DLabel")
					rpnamelabel:SetText(LANGUAGE.change_name)
				ActionsPanel:AddItem(rpnamelabel)

					local rpnameTextbox = vgui.Create("DTextEntry")
					rpnameTextbox:SetText(LocalPlayer():Nick())
					rpnameTextbox.OnEnter = function() LocalPlayer():ConCommand("say /rpname " .. tostring(rpnameTextbox:GetValue())) end
					rpnameTextbox.OnLoseFocus = function() LocalPlayer():ConCommand("say /rpname " .. tostring(rpnameTextbox:GetValue())) end

					ActionsPanel:AddItem(rpnameTextbox)

					local sleep = vgui.Create("DButton")
					sleep:SetText(LANGUAGE.go_to_sleep)
					sleep.DoClick = function()
						LocalPlayer():ConCommand("say /sleep")
					end
				ActionsPanel:AddItem(sleep)
					local Drop = vgui.Create("DButton")
					Drop:SetText(LANGUAGE.drop_weapon)
					Drop.DoClick = function() LocalPlayer():ConCommand("say /drop") end
				ActionsPanel:AddItem(Drop)
					local health = vgui.Create("DButton")
					health:SetText(string.format(LANGUAGE.buy_health, tostring(GetConVarNumber("healthcost"))))
					health.DoClick = function() LocalPlayer():ConCommand("say /Buyhealth") end
				ActionsPanel:AddItem(health)

				if LocalPlayer():Team() ~= TEAM_MAYOR then
					local RequestLicense = vgui.Create("DButton")
						RequestLicense:SetText(LANGUAGE.request_gunlicense)
						RequestLicense.DoClick = function() LocalPlayer():ConCommand("say /requestlicense") end
					ActionsPanel:AddItem(RequestLicense)
				end

				local Demote = vgui.Create("DButton")
				Demote:SetText(LANGUAGE.demote_player_menu)
				Demote.DoClick = function()
					local menu = DermaMenu()
					for _,ply in pairs(player.GetAll()) do
						if ply ~= LocalPlayer() then
							menu:AddOption(ply:Nick(), function()
								Derma_StringRequest("Demote reason", "Why would you demote "..ply:Nick().."?", nil,
									function(a)
									LocalPlayer():ConCommand("say /demote ".. tostring(ply:UserID()).." ".. a)
									end, function() end )
							end)
						end
					end
					if #menu.Items == 0 then
						menu:AddOption(LANGUAGE.noone_available, function() end)
					end
					menu:Open()
				end
				ActionsPanel:AddItem(Demote)

				local UnOwnAllDoors = vgui.Create("DButton")
						UnOwnAllDoors:SetText("Sell all of your doors")
						UnOwnAllDoors.DoClick = function() LocalPlayer():ConCommand("say /unownalldoors") end
					ActionsPanel:AddItem(UnOwnAllDoors)
			Commands:SetContents(ActionsPanel)
		FirstTabPanel:AddItem(MoneyCat)
		Commands:SetSkin("DarkRP")
		FirstTabPanel:AddItem(Commands)

		if LocalPlayer():Team() == TEAM_MAYOR then
			FirstTabPanel:AddItem(MayorOptns())
		elseif LocalPlayer():Team() == TEAM_CITIZEN then
			FirstTabPanel:AddItem(CitOptns())
		elseif LocalPlayer():Team() == TEAM_POLICE or LocalPlayer():Team() == TEAM_CHIEF then
			FirstTabPanel:AddItem(CPOptns())
		elseif LocalPlayer():Team() == TEAM_MOB then
			FirstTabPanel:AddItem(MobOptns())
		end
	end
	FirstTabPanel:Update()
	return FirstTabPanel
end

function GM:JobsTab()
	local hordiv = vgui.Create("DHorizontalDivider")
	hordiv:SetLeftWidth(370)
	function hordiv.m_DragBar:OnMousePressed() end
	hordiv.m_DragBar:SetCursor("none")
	local Panel
	local Information
	function hordiv:Update()
		if Panel and Panel:IsValid() then
			Panel:Remove()
		end
		Panel = vgui.Create( "DPanelList")
		Panel:SetSize(370, 540)
		Panel:SetSpacing(1)
		Panel:EnableHorizontal( true )
		Panel:EnableVerticalScrollbar( true )
		Panel:SetSkin("DarkRP")


		local Info = {}
		local model
		local modelpanel
		local function UpdateInfo(a)
			if Information and Information:IsValid() then
				Information:Remove()
			end
			Information = vgui.Create( "DPanelList" )
			Information:SetPos(378,0)
			Information:SetSize(370, 540)
			Information:SetSpacing(10)
			Information:EnableHorizontal( false )
			Information:EnableVerticalScrollbar( true )
			Information:SetSkin("DarkRP")
			function Information:Rebuild() -- YES IM OVERRIDING IT AND CHANGING ONLY ONE LINE BUT I HAVE A FUCKING GOOD REASON TO DO IT!
				local Offset = 0
				if ( self.Horizontal ) then
					local x, y = self.Padding, self.Padding;
					for k, panel in pairs( self.Items ) do
						local w = panel:GetWide()
						local h = panel:GetTall()
						if ( x + w  > self:GetWide() ) then
							x = self.Padding
							y = y + h + self.Spacing
						end
						panel:SetPos( x, y )
						x = x + w + self.Spacing
						Offset = y + h + self.Spacing
					end
				else
					for k, panel in pairs( self.Items ) do
						if not panel:IsValid() then return end
						panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
						panel:SetPos( self.Padding, self.Padding + Offset )
						panel:InvalidateLayout( true )
						Offset = Offset + panel:GetTall() + self.Spacing
					end
					Offset = Offset + self.Padding
				end
				self:GetCanvas():SetTall( Offset + (self.Padding) - self.Spacing )
			end

			if type(Info) == "table" and #Info > 0 then
				for k,v in ipairs(Info) do
					local label = vgui.Create("DLabel")
					label:SetText(v)
					label:SizeToContents()
					if label:IsValid() then
						Information:AddItem(label)
					end
				end
			end

			if model and type(model) == "string" and a ~= false then
				modelpanel = vgui.Create("DModelPanel")
				modelpanel:SetModel(model)
				modelpanel:SetSize(90,230)
				modelpanel:SetAnimated(true)
				modelpanel:SetFOV(90)
				modelpanel:SetAnimSpeed(1)
				if modelpanel:IsValid() then
					Information:AddItem(modelpanel)
				end
			end
			hordiv:SetLeft(Panel)
			hordiv:SetRight(Information)
		end
		UpdateInfo()

		local function AddIcon(Model, name, description, Weapons, command, special, specialcommand)
			local icon = vgui.Create("SpawnIcon")
			local IconModel = Model
			if type(Model) == "table" then
				IconModel = Model[math.random(#Model)]
			end
			icon:SetModel(IconModel)

			icon:SetIconSize(120)
			icon:SetToolTip()
			icon.OnCursorEntered = function()
				icon.PaintOverOld = icon.PaintOver
				icon.PaintOver = icon.PaintOverHovered
				Info[1] = LANGUAGE.job_name .. name
				Info[2] = LANGUAGE.job_description .. description
				Info[3] = LANGUAGE.job_weapons .. Weapons
				model = IconModel
				UpdateInfo()
			end
			icon.OnCursorExited = function()
				if ( icon.PaintOver == icon.PaintOverHovered ) then
					icon.PaintOver = icon.PaintOverOld
				end
				Info = {}
				if modelpanel and modelpanel:IsValid() and icon:IsValid() then
					modelpanel:Remove()
					UpdateInfo(false)
				end
			end

			icon.DoClick = function()
				local function DoChatCommand(frame)
					if special then
						local menu = DermaMenu()
						menu:AddOption("Vote", function() LocalPlayer():ConCommand("say "..command) frame:Close() end)
						menu:AddOption("Do not vote", function() LocalPlayer():ConCommand("say " .. specialcommand) frame:Close() end)
						menu:Open()
					else
						LocalPlayer():ConCommand("say " .. command)
						frame:Close()
					end
				end

				if type(Model) == "table" and #Model > 0 then
					hordiv:GetParent():GetParent():Close()
					local frame = vgui.Create( "DFrame" )
					frame:SetTitle( "Choose model" )
					frame:SetVisible(true)
					frame:MakePopup()

					local levels = 1
					local IconsPerLevel = math.floor(ScrW()/64)

					while #Model * (64/levels) > ScrW() do
						levels = levels + 1
					end
					frame:SetSize(math.Min(#Model * 64, IconsPerLevel*64), math.Min(90+(64*(levels-1)), ScrH()))
					frame:Center()

					local CurLevel = 1
					for k,v in pairs(Model) do
						local icon = vgui.Create("SpawnIcon", frame)
						if (k-IconsPerLevel*(CurLevel-1)) > IconsPerLevel then
							CurLevel = CurLevel + 1
						end
						icon:SetPos((k-1-(CurLevel-1)*IconsPerLevel) * 64, 25+(64*(CurLevel-1)))
						icon:SetModel(v)
						icon:SetIconSize(64)
						icon:SetToolTip()
						icon.DoClick = function()
							RunConsoleCommand("rp_playermodel", v)
							RunConsoleCommand("_rp_ChosenModel", v)
							DoChatCommand(frame)
						end
					end
				else
					DoChatCommand(hordiv:GetParent():GetParent())
				end
			end

			if icon:IsValid() then
				Panel:AddItem(icon)
			end
		end

		for k,v in ipairs(RPExtraTeams) do
			if LocalPlayer():Team() ~= k then
				local nodude = true
				if v.admin == 1 and not LocalPlayer():IsAdmin() then
					nodude = false
				end
				if v.admin > 1 and not LocalPlayer():IsSuperAdmin() then
					nodude = false
				end
				if v.customCheck and not v.customCheck(LocalPlayer()) then
					nodude = false
				end

				if (type(v.NeedToChangeFrom) == "number" and LocalPlayer():Team() ~= v.NeedToChangeFrom) or (type(v.NeedToChangeFrom) == "table" and not table.HasValue(v.NeedToChangeFrom, LocalPlayer():Team())) then
					nodude = false
				end

				if nodude then
					local weps = "no extra weapons"
					if #v.Weapons > 0 then
						weps = table.concat(v.Weapons, "\n")
					end
					if v.Vote then
						local condition = ((v.admin == 0 and LocalPlayer():IsAdmin()) or (v.admin == 1 and LocalPlayer():IsSuperAdmin()) or LocalPlayer().DarkRPVars["Priv"..v.command])
						if not v.model or not v.name or not v.Des or not v.command then chat.AddText(Color(255,0,0,255), "Incorrect team! Fix your shared.lua!") return end
						AddIcon(v.model, v.name, v.Des, weps, "/vote"..v.command, condition, "/"..v.command)
					else
						if not v.model or not v.name or not v.Des or not v.command then chat.AddText(Color(255,0,0,255), "Incorrect team! Fix your shared.lua!") return end
						AddIcon(v.model, v.name, v.Des, weps, "/"..v.command)
					end
				end
			end
		end
	end
	hordiv:Update()
	return hordiv
end

function GM:EntitiesTab()
	local EntitiesPanel = vgui.Create("DPanelList")
	EntitiesPanel:EnableVerticalScrollbar( true )
		function EntitiesPanel:Update()
			self:Clear(true)
			local WepCat = vgui.Create("DCollapsibleCategory")
			WepCat:SetLabel("Weapons")
				local WepPanel = vgui.Create("DPanelList")
				WepPanel:SetSize(470, 100)
				WepPanel:SetAutoSize(true)
				WepPanel:SetSpacing(1)
				WepPanel:EnableHorizontal(true)
				WepPanel:EnableVerticalScrollbar(true)
					local function AddIcon(Model, description, command)
						local icon = vgui.Create("SpawnIcon")
						icon:InvalidateLayout( true )
						icon:SetModel(Model)
						icon:SetIconSize(64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("say "..command) end
						WepPanel:AddItem(icon)
					end

					for k,v in pairs(CustomShipments) do
						if (v.seperate and (GetConVarNumber("restrictbuypistol") == 0 or
							(GetConVarNumber("restrictbuypistol") == 1 and (not v.allowed[1] or table.HasValue(v.allowed, LocalPlayer():Team())))))
							and (not v.customCheck or v.customCheck and v.customCheck(LocalPlayer())) then
							AddIcon(v.model, string.format(LANGUAGE.buy_a, "a "..v.name, CUR..(v.pricesep or "")), "/buy "..v.name)
						end
					end

					for k,v in pairs(GAMEMODE.AmmoTypes) do
						if not v.customCheck or v.customCheck(LocalPlayer()) then
							AddIcon(v.model, string.format(LANGUAGE.buy_a, v.name, CUR .. v.price), "/buyammo " .. v.ammoType)
						end
					end
			WepCat:SetContents(WepPanel)
			WepCat:SetSkin("DarkRP")
			self:AddItem(WepCat)

			local EntCat = vgui.Create("DCollapsibleCategory")
			EntCat:SetLabel("Entities")
				local EntPanel = vgui.Create("DPanelList")
				EntPanel:SetSize(470, 200)
				EntPanel:SetAutoSize(true)
				EntPanel:SetSpacing(1)
				EntPanel:EnableHorizontal(true)
				EntPanel:EnableVerticalScrollbar(true)
					local function AddEntIcon(Model, description, command)
						local icon = vgui.Create("SpawnIcon")
						icon:InvalidateLayout( true )
						icon:SetModel(Model)
						icon:SetIconSize(64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("say "..command) end
						EntPanel:AddItem(icon)
					end

					for k,v in pairs(DarkRPEntities) do
						if not v.allowed or (type(v.allowed) == "table" and table.HasValue(v.allowed, LocalPlayer():Team()))
							and (not v.customCheck or (v.customCheck and v.customCheck(LocalPlayer()))) then
							local cmdname = string.gsub(v.ent, " ", "_")

							if not tobool(GetConVarNumber("disable"..cmdname)) then
								local price = GetConVarNumber(cmdname.."_price")
								if price == 0 then
									price = v.price
								end
								AddEntIcon(v.model, "Buy a " .. v.name .." " .. CUR .. price, v.cmd)
							end
						end
					end

					if FoodItems and (GetConVarNumber("foodspawn") ~= 0 or LocalPlayer():Team() == TEAM_COOK) and (GetConVarNumber("hungermod") == 1 or LocalPlayer():Team() == TEAM_COOK) then
						for k,v in pairs(FoodItems) do
							AddEntIcon(v.model, string.format(LANGUAGE.buy_a, "a "..k, "a few bucks"), "/buyfood "..k)
						end
					end
					for k,v in pairs(CustomShipments) do
						if not v.noship and table.HasValue(v.allowed, LocalPlayer():Team())
							and (not v.customCheck or (v.customCheck and v.customCheck(LocalPlayer()))) then
							AddEntIcon(v.model, string.format(LANGUAGE.buy_a, "a "..v.name .." shipment", CUR .. tostring(v.price)), "/buyshipment "..v.name)
						end
					end
			EntCat:SetContents(EntPanel)
			EntCat:SetSkin("DarkRP")
			self:AddItem(EntCat)


			if #CustomVehicles <= 0 then return end
			local VehicleCat = vgui.Create("DCollapsibleCategory")
			VehicleCat:SetLabel("Vehicles")
				local VehiclePanel = vgui.Create("DPanelList")
				VehiclePanel:SetSize(470, 200)
				VehiclePanel:SetAutoSize(true)
				VehiclePanel:SetSpacing(1)
				VehiclePanel:EnableHorizontal(true)
				VehiclePanel:EnableVerticalScrollbar(true)
				local function AddVehicleIcon(Model, skin, description, command)
					local icon = vgui.Create("SpawnIcon")
					icon:InvalidateLayout( true )
					icon:SetModel(Model)
					icon:SetSkin(skin)
					icon:SetIconSize(64)
					icon:SetToolTip(description)
					icon.DoClick = function() LocalPlayer():ConCommand("say "..command) end
					VehiclePanel:AddItem(icon)
				end

				local founds = 0
				for k,v in pairs(CustomVehicles) do
					if not v.allowed or table.HasValue(v.allowed, LocalPlayer():Team()) then
						local Skin = (list.Get("Vehicles")[v.name] and list.Get("Vehicles")[v.name].KeyValues and list.Get("Vehicles")[v.name].KeyValues.Skin) or "0"
						AddVehicleIcon(v.model or "models/buggy.mdl", Skin, "Buy a "..v.name.." for "..CUR..v.price, "/buyvehicle "..v.name)
						founds = founds + 1
					end
				end
			if founds ~= 0 then
				VehicleCat:SetContents(VehiclePanel)
				VehicleCat:SetSkin("DarkRP")
				self:AddItem(VehicleCat)
			else
				VehiclePanel:Remove()
				VehicleCat:Remove()
			end
		end
	EntitiesPanel:SetSkin("DarkRP")
	EntitiesPanel:Update()
	return EntitiesPanel
end

function GM:RPHUDTab()
	local HUDTABpanel = vgui.Create("DPanelList")
	HUDTABpanel:SetSpacing(21)
	HUDTABpanel:SetSize(750, 550)
	HUDTABpanel:EnableHorizontal( true	)
	HUDTABpanel:EnableVerticalScrollbar( true )
	function HUDTABpanel:Update()
		self:Clear(true)

		backgrndcat = vgui.Create("DCollapsibleCategory")
		backgrndcat:SetSize(230, 130)
		function backgrndcat.Header:OnMousePressed() end
		backgrndcat:SetLabel("HUD background")
			local backgrndpanel = vgui.Create("DPanelList")
			backgrndpanel:SetTall(130)
				local backgrnd = vgui.Create("CtrlColor")
				backgrnd:SetConVarR("background1")
				backgrnd:SetConVarG("background2")
				backgrnd:SetConVarB("background3")
				backgrnd:SetConVarA("background4")
			backgrndpanel:AddItem(backgrnd)

			local resetbackgrnd = vgui.Create("DButton")
			resetbackgrnd:SetText("Reset")
			resetbackgrnd:SetSize(230, 20)
			resetbackgrnd.DoClick = function()
				LocalPlayer():ConCommand("background1 0")
				LocalPlayer():ConCommand("background2 0")
				LocalPlayer():ConCommand("background3 0")
				LocalPlayer():ConCommand("background4 100")
			end
			backgrndpanel:AddItem(resetbackgrnd)
		backgrndcat:SetContents(backgrndpanel)
		backgrndcat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(backgrndcat)

		hforegrndcat = vgui.Create("DCollapsibleCategory")
		hforegrndcat:SetSize(230, 130)
		function hforegrndcat.Header:OnMousePressed() end
		hforegrndcat:SetLabel("Health bar foreground")
			local hforegrndpanel = vgui.Create("DPanelList")
			hforegrndpanel:SetTall(130)
				local hforegrnd = vgui.Create("CtrlColor")
				hforegrnd:SetConVarR("Healthforeground1")
				hforegrnd:SetConVarG("Healthforeground2")
				hforegrnd:SetConVarB("Healthforeground3")
				hforegrnd:SetConVarA("Healthforeground4")
			hforegrndpanel:AddItem(hforegrnd)

			local resethforegrnd = vgui.Create("DButton")
			resethforegrnd:SetText("Reset")
			resethforegrnd:SetSize(230, 20)
			resethforegrnd.DoClick = function()
				LocalPlayer():ConCommand("Healthforeground1 140")
				LocalPlayer():ConCommand("Healthforeground2 0")
				LocalPlayer():ConCommand("Healthforeground3 0")
				LocalPlayer():ConCommand("Healthforeground4 180")
			end
			hforegrndpanel:AddItem(resethforegrnd)
		hforegrndcat:SetContents(hforegrndpanel)
		hforegrndcat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(hforegrndcat)


		hbackgrndcat = vgui.Create("DCollapsibleCategory")
		hbackgrndcat:SetSize(230, 130)
		function hbackgrndcat.Header:OnMousePressed() end
		hbackgrndcat:SetLabel("Health bar Background")
			local hbackgrndpanel = vgui.Create("DPanelList")
			hbackgrndpanel:SetTall(130)
				local hbackgrnd = vgui.Create("CtrlColor")
				hbackgrnd:SetConVarR("Healthbackground1")
				hbackgrnd:SetConVarG("Healthbackground2")
				hbackgrnd:SetConVarB("Healthbackground3")
				hbackgrnd:SetConVarA("Healthbackground4")
			hbackgrndpanel:AddItem(hbackgrnd)

			local resethbackgrnd = vgui.Create("DButton")
			resethbackgrnd:SetText("Reset")
			resethbackgrnd:SetSize(230, 20)
			resethbackgrnd.DoClick = function()
				LocalPlayer():ConCommand("Healthbackground1 0")
				LocalPlayer():ConCommand("Healthbackground2 0")
				LocalPlayer():ConCommand("Healthbackground3 0")
				LocalPlayer():ConCommand("Healthbackground4 200")
			end
			hbackgrndpanel:AddItem(resethbackgrnd)
		hbackgrndcat:SetContents(hbackgrndpanel)
		hbackgrndcat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(hbackgrndcat)

		hTextcat = vgui.Create("DCollapsibleCategory")
		hTextcat:SetSize(230, 130)
		function hTextcat.Header:OnMousePressed() end
		hTextcat:SetLabel("Health bar text")
			local hTextpanel = vgui.Create("DPanelList")
			hTextpanel:SetTall(130)
				local hText = vgui.Create("CtrlColor")
				hText:SetConVarR("HealthText1")
				hText:SetConVarG("HealthText2")
				hText:SetConVarB("HealthText3")
				hText:SetConVarA("HealthText4")
			hTextpanel:AddItem(hText)

			local resethText = vgui.Create("DButton")
			resethText:SetText("Reset")
			resethText:SetSize(230, 20)
			resethText.DoClick = function()
				LocalPlayer():ConCommand("HealthText1 255")
				LocalPlayer():ConCommand("HealthText2 255")
				LocalPlayer():ConCommand("HealthText3 255")
				LocalPlayer():ConCommand("HealthText4 200")
			end
			hTextpanel:AddItem(resethText)
		hTextcat:SetContents(hTextpanel)
		hTextcat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(hTextcat)

		jobs1cat = vgui.Create("DCollapsibleCategory")
		jobs1cat:SetSize(230, 130)
		function jobs1cat.Header:OnMousePressed() end
		jobs1cat:SetLabel("Jobs/wallet foreground")
			local jobs1panel = vgui.Create("DPanelList")
			jobs1panel:SetTall(130)
				local jobs1 = vgui.Create("CtrlColor")
				jobs1:SetConVarR("Job21")
				jobs1:SetConVarG("Job22")
				jobs1:SetConVarB("Job23")
				jobs1:SetConVarA("Job24")
			jobs1panel:AddItem(jobs1)

			local resetjobs1 = vgui.Create("DButton")
			resetjobs1:SetText("Reset")
			resetjobs1:SetSize(230, 20)
			resetjobs1.DoClick = function()
				LocalPlayer():ConCommand("Job21 0")
				LocalPlayer():ConCommand("Job22 0")
				LocalPlayer():ConCommand("Job23 0")
				LocalPlayer():ConCommand("Job24 255")
			end
			jobs1panel:AddItem(resetjobs1)
		jobs1cat:SetContents(jobs1panel)
		jobs1cat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(jobs1cat)

		jobs2cat = vgui.Create("DCollapsibleCategory")
		jobs2cat:SetSize(230, 130)
		function jobs2cat.Header:OnMousePressed() end
		jobs2cat:SetLabel("Jobs/wallet background")
			local jobs2panel = vgui.Create("DPanelList")
			jobs2panel:SetSize(230, 130)
				local jobs2 = vgui.Create("CtrlColor")
				jobs2:SetConVarR("Job11")
				jobs2:SetConVarG("Job12")
				jobs2:SetConVarB("Job13")
				jobs2:SetConVarA("Job14")
			jobs2panel:AddItem(jobs2)

			local resetjobs2 = vgui.Create("DButton")
			resetjobs2:SetText("Reset")
			resetjobs2:SetSize(230, 20)
			resetjobs2.DoClick = function()
				LocalPlayer():ConCommand("Job11 0")
				LocalPlayer():ConCommand("Job12 0")
				LocalPlayer():ConCommand("Job13 150")
				LocalPlayer():ConCommand("Job14 200")
			end
			jobs2panel:AddItem(resetjobs2)
		jobs2cat:SetContents(jobs2panel)
		jobs2cat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(jobs2cat)

		salary1cat = vgui.Create("DCollapsibleCategory")
		salary1cat:SetSize(230, 130)
		function salary1cat.Header:OnMousePressed() end
		salary1cat:SetLabel("Salary foreground")
			local salary1panel = vgui.Create("DPanelList")
			salary1panel:SetSize(230, 130)
				local salary1 = vgui.Create("CtrlColor")
				salary1:SetConVarR("salary21")
				salary1:SetConVarG("salary22")
				salary1:SetConVarB("salary23")
				salary1:SetConVarA("salary24")
			salary1panel:AddItem(salary1)

			local resetsalary1 = vgui.Create("DButton")
			resetsalary1:SetText("Reset")
			resetsalary1:SetSize(230, 20)
			resetsalary1.DoClick = function()
				LocalPlayer():ConCommand("salary21 0")
				LocalPlayer():ConCommand("salary22 0")
				LocalPlayer():ConCommand("salary23 0")
				LocalPlayer():ConCommand("salary24 255")
			end
			salary1panel:AddItem(resetsalary1)
		salary1cat:SetContents(salary1panel)
		salary1cat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(salary1cat)

		salary2cat = vgui.Create("DCollapsibleCategory")
		salary2cat:SetSize(230, 130)
		function salary2cat.Header:OnMousePressed() end
		salary2cat:SetLabel("Salary background")
			local salary2panel = vgui.Create("DPanelList")
			salary2panel:SetSize(230, 130)
				local salary2 = vgui.Create("CtrlColor")
				salary2:SetConVarR("salary11")
				salary2:SetConVarG("salary12")
				salary2:SetConVarB("salary13")
				salary2:SetConVarA("salary14")
			salary2panel:AddItem(salary2)

			local resetsalary2 = vgui.Create("DButton")
			resetsalary2:SetText("Reset")
			resetsalary2:SetSize(230, 20)
			resetsalary2.DoClick = function()
				LocalPlayer():ConCommand("salary11 0")
				LocalPlayer():ConCommand("salary12 150")
				LocalPlayer():ConCommand("salary13 0")
				LocalPlayer():ConCommand("salary14 200")
			end
			salary2panel:AddItem(resetsalary2)
		salary2cat:SetContents(salary2panel)
		salary2cat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(salary2cat)

		local HudWidthCat = vgui.Create("DCollapsibleCategory")
		HudWidthCat:SetSize(230, 130)
		function HudWidthCat.Header:OnMousePressed() end
		HudWidthCat:SetLabel("HUD width")
		local HudWidthpanel = vgui.Create("DPanelList")
			HudWidthpanel:SetSize(230, 130)
				local HudWidth = vgui.Create("DNumSlider")
				HudWidth:SetMinMax(0, ScrW() - 30)
				HudWidth:SetDecimals(0)
				HudWidth:SetConVar("HudW")
			HudWidthpanel:AddItem(HudWidth)

			local resetHudWidth = vgui.Create("DButton")
			resetHudWidth:SetText("Reset")
			resetHudWidth:SetSize(230, 20)
			resetHudWidth.DoClick = function()
				LocalPlayer():ConCommand("HudW 240")
			end
			HudWidthpanel:AddItem(resetHudWidth)
		HudWidthCat:SetContents(HudWidthpanel)
		HudWidthCat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(HudWidthCat)

		local HudHeightCat = vgui.Create("DCollapsibleCategory")
		HudHeightCat:SetSize(230, 130)
		function HudHeightCat.Header:OnMousePressed() end
		HudHeightCat:SetLabel("HUD Height")
		local HudHeightpanel = vgui.Create("DPanelList")
			HudHeightpanel:SetSize(230, 130)
				local HudHeight = vgui.Create("DNumSlider")
				HudHeight:SetMinMax(1, ScrW() - 20)
				HudHeight:SetDecimals(0)
				HudHeight:SetConVar("HudH")
			HudHeightpanel:AddItem(HudHeight)

			local resetHudHeight = vgui.Create("DButton")
			resetHudHeight:SetText("Reset")
			resetHudHeight:SetSize(230, 20)
			resetHudHeight.DoClick = function()
				LocalPlayer():ConCommand("HudH 110")
			end
			HudHeightpanel:AddItem(resetHudHeight)
		HudHeightCat:SetContents(HudHeightpanel)
		HudHeightCat:SetSkin("DarkRP")
		HUDTABpanel:AddItem(HudHeightCat)
	end
	HUDTABpanel:SetSkin("DarkRP")
	return HUDTABpanel
end

function GM:RPAdminTab()
	local AdminPanel = vgui.Create("DPanelList")
	AdminPanel:SetSpacing(1)
	AdminPanel:EnableHorizontal( false	)
	AdminPanel:EnableVerticalScrollbar( true )
		function AdminPanel:Update()
			self:Clear(true)
			local ToggleCat = vgui.Create("DCollapsibleCategory")
			ToggleCat:SetLabel("Toggle commands")
				local TogglePanel = vgui.Create("DPanelList")
				TogglePanel:SetSize(470, 230)
				TogglePanel:SetSpacing(1)
				TogglePanel:EnableHorizontal(false)
				TogglePanel:EnableVerticalScrollbar(true)

				local ValueCat = vgui.Create("DCollapsibleCategory")
				ValueCat:SetLabel("Value commands")
				local ValuePanel = vgui.Create("DPanelList")
				ValuePanel:SetSize(470, 230)
				ValuePanel:SetSpacing(1)
				ValuePanel:EnableHorizontal(false)
				ValuePanel:EnableVerticalScrollbar(true)

				for k, v in SortedPairsByMemberValue(GAMEMODE.ToggleCmds, "var") do
					local found = false
					for a,b in pairs(GAMEMODE:getHelpLabels()) do
						if string.find(b.text, k) then
							found = b.text
							break
						end
					end
					if found and type(v) == "table" then
						local checkbox = vgui.Create("DCheckBoxLabel")
						checkbox:SetValue(GetConVarNumber(v.var))
						checkbox:SetText(found)
						function checkbox.Button:Toggle()
							if self:GetChecked() == nil or not self:GetChecked() then
								self:SetValue( true )
							else
								self:SetValue( false )
							end
							local tonum = {}
							tonum[false] = "0"
							tonum[true] = "1"
							RunConsoleCommand(k, tonum[self:GetChecked()])
						end
						TogglePanel:AddItem(checkbox)
					end
				end
			ToggleCat:SetContents(TogglePanel)
			ToggleCat:SetSkin("DarkRP")
			self:AddItem(ToggleCat)
			function ToggleCat:Toggle()
				self:SetExpanded( !self:GetExpanded() )
				self.animSlide:Start( self:GetAnimTime(), { From = self:GetTall() } )
				if not self:GetExpanded() and ValueCat:GetExpanded() then
					ValuePanel:SetTall(470)
				elseif self:GetExpanded() and ValueCat:GetExpanded() then
					ValuePanel:SetTall(230)
					TogglePanel:SetTall(230)
				elseif self:GetExpanded() and not ValueCat:GetExpanded() then
					TogglePanel:SetTall(470)
				end
				self:InvalidateLayout( true )
				self:GetParent():InvalidateLayout()
				self:GetParent():GetParent():InvalidateLayout()
				local cookie = '1'
				if ( !self:GetExpanded() ) then cookie = '0' end
				self:SetCookie( "Open", cookie )
			end

			function ValueCat:Toggle()
				self:SetExpanded( !self:GetExpanded() )
				self.animSlide:Start( self:GetAnimTime(), { From = self:GetTall() } )

				if not self:GetExpanded() and ToggleCat:GetExpanded() then
					TogglePanel:SetTall(470)
				elseif self:GetExpanded() and ToggleCat:GetExpanded() then
					TogglePanel:SetTall(230)
					ValuePanel:SetTall(230)
				elseif self:GetExpanded() and not ToggleCat:GetExpanded() then
					ValuePanel:SetTall(470)
				end
				self:InvalidateLayout( true )
				self:GetParent():InvalidateLayout()
				self:GetParent():GetParent():InvalidateLayout()
				local cookie = '1'
				if ( !self:GetExpanded() ) then cookie = '0' end
				self:SetCookie( "Open", cookie )
			end
				for k, v in SortedPairsByMemberValue(GAMEMODE.ValueCmds, "var") do
					local found = false
					for a,b in pairs(GAMEMODE:getHelpLabels()) do
						if string.find(b.text, k) then
							found = b.text
							break
						end
					end
					if found and type(v) == "table" then
						local slider = vgui.Create("DNumSlider")
						slider:SetDecimals(0)
						slider:SetMin(0)
						slider:SetMax(3000)
						slider:SetText(found)
						slider:SetValue(GetConVarNumber(v.var))

						function slider.Slider:OnMouseReleased()
							self:SetDragging( false )
							self:MouseCapture( false )
							RunConsoleCommand(k, slider:GetValue())
						end
						function slider.Wang:EndWang()
							self:MouseCapture( false )
							self.Dragging = false
							self.HoldPos = nil
							self.Wanger:SetCursor( "" )
							if ( ValidPanel( self.IndicatorT ) ) then self.IndicatorT:Remove() end
							if ( ValidPanel( self.IndicatorB ) ) then self.IndicatorB:Remove() end
							RunConsoleCommand(k, self:GetValue())
						end
						function slider.Wang.TextEntry:OnEnter()
							RunConsoleCommand(k, self:GetValue())
						end
						ValuePanel:AddItem(slider)
					end
				end
			ValueCat:SetContents(ValuePanel)
			ValueCat:SetSkin("DarkRP")
			self:AddItem(ValueCat)
		end
		AdminPanel:Update()
	AdminPanel:SetSkin("DarkRP")
	return AdminPanel
end

local DefaultWeapons = {
{name = "GravGun",class = "weapon_physcannon"},
{name = "Physgun",class = "weapon_physgun"},
{name = "Crowbar",class = "weapon_crowbar"},
{name = "Stunstick",class = "weapon_stunstick"},
{name = "Pistol",class = "weapon_pistol"},
{name = "357",	class = "weapon_357"},
{name = "SMG", class = "weapon_smg1"},
{name = "Shotgun", class = "weapon_shotgun"},
{name = "Crossbow", class = "weapon_crossbow"},
{name = "AR2", class = "weapon_ar2"},
{name = "BugBait",	class = "weapon_bugbait"},
{name = "RPG", class = "weapon_rpg"}
}

function GM:RPLicenseWeaponsTab()
	local weaponspanel = vgui.Create("DPanelList")
	weaponspanel:SetSpacing(1)
	weaponspanel:EnableHorizontal(false)
	weaponspanel:EnableVerticalScrollbar(true)
		function weaponspanel:Update()
			self:Clear(true)
			local Explanation = vgui.Create("DLabel")
			Explanation:SetText(LANGUAGE.license_tab)
			Explanation:SizeToContents()
			self:AddItem(Explanation)

			for k,v in pairs(DefaultWeapons) do
				if type(v) == "table" and v.name then
					local checkbox = vgui.Create("DCheckBoxLabel")
					checkbox:SetText(v.name)
					checkbox:SetValue(GetConVarNumber("licenseweapon_"..v.class))
					function checkbox.Button:Toggle()
						if ( self:GetChecked() == nil || !self:GetChecked() ) then
							self:SetValue( true )
						else
							self:SetValue( false )
						end
						local tonum = {}
						tonum[false] = "0"
						tonum[true] = "1"
						RunConsoleCommand("rp_licenseweapon_".. v.class, tonum[self:GetChecked()])
					end
					self:AddItem(checkbox)
				end
			end

			local OtherWeps = vgui.Create("DLabel")
			OtherWeps:SetText(LANGUAGE.license_tab_other_weapons)
			OtherWeps:SizeToContents()
			self:AddItem(OtherWeps)
			for k,v in pairs(weapons.GetList()) do
				if type(v) == "table" and v.Classname then
					if v.Classname and not string.find(string.lower(v.Classname), "base") and v.Classname ~= "" then
						local checkbox = vgui.Create("DCheckBoxLabel")
						if v.PrintName then
							checkbox:SetText(v.PrintName)
						else
							checkbox:SetText(v.Classname)
						end
						checkbox:SetValue(GetConVarNumber("licenseweapon_"..v.Classname))
						function checkbox.Button:Toggle()
							if ( self:GetChecked() == nil || !self:GetChecked() ) then
								self:SetValue( true )
							else
								self:SetValue( false )
							end
							local tonum = {}
							tonum[false] = "0"
							tonum[true] = "1"
							RunConsoleCommand("rp_licenseweapon_".. string.lower(v.Classname), tonum[self:GetChecked()])
						end
						self:AddItem(checkbox)
					end
				end
			end
		end
	weaponspanel:Update()
	return weaponspanel
end
