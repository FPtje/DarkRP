FAdmin.StartHooks["God"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "god",
        hasTarget = true,
        message = {"instigator", " enabled godmode for ", "targets"},
        receivers = "everyone",
    }

    FAdmin.Messages.RegisterNotification{
        name = "ungod",
        hasTarget = true,
        message = {"instigator", " disabled godmode for ", "targets"},
        receivers = "everyone",
    }

    FAdmin.Access.AddPrivilege("God", 2)
    FAdmin.Commands.AddCommand("god", nil, "<Player>")
    FAdmin.Commands.AddCommand("ungod", nil, "<Player>")

    FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_godded") then return "Ungod" end
        return "God"
    end, function(ply)
        if ply:FAdmin_GetGlobal("FAdmin_godded") then return "fadmin/icons/god", "fadmin/icons/disable" end
        return "fadmin/icons/god"
    end, Color(255, 130, 0, 255),

    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "God") end, function(ply, button)
        if not ply:FAdmin_GetGlobal("FAdmin_godded") then
            RunConsoleCommand("_FAdmin", "god", ply:UserID())
        else
            RunConsoleCommand("_FAdmin", "ungod", ply:UserID())
        end

        if not ply:FAdmin_GetGlobal("FAdmin_godded") then button:SetImage2("fadmin/icons/disable") button:SetText("Ungod") button:GetParent():InvalidateLayout() return end
        button:SetImage2("null")
        button:SetText("God")
        button:GetParent():InvalidateLayout()
    end)
end
