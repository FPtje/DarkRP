DarkRP.PLAYER.requestWarrant = DarkRP.stub{
	name = "requestWarrant",
	description = "File a request for a search warrant.",
	parameters = {
		{
			name = "suspect",
			description = "The player who is suspected",
			type = "Player",
			optional = false
		},
		{
			name = "actor",
			description = "The player who wants the warrant",
			type = "Player",
			optional = false
		},
		{
			name = "reason",
			description = "The reason for the warrant",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.warrant = DarkRP.stub{
	name = "warrant",
	description = "Get a search warrant for this person",
	parameters = {
		{
			name = "warranter",
			description = "The player who set the warrant",
			type = "Player",
			optional = false
		},
		{
			name = "reason",
			description = "The reason for the warrant",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.unWarrant = DarkRP.stub{
	name = "unWarrant",
	description = "Remove the search warrant for this person",
	parameters = {
		{
			name = "unwarranter",
			description = "The player who removed the warrant",
			type = "Player",
			optional = true
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.wanted = DarkRP.stub{
	name = "wanted",
	description = "Make this person wanted by the police",
	parameters = {
		{
			name = "actor",
			description = "The player who made the other person wanted",
			type = "Player",
			optional = false
		},
		{
			name = "reason",
			description = "The reason for the wanted status",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.unWanted = DarkRP.stub{
	name = "unWanted",
	description = "Clear the wanted status for this person",
	parameters = {
		{
			name = "actor",
			description = "The player who cleared the wanted status",
			type = "Player",
			optional = true
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.arrest = DarkRP.stub{
	name = "arrest",
	description = "Arrest a player",
	parameters = {
		{
			name = "time",
			description = "For how long the player is arrested",
			type = "number",
			optional = true
		},
		{
			name = "Arrester",
			description = "The player who arrested the target",
			type = "Player",
			optional = true
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.unArrest = DarkRP.stub{
	name = "unArrest",
	description = "Unarrest a player",
	parameters = {
		{
			name = "Unarrester",
			description = "The player who unarrested the target",
			type = "Player",
			optional = true
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.hookStub{
	name = "playerArrested",
	description = "When a player is arrested",
	parameters = {
		{
			name = "criminal",
			description = "The arrested criminal",
			type = "Player"
		},
		{
			name = "time",
			description = "The jail time",
			type = "number"
		},
		{
			name = "actor",
			description = "The person who arrested the criminal",
			type = "Player"
		}
	},
	returns = {
	}
}

DarkRP.hookStub{
	name = "playerUnArrested",
	description = "When a player is unarrested",
	parameters = {
		{
			name = "criminal",
			description = "The arrested criminal",
			type = "Player"
		},
		{
			name = "actor",
			description = "The person who arrested the criminal",
			type = "Player"
		}
	},
	returns = {
	}
}