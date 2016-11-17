local logging = CreateConVar("FAdmin_logging", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

if SERVER then return end
FAdmin.StartHooks["Logging"] = function()
    FAdmin.Access.AddPrivilege("Logging", 3)
    FAdmin.Commands.AddCommand("Logging", nil)

    FAdmin.ScoreBoard.Server:AddServerSetting(function() return (logging:GetBool() and "Disable" or "Enable") .. " Logging" end,
    function() return "fadmin/icons/message", logging:GetBool() and "fadmin/icons/disable" end,
    Color(0, 0, 155, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(ply, "Logging") end, function(button)
        button:SetImage2((not logging:GetBool() and "fadmin/icons/disable") or "null")
        button:SetText((not logging:GetBool() and "Disable" or "Enable") .. " Logging")
        button:GetParent():InvalidateLayout()

        RunConsoleCommand("_Fadmin", "Logging", logging:GetBool() and 0 or 1)
    end)
end
