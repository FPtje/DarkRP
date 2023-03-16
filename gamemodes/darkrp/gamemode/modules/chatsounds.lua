-- This module will make voice sounds play when certain words are typed in the chat
-- You can add/remove sounds as you wish using DarkRP.setChatSound, just follow the format used here
-- To disable them completely, set GM.Config.chatsounds to false
-- TODO: Add female sounds & detect gender of model, and use combine sounds for CPs

local sounds = {}
sounds["ammo"] = {"vo/npc/male01/ammo03.wav", "vo/npc/male01/ammo04.wav", "vo/npc/male01/ammo05.wav"}

sounds["behind you"] = {"vo/npc/male01/behindyou01.wav", "vo/npc/male01/behindyou02.wav"}

sounds["better reload"] = {"vo/npc/male01/youdbetterreload01.wav"}

sounds["bullshit"] = {"vo/npc/male01/question26.wav"}

sounds["bull shit"] = sounds["bullshit"]

sounds["cheese"] = {"vo/npc/male01/question06.wav"}

sounds["combine"] = {"vo/npc/male01/combine01.wav", "vo/npc/male01/combine02.wav"}

sounds["coming"] = {"vo/npc/male01/squad_approach04.wav"}

sounds["cops"] = {"vo/npc/male01/civilprotection01.wav", "vo/npc/male01/civilprotection02.wav", "vo/npc/male01/cps01.wav", "vo/npc/male01/cps02.wav"}

sounds["cp"] = sounds["cops"]
sounds["cps"] = sounds["cops"]

sounds["cut it"] = {"vo/trainyard/male01/cit_hit01.wav", "vo/trainyard/male01/cit_hit02.wav", "vo/trainyard/male01/cit_hit03.wav", "vo/trainyard/male01/cit_hit04.wav", "vo/trainyard/male01/cit_hit05.wav"}

sounds["dont tell me"] = {"vo/npc/male01/gordead_ans03.wav"}

sounds["de ja vu"] = {"vo/npc/male01/question05.wav"}

sounds["dejavu"] = sounds["de ja vu"]

sounds["excuse me"] = {"vo/npc/male01/excuseme01.wav", "vo/npc/male01/excuseme02.wav"}

sounds["fantastic"] = {"vo/npc/male01/fantastic01.wav", "vo/npc/male01/fantastic02.wav"}

sounds["figures"] = {"vo/npc/male01/answer03.wav"}

sounds["finally"] = {"vo/npc/male01/finally.wav"}

sounds["follow"] = {"vo/coast/odessa/male01/stairman_follow01.wav", "vo/npc/male01/squad_away03.wav", "vo/coast/cardock/le_followme.wav"}

sounds["focus"] = {"vo/npc/male01/answer18.wav", "vo/npc/male01/answer19.wav"}

sounds["freeman"] = {"vo/npc/male01/freeman.wav", "vo/npc/male01/docfreeman01.wav", "vo/npc/male01/docfreeman02.wav"}

sounds["get down"] = {"vo/npc/male01/getdown02.wav"}

sounds["get in"] = {"vo/canals/gunboat_getin.wav"}

sounds["get out"] = {"vo/npc/male01/gethellout.wav"}

sounds["good god"] = {"vo/npc/male01/goodgod.wav", "vo/npc/male01/gordead_ans04.wav"}

sounds["gosh"] = sounds["good god"]

sounds["got one"] = {"vo/npc/male01/gotone01.wav", "vo/npc/male01/gotone01.wav"}

sounds["gotta reload"] = {"vo/npc/male01/gottareload01.wav"}

sounds["gtfo"] = sounds["get out"]

sounds["hacks"] = {"vo/npc/male01/hacks01.wav", "vo/npc/male01/hacks02.wav", "vo/npc/male01/thehacks01.wav", "vo/npc/male01/thehacks02.wav"}

sounds["hax"] = sounds["hacks"]
sounds["haxx"] = sounds["hacks"]

sounds["help"] = {"vo/npc/male01/help01.wav"}

sounds["here they come"] = {"vo/npc/male01/heretheycome01.wav", "vo/npc/male01/incoming02.wav"}

sounds["hello"] = {"vo/npc/male01/hi01.wav", "vo/npc/male01/hi02.wav"}

sounds["hey"] = sounds["hello"]
sounds["hi"] = sounds["hello"]

sounds["heads up"] = {"vo/npc/male01/headsup01.wav", "vo/npc/male01/headsup02.wav"}

sounds["he's dead"] = {"vo/npc/male01/gordead_ques01.wav", "vo/npc/male01/gordead_ques07.wav"}

sounds["he is dead"] = sounds["he's dead"]

sounds["how about that"] = {"vo/npc/male01/answer25.wav"}

sounds["i know"] = {"vo/npc/male01/answer08.wav"}

sounds["ill stay here"] = {"vo/npc/male01/illstayhere01.wav", "vo/npc/male01/holddownspot01.wav", "vo/npc/male01/holddownspot02.wav", "vo/npc/male01/imstickinghere01.wav", "vo/npc/male01/littlecorner01.wav"}

