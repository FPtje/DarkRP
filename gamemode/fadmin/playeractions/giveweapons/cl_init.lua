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
		if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
			RunConsoleCommand("FAdmin", "give"..giveWhat, ply:Nick(), SpawnName)
		else
			RunConsoleCommand("FAdmin", "give"..giveWhat, ply:SteamID(), SpawnName)
		end
	end

	WeaponMenu:BuildList()
end

FAdmin.StartHooks["GiveWeapons"] = function()
	FAdmin.Access.AddPrivilege("giveweapon", 2)
	FAdmin.Commands.AddCommand("giveweapon", nil, "<Player>", "<weapon>")

	FAdmin.ScoreBoard.Player:AddActionButton("Give weapon(s)", "FAdmin/icons/weapon", Color(255, 130, 0, 255),

	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "giveweapon") end, function(ply, button)
		GiveWeaponGui(ply)
	end)
end