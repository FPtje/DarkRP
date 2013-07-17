DarkRP.findPlayer = DarkRP.stub{
	name = "findPlayer",
	description = "Find a player based on vague information",
	parameters = {
		{
			name = "info",
			description = "The information of the player (UserID, SteamID, name)",
			type = "string",
			optional = false
		}
	},
	returns = {
		{
			name = "found",
			description = "The player that matches the description",
			type = "Player"
		}
	},
	metatable = DarkRP
}

DarkRP.PLAYER.canAfford = DarkRP.stub{
	name = "canAfford",
	description = "Whether the player can afford the given amount of money",
	parameters = {
		{
			name = "amount",
			description = "The amount of money",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether the player can afford it",
			type = "boolean"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.VECTOR.isInSight = DarkRP.stub{
	name = "isInSight",
	description = "Decides whether the vector could be seen by the player if they were to look at it",
	parameters = {
		{
			name = "filter",
			description = "Trace filter that decides what the player can see through",
			type = "table",
			optional = false
		},
		{
			name = "ply",
			description = "The player for whom the vector may or may not be visible",
			type = "Player",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether the player can see the position",
			type = "boolean"
		},
		{
			name = "HitPos",
			description = "The position of the thing that blocks the player's sight",
			type = "Vector"
		}
	},
	metatable = DarkRP.VECTOR
}

/*---------------------------------------------------------------------------
Creating custom items
---------------------------------------------------------------------------*/
DarkRP.createJob = DarkRP.stub{
	name = "createJob",
	description = "Create a job for DarkRP",
	parameters = {
		{
			name = "name",
			description = "The name of the job",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the job",
			type = "table",
			optional = false
		}
	},
	returns = {
		{
			name = "team",
			description = "The team number of the job you've created",
			type = "number"
		}
	},
	metatable = DarkRP
}
AddExtraTeam = DarkRP.createJob

DarkRP.createShipment = DarkRP.stub{
	name = "createShipment",
	description = "Create a shipment for DarkRP",
	parameters = {
		{
			name = "name",
			description = "The name of the shipment",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the shipment",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddCustomShipment = DarkRP.createShipment

DarkRP.createVehicle = DarkRP.stub{
	name = "createVehicle",
	description = "Create a vehicle for DarkRP",
	parameters = {
		{
			name = "name",
			description = "The name of the vehicle",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the vehicle",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddCustomVehicle = DarkRP.createVehicle

DarkRP.createEntity = DarkRP.stub{
	name = "createEntity",
	description = "Create a entity for DarkRP",
	parameters = {
		{
			name = "name",
			description = "The name of the entity",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the entity",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddCustomVehicle = DarkRP.createEntity

DarkRP.createAgenda = DarkRP.stub{
	name = "createAgenda",
	description = "Create an agenda for groups of jobs to communicate",
	parameters = {
		{
			name = "title",
			description = "The name of the agenda",
			type = "string",
			optional = false
		},
		{
			name = "manager",
			description = "The team numer of the manager of the agenda (the one who can set the agenda)",
			type = "number",
			optional = false
		},
		{
			name = "listeners",
			description = "The jobs that can see this agenda",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddAgenda = DarkRP.createAgenda

DarkRP.createGroupChat = DarkRP.stub{
	name = "createGroupChat",
	description = "Create a group chat",
	parameters = {
		{
			name = "functionOrJob",
			description = "A function that returns whether the person can see the group chat, or a team number",
			type = "any",
			optional = false
		},
		{
			name = "teamNr",
			description = "VarArg team number",
			type = "number",
			optional = true
		}
	},
	returns = {
	},
	metatable = DarkRP
}
GM.AddGroupChat = DarkRP.createGroupChat

DarkRP.createAmmoType = DarkRP.stub{
	name = "createAmmoType",
	description = "Create an ammo type",
	parameters = {
		{
			name = "name",
			description = "The name of the ammo",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the ammo",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
//GM.AddAmmoType = DarkRP.createAmmoType
