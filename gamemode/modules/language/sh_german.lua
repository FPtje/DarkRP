
-- German translation by DaCoolboy(STEAM_0:0:15924852) - Contact for critism etc.  
local english = {
	-- Admin things
	need_admin = "Du brauchst Admin-Privilegien fuer: %s",
	need_sadmin = "Du brauchst SuperAdmin-Privilegien fuer: %s",
	no_jail_pos = "Keine Gefaengnisposition",
	invalid_x = "Falsch: %s! %s",

	-- F1 menu
	mouse_wheel_to_scroll = "Benutze Mausrad um zu scrollen",

	-- Money things:
	customer_price = "Kundenpreis: ",
	reset_money = "%s hat das Geld von allen Spielern zurueckgesetzt!",
	has_given = "%s hat dir %s gegeben",
	you_gave = "Du hast %s %s gegeben",
	npc_killpay = "%s fuer das toeten eines NPCs!",

	payday_message = "Zahltag! Dir wurde %s ueberwiesen!",
	payday_unemployed = "Du kriegst kein Gehalt aufgrund von Arbeitslosigkeit!",
	payday_missed = "Zahltag verpasst! (Wegen Inhaftierung)",

	property_tax = "Besitz-Steuer! %s",
	property_tax_cant_afford = "Du konntest die Besitz-Steuer nicht zahlen! Besitztuemer wurden dir entzogen!",

	-- Players
	wanted = "Zur Fahndung ausgeschrieben!\nGrund: %s",
	youre_arrested = "Du wurdest fuer %d Sekunden verhaftet!",
	hes_arrested = "%s wurde verhaftet fuer %d Sekunden!",
	hes_unarrested = "%s wurde aus der Haft entlassen!",
	health = "Gesundheit: %s",
	job = "Beruf: %s",
	salary = "Gehalt: %s%s",
	wallet = "Geldboerse: %s%s",
	warrant_request = "%s fragt fuer einen Durchsuchungsbeschluss fuer %s\nGrund: %s",
	warrant_request2 = "Anfrage fuer einen Durchsuchungsbeschluss gesendet an Mayor %s!",
	warrant_approved = "Durchsuchungsbeschluss zugelassen fuer %s!",
	warrant_approved2 = "Du kannst jetzt eine Hausdurchsuchung bei ihm durchfueren.", 
	warrant_denied = "Mayor %s hat deine Anfrage fuer einen Durchsuchungsbeschluss abgelehnt.",
	warrant_expired = "Der Durchsuchungsbeschluss fuer %s ist abgelaufen!",
	wanted_by_police = "%s ist zur Fahndung ausgeschrieben!\nGrund: %s\nIm Auftrag von: %s",
	wanted_by_police_print = "%s hat %s eine Fahndung ausgestellt, Grund: %s",
	wanted_expired = "%s's Fahndung wurde eingestellt.",
	wanted_revoked = "%s's Fahndung wurde eingestellt.\nAufgehoben durch: %s",
	rpname_changed = "%s hat seinen RP-Namen geaendert zu: %s",

	-- Teams
	need_to_be_before = "Du musst erst %s sein, um %s zu werden",
	need_to_make_vote = "Du musst eine Abstimmung starten um %s zu werden!",
	team_limit_reached = "Du kannst nicht %s werden weil das Limit erreicht ist",
	wants_to_be = "%s\nmoechte folgendes werden:\n%s",
	has_not_been_made_team = "%s wurde nicht %s!",
	job_has_become = "%s wurde %s!",

	-- Disasters
	meteor_approaching = "WARNUNG: Meteor Schauer naehrt sich!",
	meteor_passing = "Meteor Schauer zieht vorueber.",
	meteor_enabled = "Meteor Schauer sind jetzt aktiviert.",
	meteor_disabled = "Meteor Schauer sind jetzt deaktiviert.",
	earthquake_report = "Erdbeben von der Staerke %sMw gemeldet",
	earthtremor_report = "Erdstoss von der Staerke %sMw gemeldet",

	-- Keys, vehicles and doors
	keys_allowed_to_coown = "Du bist als Zweitbesitzer zugelassen\n(Druecke Reload mit den Keys oder F2 um zu kaufen)\n",
	keys_other_allowed = "Als Zweitbesitzer zugelassen:\n%s\n",
	keys_allow_ownership = "(Druecke Reload mit den Keys oder F2 um Besitztum zuzulassen)",
	keys_disallow_ownership = "(Druecke Reload mit den Keys oder F2 um Besitztum zu verbieten)",
	keys_owned_by = "Besitzer: ",
	keys_cops_and_mayor = "Die Polizei und der Mayor",
	keys_unowned = "Nicht im Besitz\n(Druecke Reload mit den Keys oder F2 zum kaufen)",
	keys_everyone = "(Druecke Reload mit den Keys oder F2 um es fuer jeden freizuschalten)",
	keys_cops = "(Druecke Reload mit den Keys oder F2 um es nur fuer den Mayor und der Polizei freizuschalten)",
	door_unown_arrested = "Du kannst keine Sachen kaufen oder verkaufen waehrend der Haft!",
	door_unownable = "Diese Tuer kann nicht gekauft oder verkauft werden!",
	door_sold = "Du hast es fuer %s verkauft",
	door_already_owned = "Jemand besitzt bereits diese Tuer!",
	door_cannot_afford = "Du kannst dir diese Tuer nicht leisten!",
	door_hobo_unable = "Hobos ist es nicht erlaubt Tueren zu besitzen!",
	vehicle_cannot_afford = "Du kannst dir dieses Fahrzeug nicht leisten!",
	door_bought = "Du hast diese Tuer gekauft fuer %s%s",
	vehicle_bought = "Du hast dieses Fahrzeug gekauft fuer %s%s",
	door_need_to_own = "Du musst diese Tuer besitzen um in der Lage fuer %s zu sein",
	door_rem_owners_unownable = "Du kannst keine Besitzer entfernen bei einer nicht-besitzbaren Tuer!",
	door_add_owners_unownable = "Du kannst keine Besitzer hinzufuegen bei einer nicht-besitzbaren Tuer!",
	rp_addowner_already_owns_door = "%s ist bereits als Besitzer eingetragen!",

	-- Talking
	hear_noone = "Niemand kann dich %s hoeren!",
	hear_everyone = "Jeder kann dich hoeren!",
	hear_certain_persons = "Spieler die dich %s hoeren: ",

	whisper = "fluestern",
	yell = "schreien",
	advert = "[Werbung]",
	radio = "Radio",
	request = "(Anfrage!)",
	group = "(Gruppe)",

	-- Notifies
	disabled = "%s ist deaktiviert! %s",
	limit = "Du hast das Limit fuer %s erreicht!",
	have_to_wait = "Du musst %d Sekunden warten bevor du dies wieder benutzen kannst: %s!",
	must_be_looking_at = "Du musst dafür  ein %s ansehen!",
	incorrect_job = "Du hast nicht den richtigen Beruf um diesen zu tun: %s",
	unavailable = "Dieser %s ist nicht verfuegbar",
	unable = "Du kannst dies nicht tun: %s. %s",
	cant_afford = "Du kannst dir dies nicht leisten: %s",
	created_x = "%s hat einen %s erschaffen",
	cleaned_up = "Deine %s wurden entfernt.",
	you_bought_x = "Du hast ein %s fuer %s gekauft",

	created_first_jailpos = "Du hast die erste Gefaengnisposition gesetzt!",
	added_jailpos = "Du hast eine weitere Gefaengnisposition hinzugefuegt!",
	reset_add_jailpos = "Du hast die Gefaengnispositionen zurueckgesetzt und hier eine neu gesetzt.",
	created_spawnpos = "%s's Spawn Position erstellt.",
	updated_spawnpos = "%s's Spawn Position aktualisiert.",
	do_not_own_ent = "Du besitzt dieses Objekt nicht!",
	cannot_drop_weapon = "Diese Waffe kann nicht fallen gelassen werden!",
	team_switch = "Berufe erfolgreich ausgetauscht!",

	-- Misc
	could_not_find = "%s konnte nicht gefunden werden",
	f3tovote = "Druecke F3 um abzustimmen",
	listen_up = "Achtung:", -- In rp_tell or rp_tellall
	nlr = "Neues Leben Regel: Keine Rache-Verhaftungen/Toetungen.",
	reset_settings = "Du hast alle Einstellungen zurueckgesetzt!",
	must_be_x = "Du musst %s sein um dies tun zu koennen: %s.",
	agenda_updated = "Die Agenda wurde aktualisiert",
	job_set = "%s hat seinen Beruf zu '%s' gesetzt",
	demoted = "%s wurde entlassen",
	demoted_not = "%s wurde nicht entlassen",
	demote_vote_started = "%s hat eine Abstimmung zur Entlassung von %s gestartet",
	demote_vote_text = "Entlassungs-Abstimmung:\n%s", -- '%s' is the reason here
	lockdown_started = "Der Mayor hat eine Abriegelung initiiert, bitte begeben sie sich in ihre Haueser!",
	lockdown_ended = "Die Abriegelung ist zum Ende gekommen",
	gunlicense_requested = "%s hat %s fuer eine Waffenlizens angefragt",
	gunlicense_granted = "%s hat %s eine Waffenlizens erteilt ",
	gunlicense_denied = "%s hat %s eine Waffenlizens nicht erteilt",
	gunlicense_question_text = "%s eine Waffenlizens erteilen?",
	gunlicense_remove_vote_text = "%s hat eine Abstimmung zum Entzug der Waffelizens von %s initiiert",
	gunlicense_remove_vote_text2 = "Waffenlizens entziehen?:\n%s", -- Where %s is the reason
	gunlicense_removed = "%s's Waffenlizens wurde entzogen!",
	gunlicense_not_removed = "%s's Waffenlizens wurde nicht entzogen!",
	vote_specify_reason = "Du musst einen Grund angebenn!",
	vote_started = "Die Abstimmung wurde initiiert",
	vote_alone = "Aufgrund eines leeren Servers hast du die Abstimmung fuer dich entschieden.",
	jail_punishment = "Strafe fuer das Verlassen des Servers!\nInhaftiert fuer: %d Sekunden.",
	admin_only = "Admin ist dies nur gestattet!", -- When doing /addjailpos
	chief_or = "Chief oder",-- When doing /addjailpos

	dead_in_jail = "Dein Tod wird bis zum Ende deiner Haft andauern!",
	died_in_jail = "%s ist in der Haft gestorben!",

	-- The lottery
	lottery_started = "Es gibt eine Lotterie! Teilnahme fuer %s",
	lottery_entered = "Du nimmst an der  Lotterie fuer %s teil",
	lottery_not_entered = "%s nimmt nicht an der Lotterie teil",
	lottery_noone_entered = "Niemmand hat an der Lotterie teilgenommen",
	lottery_won = "%s hat die Lotterie gewonnen! Hoehe des Gewinns: %s",

	-- Hungermod
	starving = "Am Verhungern!",

	-- F4menu
	-- Tab 1
	give_money = "Dem Spieler Geld geben, den du ansiehst",
	drop_money = "Geld fallen lassen",
	change_name = "DarkRP Namen veraendern",
	go_to_sleep = "Schlafen legen/Aufwachen",
	drop_weapon = "Jetztige Waffe fallen lassen",
	buy_health = "Kaufe Gesundheit(%s)",
	request_gunlicense = "Fuer Waffenlizens anfraggen",
	demote_player_menu = "Entlassung eines Spielers initiieren",


	searchwarrantbutton = "Eine Fahndung fuer einen Spieler einleiten",
	unwarrantbutton = "Eine Fahndung fuer einen Spieler einstellen",
	noone_available = "Niemand verfügbar",
	request_warrant = "Eine Durchsuchungsbeschluss beantragen",
	make_wanted = "Eine Fahndung einleiten",
	make_unwanted = "Eine Fahndung einstellen",
	set_jailpos = "Die Gefaengnisposition neu setzen",
	add_jailpos = "Eine Geaengnisposition hinzufuegen",

	set_custom_job = "Dier einen eigenen Beruf-Titel geben (Enter zum aktivieren)",

	set_agenda = "Die Agenda setzen (Enter zum aktivieren)",

	initiate_lockdown = "Abriegelung initiieren",
	stop_lockdown = "Abriegelung stoppen",
	start_lottery = "Ein Lotterie starten",
	give_license_lookingat = "Dem Spieler eine Waffenlizens erteilen, den du ansiehst",

	-- Second tab
	job_name = "Name: ",
	job_description = "Beschreibung: " ,
	job_weapons = "Waffen: ",

	-- Entities tab
	buy_a = "Kaufe %s: %s",

	-- Licenseweaponstab
	license_tab = [[Lizens-plichtige Waffen

	Kreuze die Waffen an die man OHNE Waffenlizens aufnehmen darf!
	]],
	license_tab_other_weapons = "Andere Waffen:",
}

DarkRP.addLanguage("de", german)
