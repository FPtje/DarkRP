DarkRP.addLanguage = DarkRP.stub{
	name = "addLanguage",
	description = "Create a language/translation.",
	parameters = {
		{
			name = "Language name",
			description = "The short name of the language (\"en\" is English). Make sure the language name fits a possible value for gmod_language!",
			type = "string",
			optional = false
		},
		{
			name = "Language contents",
			description = "A table that contains the translation sentences. Look at sh_english.lua for an example.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}

DarkRP.addPhrase = DarkRP.stub{
	name = "addPhrase",
	description = "Add a phrase to the existing translation",
	parameters = {
		{
			name = "Language name",
			description = "The short name of the language (\"en\" is English). Make sure the language name fits a possible value for gmod_language!",
			type = "string",
			optional = false
		},
		{
			name = "key",
			description = "The name of the translated phrase.",
			type = "string",
			optional = false
		},
		{
			name = "translation",
			description = "The translation of the phrase.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}

DarkRP.getPhrase = DarkRP.stub{
	name = "getPhrase",
	description = "Get a phrase from the selected language",
	parameters = {
		{
			name = "key",
			description = "The name of the translated phrase.",
			type = "string",
			optional = false
		},
		{
			name = "Phrase parameters",
			description = "Some phrases need extra information, like in \"PLAYERNAME just won the lottery!\". Not filling in the phrase parameters will cause errors",
			type = "vararg",
			optional = false
		}
	},
	returns = {
		{
			name = "phrase",
			description = "The formatted phrase.",
			type = "string"
		}
	},
	metatable = DarkRP
}
