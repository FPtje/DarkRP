local function FillMenu(menu, SpawnName, GroupName)
    menu:AddOption("unrestrict", function() RunConsoleCommand("_FAdmin", "UnRestrictWeapon", SpawnName) end)

    menu:AddSpacer("")
    for k in SortedPairsByMemberValue(FAdmin.Access.Groups, "ADMIN", true) do
        menu:AddOption(k, function() RunConsoleCommand("_FAdmin", "RestrictWeapon", SpawnName, k) end)
    end
end

local function RestrictWeaponMenu()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Restrict weapons")
    frame:SetSize(ScrW() / 2, ScrH() - 50)
    frame:Center()
    frame:SetVisible(true)
    frame:MakePopup()

    local WeaponMenu = vgui.Create("FAdmin_weaponPanel", frame)
    WeaponMenu.HideAmmo = true
    function WeaponMenu:DoGiveWeapon(SpawnName)
        local menu = DermaMenu()
        menu:SetPos(gui.MouseX(), gui.MouseY())
        FillMenu(menu, SpawnName)
        menu:Open()
    end
    WeaponMenu:BuildList()
    WeaponMenu:StretchToParent(0,25,0,0)
end

FAdmin.StartHooks["Restrict"] = function()
    FAdmin.Access.AddPrivilege("Restrict", 3)
    FAdmin.ScoreBoard.Server:AddPlayerAction("Restrict weapons", "fadmin/icons/weapon", Color(0, 155, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(ply, "Restrict") end, RestrictWeaponMenu)
end
