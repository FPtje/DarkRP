local rp_languages = {}
-- DO NOT remove the english language!, you can edit it though
rp_languages.english = {
	-- Admin things
	need_admin = "You need admin privileges in order to be able to %s",
	need_sadmin = "You need super admin privileges in order to be able to %s",
	no_jail_pos = "No jail position",
	invalid_x = "Invalid %s! %s",

	-- F1 menu
	get_mod = "Get the mod at garrysmod.org!",
	mouse_wheel_to_scroll = "Use mousewheel to scroll",

	-- Money things:
	customer_price = "Customer price: ",
	reset_money = "%s has reset all player's money!",
	has_given = "%s has given you %s",
	you_gave = "You gave %s %s",
	npc_killpay = "%s for killing an NPC!",

	payday_message = "Payday! You received %s!",
	payday_unemployed = "You received no salary because you are unemployed!",
	payday_missed = "Pay day missed! (You're Arrested)",

	property_tax = "Property tax! %s",
	property_tax_cant_afford = "You couldn't pay the taxes! Your property has been taken away from you!",

	-- Players
	wanted = "Wanted by Police!",
	youre_arrested = "You have been arrested for %d seconds!",
	hes_arrested = "%s has been arrested for %d seconds!",
	hes_unarrested = "%s has been released from jail!",
	health = "Health: ",
	job = "Job: ",
	salary = "Salary: ",
	wallet = "Wallet: ",
	warrant_request = "%s requests a search warrant for %s",
	warrant_request2 = "Search warrant request sent to Mayor %s!",
	warrant_approved = "Search warrant approved for %s!",
	warrant_approved2 = "You are now able to search his house.",
	warrant_denied = "Mayor %s has denied your search warrant request.",
	warrant_expired = "The search warrant for %s has expired!",
	wanted_by_police = "%s is wanted by the police!",
	wanted_expired = "%s is no longer wanted by the Police.",
	rpname_changed = "%s changed their RPName to: %s",

	-- Teams
	need_to_be_before = "You need to be %s first in order to be able to become %s",
	need_to_make_vote = "You need to make a vote to become a %s!",
	team_limit_reached = "Can not become %s as the limit is reached",
	wants_to_be = "%s\nwants to be\n%s",
	has_not_been_made_team = "%s has not been made %s!",
	job_has_become = "%s has been made a %s!",

	-- Disasters
	zombie_approaching = "WARNING: Zombies are approaching!",
	zombie_leaving = "Zombies are leaving.",
	zombie_spawn_not_exist = "Zombie Spawn %s does not exist.",
	zombie_spawn_removed = "You have removed this zombie spawn.",
	zombie_spawn_added = "You have added a zombie spawn.",
	zombie_maxset = "Maximum amount of zombies is now set to %s",
	zombie_enabled = "Zombies are now enabled.",
	zombie_disabled = "Zombies are now disabled.",
	meteor_approaching = "WARNING: Meteor storm approaching!",
	meteor_passing = "Meteor storm passing.",
	meteor_enabled = "Meteor Storms are now enabled.",
	meteor_disabled = "Meteor Storms are now disabled.",
	earthquake_report = "Earthquake reported of magnitude %sMw",
	earthtremor_report = "Earth tremor reported of magnitude %sMw",

	-- Keys, vehicles and doors
	keys_allowed_to_coown = "You are allowed to co-own this\n(Press Reload with keys or press F2 to co-own)\n",
	keys_other_allowed = "Allowed to co-own:\n",
	keys_allow_ownership = "(Press Reload with keys or press F2 to allow ownership)",
	keys_disallow_ownership = "(Press Reload with keys or press F2 to disallow ownership)",
	keys_owned_by = "Owned by: ",
	keys_cops_and_mayor = "All cops and the mayor",
	keys_unowned = "Unowned\n(Press Reload with keys or press F2 to own)",
	keys_everyone = "(Press Reload with keys or press F2 to enable for everyone)",
	keys_cops = "(Press Reload with keys or press F2 to set to cops and mayor only)",
	door_unown_arrested = "You can not own or unown things while arrested!",
	door_unownable = "This door cannot be owned or unowned!",
	door_sold = "You have sold this for %s",
	door_already_owned = "This door is already owned by someone!",
	door_cannot_afford = "You can not afford this door!",
	door_hobo_unable = "You can not buy a door if you are a hobo!",
	vehicle_cannot_afford = "You can not afford this vehicle!",
	door_bought = "You've bought this door for %s",
	vehicle_bought = "You've bought this vehicle for %s",
	door_need_to_own = "You need to own this door in order to be able to %s",
	door_rem_owners_unownable = "You can not remove owners if a door is non-ownable!",
	door_add_owners_unownable = "You can not add owners if a door is non-ownable!",
	rp_addowner_already_owns_door = "%s already owns (or is already allowed to own) this door!",

	-- Talking
	hear_noone = "No-one can hear you %s!",
	hear_everyone = "Everyone can hear you!",
	hear_certain_persons = "Players who can hear you %s: ",

	whisper = "whisper",
	yell = "yell",
	advert = "[Advert]",
	radio = "radio",
	request = "(REQUEST!)",
	group = "(group)",

	-- Notifies
	disabled = "%s is disabled! %s",
	limit = "You have reached the %s limit!",
	have_to_wait = "You need to wait another %d seconds before using %s!",
	must_be_looking_at = "You need to be looking at a %s!",
	incorrect_job = "You do not have the right job to %s",
	unavailable = "This %s is unavailable",
	unable = "You are unable to %s. %s",
	cant_afford = "You can not afford this %s",
	created_x = "%s created a %s",
	cleaned_up = "Your %s were cleaned up.",
	you_bought_x = "You have bought a %s for %s",

	created_first_jailpos = "You have created the first jail position!",
	added_jailpos = "You have added one extra jail position!",
	reset_add_jailpos = "You have removed all jail positions and you have added a new one here.",
	created_spawnpos = "%s's spawn position created.",
	updated_spawnpos = "%s's spawn position updated.",
	do_not_own_ent = "You do not own this entity!",
	cannot_drop_weapon = "Can't drop this weapon!",
	team_switch = "Jobs switched successfully!",

	-- Misc
	could_not_find = "Could not find %s",
	f3tovote = "Hit F3 to vote",
	listen_up = "Listen up:", -- In rp_tell or rp_tellall
	nlr = "New Life Rule: Do Not Revenge Arrest/Kill.",
	reset_settings = "You have reset all settings!",
	must_be_x = "You must be a %s in order to be able to %s.",
	agenda_updated = "The agenda has been updated",
	job_set = "%s has set his/her job to '%s'",
	demoted = "%s has been demoted",
	demoted_not = "%s has not been demoted",
	demote_vote_started = "%s has started a vote for the demotion of %s",
	demote_vote_text = "Demotion nominee:\n%s", -- '%s' is the reason here
	lockdown_started = "The mayor has initiated a Lockdown, please return to your homes!",
	lockdown_ended = "The lockdown has ended",
	gunlicense_requested = "%s has requested %s a gun license",
	gunlicense_granted = "%s has granted %s a gun license",
	gunlicense_denied = "%s has denied %s a gun license",
	gunlicense_question_text = "Grant %s a gun license?",
	gunlicense_remove_vote_text = "%s has started a vote for the gun license removal of %s",
	gunlicense_remove_vote_text2 = "Revoke gunlicense:\n%s", -- Where %s is the reason
	gunlicense_removed = "%s's license has been removed!",
	gunlicense_not_removed = "%s's license has not been removed!",
	vote_specify_reason = "You need to specify a reason!",
	vote_started = "The vote is created",
	vote_alone = "You have won the vote since you are alone in the server.",
	jail_punishment = "Punishment for disconnecting! Jailed for: %d seconds.",
	admin_only = "Admin only!", -- When doing /addjailpos
	chief_or = "Chief or",-- When doing /addjailpos

	dead_in_jail = "You now are dead until your jail time is up!",
	died_in_jail = "%s has died in jail!",

	-- The lottery
	lottery_started = "There is a lottery! Participate for %s",
	lottery_entered = "You entered the lottery for %s",
	lottery_not_entered = "%s did not enter the lottery",
	lottery_noone_entered = "No-one has entered the lottery",
	lottery_won = "%s has won the lottery! He has won %s",

	-- Hungermod
	starving = "Starving!",

	-- F4menu
	-- Tab 1
	give_money = "Give money to the player you're looking at",
	drop_money = "Drop money",
	change_name = "Change your DarkRP name",
	go_to_sleep = "Go to sleep/wake up",
	drop_weapon = "Drop current weapon",
	buy_health = "Buy health(%s)",
	request_gunlicense = "Request gunlicense",
	demote_player_menu = "Demote a player",


	searchwarrantbutton = "Make a player wanted",
	unwarrantbutton = "Remove the wanted status from a player",
	noone_available = "No-one available",
	request_warrant = "Request a search warrant for a player",
	make_wanted = "Make someone wanted",
	make_unwanted = "Make someone unwanted",
	set_jailpos = "Set the jail position",
	add_jailpos = "Add a jail position",

	set_custom_job = "Set a custom job (press enter to activate)",

	set_agenda = "Set the agenda (press enter to activate)",

	initiate_lockdown = "Initiate a lockdown",
	stop_lockdown = "Stop the lockdown",
	start_lottery = "Start a lottery",
	give_license_lookingat = "Give <lookingat> a gun license",

	-- Second tab
	job_name = "Name: ",
	job_description = "Description: " ,
	job_weapons = "Weapons: ",

	-- Entities tab
	buy_a = "Buy %s: %s",

	-- Licenseweaponstab
	license_tab = [[License weapons

	Tick the weapons people should be able to get WITHOUT a license!
	]],
	license_tab_other_weapons = "Other weapons:",


	-- Help!
	cophelp = [[Things Cops need to know
Please don't abuse your job
When you arrest someone they are auto transported to jail.
They are auto let out of jail after %d seconds
Type /warrant [Nick|SteamID|Status ID] to set a search warrant for a player.
Type /wanted [Nick|SteamID|Status ID] to alert everyone to a wanted suspect
Type /unwanted [Nick|SteamID|Status ID] to clear the suspect
Type /jailpos to set the jail position
Type /cophelp to toggle this menu, /x to close it]],

	mayorhelp = [[Type /warrant [Nick|SteamID|Status ID] to set a search warrant for a player.
Type /wanted [Nick|SteamID|Status ID] to alert everyone to a wanted suspect.
Type /unwanted [Nick|SteamID|Status ID] to clear the suspect.
Type /lockdown to initiate a lockdown
Type /unlockdown to end a lockdown
Type /placelaws to place a screen containing the laws.
Type /addlaw and /removelaw to edit the laws.
Type /mayorhelp toggles this menu, /x closes it]],

	adminhelp = [[/enablestorm Enables meteor storms
/disablestorm Disables meteor storms
You can change the price of weapons, jailtime, max gangsters, etc.
To do this press F1 then scroll down and you will see all of the console commands
If you edit the init.lua file you can save the vars.
/jailpos sets the jailposition!
/setspawn <team> - Enter teamname Ex. police, mayor, gangster
/adminhelpmenu toggles this menu, /x closes it]],

	bosshelp = [[As the mob boss, you decide what you want the other Gangsters to do.
You get an Unarrest Stick which you can use to break people out of jail.
/agenda <Message> (Sets the Gangsters' agenda. Use // to go to the next line.
Typing /mobbosshelp toggles this menu, /x closes it]],

	hints =
	-- English hints:
	{
	"Roleplay according to the server rules!",
	"You can be arrested for buying or owning an illegal weapon!",
	"Type /sleep to fall asleep.",
	"You may own a handgun, but use it only in self defence.",
	"All weapons can NOT shoot unless you aim down the sight.",
	"If you are a cop, do your job properly or you could get demoted.",
	"Type /buyshipment <Weapon name> to buy a shipment of weapons (e.g: /buyshipment ak47).",
	"Type /buy <Pistol name/item name> to buy a pistol, e.g: /buy glock.",
	"Type /buyammo <Ammo type> to buy ammo. Ammo types are: [rifle | shotgun | pistol]",
	"If you wish to bail a friend out of jail, go to your designated Police Department and negotiate!",
	"Press F1 to see RP help.",
	"If you get arrested, don't worry - you will be auto unarrested in a few minutes.",
	"If you are a chief or admin, type /jailpos or /addjail to set the positions of the first (and extra) jails.",
	"You will be teleported to jail if you get arrested!",
	"If you're a cop and see someone with an illegal weapon, arrest them and confiscate it.",
	"Type /sleep to fall asleep.",
	"Your money and RP name are saved by the server.",
	"Type /buyhealth to refil your health to 100%",
	"Type /buydruglab to buy a druglab. be sure you sell your drugs!",
	"Press F2 or reload with keys to open the keys menu",
	"You will be teleported to a jail if you get arrested!",
	"Type /price <Price> while looking at a drug lab, gun lab or a microwave to set the customer purchase price.",
	"Type /warrant [Nick|SteamID|UserID] to get a search warrant for a player.",
	"Type /wanted or /unwanted [Nick|SteamID|UserID] to set a player as wanted/unwanted by the Police.",
	"Type /drop to drop the weapon you are holding.",
	"Type /gangster to become a Gangster.",
	"Type /mobboss to become a mob boss.",
	"Type /buymicrowave to buy a Microwave Oven that spawns food.",
	"Type /dropmoney <Amount> to drop a money amount.",
	"Type /buymoneyprinter to buy a Money Printer.",
	"Type /medic - To become a Medic.",
	"Type /gundealer - To become a Gun Dealer.",
	"Type /buygunlab - to buy a Gun Lab.",
	"Type /cook - to become a Cook.",
	"Type /cophelp to see what you need to do as a cop.",
	"Type /buyfood <Type> (e.g: /buyfood melon)",
	"Type /rpname <Name> to choose your roleplay name.",
	"Type /call <Name> to call someone!",
	"If you are a cop you can use the CP console in the Police Station to respond to 911 calls.",
	"Use /911 to call the police (only works if you have taken damage recently).",
	"Found an illegal item? Look at it and type /report to alert the police.",
	"Type /dropmoney <Amount> to drop money on the floor.",
	"Type /give <Amount> to give money to the player you are looking at.",
	"Type /cheque <Name> <Amount> to create a cheque, only the player you assign can pick it up."
	}
}

//Dutch bitches!
rp_languages.dutch = {
	-- Admin things
	need_admin = "Je hebt administrator toegang nodig om %s te kunnen doen",
	need_sadmin = "Je hebt superadmin toegang nodig om %s te kunnen doen",
	no_jail_pos = "Er is geen gevangenis positie!",
	invalid_x = "Ongeldig(e) %s! %s",

	-- F1 menu
	get_mod = "Verkrijg DarkRP op garrysmod.org!",
	mouse_wheel_to_scroll = "Gebruik je muiswiel om te scrollen",

	-- Money things:
	customer_price = "klantenprijs: ",
	reset_money = "%s heeft iedereen zijn geld gereset!",
	has_given = "%s heeft jou %s gegeven",
	you_gave = "Jij hebt %s %s gegeven",
	npc_killpay = "%s verdiend voor het vermoorden van een NPC",

	payday_message = "Loon! je hebt %s verdiend!",
	payday_unemployed = "Je hebt geen salaris ontvangen omdat je werkloos bent!",
	payday_missed = "Je hebt je loon gemist! Je zit in de gevangenis!",

	property_tax = "BTW over je eigendom! %s",
	property_tax_cant_afford = "Je kon de belasting niet betalen, nu is je eigendom je ontnomen!",

	-- Players
	wanted = "Gezocht!",
	youre_arrested = "Je bent gearresteerd voor %d seconden!",
	hes_arrested = "%s is gearresteerd voor %d seconden!",
	hes_unarrested = "%s is vrij uit de gevangenis!",
	health = "Levens: ",
	job = "Baan: ",
	salary = "Salaris: ",
	wallet = "portemonnee: ",
	warrant_request = "%s verzoekt een huiszoekingsbevel voor %s",
	warrant_request2 = "Uw verzoek wordt bekeken! %s!",
	warrant_approved = "Het huiszoekingsbevel is geaccepteerd! %s!",
	warrant_approved2 = "Nu kun je zijn huis doorzoeken!",
	warrant_denied = "De mayor %s heeft je huiszoekingsbevel afgewezen.",
	warrant_expired = "Het huiszoekingsbevel voor %s is verlopen!",
	wanted_by_police = "%s wordt gezocht!",
	wanted_expired = "%s wordt niet meer gezocht",
	rpname_changed = "%s heeft zijn RPname veranderd naar: %s",

	-- Teams
	need_to_be_before = "Je moet eerst een %s zijn voordat je een %s kan worden!",
	need_to_make_vote = "Je moet eerst een vote maken om %s te kunnen worden!",
	team_limit_reached = "Je kan geen %s worden omdat het limiet bereikt is.",
	wants_to_be = "%s\nwil een\n%s zijn",
	has_not_been_made_team = "%s is geen %s geworden!",
	job_has_become = "%s is een %s geworden!",

	-- Disasters
	zombie_approaching = "PAS OP: er komen zombies aan!",
	zombie_leaving = "De zombies vertrekken!",
	zombie_spawn_not_exist = "Zombie Spawn %s bestaat niet.",
	zombie_spawn_removed = "Je hebt deze zombie spawn verwijderd",
	zombie_spawn_added = "Je hebt een zombie spawn toegevoegd.",
	zombie_maxset = "Het maximaal aantal zombies is nu %s",
	zombie_enabled = "Zombies zijn nu aangezet.",
	zombie_disabled = "Zombies zijn nu uitgeschakeld.",
	meteor_approaching = "PAS OP: er komen meteoren aan!",
	meteor_passing = "Het gevaar voor meteoren is geweken.",
	meteor_enabled = "Meteoor stormen zijn nu aangezet",
	meteor_disabled = "Meteoor stormen zijn nu uitgeschakeld",
	earthquake_report = "Aardbeving gemeten met een kracht van %sMw",
	earthtremor_report = "Lichte aardbeving gemeten met een kracht van %sMw",

	-- Keys, vehicles and doors
	keys_allowed_to_coown = "Jij mag mede-eigenaar zijn\n(Druk op reload met de keys of druk op F2 om mede-eigenaar te zijn\n",
	keys_other_allowed = "%s mag mede-eigenaar zijn\n",
	keys_allow_ownership = "(Druk op reload met de keys of druk op F2 om eigenaarschap toe te staan",
	keys_disallow_ownership = "(Druk op reload met de keys of druk op F2 om eigenaarschap niet toe te staan",
	keys_owned_by = "Eigenaar: ",
	keys_cops_and_mayor = "De politie en de mayor.",
	keys_unowned = "Geen eigenaar\n(Druk op reload met de keys of druk op F2 om eigenaar te worden)",
	keys_everyone = "(Druk op reload met de keys of druk op F2 om deze deur voor iedereen te maken",
	keys_cops = "(Druk op reload met de keys of druk op F2 om het politie en mayor only te maken",
	door_unown_arrested = "Je kan geen dingen kopen als je gearresteerd bent.",
	door_unownable = "Deze deur mag geen eigenaar hebben",
	door_sold = "Je hebt dit voor %s verkocht!",
	door_already_owned = "Deze deur heeft al een eigenaar!",
	door_cannot_afford = "Je kan deze deur niet betalen!",
	vehicle_cannot_afford = "Je kan dit vehikel niet betalen!",
	door_bought = "Je hebt deze deur gekocht voor %s!",
	vehicle_bought = "Je hebt dit vehikel gekocht voor %s",
	door_need_to_own = "Je moet eigenaar van de deur zijn om %s te kunnen doen",
	door_rem_owners_unownable = "Je kan geen eigenaren verwijderen terwijl de deur geen eigenaren mag hebben!",
	door_add_owners_unownable = "Je kan geen eigenaren toevoegen terwijl de deur geen eigenaren mag hebben!",
	rp_addowner_already_owns_door = "%s is al (mede) eigenaar van deze deur!",

	-- Talking
	hear_noone = "Niemand hoort je %s!",
	hear_everyone = "Iedereen kan je horen!",
	hear_certain_persons = "Mensen die je horen %s: ",

	whisper = "fluisteren",
	yell = "schreeuwen",
	advert = "[Advertentie]",
	radio = "radio",
	request = "(112!)",
	group = "(groep)",

	-- Notifies
	disabled = "%s is uitgeschakeld! %s",
	limit = "Je hebt het %s limit bereikt!",
	have_to_wait = "Je moet %d seconden wachten voordat je weer %s kan doen!",
	must_be_looking_at = "Je moet naar een %s staan kijken!",
	incorrect_job = "Je hebt niet de goede baan om %s te kunnen doen!",
	unavailable = "Deze %s is niet beschikbaar",
	unable = "Je kan %s niet doen. %s",
	cant_afford = "Je kan %s niet betalen!",
	created_x = "%s heeft een %s gemaakt",
	cleaned_up = "Jouw %ss zijn verwijderd.",
	you_bought_x = "Je hebt een %s voor %s gekocht!",

	created_first_jailpos = "Je hebt de eerste gevangenispositie gecreëerd",
	added_jailpos = "Je hebt een extra gevangenispositie toegevoegd!",
	reset_add_jailpos = "Je hebt alle gevangenisposities verwijderd en een nieuwe toegevoegd!",
	created_spawnpos = "Spawn positie van %s is aangemaakt!",
	updated_spawnpos = "Spawn positie van %s is geüpdate!",
	do_not_own_ent = "Je bent niet de eigenaar van dit object!",
	cannot_drop_weapon = "Kan dit wapen niet laten vallen!",
	team_switch = "Banen succesvol gewisseld!",

	-- Misc
	could_not_find = "Kan %s niet vinden",
	f3tovote = "Druk op F3 te stemmen",
	listen_up = "Let op:", -- In rp_tell and rp_tellall
	nlr = "New Life Rule: Als je gedood wordt mag je je dood niet wreken of de dader arresteren.",
	reset_settings = "Je hebt alle instellingen gereset.",
	must_be_x = "Je moet eerst een %s zijn om een %s te kunnen worden.",
	agenda_updated = "De agenda is vernieuwd",
	job_set = "%s heeft zijn baan naar '%s' veranderd!",
	demoted = "%s is ontslagen!",
	demoted_not = "%s is niet ontslagen",
	demote_vote_started = "%s is een referendum gestart voor het ontslag van %s",
	demote_vote_text = "Ontslagene:\n%s", -- '%s' is the reason here
	lockdown_started = "De mayor heeft een Lockdown gestart, blijf alstublieft binnen!",
	lockdown_ended = "De lockdown is geëindigd!",
	gunlicense_requested = "%s verzoekt een %s gun license",
	gunlicense_granted = "%s heeft %s een gun license gegeven",
	gunlicense_denied = "%s heeft de gun license van %s afgewezen",
	gunlicense_question_text = "%s een gun license geven?",
	gunlicense_remove_vote_text = "%s heeft een referendum geplaatst voor het afnemen van de license van %s",
	gunlicense_remove_vote_text2 = "gun license afnemen?:\n%s", -- Where %s is the reason
	gunlicense_removed = "Gun license van %s is afgenomen!",
	gunlicense_not_removed = "Gun license van %s is NIET afgenomen!",
	vote_specify_reason = "Je moet een rede invoeren!",
	vote_started = "Het referendum is geplaatst!",
	vote_alone = "Je hebt het referendum gewonnen omdat je in je uppie zit.",
	jail_punishment = "Straf omdat je hem gepeert bent! In de gevangenis voor: %d seconden!",
	admin_only = "Administrator only!", -- When doing /addjailpos
	chief_or = "Chief of",-- When doing /addjailpos

	dead_in_jail = "Je bent nu dood totdat je uit de gevangenis mag!",
	died_in_jail = "%s is in de gevangenis gestorven",

	-- The lottery
	lottery_started = "Er is een loterij! Doe mee voor %s!",
	lottery_entered = "Je doet mee aan de loterij voor %s",
	lottery_not_entered = "Je doet NIET mee aan de loterij!",
	lottery_noone_entered = "Niemand doet mee aan de loterij!",
	lottery_won = "%s heeft de loterij gewonnen! hij heeft %s gewonnen!",

	-- Hungermod
	starving = "Uitgehongerd!",

	-- F4menu
	-- Tab 1
	give_money = "Geef geld aan de persoon naar wie je kijkt",
	drop_money = "laat geld vallen",
	change_name = "Verander je RPName",
	go_to_sleep = "Ga slapen/word wakker",
	drop_weapon = "Laat huidige wapen vallen",
	buy_health = "Koop levens(%s)",
	request_gunlicense = "Verzoek gun license",
	demote_player_menu = "Referendum voor ontslag speler",


	searchwarrantbutton = "Verkrijg een huiszoekingsbevel",
	unwarrantbutton = "Laat een huiszoekingsbevel verlopen",
	noone_available = "Er is niemand!",
	request_warrant = "Verzoek een huiszoekingsbevel voor een speler",
	make_wanted = "Maak iemand gezocht",
	make_unwanted = "Zorg dat iemand niet meer gezocht wordt",
	set_jailpos = "Maak de gevangenispositie",
	add_jailpos = "Voeg een gevangenispositie toe",

	set_custom_job = "Verander je baan",

	set_agenda = "Verander de agenda",

	initiate_lockdown = "Begin een lockdown",
	stop_lockdown = "Eindig de lockdown",
	start_lottery = "Start a loterij",
	give_license_lookingat = "Geef een gun license",

	-- Second tab
	job_name = "Naam: ",
	job_description = "Beschrijving: " ,
	job_weapons = "Wapens: ",

	-- Entities tab
	buy_a = "Koop %s: %s",

	-- Licenseweaponstab
	license_tab = [[Licentie wapens

	Tik de wapens aan waar mensen géén gun license voor nodig hebben
	]],
	license_tab_other_weapons = "Andere wapens:",


	-- Help!
	cophelp = [[Dingen die de politie moet weten:
	Maak geen misbruik van je baan
	Als je iemand arresteerd teleporteert hij naar de gevangenis
	Ze komen daar weer uit na %d seconden
	Typ /warrant [Nick|SteamID|Status ID] om een huiszoekingsbevel te verzoeken/krijgen
	Typ /wanted [Nick|SteamID|Status ID] om iemand gezocht te maken
	Typ /unwanted [Nick|SteamID|Status ID] om iemand niet meer gezocht te maken
	Typ /jailpos om de jail positie te zetten
	Typ /cophelp om dit menu tevoorschijn te halen, /x om het te sluiten]],

	mayorhelp = [[Typ /warrant [Nick|SteamID|Status ID] om een huiszoekingsbevel te krijgen
	Typ /wanted [Nick|SteamID|Status ID] om iemand gezocht te maken
	Typ /unwanted [Nick|SteamID|Status ID] om iemand niet meer gezocht te maken
	Typ /lockdown om een lockdown te beginnen
	Typ /unlockdown om een lockdown te eindigen
	Typ /mayorhelp om dit menu tevoorschijn te halen, /x om het te sluiten]],

	adminhelp = [[/enablestorm zet meteoor stormen aan
	/disablestorm zet meteoor stormen uit
	Je kan de wapenprijzen, de jailtimer en de maximalen van dingen veranderen
	om dit te doen druk je F1 en scroll je naar beneden en je zult alle commandos zien
	/jailpos zet de gevangenispositie!
	/setspawn <team> - om een spawnpositie van een bepaalde baan te zetten
	Typ /adminhelpmenu om dit menu tevoorschijn te halen, /x om het te sluiten]],

	bosshelp = [[De mob boss bepaalt wat andere gangsters doen
	met de unarrest stick kun je anderen uit de gevangenis bevrijden
	/agenda <bericht> (verandert de gangster agenda. Gebruik // of \n om naar de volgende lijn te gaan
	Typ /mobboss help om dit menu tevoorschijn te halen, /x om het te sluiten]],

	hints =
	-- Dutch hints:
	{"Speel volgens de regels!",
	"Je kan gearresteerd worden voor een illegaal wapen!",
	"Zeg /sleep om te slapen.",
	"Je mag een pistool hebben, maar alleen ter zelfverdediging",
	"Je moet wel door het vizier kijken om te schieten",
	"Als je politie bent, doe je baan dan goed of je wordt ontslagen!",
	"Typ /buyshipment <Wapen name> om een shipment te kopen",
	"Typ /buy <Pistool naam/item naam> om een pistool te kopen, b.v.: /buy glock.",
	"Typ /buyammo <Ammo type> om ammo te kopen. Ammo types zijn: [rifle | shotgun | pistol]",
	"Als je iemand uit de gevangenis wil hebben, ga naar het lokale politiebureau en bespreek het met de politie.",
	"Druk op F1 voor hulp",
	"Als je gearresteerd wordt, kom je vrij na een aantal minuten",
	"Als je chief of admin bent, typ /jailpos of /addjail om gevangenisposities neer te zetten",
	"You will be teleported to jail if you get arrested!",
	"Arresteer mensen met illegale mensen als je politie bent.",
	"Je geld en naam zijn door de server opgeslagen",
	"Typ /buyhealth voor levens",
	"Typ /buydruglab voor een drugs lab, verkoop je drugs!",--
	"Druk op F2 of reload met de keys om het keys menu te openen",
	"Als je gearresteerd wordt, ga je naar de gevangenis!",
	"Typ /price <Prijs> als je naar een druglab, Gun Lab of een Microwave kijkt om de prijs te veranderen",
	"Typ /warrant [Nick|SteamID|UserID] om een huiszoekingsbevel te verkrijgen",
	"Typ /wanted or /unwanted [Nick|SteamID|UserID] om iemand gezocht te maken",
	"Typ /drop om je huidige wapen te laten vallen.",
	"Typ /gangster om een gangster te worden",
	"Typ /mobboss om een mob boss te worden.",
	"Typ /buymicrowave om een Microwave Oven die voedsel maakt.",
	"Typ /dropmoney <nummer> om geld te laten vallen.",
	"Typ /buymoneyprinter om een money printer te kopen.",
	"Typ /medic - om een doctor te worden.",
	"Typ /gundealer - om gundealer te worden.",
	"Typ /buygunlab - om een gunlab te kopen",
	"Typ /cook - om een cook te worden.",
	"Typ /cophelp om te zien wat je moet doen als je politie bent",
	"Typ /buyfood <Type> (b.v: /buyfood melon)",
	"Typ /rpname <Name> om je RPname te veranderen.",
	"Typ /call <Naam> om iemand te bellen!"
	}
}

	-- Danish Language by  WoRmS
rp_languages.danish = {
	-- Admin things
	need_admin = "Du har brug for admin rettigheder for at kunne være i stand til at %s",
	need_sadmin = "Du har brug for super admin rettigheder for at kunne være i stand til at %s",
	no_jail_pos = "Ingen fængsel position",
	invalid_x = "Ugyldig %s! %s",

	-- F1 menu
	get_mod = "Få denne mod på garrysmod.org!",
	mouse_wheel_to_scroll = "Brug musehjulet til at pladra",

	-- Money things:
	customer_price = "Kunde pris: ",
	reset_money = "%s har nulstille alle spillerens penge!",
	has_given = "%s har givet dig %s",
	you_gave = "Du gav %s %s",
	npc_killpay = "%s For a dræbe en NPC!",

	payday_message = "Betalings dag! Du har modtaget %s!",
	payday_unemployed = "Du har ikke modtaget løn, fordi du er arbejdsløs!",
	payday_missed = "Du er gået glip af Betalings dag (du er arresteret)",

	property_tax = "Ejendomsskat! %s",
	property_tax_cant_afford = "Du kunne ikke betale skat! Din ejendom er blevet taget fra dig!",

	-- Players
	wanted = "Eftersøgt af politiet!",
	youre_arrested = "Du er blevet arresteret for %d sekunder!",
	hes_arrested = "%s er blevet arresteret for %d sekunder!",
	hes_unarrested = "%s er blevet løsladt fra fængslet!",
	health = "Helbred: ",
	job = "Job: ",
	salary = "Løn: ",
	wallet = "Pung: ",
	warrant_request = "%s anmoder om en ransagningskendelse til %s",
	warrant_request2 = "ransagningskendelse anmodning sendt til borgmester %s!",
	warrant_approved = "Search warrant approved for %s!",
	warrant_approved2 = "Du er nu i stand til at søge hans hus.",
	warrant_denied = "Borgmester %s har nægtet din ransagningskendelse anmodning.",
	warrant_expired = "Den ransagningskendelse for %s er udløbet!",
	wanted_by_police = "%s er eftersøgt af politiet!",
	wanted_expired = "%s er ikke længere eftersøgt af politiet.",
	rpname_changed = "%s har ændret hans RPnavn til: %s",

	-- Teams
	need_to_be_before = "Du skal være %s første med henblik på at kunne blive %s",
	need_to_make_vote = "Du er nødt til at foretage en afstemning om at blive en %s!",
	team_limit_reached = "Kan ikke blive %s efter som grænsen er nået",
	wants_to_be = "%s\nønsker at være\n%s",
	has_not_been_made_team = "%s er ikke blevet gjort %s!",
	job_has_become = "%s blevet gjort til en %s!",

	-- Disasters
	zombie_approaching = "ADVARSEL: Zombierne nærmer sig!",
	zombie_leaving = "Zombierne forlader.",
	zombie_spawn_not_exist = "Zombie Spawn %s eksisterer ikke.",
	zombie_spawn_removed = "Du har fjernet denne zombie Spawn.",
	zombie_spawn_added = "Du har Tilføjet en zombie spawn.",
	zombie_maxset = "Maksimale Antal af zombier er nu sat til %s",
	zombie_enabled = "Zombier er nu aktiveret.",
	zombie_disabled = "Zombier er nu deaktiveret.",
	meteor_approaching = "ADVARSEL: Meteor storm nærmer sig!",
	meteor_passing = "Meteor stormen er over",
	meteor_enabled = "Meteor storm er nu aktiveret.",
	meteor_disabled = "Meteor storm er nu aktiveret.",
	earthquake_report = "Jordskælv rapporteret størrelsesorden %SMW",
	earthtremor_report = "Jordskælv rapporteret størrelsesorden %SMW",

	-- Keys, vehicles and doors
	keys_allowed_to_coown = "Du har lov til at co-ejer denne \n (Tryk på Genlad med nøgler eller trykke på F2 for at co-eget) \n",
	keys_other_allowed = "%s får lov til at co-ejer dette \n",
	keys_allow_ownership = "(Tryk på Genlad med nøgler eller trykke på F2 for at give ejerskab)",
	keys_disallow_ownership = "(Tryk på Genlad med nøgler eller trykke på F2 for at tag ejerskab)",
	keys_owned_by = "Ejet af: ",
	keys_cops_and_mayor = "Alle Politi betjente og borgmesteren",
	keys_unowned = "Uejet \n (Tryk på Opdater med nøgler eller trykke på F2 for at eje)",
	keys_everyone = "(Tryk på Genlad med nøgler eller trykke på F2 for at gøre det muligt for alle)",
	keys_cops = "(Tryk på Genlad med nøgler eller trykke på F2 for at indstille til politiet, og borgmester kun)",
	door_unown_arrested = "Du kan ikke eje eller ueje ting, mens du er anholdt!",
	door_unownable = "Denne dør kan ikke ejes eller Uejes!",
	door_sold = "Du har solgt denne dør for %s",
	door_already_owned = "Denne dør er allerede ejet af en person!",
	door_cannot_afford = "Du har ikke råd til denne dør!",
	vehicle_cannot_afford = "Du har ikke råd til denne bil!",
	door_bought = "Du har købt denne dør for %s",
	vehicle_bought = "Du har købt dette køretøj for %s",
	door_need_to_own = "Du er nødt til at eje denne dør for at være i stand til at %s",
	door_rem_owners_unownable = "Du kan ikke fjerne ejerne, mens Door er ikke-ownable!",
	door_add_owners_unownable = "Du kan ikke tilføje ejere, mens Door er ikke-ownable!",
	rp_addowner_already_owns_door = " %s allerede ejer (eller allerede er tilladt at eje) denne dør!",

	-- Talking
	hear_noone = "Ingen kan høre dig %s!",
	hear_everyone = "Alle kan høre dig!",
	hear_certain_persons = "Spillere, der kan høre dig %s:",
	whisper = "hviske",
	yell = "råbe",
	advert = "[Annonce]",
	radio = "radio",
	request = "(Anmod!)",
	group = "(gruppe)",

	-- Notifies
	disabled = "%s er slået fra !%s",
	limit = "Du har nået %s grænse!",
	have_to_wait = "Du er nødt til at vente endnu %d sekunder, før du kan bruger %s!",
	must_be_looking_at = "Du skal se på en %s!",
	incorrect_job = "Du har ikke det rigtige job til %s",
	unavailable = "Denne %s er ikke tilgængelig",
	unable = "Du er ude af stand til %s.%s",
	cant_afford = "Du har ikke råd til den %s",
	created_x = "%s Skabte en %s",
	cleaned_up = "Din %s er blevet renset.",
	you_bought_x = "Du har købt en %s for %s",

	created_first_jailpos = "Du har skabt den første fængsel position!",
	added_jailpos = "Du har tilføjet en ekstra fængsel position!",
	reset_add_jailpos = "Du har fjernet alle fængsel positioner og du har tilføjet en ny her.",
	created_spawnpos = "%s's spawn position Skabt.",
	updated_spawnpos = "%s's spawn position updatered.",
	do_not_own_ent = "Du ejer ikke denne enhed!",
	cannot_drop_weapon = "Kan ikke smide dette våben!!",
	team_switch = "Jobskift fuldført!",

	-- Misc
	could_not_find = "Kunne ikke finde %s",
	f3tovote = "Tryk på F3 for at stemme",
	listen_up = "Hør her:", --In rp_tell and rp_tellall
	nlr = "Nyt Liv Regel: ikke hævn ved at anholdele/Dræbe.",
	reset_settings = "Du har nulstille alle indstillinger!",
	must_be_x = "You must be a %s in order to be able to %s.",
	agenda_updated = "mafiabossen har opdateret dagsordenen",
	job_set = "%s har sat sit job til '%s'",
	demoted = "%s er blevet degraderet",
	demoted_not = "%s er ikke blevet degraderet",
	demote_vote_started = "%s har startet en afstemning for degraderingen af %s",
	demote_vote_text = "Degradering kandidat:\n%s", -- '%s' is the reason here
	lockdown_started = "Borgmesteren har indledt en nedlåsning, du bedes du vende tilbage til dit hjem!!",
	lockdown_ended = "nedlåsning er overstået",
	gunlicense_requested = "%s har anmodet %s en pistol licens",
	gunlicense_granted = "%s har modtaget %s en pistol licens",
	gunlicense_denied = "%s har nægtet %s en pistol licens",
	gunlicense_question_text = "Giv %s en pistol licens?",
	gunlicense_remove_vote_text = "%s har startet en afstemning for pistol licens fjernelse af %s",
	gunlicense_remove_vote_text2 = "Tilbagekald våben licens:\n%s", -- Where %s is the reason
	gunlicense_removed = "%s's licens er blivet fjernet!",
	gunlicense_not_removed = "%s's licens er ikke blevet fjernet!!",
	vote_specify_reason = "Du skal angive en grund!",
	vote_started = "Afstemningen er skabt",
	vote_alone = "Du har vundet afstemningen, da du er alene i serveren.",
	jail_punishment = "straf for at forlade serveren! fængslet for:%d sekunder.",
	admin_only = "Admin kun!!", -- When doing /addjailpos
	chief_or = "Chief eller",-- When doing /addjailpos

	dead_in_jail = "Du nu er døde, indtil din fængsel tid er forbi!",
	died_in_jail = "%s er døde i fængsel!!",

	-- Lottery
	lottery_started = "Der er et lotteri! Deltage for %s",
	lottery_entered = "Du har indtastet i lotteriet for %s",
	lottery_not_entered = "%s deltog ikke i lotteriet",
	lottery_noone_entered = "Ingen har deltaget i lotteriet",
	lottery_won = "%s har vundet i lotteriet! Han har vundet %s",

	-- Hungermod
	starving = "Sulter!",

	-- F4menu
	-- Tab 1
	give_money = "Giv penge på den du kigger på",
	drop_money = "Smid penge",
	change_name = "Skift dit DarkRP navn",
	go_to_sleep = "fald i søvn / vågne op",
	drop_weapon = "Smid nuværende våben",
	buy_health = "Køb Helbred (%s)",
	request_gunlicense = "Anmodning gunlicense",
	demote_player_menu = "degradering af en spiller",


	searchwarrantbutton = "Få en ransagningskendelse for en spiller",
	unwarrantbutton = "Fjern ransagningskendelse for en spiller",
	noone_available = "Ingen tilgængelige",
	request_warrant = "Anmod om en ransagningskendelse for en spiller",
	make_wanted = "gør nogen eftersøgt",
	make_unwanted = "gør nogen ueftersøgt",
	set_jailpos = "set fængsel position",
	add_jailpos = "Tilføj et fængsel position",
	set_custom_job = "Sæt en brugerdefineret job (tryk enter for at aktivere)",

	set_agenda = "Sæt dagsordenen (tryk enter for at aktivere)",

	initiate_lockdown = "start en nedlåsning",
	stop_lockdown = "Stop en nedlåsning",
	start_lottery = "Start et lotteri",
	give_license_lookingat = "Giv <Kiggerpå> en pistol licens",

	-- Second tab
	job_name = "Navn: ",
	job_description = "Beskrivelse: " ,
	job_weapons = "våben: ",

	-- Entities tab
	buy_a = "Køb %s: %s",

	-- License weapons tab
	license_tab = [[License våben

	Sæt kryds ud for våben folk bør være i stand til at komme uden en licens!
	]],
	license_tab_other_weapons = "Andre våben:",


	-- Help!
	cophelp = [[Ting, Betjente skal vide
	Vær venlig ikke at misbruge dit job
	Når du anholde en person, de er automatisk transporteret til fængsel.
	De er automatisk læsladt fra fængslet efter %d sekunder
	Skriv /warrant [Nick|SteamID|Status ID] for at lave en ransagningskendelse for en spiller.
	Skriv /wanted [Nick|SteamID|Status ID] til at advare alle om en eftersøgt mistænkt
	Skriv /unwanted [Nick|SteamID|Status ID] for at Rense en mistænkte.
	Skriv /jailpos For at sætte Fængsels Position
	Skriv /cophelp åbner/lukker denne menu, /x lukker den]],

	mayorhelp = [[Type /warrant [Nick|SteamID|Status ID] for at lave en ransagningskendelse for en spiller.
	Skriv /wanted [Nick|SteamID|Status ID] til at advare alle om en eftersøgt mistænkt
	Skriv /unwanted [Nick|SteamID|Status ID] for at Rense en mistænkte.
	Skriv /lockdown for at indlede en Nedlåsning
	Skriv /unlockdown for at afslutte en Nedlåsning
	Skriv /mayorhelp åbner/lukker denne menu, /x lukker den]],

	adminhelp = [[/enablestorm Aktiver meteor storm
	/disablestorm Deaktiver meteor storm
	Du kan ændre prisen for våben, fængslestid, max gangstere, ect.
	For at gøre dette skal du trykke på F1 rul derefter ned og du vil se alle de konsol kommandoer
	Hvis du redigerer init.lua fil, du kan gemme vars.
	Skriv /jailpos sætter Fængsels Position
	Skriv /setspawn <team> - Indtast Hold navn Ex. politi, borgmester, gangster
	Skriv /adminhelpmenu åbner/lukker denne menu, /x lukker den]],

	bosshelp = [[Som mafiabossen, beslutter du, hvad du ønsker, at andre gangstere skal gøre.
	Du får en Unarrest Stick, som du kan bruge til at bryde folk ud af fængsel.
	/agenda <Besked> (Sætter Gangsters 'dagsorden. Brug / / for at gå til den næste linje.
	Typing /mobbosshelp toggles this menu, /x closes it]],



	hints =
	-- Danish hints:
	{"Rolespil ifølge Servern's Regler!",
	"du kan blive anholdt for at købe eller eje en ulovlig våben!",
	"Type /sleep for at falde i søvn.",
	"Du kan eje en pistol, men brug det kun i selvforsvar.",
	"Alle våben kan ikke skyde medmindre du se gennem synet post",
	"Hvis du er en Politi betjent, gør dit arbejde ordentligt, eller du kunne blive degraderet.",
	"Skriv /buyshipment <Våben navn> for at købe en Pakke af våben (f.eks: /buyshipment AK47).",
	"Skriv /buy <Pistol navn/ting's navn> for at købe en pistol, fx: /buy glock.",
	"Skriv /buyammo <Ammunitions type> for at købe ammunition. Ammo typer er: [riffel | shotgun | pistol]",
	"Hvis du ønsker at Betale en ven ud af fængslet, skal du gå til din udpeget Politi Station og forhandle!",
	"Tryk på F1 for at se RP hjælpe.",
	"Hvis du bliver arresteret, så fortvivl ikke - du vil blive unarrested om få minutter",
	"Hvis du er chef eller admin, skrive /jailpos eller /addjail for at indstille Position af den første (og ekstra) fængsler.",
	"Du vil blive teleporteret til fængsel, hvis man bliver arresteret!",
	"Hvis du er en Politi betjent og se en person med et ulovligt våben, arrestere ham og konfiskere den.",
	"Type /sleep for at falde i søvn.",
	"Dine penge og RP navn er gemt af serveren.",
	"Type /buyhealth til at får upfyldt dit helbred til 100%",
	"Type /buydruglab at købe en druglab. Være sikker på at du sælger din Stuffer!",
	"Tryk F2 eller Genlad med nøgler for at åbne nøgle menuen",
	"Du vil blive teleporteret til et fængsel, hvis man bliver arresteret!",
	"Type /Price <Price> mens du ser på en druglab, Gun Lab eller en mikroovn for at sætte kunden købsprisen.",
	"Type /warrant [Nick | SteamID | UserID] for at lave en ransagningskendelse for en spiller.",
	"Type /wanted eller /unwanted [Nick | SteamID | UserID] for at gør en spiller ønsket/uønsket af politiet.",
	"Type /drop For at smide det våben du har.",
	"Type /gangster For at blive en gangster.",
	"Type /mobboss For at blive en mafiaboss.",
	"Type /buymicrowave For at købe en mikrobølgeovn, der varmer mad.",
	"Type /dropmoney <Amount> at smide et bestemt penge-beløb.",
	"Type /buymoneyprinter at købe en Penge printer.",
	"Type /medic - For at  blive en læge.",
	"Type /gundealer - For at blive en Våben sælger.",
	"Type /buygunlab - For at købe et Gun Lab.",
	"Type /cook - For at blive en Cook.",
	"Type /cophelp at se, hvad du skal gøre som en betjent.",
	"Type /buyfood <type> (e.g: / buyfood melon)",
	"Type /rpname <navn> for at vælge dit rollespil navn.",
	"Type /call <navn> for at ringe til nogen!",
	}
}

// Swedish language, by Donkie
rp_languages.swedish = {
	-- Admin things
	need_admin = "Du måste vara admin för att göra %s",
	need_sadmin = "Du måste vara superadmin för att göra %s",
	no_jail_pos = "Finns ingen jail position",
	invalid_x = "Inte godkänd %s! %s",

	-- F1 menu
	get_mod = "Hämta modden på garrysmod.org!",
	mouse_wheel_to_scroll = "Använd mushjulet för att skrolla",

	-- Money things:
	customer_price = "Kundens pris: ",
	reset_money = "%s har resetat alla spelares pengar!",
	has_given = "%s har gett dig %s",
	you_gave = "Du har gett %s %s",
	npc_killpay = "%s för att du dödade en NPC!",

	payday_message = "Löndag! Du har fått %s!",
	payday_unemployed = "Du har inte fått någon lön för du har inget jobb!",
	payday_missed = "Löndag missad! (Du är arresterad)",

	property_tax = "Hus/Lägenhet räkning! %s",
	property_tax_cant_afford = "Du kunde inte betala räkningarna! Ditt hus/lägenhet har blivit tagen!",

	-- Players
	wanted = "Efterlyst av polisen!",
	youre_arrested = "%s har blivit arresterad i %d sekunder!",
	hes_arrested = "%s har blivit arresterad i %d sekunder!",
	hes_unarrested = "%s har blivit frisläppt från fängelset",
	health = "Liv: ",
	job = "Jobb: ",
	salary = "Lön: ",
	wallet = "Plånbok: ",
	warrant_request = "%s begär en husrannsakan för %s",
	warrant_request2 = "Husrannsakan befrågan sänd till borgmästaren %s!",
	warrant_approved = "Husrannsakan godkänd för %s!",
	warrant_approved2 = "Du kan nu söka igenom hans hus/lägenhet",
	warrant_denied = "Borgmästar %s har ej beviljat din husrannsakan befrågan.",
	warrant_expired = "Husrannsakan för %s har gått ut!",
	wanted_by_police = "%s är efterlyst av polisen!",
	wanted_expired = "%s är inte längre efterlyst av polisen.",
	rpname_changed = "%s har ändrat sitt RPNamn till: %s",

	-- Teams
	need_to_be_before = "Du måste vara %s först för att kunna bli %s",
	need_to_make_vote = "Du måste rösta för att kunna bli en %s!",
	team_limit_reached = "Du kan inte bli %s för gränsen är redan nådd.",
	wants_to_be = "%s vill vara %s",
	has_not_been_made_team = "%s har inte blivit %s!",
	job_has_become = "%s har blivit %s!",

	-- Disasters
	zombie_approaching = "Varning: Zombies har kommit!",
	zombie_leaving = "Zombies börjar lämna.",
	zombie_spawn_not_exist = "Zombie spawnen %s finns inte.",
	zombie_spawn_removed = "Du har tagit bort den här zombie spawnen.",
	zombie_spawn_added = "Du har lagt dit en ny zombie spawn.",
	zombie_maxset = "Max antalet zombiesar har nu ändrats till %s",
	zombie_enabled = "Zombies är nu aktiverade.",
	zombie_disabled = "Zombies är nu deaktiverade.",
	meteor_approaching = "Varning: Meteor storm har börjat komma!",
	meteor_passing = "Meteor stormen börjar försvinna.",
	meteor_enabled = "Meteor Stormar är nu aktiverat.",
	meteor_disabled = "Meteor Storms är nu deaktiverade.",
	earthquake_report = "Jordbävningen blev en jordbävning på skala %sMw",
	earthtremor_report = "Jordbävningen blev en jordbävning på skala %sMw",

	-- Keys, vehicles and doors
	keys_allowed_to_coown = "Du är tillåten att co-äga den här dörren.\n(Tryck reload/ladda knappen eller F2 för att öppna menyn)\n",
	keys_other_allowed = "%s är tillåten att co-äga den här.\n",
	keys_allow_ownership = "(Tryck reload/ladda knappen eller F2 för att godkänna co-ägande)",
	keys_disallow_ownership = "(Tryck reload/ladda knappen eller F2 för att inte godkänna co-ägande)",
	keys_owned_by = "Ägd av: ",
	keys_cops_and_mayor = "Alla poliser och borgmästaren",
	keys_unowned = "Inte ägd\n(Tryck reload/ladda knappen eller F2 för att äga den).",
	keys_everyone = "(Tryck reload/ladda knappen eller F2 för att tillåta dörren till alla)",
	keys_cops = "(Tryck reload/ladda knappen eller F2 för att sätta på poliser och borgmästare endast.)",
	door_unown_arrested = "Du kan inte äga eller o-äga saker när du är arresterad!",
	door_unownable = "Den här dörren kan inte bli ägd eller o-ägd!",
	door_sold = "Du har sålt den här dörren för %s",
	door_already_owned = "Den här dörren är redan ägd av någon!",
	door_cannot_afford = "Du är för fattig för att betala för den här dörren!",
	vehicle_cannot_afford = "Du är för fattig för att betala för det här fordonet!",
	door_bought = "Du har köpt den här dörren för %s",
	vehicle_bought = "Du har köpt det här fordonet för %s",
	door_need_to_own = "Du måste äga den här dörren för att kunna göra %s",
	door_rem_owners_unownable = "Du kan inte tabort ägare om dörren är tillåten för alla!",
	door_add_owners_unownable = "Du kan inte lägga till ägare om dörren är tillåten för alla!",
	rp_addowner_already_owns_door = "%s äger redan (eller är redan tillåten att äga) den här dörren!",

	-- Talking
	hear_noone = "Ingen kan höra dig %s!",
	hear_everyone = "Alla kan höra dig!",
	hear_certain_persons = "Spelare som kan höra dig %s: ",

	whisper = "viska",
	yell = "skrika",
	advert = "[Annons]",
	radio = "radio",
	request = "(Begäran!)",
	group = "(grupp)",

	-- Notifies
	disabled = "%s är avaktiverad! %s",
	limit = "Du har nått %s gräns!",
	have_to_wait = "Du måste vänta yttligare %d sekunder innan du kan använda %s!",
	must_be_looking_at = "Du måste titta på en %s!",
	incorrect_job = "Du har inte det rätta jobbet för att %s",
	unavailable = "%s är inte tillgänglig",
	unable = "Du kan inte göra %s. %s",
	cant_afford = "Du har inte råd att köpa %s",
	created_x = "%s har gjort en %s",
	cleaned_up = "Dina %s har blivit raderade.",
	you_bought_x = "Du har köpt en %s för %s",

	created_first_jailpos = "Du har gjort första fängelse positionen!",
	added_jailpos = "Du har lagt till en till fängelse position!",
	reset_add_jailpos = "Du har tagit bort all fängelse positioner och lagt till en ny här.",
	created_spawnpos = "%s's spawn position gjort.",
	updated_spawnpos = "%s's spawn position updaterad.",
	do_not_own_ent = "Du äger inte den här entityn!",
	cannot_drop_weapon = "Du kan inte släppa det här vapnet!",
	team_switch = "Jobbbyte utfört!",

	-- Misc
	could_not_find = "Kunde inte hitta %s",
	f3tovote = "Tryck F3 för att rösta",
	listen_up = "Lyssna:", -- In rp_tell and rp_tellall
	nlr = "New Life Rule: Gör inte ett hämnings mord.",
	reset_settings = "Du har resettat alla ändringar!",
	must_be_x = "Du måste vara en %s för att kunna göra %s.",
	agenda_updated = "Gangster bossen har uppdaterat agendan",
	job_set = "%s har sätt hans/hennes jobb till '%s'",
	demoted = "%s har blivit degraderad.",
	demoted_not = "%s har inte blivit degraderad.",
	demote_vote_started = "%s har gjort en röst för at degradera %s",
	demote_vote_text = "Degraderings röst:\n%s", -- '%s' is the reason here
	lockdown_started = "Borgmästaren har startat en lockdown, gå tillbaka till ditt hem.",
	lockdown_ended = "Lockdownen har upphört.",
	gunlicense_requested = "%s har begärt %s en vapen license",
	gunlicense_granted = "%s har beviljat %s en vapen license",
	gunlicense_denied = "%s har inte beviljat %s en vapen license",
	gunlicense_question_text = "Bevilja %s en vapen license?",
	gunlicense_remove_vote_text = "%s har startat en röstning för att ta bort %s vapen license",
	gunlicense_remove_vote_text2 = "Tabort vapen license:\n%s", -- Where %s is the reason
	gunlicense_removed = "%s's license har blivit borttagen!",
	gunlicense_not_removed = "%s's license har inte blivit borttagen!",
	vote_specify_reason = "Du måste ge en anledning!",
	vote_started = "Rösten är skapad.",
	vote_alone = "Du har vunnit rösten för du är ensam på servern.",
	jail_punishment = "Bestraffning för att du har lämnat servern! Fängslad för: %d seconds.",
	admin_only = "Admin endast!", -- When doing /addjailpos
	chief_or = "Chief eller",-- When doing /addjailpos

	dead_in_jail = "Du är nu död i fängelse tills din tid är uppe!",
	died_in_jail = "%s har dött i fängelset!",

	-- Lottery
	lottery_started = "Lottning! Följ med för bara %s",
	lottery_entered = "Du har gått med i en lottning för %s",
	lottery_not_entered = "%s har inte gått med i lottningen",
	lottery_noone_entered = "Ingen har gått med i lottningen",
	lottery_won = "%s har vunnit lottningen! Han vann %s",

	-- Hungermod
	starving = "Svälter!",

	-- F4menu
	-- Tab 1
	give_money = "Ge pengar till den du tittar på.",
	drop_money = "Släpp pengar.",
	change_name = "Ändra ditt DarkRP namn.",
	go_to_sleep = "Sov/Vakna",
	drop_weapon = "Släpp ditt vapen",
	buy_health = "Köp liv(%s)",
	request_gunlicense = "Begär vapen license",
	demote_player_menu = "Degradera en spelare",


	searchwarrantbutton = "Få en husrannsakan för en spelare",
	unwarrantbutton = "Tabort husrannsakan för en spelare",
	noone_available = "Ingen tillgänglig.",
	request_warrant = "begär en husrannsakan för en spelare",
	make_wanted = "Gör någon efterlyst",
	make_unwanted = "Tabort någons efterlysning",
	set_jailpos = "Sätt fängelse positionen",
	add_jailpos = "Lägg till en  fängelse position",

	set_custom_job = "Gör ett eget jobb (Tryck enter för att aktivera)",

	set_agenda = "Ändra agendan (Tryck enter för att aktivera)",

	initiate_lockdown = "Starta en lockdown",
	stop_lockdown = "Stoppa en lockdown",
	start_lottery = "Starta en lottning",
	give_license_lookingat = "Ge <Tittar på> en vapen license",

	-- Second tab
	job_name = "Namn: ",
	job_description = "Description: " ,
	job_weapons = "Vapen: ",

	-- Entities tab
	buy_a = "Köp %s: %s",

	-- License weapons tab
	license_tab = [[License vapen

	"Checka" vapnen som man kan plocka upp UTAN att ha en license!
	]],
	license_tab_other_weapons = "Andra vapen:",


	-- Help!
	cophelp = [[Saker polisen borde veta:
	"Abusa" inte ditt jobb.
	När du arresterar någon är dom automatiskt teleporterade till fängelset.
	Dom är automatiskt utsläppta efter %d sekunder
	Skriv /warrant [Namn|SteamID|Status ID] för att göra en husrannsakan mot en spelare.
	Skriv /wanted [Namn|SteamID|Status ID] för att göra en spelare efterlyst.
	Skriv /unwanted [Namn|SteamID|Status ID] för att tabort efterlysningen på en spelare.
	Skriv /jailpos för att ändra fängelse positionen
	Skriv /cophelp för att "toggla" denna meny, /x för att stänga den.]],

	mayorhelp = [[Skriv /warrant [Nick|SteamID|Status ID] för att göra en husrannsakan mot en spelare.
	Skriv /wanted [Nick|SteamID|Status ID] för att göra en spelare efterlyst.
	Skriv /unwanted [Nick|SteamID|Status ID] för att tabort efterlysningen på en spelare.
	Skriv /lockdown för att starta en "lockdown"
	Skriv /unlockdown för att tabort en "lockdown"
	Skriv /mayorhelp för att "toggla" denna meny, /x för att stänga den.]],

	adminhelp = [[/enablestorm Aktiverar meteor stormar
	/disablestorm Deaktiverar meteor stormar
	Du kan ändra priset på vapen, jailtiden, max gangstrars, etc..
	För att göra det tryck F1 och sen skrolla ner för att se dina krafter.
	Om du ändrar init.lua kan du spara "vars"
	/jailpos ändrar jailpositionen!
	/setspawn <team> - Lägg till ett teamnamn, tex Police, Gangster...
	/adminhelpmenu för att "toggla" denna meny, /x för att stänga den.]],

	bosshelp = [[Som mob boss, bestämmer du vad alla gangstrar ska göra.
	Du får en "unarrest stick" som du använder för att bryta andra ur fängelset.
	/agenda <Message> Ändrar gangstrars agenda. Använd // för att gå till en ny rad.
	Skriv /mobbosshelp för att "toggla" denna meny, /x för att stänga den.]],



	hints =
	-- Swedish hints:
	{"Rollspel enligt servern's regler.",
	"Du kan bli arresterad för att ha köpt/köper ett olagligt vapen!",
	"Skriv /sleep för att somna.",
	"Du får ha en pistol, men använd den bara i själv försvar.",
	"Alla vapen kan INTE skjuta om du inte tittar genom siktet!",
	"Om du är en polis, gör ditt jobb på rätt sätt annars kan du bli degraderad.",
	"Skriv /buyshipment <Vapen namn> för att köpa en låda med vapen (e.g: /buyshipment ak47).",
	"Skriv /buy <Pistol namn/Sak namn> för att köpa en pistol, e.g: /buy glock.",
	"Skriv /buyammo <Ammo typ> för att köpa ammo. Ammo typer är: [rifle | shotgun | pistol]",
	"Om du vill få ut din kompis ur fängelse, gå till din närmsta polisstation och förhandla!",
	"Tryck F1 för att se RP hjälp.",
	"Om du blir arresterad, lugn, du kommer ut inom några minuter",
	"Om du är chief eller admin, skriv /jailpos eller /addjail för att sätta positionen för första (och extra) fängelse positioner.",
	"Du blir teleporterad till fängelset om du blir arresterad!",
	"Om du är en polis och ser någon med ett olagligt vapen, arrestera dom och konfistikera vapnet.",
	"Skriv /sleep för att somna.",
	"Dina pengar och RP namn är sparade av servern.",
	"Skriv /buyhealth för att öka ditt liv till 100%",
	"Skriv /buydruglab för att köpa ett dråglab. Se upp så du säljer alla dråger!",
	"Tryck F2 eller Reload med dina keys för att öppna keys menyn",
	"Du blir teleporterad till fängelset om du blir arresterad!",
	"Skriv /price <Pris> medans du tittar på ett dråglab,  Vapenlabb eller en mikrovågsugn för att ändra priset för köpare.",
	"Skriv /warrant [Namn|SteamID|UserID] för att få en husrannsakan mot en spelare.",
	"Skriv /wanted or /unwanted [Nick|SteamID|UserID] för att få en spelare efterlyst/inte efterlyst.",
	"Skriv /drop för att släppa vapnet du håller.",
	"Skriv /gangster för att bli en gangster.",
	"Skriv /mobboss för att bli en mobboss.",
	"Skriv /buymicrowave för att köpa en mikrovågsugn som kan göra mat (nudlar <3).",
	"Skriv /dropmoney <Hur mycket> för att släppa pengar.",
	"Skriv /buymoneyprinter för att köpa en pengargörare/moneyprinter.",
	"Skriv /medic - för att bli en medic/sjukvårdare.",
	"Skriv /gundealer - för att bli en gundealer/vapen handlare.",
	"Skriv /buygunlab - för att köpa ett vapenlabb.",
	"Skriv /cook - för att bli en Cook.",
	"Skriv /cophelp för o se polisers hjälp.",
	"Skriv /buyfood <Typ> (e.g: /buyfood melon)",
	"Skriv /rpname <Namn> för att ändra ditt rollspel namn.",
	"Skriv /call <Namn> för att ringa någon!"
	}
}

// French language, by Sadness (http://steamcommunity.com/id/Sadness81)
rp_languages.french = {
	-- Pour que les accents fonctionnent, il faut sélectionner tout le contenu du fichier language.lua faire copié, et passer l'encodage en UTF-8 et coller ce que vous avez copié sur tout l'ancien contenu présent dans le fichier.
	-- Admin things (Message d'Admin)
	need_admin = "Vous devez être admin pour avoir le droit de %s",
	need_sadmin = "Vous devez être super admin pour avoir le droit de %s",
	no_jail_pos = "Aucune prison enregistrée",
	invalid_x = "Invalide %s ! %s",

	-- F1 menu (Menu F1 Aide)
	get_mod = "Obtenez le mod sur garrysmod.org !",
	mouse_wheel_to_scroll = "Utilisez la molette pour naviguer",

	-- Money things: (Message d'Argent)
	customer_price = "Prix consommateur: ",
	reset_money = "%s à remis à zéro l'argent de tous les joueurs !",
	has_given = "%s vous a donné %s",
	you_gave = "Vous donnez à %s %s",
	npc_killpay = "%s vous sont crédités pour avoir tué un NPC !",

	payday_message = "Jour de paye ! Vous recevez %s !",
	payday_unemployed = "N'ayant aucun emploi, vous ne recevez aucun salaire !",
	payday_missed = "Jour de paye annulé ! (Vous êtes arrêté)",

	property_tax = "Taxe de propriété: %s",
	property_tax_cant_afford = "Vous ne disposez pas d'assez d'argent pour payer vos taxes ! Propriété(s) retirer(s) !",

	-- Players (Joueurs)
	wanted = "Rechercher par la police !",
	youre_arrested = "Vous avez été emprisonné pour %d secondes !",
	hes_arrested = "%s a été emprisonné pour %d secondes !",
	hes_unarrested = "%s est remis en liberté !",
	health = "Santé: ",
	job = "Métier: ",
	salary = "Salaire: ",
	wallet = "Porte-Feuilles: ",
	warrant_request = "%s lance un mandat pour %s",
	warrant_request2 = "Demande de mandat envoyée au maire %s",
	warrant_approved = "Mandat approuvé pour %s !",
	warrant_approved2 = "Vous pouvez désormais rechercher sa maison.",
	warrant_denied = "Mr. %s à refusé votre demande de mandat.",
	warrant_expired = "Le mandat pour %s a expiré !",
	wanted_by_police = "%s est recherché par la police !",
	wanted_expired = "%s n'est plus recherché par la police.",
	rpname_changed = "Mr. %s a changé son nom RP en Mr. %s",

	-- Teams (Équipes/Métiers)
	need_to_be_before = "Vous devez être %s avant de pouvoir devenir %s",
	need_to_make_vote = "Vous devez créer un vote pour devenir %s !",
	team_limit_reached = "Vous ne pouvez pas devenir %s car la limite est atteinte",
	wants_to_be = "%s\nSouhaiterais devenir\n%s",
	has_not_been_made_team = "%s n'est pas devenu %s !",
	job_has_become = "%s est devenu %s !",

	-- Disasters (Catastrophes)
	zombie_approaching = "ALERTE: Le gouvernement vous annonce que des hordes de zombies approchent de la ville, veuillez rentrer chez vous !",
	zombie_leaving = "Les hordes de zombies ont cessé d'arrivée.",
	zombie_spawn_not_exist = "Le point de spawn %s n'existe pas.",
	zombie_spawn_removed = "Vous avez supprimé ce spawn de zombie.",
	zombie_spawn_added = "Vous avez ajouté un spawn de zombie.",
	zombie_maxset = "Le nombre max de zombie est maintenant à %s",
	zombie_enabled = "Zombie activés.",
	zombie_disabled = "Zombie désactivés.",
	meteor_approaching = "ALERTE: La météo prévoit des pluies de météorites, veuillez rentrer chez vous !",
	meteor_passing = "Les pluies de météorites ont cessé de tomber.",
	meteor_enabled = "Météorite activés.",
	meteor_disabled = "Météorite désactivés.",
	earthquake_report = "Séisme reporté à magnitude %sMw",
	earthtremor_report = "Température térrestre reportée à %sMw",

	-- Keys, vehicles and doors (Clés, vehicules et portes)
	keys_allowed_to_coown = "Vous êtes autorisé à co-habiter\n(Appuyer sur RECHARGER ou sur F2 avec les clefs)\n",
	keys_other_allowed = "Autorisé à co-habiter:\n",
	keys_allow_ownership = "(Appuyez sur RECHARGER avec les clefs ou sur F2 pour autoriser l'achat)",
	keys_disallow_ownership = "(Appuyez sur RECHARGER avec les clefs ou sur F2 pour ne pas autoriser l'achat)",
	keys_owned_by = "Propriétaire(s): ",
	keys_cops_and_mayor = "Equipe policière et Mr. le Maire",
	keys_unowned = "Inhabité\n(Appuyer sur RECHARGER avec les clefs ou sur F2 pour acheter la propriété)",
	keys_everyone = "(Appuyez sur RECHARGER avec les clefs ou sur F2 pour rendre cette propriété publique)",
	keys_cops = "(Appuyez sur RECHARGER avec les clefs ou sur F2 pour n'autoriser l'accès qu'au maire et aux policiers)",
	door_unown_arrested = "Vous ne pouvez pas vendre de propriété quand vous êtes arrêté !",
	door_unownable = "Cette propriété ne peut être achetée ou vendue !",
	door_sold = "Vous avez vendu cette propriété pour %s",
	door_already_owned = "Cette propriété appartient déjà à quelqu'un !",
	door_cannot_afford = "Vous ne pouvez pas acheter cette propriété !",
	door_hobo_unable = "Vous ne pouvez pas acheter une propriété si vous êtes un sans-abri !",
	vehicle_cannot_afford = "Vous ne pouvez pas acheter ce vehicule !",
	door_bought = "Vous avez acheté cette propriété pour %s",
	vehicle_bought = "Vous avez acheté ce vehicule pour %s",
	door_need_to_own = "Vous devez acheter cette propriété pour pouvoir %s",
	door_rem_owners_unownable = "Vous ne pouvez pas supprimer de propriétaire sur une porte indisponible à l'achat !",
	door_add_owners_unownable = "Vous ne pouvez pas ajouter de propriétaire sur une porte indisponible à l'achat !",
	rp_addowner_already_owns_door = "%s possède déjà (ou est déjà autorisé à acheter) cette propriété !",

	-- Talking (Parole)
	hear_noone = "Personne ne peut vous entendre %s !",
	hear_everyone = "Tout le monde peut vous entendre !",
	hear_certain_persons = "Joueur pouvant vous entendre en %s: ",

	whisper = "chuchotement",
	yell = "crier",
	advert = "[Publicité]",
	radio = "radio",
	request = "(REQUETE!)",
	group = "(groupe)",

	-- Notifies (Notification)
	disabled = "%s est désactivé ! %s",
	limit = "Vous avez atteint la limite de %s !",
	have_to_wait = "Vous devez attendre encore %d secondes avant d'utiliser %s !",
	must_be_looking_at = "Vous devez regarder un(e) %s !",
	incorrect_job = "Vous n'avez pas le bon métier pour %s",
	unavailable = "Ce(tte) %s est indisponible",
	unable = "Vous ne pouvez pas %s. %s",
	cant_afford = "Vous ne pouvez pas acheter ce(tte) %s",
	created_x = "%s a créer un %s",
	cleaned_up = "Vos %s ont été supprimés.",
	you_bought_x = "Vous avez acheté un(e) %s pour %s",

	created_first_jailpos = "Vous avez créer la première position de cellule !",
	added_jailpos = "Vous avez ajouté une position de cellule !",
	reset_add_jailpos = "Vous avez supprimé toutes les position de cellule et en avez ajoutée une ici.",
	created_spawnpos = "Cellule créer : %s.",
	updated_spawnpos = "Position de spawn de cellule : %s.",
	do_not_own_ent = "Vous n'avez pas acheté cette entité !",
	cannot_drop_weapon = "Impossible de lacher cette arme !",
	team_switch = "Métier changé avec succès !",

	-- Misc (Divers)
	could_not_find = "Impossible de trouver %s",
	f3tovote = "Appuyez sur F3 pour voter",
	listen_up = "Ecoutez tous:", -- In rp_tell or rp_tellall (Avec rp_tell ou rp_tellall)
	nlr = "Règle de nouvelle vie: Pas de revanche/arrestation/mise à mort.",
	reset_settings = "Vous avez réinitialiser tous les paramètres !",
	must_be_x = "Vous devez être un %s pour avoir la capacité de %s.",
	agenda_updated = "L'agenda a été mis à jour",
	job_set = "%s change son métier en '%s'",
	demoted = "%s a été viré !",
	demoted_not = "%s n'a pas été viré",
	demote_vote_started = "%s a commencé un vote pour %s",
	demote_vote_text = "Licenciement de:\n%s", -- '%s' is the reason here ('%s' ici c'est la raison)
	lockdown_started = "Le maire a initié un couvre-feu, merci de tous rentrez chez vous !",
	lockdown_ended = "Couvre-feu terminé",
	gunlicense_requested = "%s demande à %s une licence d'arme",
	gunlicense_granted = "%s donne à %s une licence d'arme",
	gunlicense_denied = "%s a refusé a %s une licence d'arme",
	gunlicense_question_text = "Donné à %s une licence d'arme ?",
	gunlicense_remove_vote_text = "%s lance un vote pour une suppression de la licence de %s",
	gunlicense_remove_vote_text2 = "Annuler une licence d'armes:\n%s", -- '%s' is the reason here ('%s' ici c'est la raison)
	gunlicense_removed = "La licence de %s a expirée !",
	gunlicense_not_removed = "La licence de %s n'a pas été supprimée !",
	vote_specify_reason = "Vous devez spécifier une raison !",
	vote_started = "Le vote est créer !",
	vote_alone = "Votre vote est accepté direct car vous êtes le seul sur le serveur.",
	jail_punishment = "Punition de déconnexion ! Emprisonné pour: %d secondes.",
	admin_only = "Vous ne pouvez pas ajouter de position de cellule car vous n'êtes pas administrateur !", -- When doing /addjailpos (Quand vous faites /addjailpos)
	chief_or = "Chef ou",-- When doing /addjailpos (Quand vous faites /addjailpos)

	dead_in_jail = "Vous êtes mort avant la fin de votre arrestation !",
	died_in_jail = "%s est mort en prison !",

	-- The lottery (La loterie)
	lottery_started = "Il y a une loterie ! Voulez-vous participer pour %s ?",
	lottery_entered = "Vous venez d'achetez un billet de loterie à %s",
	lottery_not_entered = "%s n'a pas participé à la loterie",
	lottery_noone_entered = "Personne n'a participé à la loterie",
	lottery_won = "La chance de %s à tournée ! Il remporte %s à la loterie, bravo à lui !",

	-- Hungermod (Mod permettant la faim)
	starving = "Affamé !",

	-- F4menu (Menu F4 Money/Action)
	-- Tab 1 (Premier onglet)
	give_money = "Donner de l'argent à la personne que vous regardez",
	drop_money = "Deposer de l'argent",
	change_name = "Changer votre nom RP",
	go_to_sleep = "Se coucher/réveiller",
	drop_weapon = "Lacher l'arme actuelle",
	buy_health = "Acheter santé (%s)",
	request_gunlicense = "Demander une licence d'arme",
	demote_player_menu = "Virer un joueur",


	searchwarrantbutton = "Lancer un mandat sur un citoyen",
	unwarrantbutton = "Annuler le mandat sur un citoyen",
	noone_available = "Aucune personne",
	request_warrant = "Demander un mandat sur un citoyen",
	make_wanted = "Lancer une recherche sur un citoyen",
	make_unwanted = "Annuler la recherche sur un citoyen",
	set_jailpos = "Supprimer toutes les positions de cellule et en ajouter une ici",
	add_jailpos = "Ajouter une position de cellule supplémentaire ici",

	set_custom_job = "Choisir un métier secondaire (appuyez sur UTILISER pour accepter)",

	set_agenda = "Ecrire dans l'agenda (appuyez sur UTILISER pour accepter)",

	initiate_lockdown = "Initier un couvre-feu",
	stop_lockdown = "Arreter le couvre-feu",
	start_lottery = "Commencer une loterie",
	give_license_lookingat = "Donner une licence d'armes à <regard>",

	-- Second tab (Deuxième onglet)
	job_name = "Nom: ",
	job_description = "Description: " ,
	job_weapons = "Arme(s): ",

	-- Entities tab (Onglet Entitées)
	buy_a = "Acheté un(e) %s pour %s",

	-- Licenseweaponstab (Menu F4 Licence d'armes)
	license_tab = [[Armes à licence

	Cocher les armes pouvant êtres utilisées SANS licence d'armes !
	]],
	license_tab_other_weapons = "Autres armes:",


	-- Help! (Aide !)
	cophelp = [[Pas d'abus.
	Après l'arrestation, l'arreté est téléporté en prison.
	Ils sortent de prison après %d secondes.
	Tapez /warrant [Nom RP|SteamID|Status ID] pour lancer un mandat sur un joueur.
	Tapez /wanted [Nom RP|SteamID|Status ID] pour rechercher un suspect.
	Tapez /unwanted [Nom RP|SteamID|Status ID] pour annuler les recherches.
	Tapez /jailpos pour supprimer toutes les positions de cellule et en ajouter une ici.
	Tapez /cophelp pour afficher ce menu, /x pour le fermer.]],

	mayorhelp = [[Tapez /warrant [Nom RP|SteamID|Status ID] pour lancer un mandat sur un joueur.
	Tapez /wanted [Nom RP|SteamID|Status ID] pour rechercher un suspect.
	Tapez /unwanted [Nom RP|SteamID|Status ID] pour annuler les recherches.
	Tapez /lockdown pour initier un couvre-feu.
	Tapez /unlockdown pour terminer le couvre-feu.
	Tapez /mayorhelp pour afficher ce menu, /x pour le fermer.]],

	adminhelp = [[/enablestorm activer les pluies de météorites.
	/disablestorm désactiver les pluies de météorites.
	Vous pouvez changer tous les prix,
	pour ce faire appuyez sur F1 celà affichera toutes les commandes.
	Si vous editez le fichier init.lua vous pouvez sauvegarder les variables.
	/jailpos supprime toutes les positions de cellule et en ajouter une ici.
	/setspawn <métier> - Entrer le nom du metier Ex. mayor, gangster, gundealer.
	/adminhelp afficher ce menu, /x le fermer.]],

	bosshelp = [[Vous décidez de ce que les gangsters doivent faire.
	Utilisez une matraque de désarrestation pour faire sortir les gens de prison.
	/agenda <message> pour écrire dans l'agenda des gangsters.
	Utilisez // pour aller a la ligne.
	Tapez /mobbosshelp pour afficher ce menu, /x pour le fermer.]],

	hints =
	-- French hints:
	{"Le RP s'accorde aux règles du serveur !",
	"Tapez /rpname <nom> pour choisir votre nom RP.",
	"Vous pouvez être arreté pour l'achat illégal d'une arme !",
	"Tapez /sleep pour dormir et de nouveau /sleep pour vous réveiller.",
	"Vous pouvez acheter un pistolet, mais ne l'utilisez qu'en légitime défense.",
	"Toutes les armes ne peuvent pas tirer sans viser.",
	"Si vous êtes policier, soyez sérieux sous peine de licenciement voir d'une sanction plus grave.",
	"Tapez /buyshipment <nom arme> pour acheter une caisse d'armes (ex: /buyshipment ak47).",
	"Tapez /buy <nom pistolet> pour acheter un pistolet (ex: /buy glock).",
	"Tapez /buyammo <type munition> pour acheter des munitions, les types de munition sont: [pistol|shotgun|rifle]",
	"Pour faire sortir votre ami de prison vous pouvez négociez avec la police !",
	"Appuyez sur F1 pour voir l'aide RP.",
	"Si vous êtes arrêté vous sortirez automatiquement de prison quelques minutes plus tard.",
	"Si vous êtes commandant de police ou maire, tapez /jailpos ou /addjail pour paramétrer les positions des cellules.",
	"Vous serez automatiquement téléporté en prison si vous vous faite arrêté !",
	"Si vous êtes policier et que vous voyez quelqu'un avec une arme illégale, arrêtez-le.",
	"Tapez /sleep pour dormir et de nouveau /sleep pour vous réveiller.",
	"Votre argent et votre nom RP sont sauvegardés par le serveur.",
	"Tapez /buyhealth pour vous rendre votre vie à 100% s'il n'y a pas de docteur.",
	"Tapez /buydruglab pour acheter un laboratoire de drogue, mais soyez sur de vendre vos drogues ou d'être un bon consommateur !",
	"Vous serez automatiquement téléporté en prison si vous vous faite arrêté !",
	"Tapez /price <prix> en regardant un laboratoire de drogue, d'armes ou un micro-ondes pour changer le prix de consommation.",
	"Tapez /warrant [Nom RP|SteamID|UserID] pour obtenir un mandat sur un joueur.",
	"Tapez /wanted ou /unwanted [Nom RP|SteamID|UserID] pour faire rechercher/ne plus rechercher un joueur par la police.",
	"Tapez /drop pour lâcher l'arme que vous tenez dans vos mains.",
	"Tapez /gangster pour devenir un gangster.",
	"Tapez /mobboss pour devenir mobboss.",
	"Tapez /buymicrowave pour acheter un micro-ondes qui fait apparaitre de la nourriture.",
	"Tapez /dropmoney <nombre> pour poser une somme d'argent.",
	"Tapez /buymoneyprinter pour acheter une imprimante d'argent.",
	"Tapez /medic pour devenir médecin.",
	"Tapez /gundealer pour devenir vendeur d'armes.",
	"Tapez /buygunlab pour acheter un laboratoire d'armes.",
	"Tapez /cook pour devenir cuisinier.",
	"Tapez /cophelp pour voir ce que vous devez savoir quand vous êtes policier.",
	"Tapez /buyfood <nom nourriture> pour acheter de la nourriture (ex: /buyfood melon)",
	"Tapez /rpname <nom> pour choisir votre nom RP.",
	"Tapez /call <nom> pour appeler quelqu'un avec votre téléphone portable !",
	"Si vous êtes un policier vous pouvez utiliser les ordinateurs de la police pour répondre aux appels 911.",
	"Utilisez /911 pour appeler la police (fonctionne seulement si vous avez récemment subit des dommages).",
	"Vous avez trouvé quelque chose d'illégal ? Regardez le et tapez /report pour alerter la police.",
	"Tapez /dropmoney <nombre> pour deposer de l'argent au sol.",
	"Tapez /give <nombre> pour donner de l'argent à la personne que vous regardez.",
	"Tapez /cheque <joueur> <nombre> pour créer un cheque, seul la personne mentionné pourras le prendre."
	}
}

if not ConVarExists("rp_language") then
	CreateConVar("rp_language", "english", {FCVAR_ARCHIVE, FCVAR_REPLICATED})
end
LANGUAGE = rp_languages[GetConVarString("rp_language")]
if not LANGUAGE then
	LANGUAGE = rp_languages["english"] -- Now we hope people don't remove the english language ._.
end