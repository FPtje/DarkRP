CreateClientConVar("rp_playermodel", "", true, true)

local function MayorOptns()
	local MayCat = vgui.Create("DCollapsibleCategory")
	function MayCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MayCat:SetLabel("Mayor options")
		local maypanel = vgui.Create("DListLayout")
		maypanel:SetSize(740,170)
			local SearchWarrant = maypanel:Add("DButton")
			SearchWarrant:SetText(DarkRP.getPhrase("searchwarrantbutton"))
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("warrant") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("Warrant", "Why would you warrant "..ply:Nick().."?", nil,
								function(a)
									RunConsoleCommand("darkrp", "/warrant", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local Warrant = maypanel:Add("DButton")
			Warrant:SetText(DarkRP.getPhrase("make_wanted"))
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() Derma_StringRequest("wanted", "Why would you make "..ply:Nick().." wanted?", nil,
								function(a)
									RunConsoleCommand("darkrp", "/wanted", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local UnWarrant = maypanel:Add("DButton")
			UnWarrant:SetText(DarkRP.getPhrase("make_unwanted"))
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("darkrp /unwanted \"" .. ply:SteamID() .. "\"") end)
					end
				end
				menu:Open()
			end

			local Lockdown = maypanel:Add("DButton")
			Lockdown:SetText(DarkRP.getPhrase("initiate_lockdown"))
			Lockdown.DoClick = function()
				LocalPlayer():ConCommand("darkrp /lockdown")
			end


			local UnLockdown = maypanel:Add("DButton")
			UnLockdown:SetText(DarkRP.getPhrase("stop_lockdown"))
			UnLockdown.DoClick = function()
				LocalPlayer():ConCommand("darkrp /unlockdown")
			end

			local Lottery = maypanel:Add("DButton")
			Lottery:SetText(DarkRP.getPhrase("start_lottery"))
			Lottery.DoClick = function()
				LocalPlayer():ConCommand("darkrp /lottery")
			end

			local GiveLicense = maypanel:Add("DButton")
			GiveLicense:SetText(DarkRP.getPhrase("give_license_lookingat"))
			GiveLicense.DoClick = function()
				LocalPlayer():ConCommand("darkrp /givelicense")
			end

			local PlaceLaws = maypanel:Add("DButton")
			PlaceLaws:SetText("Place a screen containing the laws.")
			PlaceLaws.DoClick = function()
				LocalPlayer():ConCommand("darkrp /placelaws")
			end

			local AddLaws = maypanel:Add("DButton")
			AddLaws:SetText("Add a law.")
			AddLaws.DoClick = function()
				Derma_StringRequest("Add a law", "Type the law you would like to add here.", "", function(law)
					RunConsoleCommand("darkrp", "/addlaw", law)
				end)
			end

			local RemLaws = maypanel:Add("DButton")
			RemLaws:SetText("Remove a law.")
			RemLaws.DoClick = function()
				Derma_StringRequest("Remove a law", "Enter the number of the law you would like to remove here.", "", function(num)
					LocalPlayer():ConCommand("darkrp /removelaw " .. num)
				end)
			end
	MayCat:SetContents(maypanel)
	MayCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
	return MayCat
end

local function CPOptns()
	local CPCat = vgui.Create("DCollapsibleCategory")
	function CPCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CPCat:SetLabel("Police options")
		local CPpanel = vgui.Create("DListLayout")
		CPpanel:SetSize(740,170)
			local SearchWarrant = CPpanel:Add("DButton")
			SearchWarrant:SetText(DarkRP.getPhrase("request_warrant"))
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("warrant") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("Warrant", "Why would you warrant "..ply:Nick().."?", nil,
								function(a)
									RunConsoleCommand("darkrp", "/warrant", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local Warrant = CPpanel:Add("DButton")
			Warrant:SetText(DarkRP.getPhrase("searchwarrantbutton"))
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("wanted", "Why would you make "..ply:Nick().." wanted?", nil,
								function(a)
									if not IsValid(ply) then return end
									RunConsoleCommand("darkrp", "/wanted", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local UnWarrant = CPpanel:Add("DButton")
			UnWarrant:SetText(DarkRP.getPhrase("unwarrantbutton"))
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("darkrp /unwanted \"" .. ply:SteamID() .. "\"") end)
					end
				end
				menu:Open()
			end

			if LocalPlayer():Team() == TEAM_CHIEF and GAMEMODE.Config.chiefjailpos or LocalPlayer():IsAdmin() then
				local SetJailPos = CPpanel:Add("DButton")
				SetJailPos:SetText(DarkRP.getPhrase("set_jailpos"))
				SetJailPos.DoClick = function() LocalPlayer():ConCommand("darkrp /jailpos") end

				local AddJailPos = CPpanel:Add("DButton")
				AddJailPos:SetText(DarkRP.getPhrase("add_jailpos"))
				AddJailPos.DoClick = function() LocalPlayer():ConCommand("darkrp /addjailpos") end
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
				local GiveLicense = CPpanel:Add("DButton")
				GiveLicense:SetText(DarkRP.getPhrase("give_license_lookingat"))
				GiveLicense.DoClick = function()
					LocalPlayer():ConCommand("darkrp /givelicense")
				end
			end
	CPCat:SetContents(CPpanel)
	CPCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
	return CPCat
end


local function CitOptns()
	local CitCat = vgui.Create("DCollapsibleCategory")
	function CitCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CitCat:SetLabel("Citizen options")
		local Citpanel = vgui.Create("DListLayout")
		Citpanel:SetSize(740,110)

		local joblabel = Citpanel:Add("DLabel")
		joblabel:SetText(DarkRP.getPhrase("set_custom_job"))

		local jobentry = Citpanel:Add("DTextEntry")
		jobentry:SetAllowNonAsciiCharacters(true)
		jobentry:SetValue(LocalPlayer():getDarkRPVar("job") or "")
		jobentry.OnEnter = function()
			RunConsoleCommand("DarkRP", "/job", tostring(jobentry:GetValue()))
		end

	CitCat:SetContents(Citpanel)
	CitCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
	return CitCat
end


local function MobOptns()
	local MobCat = vgui.Create("DCollapsibleCategory")
	function MobCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MobCat:SetLabel("Mobboss options")
		local Mobpanel = vgui.Create("DListLayout")
		Mobpanel:SetSize(740,110)

		local agendalabel = Mobpanel:Add("DLabel")
		agendalabel:SetText(DarkRP.getPhrase("set_agenda"))

		local agendaentry = Mobpanel:Add("DTextEntry")
		agendaentry:SetAllowNonAsciiCharacters(true)
		agendaentry:SetValue(LocalPlayer():getDarkRPVar("agenda") or "")
		agendaentry.OnEnter = function()
			RunConsoleCommand("darkrp", "/agenda", tostring(agendaentry:GetValue()))
		end

	MobCat:SetContents(Mobpanel)
	MobCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
	return MobCat
end

function GM:MoneyTab()
	local FirstTabPanel = vgui.Create("DPanelList")
	FirstTabPanel:EnableVerticalScrollbar( true )
		function FirstTabPanel:Update()
			self:Clear(true)
			local MoneyCat = vgui.Create("DCollapsibleCategory")
			MoneyCat:SetLabel("Money")
				local MoneyPanel = vgui.Create("DListLayout")
				MoneyPanel:SetSize(740,60)

				local GiveMoneyButton = MoneyPanel:Add("DButton")
				GiveMoneyButton:SetText(DarkRP.getPhrase("give_money"))
				GiveMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to give?", "", function(a) LocalPlayer():ConCommand("darkrp /give " .. tostring(a)) end)
				end

				local SpawnMoneyButton = MoneyPanel:Add("DButton")
				SpawnMoneyButton:SetText(DarkRP.getPhrase("drop_money"))
				SpawnMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to drop?", "", function(a) LocalPlayer():ConCommand("darkrp /dropmoney " .. tostring(a)) end)
				end

			MoneyCat:SetContents(MoneyPanel)
			MoneyCat:SetSkin(GAMEMODE.Config.DarkRPSkin)


			local Commands = vgui.Create("DCollapsibleCategory")
			Commands:SetLabel("Actions")
				local ActionsPanel = vgui.Create("DListLayout")
				ActionsPanel:SetSize(740,210)
					local rpnamelabel = ActionsPanel:Add("DLabel")
					rpnamelabel:SetText(DarkRP.getPhrase("change_name"))

					local rpnameTextbox = ActionsPanel:Add("DTextEntry")
					--/rpname does not support non-ASCII characters
					rpnameTextbox:SetText(LocalPlayer():Nick())
					rpnameTextbox.OnEnter = function() RunConsoleCommand("darkrp", "/rpname", tostring(rpnameTextbox:GetValue())) end

					local sleep = ActionsPanel:Add("DButton")
					sleep:SetText(DarkRP.getPhrase("go_to_sleep"))
					sleep.DoClick = function()
						LocalPlayer():ConCommand("darkrp /sleep")
					end
					local Drop = ActionsPanel:Add("DButton")
					Drop:SetText(DarkRP.getPhrase("drop_weapon"))
					Drop.DoClick = function() LocalPlayer():ConCommand("darkrp /drop") end
					if GAMEMODE.Config.enablebuyhealth then
						local health = MoneyPanel:Add("DButton")
						health:SetText(DarkRP.getPhrase("buy_health", tostring(GAMEMODE.Config.healthcost)))
						health.DoClick = function() LocalPlayer():ConCommand("darkrp /Buyhealth") end
					end

				if LocalPlayer():Team() ~= TEAM_MAYOR then
					local RequestLicense = ActionsPanel:Add("DButton")
						RequestLicense:SetText(DarkRP.getPhrase("request_gunlicense"))
						RequestLicense.DoClick = function() LocalPlayer():ConCommand("darkrp /requestlicense") end
				end

				local Demote = ActionsPanel:Add("DButton")
				Demote:SetText(DarkRP.getPhrase("demote_player_menu"))
				Demote.DoClick = function()
					local menu = DermaMenu()
					for _,ply in pairs(player.GetAll()) do
						if ply ~= LocalPlayer() and IsValid(ply) then
							menu:AddOption(ply:Nick(), function()
								Derma_StringRequest("Demote reason", "Why would you demote "..ply:Nick().."?", nil,
									function(a)
										RunConsoleCommand("darkrp", "/demote", ply:SteamID(), a)
									end,
								function() end )
							end)
						end
					end
					menu:Open()
				end

				local UnOwnAllDoors = ActionsPanel:Add("DButton")
						UnOwnAllDoors:SetText("Sell all of your doors")
						UnOwnAllDoors.DoClick = function() LocalPlayer():ConCommand("darkrp /unownalldoors") end
			Commands:SetContents(ActionsPanel)
		FirstTabPanel:AddItem(MoneyCat)
		Commands:SetSkin(GAMEMODE.Config.DarkRPSkin)
		FirstTabPanel:AddItem(Commands)

		if LocalPlayer():Team() == TEAM_MAYOR then
			FirstTabPanel:AddItem(MayorOptns())
		elseif LocalPlayer():Team() == TEAM_CITIZEN then
			FirstTabPanel:AddItem(CitOptns())
		elseif LocalPlayer():IsCP() then
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
	hordiv:SetLeftWidth(390)
	function hordiv.m_DragBar:OnMousePressed() end
	hordiv.m_DragBar:SetCursor("none")
	local Panel
	local Information
	function hordiv:Update()
		if Panel and Panel:IsValid() then
			Panel:Remove()
		end
		Panel = vgui.Create("DPanelList")
		Panel:SetSize(390, 540)
		Panel:EnableHorizontal( true )
		Panel:EnableVerticalScrollbar( true )
		Panel:SetSkin(GAMEMODE.Config.DarkRPSkin)


		local Info = {}
		local model
		local modelpanel
		local function UpdateInfo(a)
			if Information and Information:IsValid() then
				Information:Remove()
			end
			Information = vgui.Create("DPanelList")
			Information:SetPos(378,0)
			Information:SetSize(370, 540)
			Information:SetSpacing(10)
			Information:EnableHorizontal( false )
			Information:EnableVerticalScrollbar( true )
			Information:SetSkin(GAMEMODE.Config.DarkRPSkin)
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

			icon:SetSize(128, 128)
			icon:SetToolTip()
			icon.OnCursorEntered = function()
				icon.PaintOverOld = icon.PaintOver
				icon.PaintOver = icon.PaintOverHovered
				Info[1] = DarkRP.getPhrase("job_name") .. name
				Info[2] = DarkRP.getPhrase("job_description") .. description
				Info[3] = DarkRP.getPhrase("job_weapons") .. Weapons
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
						menu:AddOption("Vote", function() LocalPlayer():ConCommand("darkrp "..command) frame:Close() end)
						menu:AddOption("Do not vote", function() LocalPlayer():ConCommand("darkrp " .. specialcommand) frame:Close() end)
						menu:Open()
					else
						LocalPlayer():ConCommand("darkrp " .. command)
						frame:Close()
					end
				end

				if type(Model) == "table" and #Model > 0 then
					hordiv:GetParent():GetParent():Close()
					local frame = vgui.Create("DFrame")
					frame:SetTitle("Choose model")
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
						icon:SetSize(64, 64)
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
			if LocalPlayer():Team() ~= k and GAMEMODE:CustomObjFitsMap(v) then
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
					if #v.weapons > 0 then
						weps = table.concat(v.weapons, "\n")
					end
					if (not v.RequiresVote and v.vote) or (v.RequiresVote and v.RequiresVote(LocalPlayer(), k)) then
						local condition = ((v.admin == 0 and LocalPlayer():IsAdmin()) or (v.admin == 1 and LocalPlayer():IsSuperAdmin()) or LocalPlayer().DarkRPVars["Priv"..v.command])
						if not v.model or not v.name or not v.description or not v.command then chat.AddText(Color(255,0,0,255), "Incorrect team! Fix your shared.lua!") return end
						AddIcon(v.model, v.name, v.description, weps, "/vote"..v.command, condition, "/"..v.command)
					else
						if not v.model or not v.name or not v.description or not v.command then chat.AddText(Color(255,0,0,255), "Incorrect team! Fix your shared.lua!") return end
						AddIcon(v.model, v.name, v.description, weps, "/"..v.command)
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
			local AmmCat = vgui.Create("DCollapsibleCategory")
			AmmCat:SetLabel("Ammo")
				local AmmPanel = vgui.Create("DPanelList")
				AmmPanel:SetSize(470, 100)
				AmmPanel:SetAutoSize(true)
				AmmPanel:SetSpacing(1)
				AmmPanel:EnableHorizontal(true)
				AmmPanel:EnableVerticalScrollbar(true)
					local function AddAmmoIcon(Model, description, command)
						local icon = vgui.Create("SpawnIcon")
						icon:InvalidateLayout( true )
						icon:SetModel(Model)
						icon:SetSize(64, 64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("darkrp "..command) end
						AmmPanel:AddItem(icon)
					end

					local ammnum = 0
					for k,v in pairs(GAMEMODE.AmmoTypes) do
						if not v.customCheck or v.customCheck(LocalPlayer()) then
							AddAmmoIcon(v.model, DarkRP.getPhrase("buy_a", v.name, GAMEMODE.Config.currency .. v.price), "/buyammo " .. v.ammoType)
							ammnum = ammnum + 1
						end
					end

			if ammnum ~= 0 then
				AmmCat:SetContents(AmmPanel)
				AmmCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
				self:AddItem(AmmCat)
			else
				AmmPanel:Remove()
				AmmCat:Remove()
			end

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
						icon:SetSize(64, 64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("darkrp "..command) end
						WepPanel:AddItem(icon)
					end

					local wepnum = 0
					for k,v in pairs(CustomShipments) do
						if not GAMEMODE:CustomObjFitsMap(v) then continue end
						if (v.seperate and (not GAMEMODE.Config.restrictbuypistol or
							(GAMEMODE.Config.restrictbuypistol and (not v.allowed[1] or table.HasValue(v.allowed, LocalPlayer():Team())))))
							and (not v.customCheck or v.customCheck and v.customCheck(LocalPlayer())) then
							AddIcon(v.model, DarkRP.getPhrase("buy_a", "a "..v.name, GAMEMODE.Config.currency..(v.pricesep or "")), "/buy "..v.name)
							wepnum = wepnum + 1
						end
					end

				if wepnum ~= 0 then
					WepCat:SetContents(WepPanel)
					WepCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
					self:AddItem(WepCat)
				else
					WepPanel:Remove()
					WepCat:Remove()
				end

			local ShipCat = vgui.Create("DCollapsibleCategory")
			ShipCat:SetLabel("Shipments")
				local ShipPanel = vgui.Create("DPanelList")
				ShipPanel:SetSize(470, 200)
				ShipPanel:SetAutoSize(true)
				ShipPanel:SetSpacing(1)
				ShipPanel:EnableHorizontal(true)
				ShipPanel:EnableVerticalScrollbar(true)
					local function AddShipIcon(Model, description, command)
						local icon = vgui.Create("SpawnIcon")
						icon:InvalidateLayout( true )
						icon:SetModel(Model)
						icon:SetSize(64, 64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("darkrp "..command) end
						ShipPanel:AddItem(icon)
					end

					local shipnum = 0
					for k,v in pairs(CustomShipments) do
						if not GAMEMODE:CustomObjFitsMap(v) then continue end
						if not v.noship and table.HasValue(v.allowed, LocalPlayer():Team())
							and (not v.customCheck or (v.customCheck and v.customCheck(LocalPlayer()))) then
							AddShipIcon(v.model, DarkRP.getPhrase("buy_a", "a "..v.name .." shipment", GAMEMODE.Config.currency .. tostring(v.price)), "/buyshipment "..v.name)
							shipnum = shipnum + 1
						end
					end
				if shipnum ~= 0 then
					ShipCat:SetContents(ShipPanel)
					ShipCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
					self:AddItem(ShipCat)
				else
					ShipPanel:Remove()
					ShipCat:Remove()
				end

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
						icon:SetSize(64, 64)
						icon:SetToolTip(description)
						icon.DoClick = function() LocalPlayer():ConCommand("darkrp "..command) end
						EntPanel:AddItem(icon)
					end
					local entnum = 0
					for k,v in pairs(DarkRPEntities) do
						if not v.allowed or (type(v.allowed) == "table" and table.HasValue(v.allowed, LocalPlayer():Team()))
							and (not v.customCheck or (v.customCheck and v.customCheck(LocalPlayer()))) then
							local cmdname = string.gsub(v.ent, " ", "_")

							AddEntIcon(v.model, "Buy a " .. v.name .." " .. GAMEMODE.Config.currency .. v.price, v.cmd)
							entnum = entnum + 1
						end
					end

					if FoodItems and (GAMEMODE.Config.foodspawn or LocalPlayer():Team() == TEAM_COOK) and LocalPlayer():Team() == TEAM_COOK then
						for k,v in pairs(FoodItems) do
							AddEntIcon(v.model, DarkRP.getPhrase("buy_a", "a "..k, "$15"), "/buyfood "..k)
							entnum = entnum + 1
						end
					end
				if entnum ~= 0 then
					EntCat:SetContents(EntPanel)
					EntCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
					self:AddItem(EntCat)
				else
					EntPanel:Remove()
					EntCat:Remove()
				end


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
					icon:SetSize(64, 64)
					icon:SetToolTip(description)
					icon.DoClick = function() LocalPlayer():ConCommand("darkrp "..command) end
					VehiclePanel:AddItem(icon)
				end

				local founds = 0
				for k,v in pairs(CustomVehicles) do
					if (not v.allowed or table.HasValue(v.allowed, LocalPlayer():Team())) and (not v.customCheck or v.customCheck(LocalPlayer())) then
						local Skin = (list.Get("Vehicles")[v.name] and list.Get("Vehicles")[v.name].KeyValues and list.Get("Vehicles")[v.name].KeyValues.Skin) or "0"
						AddVehicleIcon(v.model or "models/buggy.mdl", Skin, "Buy a "..v.name.." for "..GAMEMODE.Config.currency..v.price, "/buyvehicle "..v.name)
						founds = founds + 1
					end
				end
			if founds ~= 0 then
				VehicleCat:SetContents(VehiclePanel)
				VehicleCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
				self:AddItem(VehicleCat)
			else
				VehiclePanel:Remove()
				VehicleCat:Remove()
			end
		end
	EntitiesPanel:SetSkin(GAMEMODE.Config.DarkRPSkin)
	EntitiesPanel:Update()
	return EntitiesPanel
end

function GM:RPHUDTab()
	local HUDTABpanel = vgui.Create("DIconLayout")
	HUDTABpanel:SetSize(750, 550)
	function HUDTABpanel:Update()
		self:Clear(true)

		backgrndcat = HUDTABpanel:Add("DCollapsibleCategory")
		backgrndcat:SetSize(230, 130)
		function backgrndcat.Header:OnMousePressed() end
		backgrndcat:SetLabel("HUD background")
			local backgrndpanel = vgui.Create("DListLayout")
				local backgrnd = backgrndpanel:Add("CtrlColor")
				backgrnd:SetConVarR("background1")
				backgrnd:SetConVarG("background2")
				backgrnd:SetConVarB("background3")
				backgrnd:SetConVarA("background4")

			local resetbackgrnd = backgrndpanel:Add("DButton")
			resetbackgrnd:SetText("Reset")
			resetbackgrnd:SetSize(230, 20)
			resetbackgrnd.DoClick = function()
				LocalPlayer():ConCommand("background1 0")
				LocalPlayer():ConCommand("background2 0")
				LocalPlayer():ConCommand("background3 0")
				LocalPlayer():ConCommand("background4 100")
			end
		backgrndcat:SetContents(backgrndpanel)
		backgrndcat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		hforegrndcat = HUDTABpanel:Add("DCollapsibleCategory")
		hforegrndcat:SetSize(230, 130)
		function hforegrndcat.Header:OnMousePressed() end
		hforegrndcat:SetLabel("Health bar foreground")
			local hforegrndpanel = vgui.Create("DListLayout")
			hforegrndpanel:SetTall(130)
				local hforegrnd = hforegrndpanel:Add("CtrlColor")
				hforegrnd:SetConVarR("Healthforeground1")
				hforegrnd:SetConVarG("Healthforeground2")
				hforegrnd:SetConVarB("Healthforeground3")
				hforegrnd:SetConVarA("Healthforeground4")

			local resethforegrnd = hforegrndpanel:Add("DButton")
			resethforegrnd:SetText("Reset")
			resethforegrnd:SetSize(230, 20)
			resethforegrnd.DoClick = function()
				LocalPlayer():ConCommand("Healthforeground1 140")
				LocalPlayer():ConCommand("Healthforeground2 0")
				LocalPlayer():ConCommand("Healthforeground3 0")
				LocalPlayer():ConCommand("Healthforeground4 180")
			end
		hforegrndcat:SetContents(hforegrndpanel)
		hforegrndcat:SetSkin(GAMEMODE.Config.DarkRPSkin)


		hbackgrndcat = HUDTABpanel:Add("DCollapsibleCategory")
		hbackgrndcat:SetSize(230, 130)
		function hbackgrndcat.Header:OnMousePressed() end
		hbackgrndcat:SetLabel("Health bar Background")
			local hbackgrndpanel = vgui.Create("DListLayout")
			hbackgrndpanel:SetTall(130)
				local hbackgrnd = hbackgrndpanel:Add("CtrlColor")
				hbackgrnd:SetConVarR("Healthbackground1")
				hbackgrnd:SetConVarG("Healthbackground2")
				hbackgrnd:SetConVarB("Healthbackground3")
				hbackgrnd:SetConVarA("Healthbackground4")

			local resethbackgrnd = hbackgrndpanel:Add("DButton")
			resethbackgrnd:SetText("Reset")
			resethbackgrnd:SetSize(230, 20)
			resethbackgrnd.DoClick = function()
				LocalPlayer():ConCommand("Healthbackground1 0")
				LocalPlayer():ConCommand("Healthbackground2 0")
				LocalPlayer():ConCommand("Healthbackground3 0")
				LocalPlayer():ConCommand("Healthbackground4 200")
			end
		hbackgrndcat:SetContents(hbackgrndpanel)
		hbackgrndcat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		hTextcat = HUDTABpanel:Add("DCollapsibleCategory")
		hTextcat:SetSize(230, 130)
		function hTextcat.Header:OnMousePressed() end
		hTextcat:SetLabel("Health bar text")
			local hTextpanel = vgui.Create("DListLayout")
			hTextpanel:SetTall(130)
				local hText = hTextpanel:Add("CtrlColor")
				hText:SetConVarR("HealthText1")
				hText:SetConVarG("HealthText2")
				hText:SetConVarB("HealthText3")
				hText:SetConVarA("HealthText4")

			local resethText = hTextpanel:Add("DButton")
			resethText:SetText("Reset")
			resethText:SetSize(230, 20)
			resethText.DoClick = function()
				LocalPlayer():ConCommand("HealthText1 255")
				LocalPlayer():ConCommand("HealthText2 255")
				LocalPlayer():ConCommand("HealthText3 255")
				LocalPlayer():ConCommand("HealthText4 200")
			end
		hTextcat:SetContents(hTextpanel)
		hTextcat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		jobs1cat = HUDTABpanel:Add("DCollapsibleCategory")
		jobs1cat:SetSize(230, 130)
		function jobs1cat.Header:OnMousePressed() end
		jobs1cat:SetLabel("Jobs/wallet foreground")
			local jobs1panel = vgui.Create("DListLayout")
			jobs1panel:SetTall(130)
				local jobs1 = jobs1panel:Add("CtrlColor")
				jobs1:SetConVarR("Job21")
				jobs1:SetConVarG("Job22")
				jobs1:SetConVarB("Job23")
				jobs1:SetConVarA("Job24")

			local resetjobs1 = jobs1panel:Add("DButton")
			resetjobs1:SetText("Reset")
			resetjobs1:SetSize(230, 20)
			resetjobs1.DoClick = function()
				LocalPlayer():ConCommand("Job21 0")
				LocalPlayer():ConCommand("Job22 0")
				LocalPlayer():ConCommand("Job23 0")
				LocalPlayer():ConCommand("Job24 255")
			end
		jobs1cat:SetContents(jobs1panel)
		jobs1cat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		jobs2cat = HUDTABpanel:Add("DCollapsibleCategory")
		jobs2cat:SetSize(230, 130)
		function jobs2cat.Header:OnMousePressed() end
		jobs2cat:SetLabel("Jobs/wallet background")
			local jobs2panel = vgui.Create("DListLayout")
			jobs2panel:SetSize(230, 130)
				local jobs2 = jobs2panel:Add("CtrlColor")
				jobs2:SetConVarR("Job11")
				jobs2:SetConVarG("Job12")
				jobs2:SetConVarB("Job13")
				jobs2:SetConVarA("Job14")

			local resetjobs2 = jobs2panel:Add("DButton")
			resetjobs2:SetText("Reset")
			resetjobs2:SetSize(230, 20)
			resetjobs2.DoClick = function()
				LocalPlayer():ConCommand("Job11 0")
				LocalPlayer():ConCommand("Job12 0")
				LocalPlayer():ConCommand("Job13 150")
				LocalPlayer():ConCommand("Job14 200")
			end
		jobs2cat:SetContents(jobs2panel)
		jobs2cat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		salary1cat = HUDTABpanel:Add("DCollapsibleCategory")
		salary1cat:SetSize(230, 130)
		function salary1cat.Header:OnMousePressed() end
		salary1cat:SetLabel("Salary foreground")
			local salary1panel = vgui.Create("DListLayout")
			salary1panel:SetSize(230, 130)
				local salary1 = salary1panel:Add("CtrlColor")
				salary1:SetConVarR("salary21")
				salary1:SetConVarG("salary22")
				salary1:SetConVarB("salary23")
				salary1:SetConVarA("salary24")

			local resetsalary1 = salary1panel:Add("DButton")
			resetsalary1:SetText("Reset")
			resetsalary1:SetSize(230, 20)
			resetsalary1.DoClick = function()
				LocalPlayer():ConCommand("salary21 0")
				LocalPlayer():ConCommand("salary22 0")
				LocalPlayer():ConCommand("salary23 0")
				LocalPlayer():ConCommand("salary24 255")
			end
		salary1cat:SetContents(salary1panel)
		salary1cat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		salary2cat = HUDTABpanel:Add("DCollapsibleCategory")
		salary2cat:SetSize(230, 130)
		function salary2cat.Header:OnMousePressed() end
		salary2cat:SetLabel("Salary background")
			local salary2panel = vgui.Create("DListLayout")
			salary2panel:SetSize(230, 130)
				local salary2 = salary2panel:Add("CtrlColor")
				salary2:SetConVarR("salary11")
				salary2:SetConVarG("salary12")
				salary2:SetConVarB("salary13")
				salary2:SetConVarA("salary14")

			local resetsalary2 = salary2panel:Add("DButton")
			resetsalary2:SetText("Reset")
			resetsalary2:SetSize(230, 20)
			resetsalary2.DoClick = function()
				LocalPlayer():ConCommand("salary11 0")
				LocalPlayer():ConCommand("salary12 150")
				LocalPlayer():ConCommand("salary13 0")
				LocalPlayer():ConCommand("salary14 200")
			end
		salary2cat:SetContents(salary2panel)
		salary2cat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		local HudWidthCat = HUDTABpanel:Add("DCollapsibleCategory")
		HudWidthCat:SetSize(230, 130)
		function HudWidthCat.Header:OnMousePressed() end
		HudWidthCat:SetLabel("HUD width")
		local HudWidthpanel = vgui.Create("DListLayout")
			HudWidthpanel:SetSize(230, 130)
				local HudWidth = HudWidthpanel:Add("DNumSlider")
				HudWidth:SetMinMax(0, ScrW() - 30)
				HudWidth:SetDecimals(0)
				HudWidth:SetConVar("HudW")

			local resetHudWidth = HudWidthpanel:Add("DButton")
			resetHudWidth:SetText("Reset")
			resetHudWidth:SetSize(230, 20)
			resetHudWidth.DoClick = function()
				LocalPlayer():ConCommand("HudW 240")
			end
		HudWidthCat:SetContents(HudWidthpanel)
		HudWidthCat:SetSkin(GAMEMODE.Config.DarkRPSkin)

		local HudHeightCat = HUDTABpanel:Add("DCollapsibleCategory")
		HudHeightCat:SetSize(230, 130)
		function HudHeightCat.Header:OnMousePressed() end
		HudHeightCat:SetLabel("HUD Height")
		local HudHeightpanel = vgui.Create("DListLayout")
			HudHeightpanel:SetSize(230, 130)
				local HudHeight = HudHeightpanel:Add("DNumSlider")
				HudHeight:SetMinMax(1, ScrW() - 20)
				HudHeight:SetDecimals(0)
				HudHeight:SetConVar("HudH")

			local resetHudHeight = HudHeightpanel:Add("DButton")
			resetHudHeight:SetText("Reset")
			resetHudHeight:SetSize(230, 20)
			resetHudHeight.DoClick = function()
				LocalPlayer():ConCommand("HudH 110")
			end
		HudHeightCat:SetContents(HudHeightpanel)
		HudHeightCat:SetSkin(GAMEMODE.Config.DarkRPSkin)
	end
	HUDTABpanel:SetSkin(GAMEMODE.Config.DarkRPSkin)
	return HUDTABpanel
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
