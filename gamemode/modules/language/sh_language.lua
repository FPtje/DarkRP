local rp_languages = {}
local selectedLanguage = GetConVarString("gmod_language") -- Switch language by setting gmod_language to another language

function DarkRP.addLanguage(name, tbl)
	local old = rp_languages[name] or {}
	rp_languages[name] = tbl

	-- Merge the language with the translations added by DarkRP.addPhrase
	for k,v in pairs(old) do
		rp_languages[name][k] = v
	end
end

function DarkRP.addPhrase(lang, name, phrase)
	rp_languages[lang] = rp_languages[lang]  or {}
	rp_languages[lang][name] = phrase
end

function DarkRP.getPhrase(name, ...)
	local langTable = rp_languages[selectedLanguage] or rp_languages.en

	return string.format(langTable[name] or rp_languages.en[name], ...)
end
