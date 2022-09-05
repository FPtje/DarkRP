local meta = FindMetaTable("Player")
local pocket = {}
local frame
local reload

--[[---------------------------------------------------------------------------
Stubs
---------------------------------------------------------------------------]]
DarkRP.stub{
    name = "openPocketMenu",
    description = "Open the DarkRP pocket menu.",
    realm = "Client",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP
}

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function meta:getPocketItems()
    if self ~= LocalPlayer() then return nil end

    return pocket
end

function DarkRP.openPocketMenu()
    if IsValid(frame) and frame:IsVisible() then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if not wep:IsValid() or wep:GetClass() ~= "pocket" then return end

    if not pocket then
        pocket = {}

        return
    end

    if table.IsEmpty(pocket) then return end
    frame = vgui.Create("DFrame")

    local count = GAMEMODE.Config.pocketitems or GM.Config.pocketitems
    frame:SetSize(345, 32 + 64 * math.ceil(count / 5) + 3 * math.ceil(count / 5))
    frame:SetTitle(DarkRP.getPhrase("drop_item"))
    frame.btnMaxim:SetVisible(false)
    frame.btnMinim:SetVisible(false)
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:Center()

    local Scroll = vgui.Create("DScrollPanel", frame)
    Scroll:Dock(FILL)

    local sbar = Scroll:GetVBar()
    sbar:SetWide(3)
    frame.List = vgui.Create("DIconLayout", Scroll)
    frame.List:Dock(FILL)
    frame.List:SetSpaceY(3)
    frame.List:SetSpaceX(3)
    reload()
    frame:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
net.Receive("DarkRP_PocketMenu", DarkRP.openPocketMenu)

--[[---------------------------------------------------------------------------
UI
---------------------------------------------------------------------------]]
function reload()
    if not IsValid(frame) or not frame:IsVisible() then return end
    if not pocket or next(pocket) == nil then frame:Close() return end

    local itemCount = table.Count(pocket)

    frame.List:Clear()
    local items = {}

    for k, v in pairs(pocket) do
        local ListItem = frame.List:Add("DPanel")
        ListItem:SetSize(64, 64)

        local icon = vgui.Create("SpawnIcon", ListItem)
        icon:SetModel(v.model)
        icon:SetSize(64, 64)
        icon:SetTooltip()
        icon.DoClick = function(self)
            icon:SetTooltip()

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

            local wep = LocalPlayer():GetActiveWeapon()

            wep:SetHoldType("pistol")
            timer.Simple(0.2, function()
                if wep:IsValid() then
                    wep:SetHoldType("normal")
                end
            end)
        end

        table.insert(items, icon)
    end
    if itemCount < GAMEMODE.Config.pocketitems then
        for _ = 1, GAMEMODE.Config.pocketitems - itemCount do
            local ListItem = frame.List:Add("DPanel")
            ListItem:SetSize(64, 64)
        end
    end
end

local function retrievePocket()
    pocket = net.ReadTable()
    reload()
end
net.Receive("DarkRP_Pocket", retrievePocket)
