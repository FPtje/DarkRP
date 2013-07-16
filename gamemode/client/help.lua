local HelpCategories = {}

local function addCategory(id, name)
	HelpCategories[id] = {id = id, name = name, labels = {}}
	return id
end

local function addLabel(category, text)
	table.insert(HelpCategories[category].labels, text)
end

function GM:AddHelpLabel(category, text)
	addLabel(category, text)
end

function GM:AddHelpLabels(category, labels)
	if type(labels) == "string" then return self:AddHelpLabel(category, labels) end

	for k,v in pairs(labels) do
		table.insert(HelpCategories[category].labels, v)
	end
end

function GM:AddHelpCategory(id, name)
	addCategory(id, name)
end

function GM:RemoveHelpCategory(id)
	HelpCategories[id] = nil
end

function GM:getHelpCategories()
	return HelpCategories
end

local HELP_CATEGORY_CHATCMD = 1
local HELP_CATEGORY_CONCMD = 2
local HELP_CATEGORY_ADMINCMD = 4

addCategory(HELP_CATEGORY_CHATCMD, "Chat Commands")
addCategory(HELP_CATEGORY_CONCMD, "Console Commands")
addCategory(HELP_CATEGORY_ADMINCMD, "Admin Console Commands")

addLabel(HELP_CATEGORY_CONCMD, "gm_showhelp - Toggle help menu (bind this to F1 if you haven't already)")
addLabel(HELP_CATEGORY_CONCMD, "gm_showteam - Show door menu")
addLabel(HELP_CATEGORY_CONCMD, "gm_showspare1 - Toggle vote clicker (bind this to F3 if you haven't already)")
addLabel(HELP_CATEGORY_CONCMD, "gm_showspare2 - Job menu(bind this to F4 if you haven't already)")

addLabel(HELP_CATEGORY_CHATCMD, "/job <Job Name> - Set a custom job")
addLabel(HELP_CATEGORY_CHATCMD, "/w <Message> - Whisper a message")
addLabel(HELP_CATEGORY_CHATCMD, "/y <Message> - Yell a message")
addLabel(HELP_CATEGORY_CHATCMD, "/g <Message> - Group only message")
addLabel(HELP_CATEGORY_CHATCMD, "/pm <Person> <Message> - Private message")
addLabel(HELP_CATEGORY_CHATCMD, "/Channel <1-100> - Set the channel of the radio", 1)
addLabel(HELP_CATEGORY_CHATCMD, "/radio <Message> - Say something through the radio!", 1)
addLabel(HELP_CATEGORY_CHATCMD, "/me <Message> - *name* is doing something!", 1)
addLabel(HELP_CATEGORY_CHATCMD, "/advert <Message> - Advertise!", 1)
addLabel(HELP_CATEGORY_CHATCMD, "/broadcast <Message> - Broadcast a message as mayor!", 1)
addLabel(HELP_CATEGORY_CHATCMD, "//, or /a, or /ooc - Out of Character speak", 1)
addLabel(HELP_CATEGORY_CHATCMD, "/x to close a help dialog", 1)
addLabel(HELP_CATEGORY_CHATCMD, "")
addLabel(HELP_CATEGORY_CHATCMD, "Letters - Press use key to read a letter.  Look away and press use key again to stop reading a letter.")
addLabel(HELP_CATEGORY_CHATCMD, "/write <Message> - Write a letter in handwritten font. Use // to go down a line.")
addLabel(HELP_CATEGORY_CHATCMD, "/type <Message> - Type a letter in computer font.  Use // to go down a line.")
addLabel(HELP_CATEGORY_CHATCMD, "")
addLabel(HELP_CATEGORY_CHATCMD, "/give <Amount> - Give a money amount")
addLabel(HELP_CATEGORY_CHATCMD, "/moneydrop or /dropmoney <Amount> - Drop a money amount")
addLabel(HELP_CATEGORY_CHATCMD, "")
addLabel(HELP_CATEGORY_CHATCMD, "/title <Name> - Give a door you own, a title")
addLabel(HELP_CATEGORY_CHATCMD, "/addowner or ao <Name> - Allow another to player to own your door")
addLabel(HELP_CATEGORY_CHATCMD, "/removeowner <Name> - Remove an owner from your door")
addLabel(HELP_CATEGORY_CHATCMD, "")
addLabel(HELP_CATEGORY_CHATCMD, "/cr <Message> - Request the CP's assistance")

-- concommand help labels
addLabel(HELP_CATEGORY_ADMINCMD, "rp_own - Own the door you're looking at.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_unown - Remove ownership from the door you're looking at.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_addowner [Nick|SteamID|UserID] - Add a co-owner to the door you're looking at.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_removeowner [Nick|SteamID|UserID] - Remove co-owner from door you're looking at.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_lock - Lock the door you're looking at.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_unlock - Unlock the door you're looking at.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_tell [Nick|SteamID|UserID] <Message> - Send a noticeable message to a named player.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_removeletters [Nick|SteamID|UserID] - Remove all letters for a given player (or all if none specified).")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_arrest [Nick|SteamID|UserID] <Length> - Arrest a player for a custom amount of time.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_unarrest [Nick|SteamID|UserID] - Unarrest a player.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_setmoney [Nick|SteamID|UserID] <Amount> - Set a player's money to a specific amount.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_setsalary [Nick|SteamID|UserID] <Amount> - Set a player's Roleplay Salary.")
addLabel(HELP_CATEGORY_ADMINCMD, "rp_setname [Nick|SteamID|UserID] <Name> - Set a player's RP name.")

