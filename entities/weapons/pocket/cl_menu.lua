local frame
local function Reload()
	if not ValidPanel(frame) or not frame:IsVisible() then return end
	local items = LocalPlayer():GetTable().Pocket
	if not items or next(items) == nil then frame:Close() return end
	frame:SetSize(#items * 64, 90)
	frame:Center()
	for k,v in pairs(items) do
		if not IsValid(v) then
			items[k] = nil
			for a,b in pairs(LocalPlayer().Pocket) do
				if b == v or not IsValid(b) then
					LocalPlayer():GetTable().Pocket[a] = nil
				end
			end
			items = table.ClearKeys(items)
			frame:Close()
			PocketMenu()
			break
		end
		local icon = vgui.Create("SpawnIcon", frame)
		icon:SetPos((k-1) * 64, 25)
		icon:SetModel(v:GetModel())
		icon:SetSize(64, 64)
		icon:SetToolTip()
		icon.DoClick = function()
			icon:SetToolTip()
			RunConsoleCommand("_RPSpawnPocketItem", v:EntIndex())
			items[k] = nil
			for a,b in pairs(LocalPlayer().Pocket) do
				if b == v then
					LocalPlayer():GetTable().Pocket[a] = nil
				end
			end
			if #items == 0 then
				frame:Close()
				return
			end
			items = table.ClearKeys(items)
			Reload()
			LocalPlayer():GetActiveWeapon():SetWeaponHoldType("pistol")
			timer.Simple(0.2, function() if LocalPlayer():GetActiveWeapon():IsValid() then LocalPlayer():GetActiveWeapon():SetWeaponHoldType("normal") end end)
		end
	end
end

local function StorePocketItem(um)
	LocalPlayer():GetTable().Pocket = LocalPlayer():GetTable().Pocket or {}

	local ent = Entity(um:ReadShort())
	if IsValid(ent) and not table.HasValue(LocalPlayer():GetTable().Pocket, ent) then
		table.insert(LocalPlayer():GetTable().Pocket, ent)
	end

	Reload()
end
usermessage.Hook("Pocket_AddItem", StorePocketItem)

local function RemovePocketItem(um)
	LocalPlayer():GetTable().Pocket = LocalPlayer():GetTable().Pocket or {}

	local ent = Entity(um:ReadShort())
	for k,v in pairs(LocalPlayer():GetTable().Pocket) do
		if v == ent then LocalPlayer():GetTable().Pocket[k] = nil end
	end

	Reload()
end
usermessage.Hook("Pocket_RemoveItem", RemovePocketItem)

local function PocketMenu()
	if frame and frame:IsValid() and frame:IsVisible() then return end
	if LocalPlayer():GetActiveWeapon():GetClass() ~= "pocket" then return end
	if not LocalPlayer():GetTable().Pocket then LocalPlayer():GetTable().Pocket = {} return end
	for k,v in pairs(LocalPlayer():GetTable().Pocket) do if not IsValid(v) then table.remove(LocalPlayer():GetTable().Pocket, k) end end
	if #LocalPlayer():GetTable().Pocket <= 0 then return end
	LocalPlayer():GetTable().Pocket = table.ClearKeys(LocalPlayer():GetTable().Pocket)
	frame = vgui.Create("DFrame")

	frame:SetTitle(DarkRP.getPhrase("drop_item"))
	frame:SetVisible(true)
	frame:MakePopup()

	Reload()
	frame:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
usermessage.Hook("StartPocketMenu", PocketMenu)
