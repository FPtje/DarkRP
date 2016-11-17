local AdminsCanPickUpPlayers = CreateConVar("AdminsCanPickUpPlayers", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local PlayersCanPickUpPlayers = CreateConVar("PlayersCanPickUpPlayers", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

FAdmin.StartHooks["PickUpPlayers"] = function()
    FAdmin.Access.AddPrivilege("PickUpPlayers", 2)
    FAdmin.ScoreBoard.Server:AddPlayerAction(function() return (AdminsCanPickUpPlayers:GetBool() and "Disable" or "Enable") .. " Admin>Player pickup" end,
    function() return "fadmin/icons/pickup", AdminsCanPickUpPlayers:GetBool() and "fadmin/icons/disable" end, Color(0, 155, 0, 255), function(ply) return ply:IsSuperAdmin() end, function(button)
        button:SetImage2((not AdminsCanPickUpPlayers:GetBool() and "fadmin/icons/disable") or "null")
        button:SetText((not AdminsCanPickUpPlayers:GetBool() and "Disable" or "Enable") .. " Admin>Player pickup")
        button:GetParent():InvalidateLayout()
        RunConsoleCommand("_FAdmin", "AdminsCanPickUpPlayers", AdminsCanPickUpPlayers:GetBool() and "0" or "1")
    end)

    FAdmin.ScoreBoard.Server:AddPlayerAction(function() return (PlayersCanPickUpPlayers:GetBool() and "Disable" or "Enable") .. " Player>Player pickup" end,
    function() return "fadmin/icons/pickup", PlayersCanPickUpPlayers:GetBool() and "fadmin/icons/disable" end, Color(0, 155, 0, 255), function(ply) return ply:IsSuperAdmin() end, function(button)
        button:SetImage2((not PlayersCanPickUpPlayers:GetBool() and "fadmin/icons/disable") or "null")
        button:SetText((not PlayersCanPickUpPlayers:GetBool() and "Disable" or "Enable") .. " Player>Player pickup")
        button:GetParent():InvalidateLayout()
        RunConsoleCommand("_FAdmin", "PlayersCanPickUpPlayers", PlayersCanPickUpPlayers:GetBool() and "0" or "1")
    end)
end
