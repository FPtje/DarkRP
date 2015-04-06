fprp.createFood = fprp.stub{
	name = "createFood",
	description = "Create food for fprp.",
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
	metatable = fprp
}
AddFoodItem = fprp.createFood

fprp.PLAYER.isCook = fprp.stub{
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
	metatable = fprp.PLAYER
}
