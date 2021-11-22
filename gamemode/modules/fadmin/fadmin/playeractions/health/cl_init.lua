FAdmin.StartHooks["Health"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "sethealth",
        hasTarget = true,
        message = {"instigator", " set the health of ", "targets", " to ", "extraInfo.1"},
        readExtraInfo = function() return {tostring(net.ReadUInt(16))} end
    }

    FAdmin.Access.AddPrivilege("SetHealth", 2)
    FAdmin.Commands.AddCommand("hp", nil, "<Player>", "<health>")
    FAdmin.Commands.AddCommand("SetHealth", nil, "[Player]", "<health>")

    FAdmin.ScoreBoard.Player:AddActionButton("Set health", "icon16/heart.png", Color(255, 130, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetHealth", ply) end,
    function(ply, button)
        --Do nothing when the button has been clicked
    end,
    function(ply, button) -- Create the Wang when the mouse is pressed
        button.OnMousePressed = function()
            local window = Derma_StringRequest("Select health", "What do you want the health of the person to be?", "",
                function(text)
                    local health = DarkRP.toInt(text or 100) or 100
                    RunConsoleCommand("_fadmin", "SetHealth", ply:UserID(), health)
                end
            )

            -- The user is usually holding tab when clicking health, so fix the focus
            window:RequestFocus()
        end
    end)
end
