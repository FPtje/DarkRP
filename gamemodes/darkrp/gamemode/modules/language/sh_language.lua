local rp_languages = {}
local selectedLanguage = GetConVar("gmod_language"):GetString() -- Switch language by setting gmod_language to another language

cvars.AddChangeCallback("gmod_language", function(cv, old, new)
    selectedLanguage = new
end)

-- Some server owners experience that the language is not set correctly on
-- startup. This provides a failsafe in case that happens.
timer.Simple(0, function()
    local gmodLanguage = GetConVar("gmod_language"):GetString()
    if gmodLanguage ~= "" and selectedLanguage ~= gmodLanguage then
        selectedLanguage = gmodLanguage
    end
end)

function DarkRP.addLanguage(name, tbl)
    local old = rp_languages[name] or {}
    rp_languages[name] = tbl

    -- Merge the language with the translations added by DarkRP.addPhrase
    for k, v in pairs(old) do
        if rp_languages[name][k] then continue end
        rp_languages[name][k] = v
    end
    LANGUAGE = rp_languages[name] -- backwards compatibility
end

function DarkRP.addPhrase(lang, name, phrase)
    rp_languages[lang] = rp_languages[lang] or {}
    rp_languages[lang][name] = phrase
end

function DarkRP.getPhrase(name, ...)
    local langTable = rp_languages[selectedLanguage] or rp_languages.en

    return (langTable[name] or rp_languages.en[name]) and string.format(langTable[name] or rp_languages.en[name], ...) or nil
end

function DarkRP.getPhraseLocalized(ply, name, ...)
    local lang = ply:GetInfo("gmod_language") or selectedLanguage
    local langTable = rp_languages[lang] or rp_languages.en

    return (langTable[name] or rp_languages.en[name]) and string.format(langTable[name] or rp_languages.en[name], ...) or nil
end

function DarkRP.getMissingPhrases(lang)
    lang = lang or selectedLanguage
    local res = {}
    local format = "%s = \"%s\","

    for k, v in pairs(rp_languages.en) do
        if rp_languages[lang][k] then continue end
        table.insert(res, string.format(format, k, v))
    end

    return table.IsEmpty(res) and "No language strings missing!" or table.concat(res, "\n")
end

local function getMissingPhrases(ply, cmd, args)
    if not args[1] then print("Please run the command with a language code e.g. darkrp_getphrases \"en\"") return end
    local lang = rp_languages[args[1]]
    if not lang then print("This language does not exist! Make sure the casing is right.")
        print("Available languages:")
        for k in pairs(rp_languages) do print(k) end
        return
    end

    print(DarkRP.getMissingPhrases(args[1]))
end
if CLIENT then concommand.Add("darkrp_getphrases", getMissingPhrases) end

--[[---------------------------------------------------------------------------
Chat command translating
---------------------------------------------------------------------------]]
local chatCmdDescriptions = {}
function DarkRP.addChatCommandsLanguage(lang, tbl)
    chatCmdDescriptions[lang] = chatCmdDescriptions[lang] or {}

    table.Merge(chatCmdDescriptions[lang], tbl)
end

function DarkRP.getChatCommandDescription(name)
    local cmd = DarkRP.getChatCommand(name)
    return chatCmdDescriptions[selectedLanguage] and chatCmdDescriptions[selectedLanguage][name] or
        cmd and cmd.description or
        nil
end

local function getMissingCmdTranslations()
    local cmds = DarkRP.getSortedChatCommands()

    -- No commands have been translated
    if not chatCmdDescriptions[selectedLanguage] then return cmds end

    -- Remove translated commands and maintain keys
    local count = #cmds
    for i = 1, count do
        if chatCmdDescriptions[selectedLanguage][cmds[i].command] then
            cmds[i] = nil
        end
    end

    cmds = table.ClearKeys(cmds)

    return cmds
end

local function printMissingChatTranslations()
    local cmds = getMissingCmdTranslations()
    local text = {}

    local maxCmdLength = 0
    for _, v in pairs(cmds) do maxCmdLength = math.Max(maxCmdLength, string.len(v.command)) end

    for k, v in pairs(cmds) do
        text[k] = string.format([=[["%s"]%s=    "%s",]=], v.command, string.rep(' ', 4 + maxCmdLength - string.len(v.command)), v.description)
    end

    MsgC(Color(0, 255, 0), string.format("%s untranslated chat command descriptions!\n", #cmds))

    text = table.concat(text, "\n    ")
    SetClipboardText(text)

    MsgC(Color(0, 255, 0), "text copied to clipboard!\n")
end
if CLIENT then concommand.Add("darkrp_translateChatCommands", printMissingChatTranslations) end
