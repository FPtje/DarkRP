local function GiveWeaponGui(ply)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Give weapon")
    frame:SetSize(ScrW() / 2, ScrH() - 50)
    frame:Center()
    frame:SetVisible(true)
    frame:MakePopup()

    local WeaponMenu = vgui.Create("FAdmin_weaponPanel", frame)
    WeaponMenu:StretchToParent(0,25,0,0)

    function WeaponMenu:DoGiveWeapon(SpawnName, IsAmmo)
        if not ply:IsValid() then return end
        local giveWhat = (IsAmmo and "ammo") or "weapon"

        RunConsoleCommand("FAdmin", "give" .. giveWhat, ply:UserID(), SpawnName)
    end

    WeaponMenu:BuildList()
end

FAdmin.StartHooks["GiveWeapons"] = function()
    FAdmin.Access.AddPrivilege("giveweapon", 2)
    FAdmin.Commands.AddCommand("giveweapon", nil, "<Player>", "<weapon>")

    FAdmin.ScoreBoard.Player:AddActionButton("Give weapon(s)", "fadmin/icons/weapon", Color(255, 130, 0, 255),

    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "giveweapon") end, function(ply, button)
        GiveWeaponGui(ply)
    end)
end
