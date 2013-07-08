local AdminPanel
//local PrivateSettingsPanel
local EditGroupTools
local RetrieveRestrictedTool
local RetrieveBlockedModels
local BlockedLists = {}
local CatsOpened = {}
local ShowBlockedModels
FPP = FPP or {}

FPP.Groups = {}
FPP.GroupMembers = {}

function FPP.AdminMenu(Panel)
	AdminPanel = Panel
	AdminPanel:SetSize(100, 400)
	AdminPanel:Clear(true)

	AdminPanel.contents = AdminPanel.contents or vgui.Create("DListLayout")
	AdminPanel.contents:Clear()

	local superadmin = LocalPlayer():IsSuperAdmin()
	if not superadmin then
		AdminPanel.contents:Add(Label("You are not a superadmin\nThe changes you make will not have any effect."))
		local AmAdmin = AdminPanel.contents:Add("DButton")
		AmAdmin:SetText("Unlock buttons anyway")
		AmAdmin:SetToolTip("If you're REALLY not an admin it won't work")

		function AmAdmin:DoClick()
			AmAdmin:SetText("Buttons unlocked")
			AmAdmin:SetToolTip("The changes you make now DO have effect unless you're really not an admin")
			superadmin = true
		end
	end

	local function MakeOption(Name)
		local cat = AdminPanel.contents:Add("DCollapsibleCategory")
		cat:SetLabel(Name)
		cat:SetExpanded(CatsOpened[Name])
		cat.oldtoggle = cat.Toggle
		function cat:Toggle()
			self:oldtoggle()
			CatsOpened[Name] = cat:GetExpanded()
			AdminPanel:Toggle()
			timer.Simple(0, function() AdminPanel:Toggle() end)
		end

		local pan = vgui.Create("DListLayout")
		cat:SetContents(pan)
		return cat, pan
	end

	local function addchk(label, command, plist)
		local box = plist:Add("DCheckBoxLabel")
		box:SetText(label)
		box:SetValue(tobool(GetConVarNumber("_"..command[1].."_"..command[2])))
		box.Button.Toggle = function()
			if not superadmin then return end--Hehe now you can't click it anymore non-admin!
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then
				box.Button:SetValue( true )
			else
				box.Button:SetValue( false )
			end
			local tonum = {}
			tonum[false] = "0"
			tonum[true] = "1"
			RunConsoleCommand("FPP_Setting", command[1], command[2], tonum[box.Button:GetChecked()])
		end
	end

	local function addblock(pan, Type)
		local label = pan:Add("DLabel")
		label:SetText("\n"..Type.." black/whitelist entities:")
		label:SizeToContents()

		local lview = pan:Add("DListView")
		lview:AddColumn("Entity")

		BlockedLists[string.lower(Type)] = lview
		RunConsoleCommand("FPP_sendblocked", Type)

		local RemoveSelected = pan:Add("DButton")
		RemoveSelected:SetText("Remove Selected items from the list")
		RemoveSelected:SetDisabled(not superadmin)
		RemoveSelected.DoClick = function()
			for k,v in pairs(lview.Lines) do
				if v:IsLineSelected() then
					local text = v.text
					timer.Simple(k/10, function() RunConsoleCommand("FPP_RemoveBlocked", Type, text) end)
					lview:RemoveLine(k)
					lview:SetTall(17 + #lview:GetLines() * 17)
					pan:InvalidateLayout()
					pan:GetParent():GetParent():InvalidateLayout()
				end
			end
		end

		local AddLA = pan:Add("DButton")
		AddLA:SetText("Add the entity you're looking at")
		AddLA:SetDisabled(not superadmin)
		AddLA.DoClick = function()
			local ent = LocalPlayer():GetEyeTraceNoCursor().Entity
			if not IsValid(ent) then return end
			for k,v in pairs(lview.Lines) do
				if v.text == string.lower(ent:GetClass()) then return end
			end
			RunConsoleCommand("FPP_AddBlocked", Type, ent:GetClass())

			lview:AddLine(ent:GetClass()).text = ent:GetClass()
			lview:SetTall(17 + #lview:GetLines() * 17)
			pan:InvalidateLayout()
			pan:GetParent():GetParent():InvalidateLayout()
		end

		local AddManual = pan:Add("DButton")
		AddManual:SetText("Add entity manually")
		AddManual:SetDisabled(not superadmin)
		AddManual.DoClick = function()
			Derma_StringRequest("Enter entity manually", "Enter the classname of the entity you would like to add.", nil,
			function(a)
			RunConsoleCommand("FPP_AddBlocked", Type, a)
			end, function() end )
		end
	end

	local function addsldr(max, command, text, plist, decimals)
		local sldr = plist:Add("DNumSlider")
		sldr:SetMinMax(0, max)
		decimals = decimals or 1
		sldr:SetDecimals(decimals)
		sldr:SetText(text)
		sldr:SetValue(GetConVarNumber("_"..command[1].."_"..command[2]))
		function sldr.Slider:OnMouseReleased()
			self:SetDragging( false )
			self:MouseCapture( false )
			if not superadmin then
				sldr:SetValue(GetConVarNumber("_"..command[1].."_"..command[2]))
				return
			end
			RunConsoleCommand("FPP_Setting", command[1], command[2], sldr:GetValue())
		end
		local KnobMouseReleased = sldr.Slider.Knob.OnMouseReleased
		function sldr.Slider.Knob:OnMouseReleased(...)
			KnobMouseReleased(self, ...)
			sldr.Slider:OnMouseReleased()
		end
	end

	local GeneralCat, general = MakeOption("General options")
	addchk("Cleanup disconnected players's entities", {"FPP_GLOBALSETTINGS1", "cleanupdisconnected"}, general)
	addchk("Cleanup admin's entities on disconnect", {"FPP_GLOBALSETTINGS1", "cleanupadmin"}, general)
	addsldr(300, {"FPP_GLOBALSETTINGS1", "cleanupdisconnectedtime"}, "Deletion time", general, 0)
	addchk("Anti speedhack(requires changelevel)", {"FPP_GLOBALSETTINGS1", "antispeedhack"}, general)
	addchk("Anti E2 mingery (mass killing with E2)", {"FPP_GLOBALSETTINGS1", "antie2minge"}, general)

	local delnow = general:Add("DButton")
	delnow:SetText("Delete disconnected players' entities")
	delnow:SetConsoleCommand("FPP_cleanup", "disconnected")
	delnow:SetDisabled(not superadmin)

	local other = general:Add(Label("\nDelete player's entities:"))
	other:SizeToContents()

	local areplayers = false
	for k,v in pairs(player.GetAll()) do
		areplayers = true
		local rm = general:Add("DButton")
		rm:SetText(v:Nick())
		rm:SetConsoleCommand("FPP_Cleanup", v:UserID())
		rm:SetDisabled(not LocalPlayer():IsAdmin() and not superadmin)
	end
	if not areplayers then
		local nope = general:Add(Label("<No players available>"))
		nope:SizeToContents()
	end

	local Antispamcat, antispam = MakeOption("Antispam options")
	addchk("Spam protection enabled on/off", {"FPP_ANTISPAM1", "toggle"}, antispam)
	addchk("Prevent spawning a prop in a prop", {"FPP_ANTISPAM1", "antispawninprop"}, antispam)
	addsldr(10, {"FPP_ANTISPAM1", "bigpropwait"}, "Time (seconds) between spawning two big props", antispam)
	addsldr(10, {"FPP_ANTISPAM1", "smallpropdowngradecount"}, "Spawn delay (in fraction) to consider spam", antispam)
	addsldr(10, {"FPP_ANTISPAM1", "smallpropghostlimit"}, "How many props to spam before ghosting", antispam)
	addsldr(20, {"FPP_ANTISPAM1", "smallpropdenylimit"}, "How many props to spam before blocking", antispam)
	addsldr(10, {"FPP_ANTISPAM1", "duplicatorlimit"}, "How many duplications to spam before blocking", antispam)

	local physcat, physgun = MakeOption("Physgun options")
	addchk("Physgun protection enabled", {"FPP_PHYSGUN1", "toggle"}, physgun)
	addchk("Admins can physgun all entities", {"FPP_PHYSGUN1", "adminall"}, physgun)
	addchk("People can physgun world entities", {"FPP_PHYSGUN1", "worldprops"}, physgun)
	addchk("Admins can physgun world entities", {"FPP_PHYSGUN1", "adminworldprops"}, physgun)
	addchk("People can physgun blocked entities", {"FPP_PHYSGUN1", "canblocked"}, physgun)
	addchk("Admins can physgun blocked entities", {"FPP_PHYSGUN1", "admincanblocked"}, physgun)
	addchk("Show icon in the middle of the screen", {"FPP_PHYSGUN1", "shownocross"}, physgun)
	addchk("Check constrained entities", {"FPP_PHYSGUN1", "checkconstrained"}, physgun)
	addchk("Physgun reload protection enabled", {"FPP_PHYSGUN1", "reloadprotection"}, physgun)
	addchk("The blocked list is a white list", {"FPP_PHYSGUN1", "iswhitelist"}, physgun)
	addblock(physgun, "Physgun1")

	local gravcat, gravgun = MakeOption("Gravity gun options")
	addchk("Gravity gun protection enabled", {"FPP_GRAVGUN1", "toggle"}, gravgun)
	addchk("Admins can gravgun all entities", {"FPP_GRAVGUN1", "adminall"}, gravgun)
	addchk("People can gravgun world entities", {"FPP_GRAVGUN1", "worldprops"}, gravgun)
	addchk("Admins can gravgun world entities", {"FPP_GRAVGUN1", "adminworldprops"}, gravgun)
	addchk("People can gravgun blocked entities", {"FPP_GRAVGUN1", "canblocked"}, gravgun)
	addchk("Admins can gravgun blocked entities", {"FPP_GRAVGUN1", "admincanblocked"}, gravgun)
	addchk("Show icon in the middle of the screen", {"FPP_GRAVGUN1", "shownocross"}, gravgun)
	addchk("Check constrained entities", {"FPP_GRAVGUN1", "checkconstrained"}, gravgun)
	addchk("People can't punt props", {"FPP_GRAVGUN1", "noshooting"}, gravgun)
	addchk("The blocked list is a white list", {"FPP_GRAVGUN1", "iswhitelist"}, gravgun)
	addblock(gravgun, "Gravgun1")

	local toolcat, toolgun = MakeOption("Toolgun options")
	addchk("Toolgun protection enabled", {"FPP_TOOLGUN1", "toggle"}, toolgun)
	addchk("Admins can use tool all entities", {"FPP_TOOLGUN1", "adminall"}, toolgun)
	addchk("People can use tool on world entities", {"FPP_TOOLGUN1", "worldprops"}, toolgun)
	addchk("Admins can use tool on world entities", {"FPP_TOOLGUN1", "adminworldprops"}, toolgun)
	addchk("People can use tool on blocked entities", {"FPP_TOOLGUN1", "canblocked"}, toolgun)
	addchk("Admins can use tool on blocked entities", {"FPP_TOOLGUN1", "admincanblocked"}, toolgun)
	addchk("Show icon in the middle of the screen", {"FPP_TOOLGUN1", "shownocross"}, toolgun)
	addchk("Check constrained entities", {"FPP_TOOLGUN1", "checkconstrained"}, toolgun)
	addchk("The blocked list is a white list", {"FPP_TOOLGUN1", "iswhitelist"}, toolgun)
	addblock(toolgun, "Toolgun1")

	addchk("Duplicator restriction (blocked list)", {"FPP_TOOLGUN1", "duplicatorprotect"}, toolgun)
	addchk("People can't duplicate weapons", {"FPP_TOOLGUN1", "duplicatenoweapons"}, toolgun)
	addchk("Duplicator blocked list is a white list", {"FPP_TOOLGUN1", "spawniswhitelist"}, toolgun)
	addchk("Admins can spawn blocked weapons", {"FPP_TOOLGUN1", "spawnadmincanweapon"}, toolgun)
	addchk("Admins can spawn blocked entities", {"FPP_TOOLGUN1", "spawnadmincanblocked"}, toolgun)
	addblock(toolgun, "Spawning1")

	local usecat, playeruse = MakeOption("Player use options")
	addchk("Use protection enabled", {"FPP_PLAYERUSE1", "toggle"}, playeruse)
	addchk("Admins can use all entities", {"FPP_PLAYERUSE1", "adminall"}, playeruse)
	addchk("People can use world entities", {"FPP_PLAYERUSE1", "worldprops"}, playeruse)
	addchk("Admins can use world entities", {"FPP_PLAYERUSE1", "adminworldprops"}, playeruse)
	addchk("People can use blocked entities", {"FPP_PLAYERUSE1", "canblocked"}, playeruse)
	addchk("Admins can use blocked entities", {"FPP_PLAYERUSE1", "admincanblocked"}, playeruse)
	addchk("Show icon in the middle of the screen", {"FPP_PLAYERUSE1", "shownocross"}, playeruse)
	addchk("Check constrained entities", {"FPP_PLAYERUSE1", "checkconstrained"}, playeruse)
	addblock(playeruse, "PlayerUse1")

	local damagecat, damage = MakeOption("Entity damage options")
	damage:Add(Label("Prevents players from damaging other players' props"))

	addchk("Damage protection enabled", {"FPP_ENTITYDAMAGE1", "toggle"}, damage)
	addchk("Prop damage protection", {"FPP_ENTITYDAMAGE1", "protectpropdamage"}, damage)
	addchk("Admins can damage all entities", {"FPP_ENTITYDAMAGE1", "adminall"}, damage)
	addchk("People can damage world entities", {"FPP_ENTITYDAMAGE1", "worldprops"}, damage)
	addchk("Admins can damage world entities", {"FPP_ENTITYDAMAGE1", "adminworldprops"}, damage)
	addchk("People can damage blocked entities", {"FPP_ENTITYDAMAGE1", "canblocked"}, damage)
	addchk("Admins can damage blocked entities", {"FPP_ENTITYDAMAGE1", "admincanblocked"}, damage)
	addchk("Show icon in the middle of the screen", {"FPP_ENTITYDAMAGE1", "shownocross"}, damage)
	addchk("Check constrained entities", {"FPP_ENTITYDAMAGE1", "checkconstrained"}, damage)
	addchk("The blocked list is a white list", {"FPP_ENTITYDAMAGE1", "iswhitelist"}, damage)
	addblock(damage, "EntityDamage1")

	local blockedmodelscat, blockedmodels = MakeOption("Blocked models options")
	local BlockedModelsLabel = blockedmodels:Add("DLabel")
	BlockedModelsLabel:SetText("\nTo add a model in the blocked models list:\nOpen the spawn menu, right click a prop and\nadd it to the blocked list")
	BlockedModelsLabel:SizeToContents()

	addchk("Blocked models enabled", {"FPP_BLOCKMODELSETTINGS1", "toggle"}, blockedmodels)
	addchk("Apply to props only", {"FPP_BLOCKMODELSETTINGS1", "propsonly"}, blockedmodels)
	addchk("The blocked models list is a white list", {"FPP_BLOCKMODELSETTINGS1", "iswhitelist"}, blockedmodels)

	local BlockedModelsAddLA = blockedmodels:Add("DButton")
	BlockedModelsAddLA:SetText("Add model of entity you're looking at")
	function BlockedModelsAddLA:DoClick()
		if not IsValid(LocalPlayer():GetEyeTraceNoCursor().Entity) then return end
		RunConsoleCommand("FPP_AddBlockedModel", LocalPlayer():GetEyeTraceNoCursor().Entity:GetModel())
	end

	local BlockedModelsList = blockedmodels:Add("DButton")
	BlockedModelsList:SetText("Show blocked models")
	BlockedModelsList:SetToolTip("If there are no models in the list THIS BUTTON WON'T DO ANYTHING")
	function BlockedModelsList:DoClick()
		RunConsoleCommand("FPP_sendblockedmodels")

		local frame = vgui.Create("DFrame")
		frame:MakePopup()
		frame:SetVisible(true)
		frame:SetSize(math.Min(1280, ScrW() - 100), math.Min(720, ScrH() - 100))
		frame:Center()
		frame:SetTitle(((tobool(GetConVarNumber("_FPP_BLOCKMODELSETTINGS1_iswhitelist")) and "Allowed") or "Blocked") .. " models list")
		function frame:Close()
			ShowBlockedModels = nil
			self:Remove()
		end

		local Explanation = vgui.Create("DLabel", frame)
		Explanation:SetPos(5, 25)
		Explanation:SetText([[This is the list of props that are currently in the Blocked/Allowed props list.
		If this is a whitelist (set in settings), only the entities with the models in this list can be spawned
		If it's a blacklist, people will be able to spawn any model except for the ones in this list.

		To remove a model from the list, click the model in this list and click remove.
		To add a model to this list:
		        - open your spawn menu (Q by default)
		        - find the model in the props list
		        - right click it
		        - click "Add to blocked models"]])
		Explanation:SizeToContents()

		frame.pan = vgui.Create("DPanelList", frame)
		frame.pan:SetPos(5, 160)
		frame.pan:SetSize(frame:GetWide() - 10, frame:GetTall() - 165)
		frame.pan:EnableHorizontal(true)
		frame.pan:EnableVerticalScrollbar(true)
		frame.pan:SetSpacing(0)
		frame.pan:SetPadding(4)
		frame.pan:SetAutoSize(false)
		ShowBlockedModels = frame
	end

	local ToolRestrictCat, ToolRestrict = MakeOption("Tool restriction") --spawnmenu.GetTools()

	FPP.DtreeToolRestrict = ToolRestrict:Add(FPP.DtreeToolRestrict or "DTree")
	FPP.multirestricttoollist = ToolRestrict:Add(FPP.multirestricttoollist or "DListView")
	FPP.DtreeToolRestrict:SetVisible(true)
	FPP.DtreeToolRestrict:SetSize(0, 300)

	local NodesTable = {}
	FPP.SELECTEDRESTRICTNODE = FPP.SELECTEDRESTRICTNODE or "weld"

	if not FPP.DtreeToolRestrict.Items then
		FPP.DtreeToolRestrict.Items = true
		for a,b in pairs(spawnmenu.GetTools()) do
			for c,d in pairs(spawnmenu.GetTools()[a].Items) do
				local addnodes = {}
				for e,f in pairs(spawnmenu.GetTools()[a].Items[c]) do
					if type(f) == "table" and string.find(f.Command, "gmod_tool") then
						table.insert(addnodes, {f.Text, f.ItemName})
					end
				end
				if #addnodes ~= 0 then
					local node1 = FPP.DtreeToolRestrict:AddNode(d.ItemName)
					for e,f in pairs(addnodes) do
						local node2 = node1:AddNode(f[1])
						node2.Icon:SetImage("gui/silkicons/wrench")
						node2.Tool = f[2]
						function node2:DoClick()
							FPP.SELECTEDRESTRICTNODE = self.Tool

							for k,v in pairs(weapons.Get("gmod_tool").Tool) do
								if v.Mode and v.Mode == FPP.SELECTEDRESTRICTNODE then
									--Add to DListView
									for a,b in pairs(FPP.multirestricttoollist:GetLines()) do
										if b.Columns[1].Value == k then
											return
										end
									end
									FPP.multirestricttoollist:AddLine(k)
									return
								end
							end
						end
					end
				end
			end
		end
	end

	local SingleEditTool = ToolRestrict:Add("DButton")
	SingleEditTool:SetText("Edit/view selected tool restrictions")
	SingleEditTool:SetToolTip("Edit or view the restrictions of the selected tool!")
	SingleEditTool.DoClick = function()
		for k,v in pairs(weapons.Get("gmod_tool").Tool) do
			if v.Mode and v.Mode == FPP.SELECTEDRESTRICTNODE then
				RunConsoleCommand("FPP_SendRestrictTool", k)
				return
			end
		end
		SingleEditTool:SetText("No tool selected!")

		timer.Simple(1, function()
			if ValidPanel(SingleEditTool) then
				SingleEditTool:SetText("Edit/view selected tool's restrictions")
			end
		end)
	end

	local EditToolListLabel = ToolRestrict:Add(Label("\nMultiple tool editor.\nAdd tools in this list by clicking on them,\nthen click \"Edit multiple tools\"\nto edit multiple tools at once!"))
	EditToolListLabel:SizeToContents()

	if #FPP.multirestricttoollist.Columns ~= 1 then
		FPP.multirestricttoollist:AddColumn("Tool names")
	end

	FPP.multirestricttoollist:SetTall(150)
	function FPP.multirestricttoollist:OnClickLine(line)
		line:SetSelected(true)
		FPP.multirestricttoollist:RemoveLine(FPP.multirestricttoollist:GetSelectedLine())
	end

	local StartEditMultiTool = ToolRestrict:Add("DButton")
	StartEditMultiTool:SetText("Edit multiple tools")
	StartEditMultiTool:SetToolTip("Start editing the tools in above list!")
	StartEditMultiTool:SetDisabled(not superadmin)
	StartEditMultiTool.DoClick = function()
		local lines = FPP.multirestricttoollist:GetLines()
		local EditTable = {}
		if #lines > 0 then
			for k,v in pairs(lines) do
				table.insert(EditTable, v.Columns[1].Value)
			end
			RetrieveRestrictedTool(EditTable)

			return
		end

		StartEditMultiTool:SetText("List is empty!")


		timer.Simple(1, function()
			if ValidPanel(StartEditMultiTool) then
				StartEditMultiTool:SetText("Edit multiple tools")
			end
		end)
	end

	local GroupRestrictCat, GroupRestrict = MakeOption("Group tool restriction")

	local PressLoadFirst = GroupRestrict:Add(Label("Press \"Load groups and members\" first!"))
	local  membersLabel = Label("Group Members: NOTE: People who have the\nusergroup that matches with this group\nare automatically in this group!")
	membersLabel:SizeToContents()
	GroupRestrict:Add(membersLabel)

	local LoadGroups = GroupRestrict:Add("DButton")
	LoadGroups:SetText("Load groups and members")
	LoadGroups.DoClick = function()
		RunConsoleCommand("FPP_SendGroups")
		RunConsoleCommand("FPP_SendGroupMembers")
		PressLoadFirst:SetText("Groups loaded!")
	end

	local ChkAllowDefault
	local GroupList = GroupRestrict:Add("DListView")
	GroupList:AddColumn("Group names")
	GroupList:SetSize(0, 100)
	function GroupList:OnClickLine(line)
		self:ClearSelection()
		line:SetSelected(true)
		ChkAllowDefault:SetValue(FPP.Groups[GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue()].allowdefault)
	end

	ChkAllowDefault = GroupRestrict:Add("DCheckBoxLabel")
	ChkAllowDefault:SetText("Allow all tools by default")
	ChkAllowDefault:SetTooltip([[Ticked: All tools are allowed, EXCEPT for the tools in the tool list
	Unticked: NO tools will be allowed, EXCEPT for the tools in the tool list]])
	if GroupList:GetSelectedLine() and FPP.Groups[GroupList:GetSelectedLine().Columns[1]:GetValue()] then
		ChkAllowDefault:SetValue(FPP.Groups[GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue()].allowdefault)
	end
	ChkAllowDefault.Button.Toggle = function()
		local line = GroupList:GetSelectedLine()
		if not line then return end
		local value = 0
		if not ChkAllowDefault.Button:GetChecked() then value = 1 end
		local lineObj = GroupList:GetLine(line)
		RunConsoleCommand("FPP_ChangeGroupStatus", lineObj.Columns[1]:GetValue(), value)
		ChkAllowDefault.Button:SetValue(not ChkAllowDefault.Button:GetChecked())
	end

	local AddGroupBtn = GroupRestrict:Add("DButton")
	AddGroupBtn:SetText("Add a group")
	AddGroupBtn.DoClick = function()
		Derma_StringRequest("Name of the group", "What will be the name of the group?\nNOTE: YOU WILL NOT BE ABLE TO CHANGE THIS AFTERWARDS", "", function(text)
			RunConsoleCommand("FPP_AddGroup", text)
		end)
	end

	local RemGroupBtn = GroupRestrict:Add("DButton")
	RemGroupBtn:SetText("Remove selected group")
	RemGroupBtn.DoClick = function()
		if not GroupList:GetLine(GroupList:GetSelectedLine()) or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns
		or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue() then
			LocalPlayer():ChatPrint("No item selected!")
			return
		end
		RunConsoleCommand("FPP_RemoveGroup", GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue())
		GroupList:RemoveLine(GroupList:GetSelectedLine())
		PressLoadFirst:SetText("List might be corrupted, reload is recommended")
	end

	local EditGroupBtn = GroupRestrict:Add("DButton")
	EditGroupBtn:SetText("Edit selected group's tools")
	EditGroupBtn.DoClick = function()
		if not GroupList:GetLine(GroupList:GetSelectedLine()) or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns
		or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue() then
			LocalPlayer():ChatPrint("No item selected!")
			return
		end
		EditGroupTools(GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue())
	end

	GroupRestrict:Add(Label("Group Members:"))
	local GroupMembers = GroupRestrict:Add("DListView")
	GroupMembers:AddColumn("SteamID")
	GroupMembers:AddColumn("Name")
	GroupMembers:AddColumn("Member of")
	GroupMembers:SetSize(0, 150)

	local AddPerson = GroupRestrict:Add("DButton")
	AddPerson:SetText("Change group of this person to selected")
	AddPerson.DoClick = function()
		if not GroupList:GetLine(GroupList:GetSelectedLine()) or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns
		or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue() then
			LocalPlayer():ChatPrint("No item selected!")
			return
		end

		for k,v in pairs(GroupMembers:GetSelected()) do
			timer.Simple(k/10, function() RunConsoleCommand("FPP_SetPlayerGroup", v.Columns[1]:GetValue(), GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue()) end)
		end
	end

	local AddPersonManual = GroupRestrict:Add("DButton")
	AddPersonManual:SetText("Add person/SteamID to selected group")
	AddPersonManual.DoClick = function()
		if not GroupList:GetLine(GroupList:GetSelectedLine()) or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns
		or not GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue() then
			LocalPlayer():ChatPrint("No item selected!")
			return
		end

		local menu = DermaMenu()
		menu:SetPos(gui.MouseX(), gui.MouseY())

		for a,b in pairs(player.GetAll()) do
			local submenu = menu:AddOption(b:Nick(), function()
				RunConsoleCommand("FPP_SetPlayerGroup", b:UserID(), GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue())
				PressLoadFirst:SetText("List might be corrupted, reload is recommended")
			end)
		end

		local other = menu:AddOption("other...", function()
			Derma_StringRequest("Enter steam ID", "Enter the Steam ID of the person you would like to add to this group.", "", function(text)
				RunConsoleCommand("FPP_SetPlayerGroup", text, GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue())
			end)
		end)
		menu:Open()
	end

	local function RetrieveGroups(len)
		FPP.Groups = net.ReadTable()
		GroupList:Clear()
		for k,v in pairs(FPP.Groups) do
			GroupList:AddLine(k)
		end
		GroupList:SelectFirstItem()
		if #FPP.Groups == 0 then return end
		ChkAllowDefault:SetValue(FPP.Groups[GroupList:GetLine(GroupList:GetSelectedLine()).Columns[1]:GetValue()].allowdefault)
	end
	net.Receive("FPP_Groups", RetrieveGroups)

	local function RetrieveGroupMembers(len)
		FPP.GroupMembers = net.ReadTable()
		GroupMembers:Clear()
		for k,v in pairs(FPP.GroupMembers) do
			local name = "Unknown"
			for _, ply in pairs(player.GetAll()) do
				if ply:SteamID() == k then
					name = ply:Nick()
					break
				end
			end
			GroupMembers:AddLine(k, name, v)
		end
		GroupMembers:SelectFirstItem()
	end
	net.Receive("FPP_GroupMembers", RetrieveGroupMembers)

	AdminPanel.contents:Add(Label("\nFalco's Prop Protection\nMade by Falco A.K.A. FPtje")):SizeToContents()
	AdminPanel:SetContents(AdminPanel.contents)
	AdminPanel:Dock(FILL)
end

RetrieveBlockedModels = function(um)
	local model = um:ReadString()
	if not ShowBlockedModels then return end

	local Icon = vgui.Create("SpawnIcon", ShowBlockedModels.pan)
	Icon:SetModel(model, 1)
	Icon:SetSize(64, 64)
	Icon.DoClick = function()
		local menu = DermaMenu()
		menu:AddOption("Remove from FPP blocked models list", function() -- I use a DMenu so people don't accidentally click the wrong icon and go FFFUUU
			RunConsoleCommand("FPP_RemoveBlockedModel", model)
			Icon:Remove()
			ShowBlockedModels.pan:InvalidateLayout()
		end)
		menu:Open()
	end
	ShowBlockedModels.pan:AddItem(Icon)
end
usermessage.Hook("FPP_BlockedModel", RetrieveBlockedModels)

RetrieveRestrictedTool = function(um)
	local tool, admin, Teams = um, 0, {}--Settings when it's not a usermessage
	if type(um) ~= "table" then
		tool = um:ReadString()
		admin = um:ReadLong()
		Teams = um:ReadString()
		if Teams ~= "nil" then
			Teams = string.Explode(";", Teams)
		else
			Teams = {}
		end
	end

	local frame = vgui.Create("DFrame")
	if type(tool) == "table" then
		frame:SetTitle("Edit multiple tools' restrictions")
	else
		frame:SetTitle("Edit/view "..tool.." restrictions")
	end
	frame:MakePopup()
	frame:SetVisible( true )
	frame:SetSize(250, 400)
	frame:Center()

	local pan = vgui.Create("DPanelList", frame)
	pan:SetPos(10, 30)
	pan:SetSize(230, 1)
	pan:SetSpacing(5)
	pan:EnableHorizontal(false)
	pan:EnableVerticalScrollbar(true)
	pan:SetAutoSize(true)

	local adminsCHKboxes = {}

	adminsCHKboxes[1] = vgui.Create("DCheckBoxLabel")
	adminsCHKboxes[1]:SetText("for everyone")
	adminsCHKboxes[1].GoodValue = 0
	if admin == 0 then
		adminsCHKboxes[1].Button:SetValue(1)
	end
	pan:AddItem(adminsCHKboxes[1])

	adminsCHKboxes[2] = vgui.Create("DCheckBoxLabel")
	adminsCHKboxes[2]:SetText("Admin only")
	adminsCHKboxes[2].GoodValue = 1
	if admin == 1 then
		adminsCHKboxes[2].Button:SetValue(1)
	end
	pan:AddItem(adminsCHKboxes[2])

	adminsCHKboxes[3] = vgui.Create("DCheckBoxLabel")
	adminsCHKboxes[3]:SetText("Superadmin only")
	adminsCHKboxes[3].GoodValue = 2
	if admin == 2 then
		adminsCHKboxes[3].Button:SetValue(1)
	end
	pan:AddItem(adminsCHKboxes[3])

	for k,v in pairs(adminsCHKboxes) do
		adminsCHKboxes[k].Button.Toggle = function()
			if adminsCHKboxes[k].Button:GetChecked() == nil or not adminsCHKboxes[k].Button:GetChecked() then
				for a,b in pairs(adminsCHKboxes) do
					adminsCHKboxes[a].Button:SetValue(false)
				end
				adminsCHKboxes[k].Button:SetValue( true )
				if type(tool) ~= "table" then
					RunConsoleCommand("FPP_restricttool", tool, "admin", adminsCHKboxes[k].GoodValue)
				else
					local i = 0
					for a,b in pairs(tool) do
						i = i + 1
						timer.Simple(i/10, function() -- Timer to prevent lag of executing multiple commands at the same time.
							RunConsoleCommand("FPP_restricttool", b, "admin", adminsCHKboxes[k].GoodValue)
						end)
					end
				end
			else
				return false -- You can't turn a checkbox off
			end
		end
	end

	local RestrictPlayerButton = vgui.Create("DButton", frame)
	RestrictPlayerButton:SetPos(10, #adminsCHKboxes*20 + 35)
	RestrictPlayerButton:SetSize(230, 20)
	RestrictPlayerButton:SetText("Restrict per player")
	RestrictPlayerButton:SetToolTip[[Default: reset their privileges and let them use this/these tool(s) like anyone else
	Allow: Allow them to use this tool no matter what team/admin access the tool is restricted to
	Disallow: Disallow them to use this tool no matter what team/admin access the tool is restricted to]]

	RestrictPlayerButton.DoClick = function(self)
		local menu = DermaMenu(self)
		menu:SetPos(gui.MouseX(), gui.MouseY())

		for k, v in pairs(player.GetAll()) do
			local submenu = menu:AddSubMenu(v:Nick())


			submenu:AddOption( "Default", function()
				if type(tool) ~= "table" then
					RunConsoleCommand("FPP_restricttoolplayer", tool, v:UserID(), 2)
				else
					for a,b in pairs(tool) do
						timer.Simple(a/10, function()
							RunConsoleCommand("FPP_restricttoolplayer", b, v:UserID(), 2)
						end)
					end
				end
			end)


			submenu:AddOption( "Allow", function()
				if type(tool) ~= "table" then
					RunConsoleCommand("FPP_restricttoolplayer", tool, v:UserID(), 1)
				else
					for a,b in pairs(tool) do
						timer.Simple(a/10, function()
							RunConsoleCommand("FPP_restricttoolplayer", b, v:UserID(), 1)
						end)
					end
				end
			end)


			submenu:AddOption( "Disallow", function()
				if type(tool) ~= "table" then
					RunConsoleCommand("FPP_restricttoolplayer", tool, v:UserID(), 0)
				else
					for a,b in pairs(tool) do
						timer.Simple(a/10, function()
							RunConsoleCommand("FPP_restricttoolplayer", b, v:UserID(), 0)
						end)
					end
				end
			end)
		end
		menu:Open()
	end

	local Tpan = vgui.Create("DPanelList", frame)
	Tpan:SetPos(10, #adminsCHKboxes*20 + 65 )
	Tpan:SetSize(230, 325-#adminsCHKboxes*20  )
	Tpan:SetSpacing(5)
	Tpan:EnableHorizontal(false)
	Tpan:EnableVerticalScrollbar(true)

	for k,v in pairs(team.GetAllTeams()) do
		local chkbx = vgui.Create("DCheckBoxLabel")
		chkbx:SetText(v.Name)
		chkbx.Team = k
		if table.HasValue(Teams, tostring(k)) then
			chkbx.Button:SetValue(true)
		end

		chkbx.Button.Toggle = function()
			if chkbx.Button:GetChecked() == nil or not chkbx.Button:GetChecked() then
				chkbx.Button:SetValue( true )
			else
				chkbx.Button:SetValue( false )
			end

			local tonum = {}
			tonum[false] = "0"
			tonum[true] = "1"
			if type(tool) ~= "table" then
				RunConsoleCommand("FPP_restricttool", tool, "team", chkbx.Team, tonum[chkbx.Button:GetChecked()] )
			else
				for a,b in pairs(tool) do
					timer.Simple(a/10, function()
						RunConsoleCommand("FPP_restricttool", b, "team", chkbx.Team, tonum[chkbx.Button:GetChecked()])
					end)
				end
			end
		end

		Tpan:AddItem(chkbx)
	end

end
usermessage.Hook("FPP_RestrictedToolList", RetrieveRestrictedTool)

EditGroupTools = function(groupname)
	if not FPP.Groups[groupname] then return end
	local tools = FPP.Groups[groupname].tools
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Edit tools of "..groupname)
	frame:MakePopup()
	frame:SetVisible( true )
	frame:SetSize(640, 480)
	frame:Center()

	local GroupTools = vgui.Create("DListView", frame)
	GroupTools:SetPos(340, 25)
	GroupTools:SetSize(295, 450)
	GroupTools:AddColumn("Tools currently in "..groupname)

	for k,v in pairs(tools or {}) do
		GroupTools:AddLine(v)
	end

	local SelectTool = Label("Select a tool or a folder", frame)
	SelectTool:SetPos(5, 25)
	SelectTool:SizeToContents()

	local ToolList = vgui.Create("DTree", frame)
	ToolList:SetPos(5, 45)
	ToolList:SetSize(300, 430)

	for a,b in pairs(spawnmenu.GetTools()) do
		for c,d in pairs(spawnmenu.GetTools()[a].Items) do
			local addnodes = {}
			for g,h in pairs(weapons.Get("gmod_tool").Tool) do
				if h.Category and h.Category == d.ItemName then
					table.insert(addnodes, {h.Name, g})
				end
			end

			if #addnodes ~= 0 then
				local node1 = ToolList:AddNode(d.ItemName)
				node1.Tool = d.ItemName
				for e,f in pairs(addnodes) do
					local node2 = node1:AddNode(f[1])
					node2.Icon:SetImage("icon16/wrench.png")
					node2.Tool = f[2]
				end
			end
		end
	end

	local AddTool = vgui.Create("DButton", frame)
	AddTool:SetPos(310, 45)
	AddTool:SetSize(25, 25)
	AddTool:SetText(">")
	AddTool.DoClick = function()

		if not ToolList.m_pSelectedItem then return end
		local SelectedTool = string.lower(ToolList.m_pSelectedItem.Tool)

		if not ToolList.m_pSelectedItem.ChildNodes then -- if it's not a folder
			for k,v in pairs(GroupTools:GetLines()) do
				if v.Columns[1]:GetValue() == SelectedTool then
					return
				end
			end
			RunConsoleCommand("FPP_AddGroupTool", groupname, SelectedTool)
			GroupTools:AddLine(SelectedTool)
		else--if it's a folder:
			for k,v in pairs(ToolList.m_pSelectedItem.ChildNodes:GetChildren()) do
				local found = false
				for a,b in pairs(GroupTools:GetLines()) do
					if b.Columns[1]:GetValue() == string.lower(v.Tool) then
						found = true
						break
					end
				end
				if not found then
					GroupTools:AddLine(string.lower(v.Tool))
					timer.Simple(k/10, function() RunConsoleCommand("FPP_AddGroupTool", groupname, v.Tool) end)
				end
			end
		end
	end

	local RemTool = vgui.Create("DButton", frame)
	RemTool:SetPos(310, 75)
	RemTool:SetSize(25, 25)
	RemTool:SetText("<")
	RemTool.DoClick = function()
		for k,v in pairs(GroupTools:GetSelected()) do
			local toolname = v.Columns[1]:GetValue()
			timer.Simple(k/10, function() RunConsoleCommand("FPP_RemoveGroupTool", groupname, toolname) end)
			GroupTools:RemoveLine(v.m_iID)
		end
	end
end

local function retrieveblocked(um)
	local Type = string.lower(um:ReadString())
	if not BlockedLists[Type] then return end
	local text = um:ReadString()
	local line = BlockedLists[Type]:AddLine(text)
	line.text = text
	BlockedLists[Type]:SetTall(18 + #BlockedLists[Type]:GetLines() * 17)
	//BlockedLists[Type]:GetParent():GetParent():GetParent():GetParent():InvalidateLayout()
end
usermessage.Hook("FPP_blockedlist", retrieveblocked)

local BuddiesPanel
function FPP.BuddiesMenu(Panel)
	BuddiesPanel = Panel
	Panel:ClearControls()
	BuddiesPanel:Clear()

	Panel:AddControl("Label", {Text = "\nBuddies menu\nNote: Your buddies are saved and will work in all servers with FPP\nThe buddies list includes players that aren't here\n\nYour buddies:"})
	local BuddiesList = vgui.Create("DListView")
	BuddiesList:AddColumn("Steam ID")
	BuddiesList:AddColumn("Name")
	BuddiesList:SetTall(150)
	BuddiesList:SetMultiSelect(false)
	BuddiesPanel:AddPanel(BuddiesList)
	for k,v in pairs(FPP.Buddies) do
		BuddiesList:AddLine(k, v.name)
	end
	BuddiesList:SelectFirstItem()

	local remove = vgui.Create("DButton")
	remove:SetText("Remove selected buddy")
	remove.DoClick = function()
		local line = BuddiesList:GetLine(BuddiesList:GetSelectedLine())--Select the only selected line
		if not line then return end
		FPP.SaveBuddy(line.Columns[1]:GetValue(), line.Columns[2]:GetValue(), "remove")
		FPP.BuddiesMenu(BuddiesPanel) -- Restart the entire menu
	end
	BuddiesPanel:AddPanel(remove)

	local edit = vgui.Create("DButton")
	edit:SetText("Edit selected buddy")
	edit.DoClick = function()
		local line = BuddiesList:GetLine(BuddiesList:GetSelectedLine())--Select the only selected line
		if not line then return end
		local tmp = FPP.Buddies[line.Columns[1]:GetValue()]
		if not tmp then return end
		local data = {tmp.physgun, tmp.gravgun, tmp.toolgun, tmp.playeruse, tmp.entitydamage}
		FPP.SetBuddyMenu(line.Columns[1]:GetValue(), line.Columns[2]:GetValue(), data)
	end
	BuddiesPanel:AddPanel(edit)

	local AddManual = vgui.Create("DButton")
	AddManual:SetText("Add steamID manually")
	AddManual.DoClick = function()
		Derma_StringRequest("Add buddy manually",
		"Please enter the SteamID of the player you want to add in your buddies list",
		"",
		function(ID)

			Derma_StringRequest("Name of buddy",
			"What is the name of this buddy? (You can enter any name, it will change the next time you meet in a server with FPP)",
			"",
			function(Name)
				FPP.SetBuddyMenu(ID, Name)
			end)
		end)
	end
	BuddiesPanel:AddPanel(AddManual)

	Panel:AddControl("Label", {Text = "\nAdd buddy:"})
	local AvailablePlayers = false
	for k,v in SortedPairs(player.GetAll(), function(a,b) return a:Nick() > b:Nick() end) do
		local cantadd = false
		if v == LocalPlayer() then cantadd = true end
		for a,b in pairs(FPP.Buddies) do
			if a == v:SteamID()then
				cantadd = true
				break
			end
		end

		if not cantadd then
			local add = vgui.Create("DButton")
			add:SetText(v:Nick())
			add.DoClick = function()
				FPP.SetBuddyMenu(v:SteamID(), v:Nick())
			end
			BuddiesPanel:AddPanel(add)
			AvailablePlayers = true
		end
	end
	if not AvailablePlayers then
		Panel:AddControl("Label", {Text = "<No players available>"})
	end
end

function FPP.SetBuddyMenu(SteamID, Name, data)
	local frame = vgui.Create("DFrame")
	frame:SetTitle(Name)
	frame:MakePopup()
	frame:SetVisible( true )
	frame:SetSize(150, 130)
	frame:Center()

	local count = 1.5
	local function AddChk(name, Type, value)
		local box = vgui.Create("DCheckBoxLabel", frame)
		box:SetText(name .." buddy")

		box:SetPos(10, count * 20)
		count = count + 1
		box:SetValue(tobool(value))
		box.Button.Toggle = function()
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then
				box.Button:SetValue( true )
			else
				box.Button:SetValue( false )
			end
			local tonum = {}
			tonum[false] = 0
			tonum[true] = 1

			FPP.SaveBuddy(SteamID, Name, Type, tonum[box.Button:GetChecked()])
			FPP.BuddiesMenu(BuddiesPanel) -- Restart the entire menu
		end
		box:SizeToContents()
	end

	data = data or {0,0,0,0,0}
	AddChk("Physgun", "physgun", data[1])
	AddChk("Gravgun", "gravgun", data[2])
	AddChk("Toolgun", "toolgun", data[3])
	AddChk("Use", "playeruse", data[4])
	AddChk("Entity damage", "entitydamage", data[5])
end

local PrivateSettings = {
	["touch my own entities"] = "OwnProps",
	["touch world entities"] = "WorldProps",
	["touch other people's entities"] = "OtherPlayerProps",
	["touch blocked entities"] = "BlockedProps",
	["see an icon in the middle of the screen"] = "ShowIcon"
}

for k,v in pairs(PrivateSettings) do
	CreateClientConVar("FPP_PrivateSettings_"..v, 0, true, true)
end
CreateClientConVar("cl_pickupplayers", 1, true, true)

function FPP.PrivateSettings(Panel)
	//PrivateSettingsPanel = PrivateSettingsPanel or Panel
	Panel:AddControl("Label", {Text = "\nPrivate settings menu\nUse to set settings that override server settings\n\nThese settings can only restrict you further.\n"})
	for k,v in pairs(PrivateSettings) do
		Panel:AddControl("CheckBox", {Label = "I don't want to "..k, Command = "FPP_PrivateSettings_"..v})
	end
	Panel:AddControl("CheckBox", {Label = "I want to pick up players", Command = "cl_pickupplayers"})
end

local function makeMenus()
	spawnmenu.AddToolMenuOption( "Utilities", "Falco's prop protection", "Falco's prop protection admin settings", "Admin settings", "", "", FPP.AdminMenu)
	spawnmenu.AddToolMenuOption( "Utilities", "Falco's prop protection", "Falco's prop protection buddies", "Buddies", "", "", FPP.BuddiesMenu)
	spawnmenu.AddToolMenuOption( "Utilities", "Falco's prop protection", "Falco's prop protection Private settings", "Private Settings", "", "", FPP.PrivateSettings)
end
hook.Add("PopulateToolMenu", "FPPMenus", makeMenus)

local function UpdateMenus()
	if AdminPanel then
		FPP.AdminMenu(AdminPanel)
	end
	if BuddiesPanel then
		FPP.BuddiesMenu(BuddiesPanel)
	end
end
hook.Add("SpawnMenuOpen", "FPPMenus", UpdateMenus)

function FPP.SharedMenu(um)
	local ent = um:ReadEntity()
	if not IsValid(ent) then frame:Close() return end
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Share "..ent:GetClass())
	frame:MakePopup()
	frame:SetVisible( true )

	local count = 1.5
	local row = 1
	local function AddChk(name, Type, value)
		local box = vgui.Create("DCheckBoxLabel", frame)
		if type(name) == "string" then
			box:SetText(name .." share this entity")
		elseif name:IsPlayer() and name:IsValid() then
			box:SetText(name:Nick() .." can touch this")
		else
			return
		end

		if count * 20 - (row-1)*ScrH() > ScrH() - 30 - (row - 1)*50 then
			row = row + 1
		end
		box:SetPos(10 + (row - 1) * 155, count * 20 - (row - 1) * ScrH() + (row - 1)*40 )
		count = count + 1
		box:SetValue(value)
		box.Button.Toggle = function()
			if not IsValid(ent) then frame:Close() return end
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then
				box.Button:SetValue( true )
			else
				box.Button:SetValue( false )
			end
			local tonum = {}
			tonum[false] = "0"
			tonum[true] = "1"
			RunConsoleCommand("FPP_ShareProp", ent:EntIndex(), Type, tonum[box.Button:GetChecked()])
		end
		box:SizeToContents()
	end
	AddChk("Physgun", "SharePhysgun1", um:ReadBool())
	AddChk("Gravgun", "ShareGravgun1", um:ReadBool())
	AddChk("Use", "SharePlayerUse1", um:ReadBool())
	AddChk("Damage", "ShareEntityDamage1", um:ReadBool())
	AddChk("Toolgun", "ShareToolgun1", um:ReadBool())

	local long = um:ReadLong()
	local SharedWith = {}

	if long > 0 then
		for i=1, long do
			table.insert(SharedWith, um:ReadEntity())
		end
	end

	if #player.GetAll() ~= 1 then
		count = count + 1
	end
	for k,v in pairs(player.GetAll()) do
		if v ~= LocalPlayer() and v:IsValid() then
			local IsShared = false
			if table.HasValue(SharedWith, v) then
				IsShared = true
			end
			AddChk(v, v:UserID(), IsShared)
		end
	end
	local height = count * 20
	if row > 1 then
		height = ScrH() - 20
	end
	frame:SetSize(math.Min(math.Max(165 + (row - 1) * 165, 165), ScrW()), height)
	frame:Center()
end
usermessage.Hook("FPP_ShareSettings", FPP.SharedMenu)

properties.Add("addFPPBlocked",
{
	MenuLabel	=	"Add to FPP blocked models",
	Order		=	2001,
	MenuIcon	=	"icon16/cross.png",

	Filter		=	function(self, ent, ply)
						if not IsValid(ent) or ent:IsPlayer() then return false end
						return ply:IsSuperAdmin()
					end,

	Action		=	function(self, ent)
						if not IsValid(ent) then return end
						RunConsoleCommand("FPP_AddBlockedModel", ent:GetModel())
					end
})

properties.Add("removeFPPBlocked",
{
	MenuLabel	=	"Remove from FPP blocked models",
	Order		=	2002,
	MenuIcon	=	"icon16/tick.png",

	Filter		=	function(self, ent, ply)
						if not IsValid(ent) or ent:IsPlayer() then return false end
						return ply:IsSuperAdmin()
					end,

	Action		=	function(self, ent)
						if not IsValid(ent) then return end
						RunConsoleCommand("FPP_RemoveBlockedModel", ent:GetModel())
					end
})
