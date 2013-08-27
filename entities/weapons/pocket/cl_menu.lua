local meta = FindMetaTable("Player")
local pocket = {}
local frame
local reload

/*---------------------------------------------------------------------------
Stubs
---------------------------------------------------------------------------*/
DarkRP.stub{
	name = "openPocketMenu",
	description = "Open the DarkRP pocket menu.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP
}

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function meta:getPocketItems()
	if self ~= LocalPlayer() then return nil end

	return pocket
end

function DarkRP.openPocketMenu()
	if frame and frame:IsValid() and frame:IsVisible() then return end
	if LocalPlayer():GetActiveWeapon():GetClass() ~= "pocket" then return end
	if not pocket then pocket = {} return end
	if #pocket <= 0 then return end
	frame = vgui.Create("DFrame")

	frame:SetTitle(DarkRP.getPhrase("drop_item"))
	frame:SetVisible(true)
	frame:MakePopup()

	reload()
	frame:SetSkin(GAMEMODE.Config.DarkRPSkin)
end


/*---------------------------------------------------------------------------
UI
---------------------------------------------------------------------------*/
function reload()
	if not ValidPanel(frame) or not frame:IsVisible() then return end
	if not pocket or next(pocket) == nil then frame:Close() return end

	local itemCount = table.Count(pocket)

	frame:SetSize(itemCount * 64, 90)
	frame:Center()

	local i = 0

	local items = {}
	for k,v in pairs(pocket) do

		local icon = vgui.Create("SpawnIcon", frame)
		icon:SetPos(i * 64, 25)
		icon:SetModel(v.model)
		icon:SetSize(64, 64)
		icon:SetToolTip()
		icon.DoClick = function(self)
			icon:SetToolTip()

			net.Start("DarkRP_spawnPocket")
				net.WriteFloat(k)
			net.SendToServer()
			pocket[k] = nil

			itemCount = itemCount - 1

			if itemCount == 0 then
				frame:Close()
				return
			end

			fn.Map(self.Remove, items)
			items = {}

			LocalPlayer():GetActiveWeapon():SetWeaponHoldType("pistol")
			timer.Simple(0.2, function() if LocalPlayer():GetActiveWeapon():IsValid() then LocalPlayer():GetActiveWeapon():SetWeaponHoldType("normal") end end)
		end

		table.insert(items, icon)
		i = i + 1
	end
end

local function retrievePocket()
	pocket = net.ReadTable()
	reload()
end
net.Receive("DarkRP_Pocket", retrievePocket)