sounds["i'll stay here"] = sounds["ill stay here"]
sounds["i will stay here"] = sounds["ill stay here"]

sounds["im busy"] = {"vo/npc/male01/busy02.wav"}

sounds["i'm busy"] = sounds["im busy"]

sounds["im with you"] = {"vo/npc/male01/answer13.wav"}

sounds["i'm with you"] = sounds["im with you"]

sounds["isnt good"] = {"vo/trainyard/male01/cit_window_use01.wav"}

sounds["isn't good"] = sounds["isnt good"]
sounds["incoming"] = sounds["here they come"]

sounds["it cant be"] = {"vo/npc/male01/gordead_ques06.wav"}

sounds["it can't be"] = sounds["it cant be"]

sounds["it is okay"] = {"vo/npc/male01/answer02.wav"}

sounds["it's okay"] = sounds["it is okay"]

sounds["kay"] = {"vo/npc/male01/ok01.wav", "vo/npc/male01/ok02.wav"}

sounds["kk"] = sounds["kay"]

sounds["lead the way"] = {"vo/npc/male01/leadtheway01.wav", "vo/npc/male01/leadtheway02.wav"}

sounds["lead on"] = sounds["lead the way"]

sounds["lets go"] = {"vo/npc/male01/letsgo01.wav", "vo/npc/male01/letsgo02.wav"}

sounds["let's go"] = sounds["lets go"]

sounds["never"] = {"vo/Citadel/eli_nonever.wav"}

sounds["never can tell"] = {"vo/npc/male01/answer23.wav"}

sounds["nice"] = {"vo/npc/male01/nice.wav"}

sounds["no"] = {"vo/Citadel/br_no.wav", "vo/Citadel/eli_notobreen.wav"}

sounds["not good"] = sounds["isnt good"]

sounds["not sure"] = {"vo/npc/male01/answer21.wav"}

sounds["now what"] = {"vo/npc/male01/gordead_ans01.wav", "vo/npc/male01/gordead_ans15.wav"}

sounds["oh no"] = {"vo/npc/male01/gordead_ans05.wav", "vo/npc/male01/ohno.wav"}

sounds["oh my god"] = sounds["good god"]
sounds["omg"] = sounds["good god"]
sounds["omfg"] = sounds["good god"]
sounds["ok"] = sounds["kay"]
sounds["okay"] = sounds["kay"]

sounds["oops"] = {"vo/npc/male01/whoops01.wav"}

sounds["over here"] = {"vo/npc/male01/overhere01.wav", "vo/npc/male01/squad_away02.wav"}

sounds["over there"] = {"vo/npc/male01/overthere01.wav", "vo/npc/male01/overthere02.wav"}

sounds["pardon me"] = {"vo/npc/male01/pardonme01.wav", "vo/npc/male01/pardonme02.wav"}

sounds["please no"] = {"vo/npc/male01/gordead_ans06.wav"}

sounds["right on"] = {"vo/npc/male01/answer18.wav"}

sounds["run"] = {"vo/npc/male01/strider_run.wav"}

sounds["same here"] = {"vo/npc/male01/answer07.wav"}

sounds["shut up"] = {"vo/npc/male01/answer17.wav"}

sounds["spread the word"] = {"vo/npc/male01/gordead_ans10.wav"}

sounds["stop it"] = sounds["cut it"]
sounds["stop that"] = sounds["cut it"]

sounds["stop looking at me"] = {"vo/npc/male01/vquestion01.wav"}

sounds["sorry"] = {"vo/npc/male01/sorry01.wav", "vo/npc/male01/sorry02.wav", "vo/npc/male01/sorry03.wav"}

sounds["sry"] = sounds["sorry"]

sounds["take cover"] = {"vo/npc/male01/takecover02.wav"}

sounds["take this medkit"] = {"vo/npc/male01/health01.wav", "vo/npc/male01/health02.wav", "vo/npc/male01/health03.wav", "vo/npc/male01/health04.wav"}

sounds["task at hand"] = {"vo/npc/male01/answer18.wav"}

sounds["talking to me"] = {"vo/npc/male01/answer30.wav"}

sounds["thats you"] = {"vo/npc/male01/answer01.wav"}

sounds["this cant be"] = sounds["it cant be"]
sounds["this can't be"] = sounds["it cant be"]

sounds["this is bad"] = {"vo/npc/male01/gordead_ques10.wav"}

sounds["too much info"] = {"vo/npc/male01/answer26.wav"}

sounds["too much information"] = sounds["too much info"]

sounds["uhoh"] = {"vo/npc/male01/uhoh.wav"}

sounds["uh oh"] = sounds["uhoh"]

sounds["wait"] = {"vo/trainyard/man_waitaminute.wav"}

sounds["wait for me"] = {"vo/npc/male01/squad_reinforce_single04.wav"}

