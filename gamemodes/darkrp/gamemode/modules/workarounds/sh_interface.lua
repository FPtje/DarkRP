DarkRP.getAvailableVehicles = DarkRP.stub{
    name = "getAvailableVehicles",
    description = "Get the available vehicles that DarkRP supports.",
    parameters = {
    },
    returns = {
        {
            name = "vehicles",
            description = "Names, models and classnames of all supported vehicles.",
            type = "table"
        }
    },
    metatable = DarkRP
}
