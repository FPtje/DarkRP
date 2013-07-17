local F4Menu
local F4MenuTabs
local F4Tabs = {}
local hasReleasedF4 = false
function GM:addF4MenuTab(name, tabControl, icon)
	return table.insert(F4Tabs, {name = name, ctrl = tabControl, icon = icon})
end

function GM:switchTabOrder(from, to)
	F4Tabs[from], F4Tabs[to] = F4Tabs[to], F4Tabs[from]
end

function GM:removeTab(tabNr)
	if ValidPanel(F4Tabs[tabNr].ctrl) then
		F4Tabs[tabNr].ctrl:Remove()
	end
	table.remove(F4Tabs, tabNr)
end

local function ChangeJobVGUI()
	if not F4Menu or not F4Menu:IsValid() then
		F4Menu = vgui.Create("DFrame")
		F4Menu:SetSize(770, 580)
		F4Menu:Center()
		F4Menu:SetVisible( true )
		F4Menu:MakePopup()
		F4Menu:SetTitle("Options menu")
		GAMEMODE:addF4MenuTab("Money/Commands", GAMEMODE:MoneyTab(), "icon16/money.png")
		GAMEMODE:addF4MenuTab("Jobs", GAMEMODE:JobsTab(), "icon16/user_suit.png")
		GAMEMODE:addF4MenuTab("Entities/weapons", GAMEMODE:EntitiesTab(), "icon16/cart.png")
		GAMEMODE:addF4MenuTab("HUD", GAMEMODE:RPHUDTab(), "icon16/camera.png")

		hook.Call("F4MenuTabs", nil)
		F4Menu:SetSkin(GAMEMODE.Config.DarkRPSkin)
	else
		F4Menu:SetVisible(true)
		F4Menu:SetSkin(GAMEMODE.Config.DarkRPSkin)
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

		for k, v in pairs(F4Tabs) do
			F4MenuTabs:AddSheet(v.name, v.ctrl, v.icon, false, false)
		end
	end

	for _, panel in pairs(F4Tabs) do
		if panel.ctrl.Update then panel.ctrl:Update() end
		panel.ctrl:SetSkin(GAMEMODE.Config.DarkRPSkin)
	end

 	function F4Menu:Close()
		F4Menu:SetVisible(false)
		F4Menu:SetSkin(GAMEMODE.Config.DarkRPSkin)
	end

	F4Menu:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
GM.ShowSpare2 = ChangeJobVGUI
