local mapList = {}
local gamemodeList = {}
net.Receive("FAdmin_ChangelevelInfo", function(len)
    mapList = {}
    local mapLen = net.ReadUInt(16)

    for i = 1, mapLen, 1 do
        local cat = net.ReadString()
        mapList[cat] = {}
        local catLen = net.ReadUInt(16)

        for j = 1, catLen, 1 do
            mapList[cat][j] = net.ReadString()
        end
    end

    gamemodeList = {}
    local gmLen = net.ReadUInt(16)

    for i = 1, gmLen, 1 do
        gamemodeList[i] = {
            name = net.ReadString(),
            title = net.ReadString()
        }
    end
end)

local Changelevel
FAdmin.StartHooks["ChangeLevel"] = function()
    FAdmin.Access.AddPrivilege("changelevel", 2)
    FAdmin.Commands.AddCommand("changelevel", "[gamemode]", "<map>")

    FAdmin.ScoreBoard.Server:AddServerAction("Changelevel", "icon16/world.png", Color(155, 0, 0, 255), function() return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "changelevel") end,
    function(ply, button)
        local refresh = not Changelevel or table.Count(Changelevel:GetMapList()) ~= table.Count(mapList)
        Changelevel = Changelevel or vgui.Create("FAdmin_Changelevel")
        if refresh then
            Changelevel:SetGamemodeList(gamemodeList)
            Changelevel:SetMapList(mapList)
            Changelevel:Refresh()
        end
        Changelevel:SetVisible(true)
        Changelevel:Center()
        Changelevel:MakePopup()
    end)
end
