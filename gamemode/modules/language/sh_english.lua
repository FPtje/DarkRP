
-- DO NOT remove the english language!
local english = {
	-- Admin things
	need_admin = "You need admin privileges in order to be able to %s",
	need_sadmin = "You need super admin privileges in order to be able to %s",
	no_jail_pos = "No jail position",
	invalid_x = "Invalid %s! %s",

	-- F1 menu
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
	wanted = "Wanted by Police!\nReason: %s",
	youre_arrested = "You have been arrested for %d seconds!",
	hes_arrested = "%s has been arrested for %d seconds!",
	hes_unarrested = "%s has been released from jail!",
	health = "Health: %s",
	job = "Job: %s",
	salary = "Salary: %s%s",
	wallet = "Wallet: %s%s",
	warrant_request = "%s requests a search warrant for %s\nReason: %s",
	warrant_request2 = "Search warrant request sent to Mayor %s!",
	warrant_approved = "Search warrant approved for %s!",
	warrant_approved2 = "You are now able to search his house.",
	warrant_denied = "Mayor %s has denied your search warrant request.",
	warrant_expired = "The search warrant for %s has expired!",
	wanted_by_police = "%s is wanted by the police!\nReason: %s\nOrdered by: %s",
	wanted_by_police_print = "%s ordered a search warrant for %s, reason: %s",
	wanted_expired = "%s is no longer wanted by the Police.",
	wanted_revoked = "%s is no longer wanted by the Police.\nRevoked by: %s",
	rpname_changed = "%s changed their RPName to: %s",

	-- Teams
	need_to_be_before = "You need to be %s first in order to be able to become %s",
	need_to_make_vote = "You need to make a vote to become a %s!",
	team_limit_reached = "Can not become %s as the limit is reached",
	wants_to_be = "%s\nwants to be\n%s",
	has_not_been_made_team = "%s has not been made %s!",
	job_has_become = "%s has been made a %s!",

	-- Disasters
	meteor_approaching = "WARNING: Meteor storm approaching!",
	meteor_passing = "Meteor storm passing.",
	meteor_enabled = "Meteor Storms are now enabled.",
	meteor_disabled = "Meteor Storms are now disabled.",
	earthquake_report = "Earthquake reported of magnitude %sMw",
	earthtremor_report = "Earth tremor reported of magnitude %sMw",

	-- Keys, vehicles and doors
	keys_allowed_to_coown = "You are allowed to co-own this\n(Press Reload with keys or press F2 to co-own)\n",
	keys_other_allowed = "Allowed to co-own:\n%s\n",
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
	door_bought = "You've bought this door for %s%s",
	vehicle_bought = "You've bought this vehicle for %s%s",
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
}

DarkRP.addLanguage("en", english)
