fprp.getAvailableVehicles = fprp.stub{
	name = "getAvailableVehicles",
	description = "Get the available vehicles that fprp supports.",
	parameters = {
	},
	returns = {
		{
			name = "vehicles",
			description = "Names, models and classnames of all supported vehicles.",
			type = "table"
		}
	},
	metatable = fprp
}
