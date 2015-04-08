if not UpdateMapList then function UpdateMapList() end end -- Dummy function

local PANEL = {}

/*---------------------------------------------------------
	Init
---------------------------------------------------------*/
function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(false)

	self:SetDeleteOnClose(false)

	self:SetTitle("Change level")
	self:SetSize(630, ScrH() * 0.8)

	self:CreateControls()
end

/*---------------------------------------------------------
	CreateControls
---------------------------------------------------------*/
function PANEL:CreateControls()
	local catList = vgui.Create("DCategoryList", self)
	catList:Dock(FILL)

	local topPanel = vgui.Create("DPanel", self)
	topPanel:SetDrawBackground(false)
	topPanel:DockMargin(0, 0, 0, 4)
	topPanel:Dock(TOP)
	local gmLabel = vgui.Create("DLabel", topPanel)
	gmLabel:SetText("Gamemode:")
	gmLabel:Dock(LEFT)
	local gmComboBox = vgui.Create("DComboBox", topPanel)
	gmComboBox:Dock(FILL)
	for k,v in ipairs(engine.GetGamemodes()) do
		gmComboBox:AddChoice(v.title, v.name)
	end
	gmComboBox:SetValue("(current)")

	local bottomPanel = vgui.Create("DPanel", self)
	bottomPanel:SetDrawBackground(false)
	bottomPanel:DockMargin(0, 4, 0, 0)
	bottomPanel:Dock(BOTTOM)
	local changeButton = vgui.Create("DButton", bottomPanel)
	changeButton:SetText("Change level")
	changeButton:Dock(RIGHT)
	changeButton:SetWidth(100)
	changeButton:SetEnabled(false)
	changeButton.DoClick = function()
		if not IsValid(self.selectedIconPanel) then return end
		local _,gmName = gmComboBox:GetSelected()
		local mapName = self.selectedIconPanel:GetText()
		RunConsoleCommand("_FAdmin", "Changelevel", gmName and gmName or mapName, gmName and mapName)
	end

	ToggleFavourite(nil) -- Trigger map refresh

	if not istable(g_MapListCategorised) then return end

	local function rpFirstSortedPairs(inTbl)
		-- Sorts the table by key but putting "Roleplay" as the first key
		local fn, tbl = SortedPairs(inTbl)
		table.remove(tbl.__SortedIndex, table.KeyFromValue(tbl.__SortedIndex, "Roleplay"))
		table.insert(tbl.__SortedIndex, 1, "Roleplay")
		return fn, tbl
	end

	for catName,maps in rpFirstSortedPairs(g_MapListCategorised) do
		local cat = catList:Add(catName)
		local iconLayout = vgui.Create("DIconLayout")
		iconLayout:SetSpaceX(5)
		iconLayout:SetSpaceY(5)
		for _,map in ipairs(maps) do
			local icon = iconLayout:Add("FAdmin_MapIcon")
			icon:SetText(map)
			icon:SetDark(true)
			local mat = Material("maps/thumb/"..map..".png")
			if mat:IsError() then mat = Material("maps/thumb/noicon.png") end
			icon:SetMaterial(mat)
			local onToggled = icon.OnToggled
			icon.OnToggled = function(iconSelf, selected)
				onToggled(iconSelf, selected)
				if IsValid(self.selectedIconPanel) then
					if selected and self.selectedIconPanel ~= iconSelf then
						self.selectedIconPanel:Toggle()
					elseif not selected and self.selectedIconPanel == iconSelf then
						self.selectedIconPanel = nil
						changeButton:SetEnabled(false)
						return
					end
				end
				self.selectedIconPanel = iconSelf
				changeButton:SetEnabled(true)
			end
		end
		cat:SetContents(iconLayout)
	end
end

vgui.Register("FAdmin_Changelevel", PANEL, "DFrame")