sounds["wait for us"] = {"vo/npc/male01/squad_reinforce_group04.wav"}

sounds["wanna bet"] = {"vo/npc/male01/answer27.wav"}

sounds["watch out"] = {"vo/npc/male01/watchout.wav"}

sounds["we are done for"] = {"vo/npc/male01/gordead_ans14.wav"}

sounds["we're done for"] = sounds["we are done for"]

sounds["what now"] = {"vo/npc/male01/gordead_ques16.wav"}

sounds["whatever you say"] = {"vo/npc/male01/squad_affirm03.wav"}

sounds["whats the use"] = {"vo/npc/male01/gordead_ans11.wav"}

sounds["what's the use"] = sounds["whats the use"]

sounds["whats the point"] = {"vo/npc/male01/gordead_ans12.wav"}

sounds["what's the point"] = sounds["whats the point"]
sounds["whoops"] = sounds["oops"]

sounds["why go on"] = {"vo/npc/male01/gordead_ans13.wav"}

sounds["why telling me"] = {"vo/npc/male01/answer24.wav"}

sounds["yeah"] = {"vo/npc/male01/yeah02.wav"}

sounds["yes"] = sounds["yeah"]

sounds["you and me both"] = {"vo/npc/male01/answer14.wav"}

sounds["you never know"] = {"vo/npc/male01/answer22.wav"}

sounds["you sure"] = {"vo/npc/male01/answer37.wav"}

DarkRP.hookStub{
    name = "canChatSound",
    description = "Whether a chat sound can be played.",
    parameters = {
        {
            name = "ply",
            description = "The player who triggered the chat sound.",
            type = "Player"
        },
        {
            name = "chatPhrase",
            description = "The chat sound phrase that has been detected.",
            type = "string"
        },
        {
            name = "chatText",
            description = "The whole chat text the player sent that contains the chat sound phrase.",
            type = "string"
        }
    },
    returns = {
        {
            name = "canChatSound",
            description = "False if the chat sound should not be played.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "onChatSound",
    description = "When a chat sound is played.",
    parameters = {
        {
            name = "ply",
            description = "The player who triggered the chat sound.",
            type = "Player"
        },
        {
            name = "chatPhrase",
            description = "The chat sound phrase that was detected.",
            type = "string"
        },
        {
            name = "chatText",
            description = "The whole chat text the player sent that contains the chat sound phrase.",
            type = "string"
        }
    },
    returns = {
    }
}

local function CheckChat(ply, text)
    if not GAMEMODE.Config.chatsounds or ply.nextSpeechSound and ply.nextSpeechSound > CurTime() then return end
    local prefix = string.sub(text, 0, 1)
    if prefix == "/" or prefix == "!" or prefix == "@" then return end -- should cover most chat commands for various mods/addons
    local longestMatch = nil
    local longestMatchLength = 0
    for k, v in pairs(sounds) do
        local res1, res2 = string.find(string.lower(text), k)
        if not res1 then continue end
        local charBefore = text[res1 - 1]
        local charAfter = text[res2 + 1]
        local length = res2 - res1
        -- Check whether the match is not part of a larger word (e.g. "no" should not match when "know" is said)
        if charBefore and charBefore ~= "" and charBefore ~= " " then continue end
        if charAfter and charAfter ~= "" and charAfter ~= " " then continue end

        if length > longestMatchLength then
            longestMatch = k
            longestMatchLength = length
        end
    end

    if not longestMatch then return end

    local canChatSound = hook.Call("canChatSound", nil, ply, longestMatch, text)
    if canChatSound == false then return end
    ply:EmitSound(table.Random(sounds[longestMatch]), 80, 100)
    ply.nextSpeechSound = CurTime() + GAMEMODE.Config.chatsoundsdelay -- make sure they don't spam HAX HAX HAX, if the server owner so desires
    hook.Call("onChatSound", nil, ply, longestMatch, text)
end
hook.Add("PostPlayerSay", "ChatSounds", CheckChat)

DarkRP.getChatSound = DarkRP.stub{
    name = "getChatSound",
    description = "Get a chat sound (play a noise when someone says something) associated with the given phrase.",
    parameters = {
        {
            name = "text",
            description = "The text that triggers the chat sound.",
            type = "string",
            optional = false
        }
    },
    returns = {
        {
            name = "soundPaths",
            description = "A table of string sound paths associated with the given text.",
            type = "table"
        }
    },
    metatable = DarkRP
}

function DarkRP.getChatSound(text)
    return sounds[string.lower(text or "")]
end

DarkRP.setChatSound = DarkRP.stub{
    name = "setChatSound",
    description = "Set a chat sound (play a noise when someone says something)",
    parameters = {
        {
            name = "text",
            description = "The text that should trigger the sound.",
            type = "string",
            optional = false
        },
        {
            name = "sounds",
            description = "A table of string sound paths.",
            type = "table",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

function DarkRP.setChatSound(text, sndTable)
    sounds[string.lower(text or "")] = sndTable
end
