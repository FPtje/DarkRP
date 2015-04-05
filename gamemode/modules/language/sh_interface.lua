fprp.addLanguage = fprp.stub{
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
	metatable = fprp
}

fprp.addPhrase = fprp.stub{
	name = "addPhrase",
	description = "Add a phrase to the existing translation.",
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
	metatable = fprp
}

fprp.getPhrase = fprp.stub{
	name = "getPhrase",
	description = "Get a phrase from the selected language.",
	parameters = {
		{
			name = "key",
			description = "The name of the translated phrase.",
			type = "string",
			optional = false
		},
		{
			name = "Phrase parameters",
			description = "Some phrases need extra information, like in \"PLAYERNAME just won the lottery!\". Not filling in the phrase parameters will cause errors.",
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
	metatable = fprp
}

fprp.getMissingPhrases = fprp.stub{
	name = "getMissingPhrases",
	description = "Get all the phrases a language is missing.",
	parameters = {
		{
			name = "languageCode",
			description = "The language code of the language. For English this is \"en\".",
			type = "string",
			optional = true
		}
	},
	returns = {
		{
			name = "missingPhrases",
			description = "All the missing phrases formatted in such way that you can copy and paste it in your language file.",
			type = "string"
		}
	},
	metatable = fprp
}

fprp.addChatCommandsLanguage = fprp.stub{
	name = "addChatCommandsLanguage",
	description = "Add a translation table for chat command descriptions. See fprpmod/lua/fprp_language/chatcommands.lua for an example.",
	parameters = {
		{
			name = "languageCode",
			description = "The language code of the language. For English this is \"en\".",
			type = "string",
			optional = false
		},
		{
			name = "translations",
			description = "Key-value table with chat command strings as keys and their translation as value.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.getChatCommandDescription = fprp.stub{
	name = "getChatCommandDescription",
	description = "Get the translated description of a chat command.",
	parameters = {
		{
			name = "command",
			description = "The chat command string.",
			type = "string",
			optional = false
		}
	},
	returns = {
		{
			name = "description",
			description = "The translated chat command description.",
			type = "string"
		}
	},
	metatable = fprp
}
