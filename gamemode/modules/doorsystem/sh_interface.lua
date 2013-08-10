DarkRP.doorToEntIndex = DarkRP.stub{
	name = "doorToEntIndex",
	description = "Get an ENT index from a door index.",
	parameters = {
		{
			name = "index",
			description = "The door index",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "index",
			description = "The ENT index",
			type = "number",
		}
	},
	metatable = DarkRP
}

DarkRP.ENTITY.isKeysOwnable = DarkRP.stub{
	name = "isKeysOwnable",
	description = "Whether this door can be bought.",
	parameters = {
	},
	returns = {
		{
			name = "answer",
			description = "Whether the door can be bought.",
			type = "boolean"
		}
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isDoor = DarkRP.stub{
	name = "isDoor",
	description = "Whether this entity is considered a door in DarkRP.",
	parameters = {
	},
	returns = {
		{
			name = "answer",
			description = "Whether it's a door.",
			type = "boolean"
		}
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.doorIndex = DarkRP.stub{
	name = "doorIndex",
	description = "Get the door index of a door. Use this to store door information in the database.",
	parameters = {
	},
	returns = {
		{
			name = "index",
			description = "The door index.",
			type = "number"
		}
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isKeysOwned = DarkRP.stub{
	name = "isKeysOwned",
	description = "Whether this door is owned by someone.",
	parameters = {
	},
	returns = {
		{
			name = "answer",
			description = "Whether it's owned.",
			type = "boolean"
		}
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getDoorOwner = DarkRP.stub{
	name = "getDoorOwner",
	description = "Get the owner of a door.",
	parameters = {
	},
	returns = {
		{
			name = "owner",
			description = "The owner of the door.",
			type = "Player"
		}
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isMasterOwner = DarkRP.stub{
	name = "isMasterOwner",
	description = "Whether the player is the main owner of the door (as opposed to a co-owner).",
	parameters = {
		{
			name = "ply",
			description = "The player to query.",
			type = "Player",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether this player is the master owner.",
			type = "boolean"
		}
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isKeysOwnedBy = DarkRP.stub{
	name = "isKeysOwnedBy",
	description = "Whether this door is owned or co-owned by this player",
	parameters = {
		{
			name = "ply",
			description = "The player to query.",
			type = "Player",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether this door is (co-)owned by the player.",
			type = "boolean"
		}
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isKeysAllowedToOwn = DarkRP.stub{
	name = "isKeysAllowedToOwn",
	description = "Whether this player is allowed to co-own a door, as decided by the master door owner.",
	parameters = {
		{
			name = "ply",
			description = "The player to query.",
			type = "Player",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether this door is (co-)ownable by the player.",
			type = "boolean"
		}
	},
	metatable = DarkRP.ENTITY
}
