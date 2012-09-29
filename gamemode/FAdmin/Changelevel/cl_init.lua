/*include("menu/getmaps.lua")
include("menu/maplist_iconview.lua")
include("menu/map_icon.lua")

local Changelevel
FAdmin.StartHooks["ChangeLevel"] = function()
	FAdmin.Access.AddPrivilege("changelevel", 2)
	FAdmin.Commands.AddCommand("changelevel", "[gamemode]", "<map>")

	FAdmin.ScoreBoard.Server:AddServerAction("Changelevel", "icon16/world.png", Color(155, 0, 0, 255), function() return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "changelevel") end,
	function(ply, button)
		Changelevel = Changelevel or vgui.Create("FAdmin_Changelevel")
		Changelevel:SetVisible(true)
		Changelevel:Center()
		Changelevel:MakePopup()
	end)
end*/