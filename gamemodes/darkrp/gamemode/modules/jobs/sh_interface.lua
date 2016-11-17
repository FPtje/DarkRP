DarkRP.hookStub{
    name = "OnPlayerChangedTeam",
    description = "When your team (job) is changed.",
    parameters = {
        {
            name = "ply",
            description = "The player that changed team. Clientside this hook is only called for the LocalPlayer.",
            type = "Player"
        },
        {
            name = "before",
            description = "The team before the change.",
            type = "number"
        },
        {
            name = "after",
            description = "The team after the change.",
            type = "number"
        }
    },
    returns = {

    }
}
