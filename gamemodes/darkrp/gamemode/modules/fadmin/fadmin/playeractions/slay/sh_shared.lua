FAdmin.PlayerActions.SlayTypes = {}
FAdmin.PlayerActions.SlayTypes[1] = "Normal"
FAdmin.PlayerActions.SlayTypes[2] = "Silent"
FAdmin.PlayerActions.SlayTypes[3] = "Explode"
FAdmin.PlayerActions.SlayTypes[4] = "Rocket"

FAdmin.StartHooks["Slaying"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "slay",
        hasTarget = true,
        message = {"instigator", " slayed ", "targets"},
        receivers = "involved+admins",
    }
end
