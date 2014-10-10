DarkRP.createFood = DarkRP.stub{
	name = "createFood",
	description = "Create food for DarkRP.",
	parameters = {
		{
			name = "name",
			description = "The name of the food.",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the food.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddFoodItem = DarkRP.createFood

DarkRP.PLAYER.isCook = DarkRP.stub{
	name = "isCook",
	description = "Whether this player is a cook. This function is only available if hungermod is enabled.",
	parameters = {
	},
	returns = {
		{
			name = "answer",
			description = "Whether this player is a cook.",
			type = "boolean"
		}
	},
	metatable = DarkRP.PLAYER
}
