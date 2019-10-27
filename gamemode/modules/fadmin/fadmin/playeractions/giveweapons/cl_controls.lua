-- Controls for the give weapons menu. These are litterally copied and edited from the garry's mod code.
-- Remaking them in case the gamemode is not derived from sandbox
-- Copying from garry's mod code because I'm lazy and because it looks good.


-- Weapon icon:
local PANEL = {}

function PANEL:Init()
    self:SetSize(83, 83)

    self.Label = vgui.Create("DLabel", self)

    self:SetKeepAspect(true)
    self:SetDrawBorder(true)
    self.m_Image:SetPaintedManually(true)
end


function PANEL:PerformLayout()
    self.Label:SizeToContents()
    self.Label:SetFont("TabLarge")
    self.Label:SetTextColor(color_white)
    self.Label:SetContentAlignment(5)
    self.Label:SetWide(self:GetWide())
    self.Label:AlignBottom(2)

    DImageButton.PerformLayout(self)

    if self.imgAdmin then
        self.imgAdmin:SizeToContents()
        self.imgAdmin:AlignTop(4)
        self.imgAdmin:AlignRight(4)
    end
end

function PANEL:CreateAdminIcon()
    self.imgAdmin = vgui.Create("DImage", self)
    self.imgAdmin:SetImage("icon16/shield.png") -- SilkIcons are now merged into GMOD as materials/icon16
    self.imgAdmin:SetTooltip("#Admin Only")
end

function PANEL:Paint()
    local w, h = self:GetSize()
    self.m_Image:Paint()

    surface.SetDrawColor(30, 30, 30, 200)
    surface.DrawRect(0, h - 16, w, 16)
end

function PANEL:Setup(NiceName, SpawnName, IconMaterial, AdminOnly, Parent, IsAmmo)
    self.Label:SetText(DarkRP.deLocalise(NiceName))

    self.DoClick = function() Parent:DoGiveWeapon(SpawnName, IsAmmo) end
    self.DoRightClick = function() end

    if not IconMaterial then
        IconMaterial = "VGUI/entities/" .. SpawnName
    end

    self:SetOnViewMaterial(IconMaterial, "vgui/swepicon")

    if AdminOnly then self:CreateAdminIcon() end

    self:InvalidateLayout()
end

local WeaponIcon = vgui.RegisterTable(PANEL, "DImageButton")

-- Full panel:
local PANEL2 = {}

function PANEL2:Init()
    self.PanelList = vgui.Create("DPanelList", self)
    self.PanelList:SetPadding(4)
    self.PanelList:SetSpacing(2)
    self.PanelList:EnableVerticalScrollbar(true)
end

function PANEL2:BuildList()
    self.PanelList:Clear()

    if not self.HideAmmo then
        local AmmoCat = vgui.Create("DCollapsibleCategory", self)
        self.PanelList:AddItem(AmmoCat)
        AmmoCat:SetLabel("Give ammo")

        local AmmoPan = vgui.Create("DPanelList")
        AmmoCat:SetContents(AmmoPan)
        AmmoPan:EnableHorizontal(true)
        AmmoPan:SetPaintBackground(false)
        AmmoPan:SetSpacing(2)
        AmmoPan:SetPadding(2)
        AmmoPan:SetAutoSize(true)

        for k in SortedPairs(FAdmin.AmmoTypes) do
            local Icon = vgui.CreateFromTable(WeaponIcon, self)
            Icon:Setup(k, k, "spawnicons/models/items/boxmrounds60x60.png", false, self, true) -- Gets created clientside by GMOD when someone is after that model, or trying to buy ammo.
            AmmoPan:AddItem(Icon)
        end
    end

    local Weapons = weapons.GetList()
    local Categorised = {}

    Categorised["Half-life 2"] = {}
    for k, weapon in pairs(FAdmin.HL2Guns) do
        table.insert(Categorised["Half-life 2"], {PrintName = k, ClassName = weapon, Spawnable = true,
        Author = "Half-life 2",
        Contact = "gaben@valvesoftware.com",
        Instructions = "Shoot!"})
    end

    for k, weapon in pairs(Weapons) do
        weapon = weapons.Get(weapon.ClassName)
        Weapons[k] = weapon
        weapon.Category = weapon.Category or "Other"

        if not weapon.Spawnable and not weapon.AdminSpawnable then
            Weapons[k] = nil
        else
            Categorised[weapon.Category] = Categorised[weapon.Category] or {}
            table.insert(Categorised[weapon.Category], weapon)
            Weapons[k] = nil
        end
    end

    Weapons = nil

    for CategoryName, v in SortedPairs(Categorised) do
        local Category = vgui.Create("DCollapsibleCategory", self)
        self.PanelList:AddItem(Category)
        Category:SetLabel(CategoryName)
        Category:SetCookieName("WeaponSpawn." .. CategoryName)

        local Content = vgui.Create("DPanelList")
        Category:SetContents(Content)
        Content:EnableHorizontal(true)
        Content:SetPaintBackground(false)
        Content:SetSpacing(2)
        Content:SetPadding(2)
        Content:SetAutoSize(true)

        for _, WeaponTable in SortedPairsByMemberValue(v, "PrintName") do
            local Icon = vgui.CreateFromTable(WeaponIcon, self)
            Icon:Setup(WeaponTable.PrintName or WeaponTable.ClassName, WeaponTable.ClassName, WeaponTable.SpawnMenuIcon, WeaponTable.AdminSpawnable and not WeaponTable.Spawnable, self)

            local Tooltip = Format("Name: %s", WeaponTable.PrintName)
            if WeaponTable.Author ~= "" then Tooltip = Format("%s\nAuthor: %s", Tooltip, WeaponTable.Author) end
            if WeaponTable.Contact ~= "" then Tooltip = Format("%s\nContact: %s", Tooltip, WeaponTable.Contact) end
            if WeaponTable.Instructions ~= "" then Tooltip = Format("%s\n\n%s", Tooltip, WeaponTable.Instructions) end

            Icon:SetTooltip(Tooltip)
            Content:AddItem(Icon)
        end
    end
    self.PanelList:InvalidateLayout()
end

function PANEL2:PerformLayout()
    self.PanelList:StretchToParent(0, 0, 0, 0)
end

derma.DefineControl("FAdmin_weaponPanel", "Weapon panel for giving weapons in FAdmin", PANEL2, "Panel")
