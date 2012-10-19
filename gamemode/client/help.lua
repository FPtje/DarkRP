local HelpCategories = {}
local HelpLabels = {}

local function addCategory(id, name)
	table.insert(HelpCategories, {id = id, name = name})
	return id
end

local function addLabel(id, category, text, constant)
	table.insert(HelpLabels, {id = id, category = category, text = text, constant = (constant or 0)})
end

function GM:AddHelpLabel(id, category, text, constant)
	addLabel(id, category, text, constant)
end

function GM:AddHelpCategory(id, name)
	addCategory(id, name)
end

function GM:getHelpCategories()
	return HelpCategories
end

function GM:getHelpLabels()
	return HelpLabels
end

local HELP_CATEGORY_CHATCMD = 1
local HELP_CATEGORY_CONCMD = 2
local HELP_CATEGORY_ZOMBIE = 3
local HELP_CATEGORY_ADMINCMD = 6

addCategory(HELP_CATEGORY_CHATCMD, "Chat Commands")
addCategory(HELP_CATEGORY_CONCMD, "Console Commands")
addCategory(HELP_CATEGORY_ADMINCMD, "Admin Console Commands")
addCategory(HELP_CATEGORY_ZOMBIE, "Zombie Chat Commands")

addLabel(-1, HELP_CATEGORY_CONCMD, "gm_showhelp - Toggle help menu (bind this to F1 if you haven't already)")
addLabel(-1, HELP_CATEGORY_CONCMD, "gm_showteam - Show door menu")
addLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare1 - Toggle vote clicker (bind this to F3 if you haven't already)")
addLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare2 - Job menu(bind this to F4 if you haven't already)")

addLabel(-1, HELP_CATEGORY_ZOMBIE, "/addzombie (creates a zombie spawn)")
addLabel(-1, HELP_CATEGORY_ZOMBIE, "/zombiemax (maximum amount of zombies that can be alive)")
addLabel(-1, HELP_CATEGORY_ZOMBIE, "/removezombie index (removes a zombie spawn, index is the number inside ()")
addLabel(-1, HELP_CATEGORY_ZOMBIE, "/showzombie (shows where the zombie spawns are)")
addLabel(-1, HELP_CATEGORY_ZOMBIE, "/enablezombie (enables zombiemode)")
addLabel(-1, HELP_CATEGORY_ZOMBIE, "/disablezombie (disables zombiemode)")
addLabel(-1, HELP_CATEGORY_ZOMBIE, "/enablestorm (enables meteor storms)")


addLabel(1000, HELP_CATEGORY_CHATCMD, "/help - Bring up this menu")
addLabel(1100, HELP_CATEGORY_CHATCMD, "/job <Job Name> - Set a custom job")
addLabel(1200, HELP_CATEGORY_CHATCMD, "/w <Message> - Whisper a message")
addLabel(1300, HELP_CATEGORY_CHATCMD, "/y <Message> - Yell a message")
addLabel(1350, HELP_CATEGORY_CHATCMD, "/g <Message> - Group only message")
addLabel(1350, HELP_CATEGORY_CHATCMD, "/pm <Person> <Message> - Private message")
addLabel(1400, HELP_CATEGORY_CHATCMD, "/Channel <1-100> - Set the channel of the radio", 1)
addLabel(1400, HELP_CATEGORY_CHATCMD, "/radio <Message> - Say something through the radio!", 1)
addLabel(1400, HELP_CATEGORY_CHATCMD, "/me <Message> - *name* is doing something!", 1)
addLabel(1400, HELP_CATEGORY_CHATCMD, "/advert <Message> - Advertise!", 1)
addLabel(1400, HELP_CATEGORY_CHATCMD, "/broadcast <Message> - Broadcast a message as mayor!", 1)
addLabel(1400, HELP_CATEGORY_CHATCMD, "//, or /a, or /ooc - Out of Character speak", 1)
addLabel(1500, HELP_CATEGORY_CHATCMD, "/x to close a help dialog", 1)
addLabel(2700, HELP_CATEGORY_CHATCMD, "/pm <Name/Partial Name> <Message> - Send another player a PM.")
addLabel(2500, HELP_CATEGORY_CHATCMD, "")
addLabel(2650, HELP_CATEGORY_CHATCMD, "Letters - Press use key to read a letter.  Look away and press use key again to stop reading a letter.")
addLabel(2550, HELP_CATEGORY_CHATCMD, "/write <Message> - Write a letter in handwritten font. Use // to go down a line.")
addLabel(2600, HELP_CATEGORY_CHATCMD, "/type <Message> - Type a letter in computer font.  Use // to go down a line.")
addLabel(1450, HELP_CATEGORY_CHATCMD, "")
addLabel(1500, HELP_CATEGORY_CHATCMD, "/give <Amount> - Give a money amount")
addLabel(1600, HELP_CATEGORY_CHATCMD, "/moneydrop or /dropmoney <Amount> - Drop a money amount")
addLabel(1650, HELP_CATEGORY_CHATCMD, "")
addLabel(1700, HELP_CATEGORY_CHATCMD, "/title <Name> - Give a door you own, a title")
addLabel(1800, HELP_CATEGORY_CHATCMD, "/addowner or ao <Name> - Allow another to player to own your door")
addLabel(1825, HELP_CATEGORY_CHATCMD, "/removeowner <Name> - Remove an owner from your door")
addLabel(2250, HELP_CATEGORY_CHATCMD, "")
addLabel(2300, HELP_CATEGORY_CHATCMD, "/cr <Message> - Request the CP's assistance")
addLabel(2300, HELP_CATEGORY_CHATCMD, "/911 - Call 911 (when you're attacked by a person)")
addLabel(2300, HELP_CATEGORY_CHATCMD, "/report - Call 911 for an illegal entity (you have to be looking at an entity)")

-- concommand help labels
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_own - Own the door you're looking at.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unown - Remove ownership from the door you're looking at.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_addowner [Nick|SteamID|UserID] - Add a co-owner to the door you're looking at.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_removeowner [Nick|SteamID|UserID] - Remove co-owner from door you're looking at.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_lock - Lock the door you're looking at.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unlock - Unlock the door you're looking at.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_tell [Nick|SteamID|UserID] <Message> - Send a noticeable message to a named player.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_removeletters [Nick|SteamID|UserID] - Remove all letters for a given player (or all if none specified).")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_arrest [Nick|SteamID|UserID] <Length> - Arrest a player for a custom amount of time.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unarrest [Nick|SteamID|UserID] - Unarrest a player.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setmoney [Nick|SteamID|UserID] <Amount> - Set a player's money to a specific amount.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setsalary [Nick|SteamID|UserID] <Amount> - Set a player's Roleplay Salary.")
addLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setname [Nick|SteamID|UserID] <Name> - Set a player's RP name.")

