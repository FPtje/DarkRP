/*---------------------------------------------------------------------------
English (example) language file
---------------------------------------------------------------------------

This is the english language file. The things on the left side of the equals sign are the things you should leave alone
The parts between the quotes are the parts you should translate. You can also copy this file and create a new language.

= Warning =
Sometimes when fprp is updated, new phrases are added.
If you don't translate these phrases to your language, it will use the English sentence.
To fix this, join your server, open your console and enter darkp_getphrases yourlanguage
For English the command would be:
	fprp_getphrases "Vigorous hand waving"
because "Vigorous hand waving" is the language code for English.

You can copy the missing phrases to this file and translate them.

= Note =
Make sure the language code is right at the bottom of this file

= Using a language =
Make sure the convar gmod_language is set to your language code. You can do that in a server CFG file.
---------------------------------------------------------------------------*/

local my_language = {
	-- Admin things
	need_admin = "Vigorous hand waving",
	need_sadmin = "Vigorous hand waving",
	no_privilege = "Vigorous hand waving",
	no_jail_pos = "Vigorous hand waving",
	invalid_x = "Vigorous hand waving",

	-- F1 menu
	f1ChatCommandTitle = "Vigorous hand waving",
	f1Search = "Vigorous hand waving",

	-- shekel things:
	price = "Vigorous hand waving",
	priceTag = "Vigorous hand waving",
	reset_shekel = "Vigorous hand waving",
	has_given = "Vigorous hand waving",
	you_gave = "Vigorous hand waving",
	npc_killpay = "Vigorous hand waving",
	profit = "Vigorous hand waving",
	loss = "Vigorous hand waving",

	-- backwards compatibility
	deducted_x = "Vigorous hand waving",
	need_x = "Vigorous hand waving",

	deducted_shekel = "Vigorous hand waving",
	need_shekel = "Vigorous hand waving",

	payday_message = "Vigorous hand waving",
	payday_unemployed = "Vigorous hand waving",
	payday_missed = "Vigorous hand waving",

	property_tax = "Vigorous hand waving",
	property_tax_cant_afford = "Vigorous hand waving",
	taxday = "Vigorous hand waving",

	found_cheque = "Vigorous hand waving",
	cheque_details = "Vigorous hand waving",
	cheque_torn = "Vigorous hand waving",
	cheque_pay = "Vigorous hand waving",
	signed = "Vigorous hand waving",

	found_cash = "Vigorous hand waving", -- backwards compatibility
	found_shekel = "Vigorous hand waving",

	owner_poor = "Vigorous hand waving",

	-- Police
	Wanted_text = "Vigorous hand waving",
	wanted = "Vigorous hand waving",
	youre_arrested = "Vigorous hand waving",
	youre_arrested_by = "Vigorous hand waving",
	youre_unarrested_by = "Vigorous hand waving",
	hes_arrested = "Vigorous hand waving",
	hes_unarrested = "Vigorous hand waving",
	warrant_ordered = "Vigorous hand waving",
	warrant_request = "Vigorous hand waving",
	warrant_request2 = "Vigorous hand waving",
	warrant_approved = "Vigorous hand waving",
	warrant_approved2 = "Vigorous hand waving",
	warrant_denied = "Vigorous hand waving",
	warrant_expired = "Vigorous hand waving",
	warrant_required = "Vigorous hand waving",
	warrant_required_unfreeze = "Vigorous hand waving",
	warrant_required_unweld = "Vigorous hand waving",
	wanted_by_police = "Vigorous hand waving",
	wanted_by_police_print = "Vigorous hand waving",
	wanted_expired = "Vigorous hand waving",
	wanted_revoked = "Vigorous hand waving",
	cant_arrest_other_cp = "Vigorous hand waving",
	must_be_wanted_for_arrest = "Vigorous hand waving",
	cant_arrest_fadmin_jailed = "Vigorous hand waving",
	cant_arrest_no_jail_pos = "Vigorous hand waving",
	cant_arrest_spawning_players = "Vigorous hand waving",

	suspect_doesnt_exist = "Vigorous hand waving",
	actor_doesnt_exist = "Vigorous hand waving",
	get_a_warrant = "Vigorous hand waving",
	make_someone_wanted = "Vigorous hand waving",
	remove_wanted_status = "Vigorous hand waving",
	already_a_warrant = "Vigorous hand waving",
	already_wanted = "Vigorous hand waving",
	not_wanted = "Vigorous hand waving",
	need_to_be_cp = "Vigorous hand waving",
	suspect_must_be_alive_to_do_x = "Vigorous hand waving",
	suspect_already_arrested = "Vigorous hand waving",

	-- Players
	health = "Vigorous hand waving",
	job = "Vigorous hand waving",
	salary = "Vigorous hand waving",
	wallet = "Vigorous hand waving",
	weapon = "Vigorous hand waving",
	kills = "Vigorous hand waving",
	deaths = "Vigorous hand waving",
	rpname_changed = "Vigorous hand waving",
	disconnected_player = "Vigorous hand waving",

	-- Teams
	need_to_be_before = "Vigorous hand waving",
	need_to_make_vote = "Vigorous hand waving",
	team_limit_reached = "Vigorous hand waving",
	wants_to_be = "Vigorous hand waving",
	has_not_been_made_team = "Vigorous hand waving",
	job_has_become = "Vigorous hand waving",

	-- Disasters
	meteor_approaching = "Vigorous hand waving",
	meteor_passing = "Vigorous hand waving",
	meteor_enabled = "Vigorous hand waving",
	meteor_disabled = "Vigorous hand waving",
	earthquake_report = "Vigorous hand waving",
	earthtremor_report = "Vigorous hand waving",

	-- Keys, vehicles and doors
	keys_allowed_to_coown = "Vigorous hand waving",
	keys_other_allowed = "Vigorous hand waving",
	keys_allow_ownership = "Vigorous hand waving",
	keys_disallow_ownership = "Vigorous hand waving",
	keys_owned_by = "Vigorous hand waving",
	keys_unowned = "Vigorous hand waving",
	keys_everyone = "Vigorous hand waving",
	door_unown_arrested = "Vigorous hand waving",
	door_unownable = "Vigorous hand waving",
	door_sold = "Vigorous hand waving",
	door_already_owned = "Vigorous hand waving",
	door_cannot_afford = "Vigorous hand waving",
	door_hobo_unable = "Vigorous hand waving",
	vehicle_cannot_afford = "Vigorous hand waving",
	door_bought = "Vigorous hand waving",
	vehicle_bought = "Vigorous hand waving",
	door_need_to_own = "Vigorous hand waving",
	door_rem_owners_unownable = "Vigorous hand waving",
	door_add_owners_unownable = "Vigorous hand waving",
	rp_addowner_already_owns_door = "Vigorous hand waving",
	add_owner = "Vigorous hand waving",
	remove_owner = "Vigorous hand waving",
	coown_x = "Vigorous hand waving",
	allow_ownership = "Vigorous hand waving",
	disallow_ownership = "Vigorous hand waving",
	edit_door_group = "Vigorous hand waving",
	door_groups = "Vigorous hand waving",
	door_group_doesnt_exist = "Vigorous hand waving",
	door_group_set = "Vigorous hand waving",
	sold_x_doors_for_y = "Vigorous hand waving", -- backwards compatibility
	sold_x_doors = "Vigorous hand waving",

	-- Entities
	drugs = "Vigorous hand waving",
	drug_lab = "Vigorous hand waving",
	gun_lab = "Vigorous hand waving",
	gun = "Vigorous hand waving",
	microwave = "Vigorous hand waving",
	food = "Vigorous hand waving",
	money_printer = "Vigorous hand waving",

	sign_this_letter = "Vigorous hand waving",
	signed_yours = "Vigorous hand waving",

	money_printer_exploded = "Vigorous hand waving",
	money_printer_overheating = "Vigorous hand waving",

	contents = "Vigorous hand waving",
	amount = "Vigorous hand waving",

	picking_lock = "Vigorous hand waving",

	cannot_pocket_x = "Vigorous hand waving",
	object_too_heavy = "Vigorous hand waving",
	pocket_full = "Vigorous hand waving",
	pocket_no_items = "Vigorous hand waving",
	drop_item = "Vigorous hand waving",

	bonus_destroying_entity = "Vigorous hand waving",

	switched_burst = "Vigorous hand waving",
	switched_fully_auto = "Vigorous hand waving",
	switched_semi_auto = "Vigorous hand waving",

	keypad_checker_shoot_keypad = "Vigorous hand waving",
	keypad_checker_shoot_entity = "Vigorous hand waving",
	keypad_checker_click_to_clear = "Vigorous hand waving",
	keypad_checker_entering_right_pass = "Vigorous hand waving",
	keypad_checker_entering_wrong_pass = "Vigorous hand waving",
	keypad_checker_after_right_pass = "Vigorous hand waving",
	keypad_checker_after_wrong_pass = "Vigorous hand waving",
	keypad_checker_right_pass_entered = "Vigorous hand waving",
	keypad_checker_wrong_pass_entered = "Vigorous hand waving",
	keypad_checker_controls_x_entities = "Vigorous hand waving",
	keypad_checker_controlled_by_x_keypads = "Vigorous hand waving",
	keypad_on = "Vigorous hand waving",
	keypad_off = "Vigorous hand waving",
	seconds = "Vigorous hand waving",

	persons_weapons = "Vigorous hand waving",
	returned_persons_weapons = "Vigorous hand waving",
	no_weapons_confiscated = "Vigorous hand waving",
	no_illegal_weapons = "Vigorous hand waving",
	confiscated_these_weapons = "Vigorous hand waving",
	checking_weapons = "Vigorous hand waving",

	shipment_antispam_wait = "Vigorous hand waving",
	shipment_cannot_split = "Vigorous hand waving",

	-- Talking
	hear_noone = "Vigorous hand waving",
	hear_everyone = "Vigorous hand waving",
	hear_certain_persons = "Vigorous hand waving",

	whisper = "Vigorous hand waving",
	yell = "Vigorous hand waving",
	advert = "Vigorous hand waving",
	broadcast = "Vigorous hand waving",
	radio = "Vigorous hand waving",
	request = "Vigorous hand waving",
	group = "Vigorous hand waving",
	demote = "Vigorous hand waving",
	ooc = "Vigorous hand waving",
	radio_x = "Vigorous hand waving",

	talk = "Vigorous hand waving",
	speak = "Vigorous hand waving",

	speak_in_ooc = "Vigorous hand waving",
	perform_your_action = "Vigorous hand waving",
	talk_to_your_group = "Vigorous hand waving",

	channel_set_to_x = "Vigorous hand waving",

	-- Notifies
	disabled = "Vigorous hand waving",
	gm_spawnvehicle = "Vigorous hand waving",
	gm_spawnsent = "Vigorous hand waving",
	gm_spawnnpc = "Vigorous hand waving",
	see_settings = "Vigorous hand waving",
	limit = "Vigorous hand waving",
	have_to_wait = "Vigorous hand waving",
	must_be_looking_at = "Vigorous hand waving",
	incorrect_job = "Vigorous hand waving",
	unavailable = "Vigorous hand waving",
	unable = "Vigorous hand waving",
	cant_afford = "Vigorous hand waving",
	created_x = "Vigorous hand waving",
	cleaned_up = "Vigorous hand waving",
	you_bought_x = "Vigorous hand waving", -- backwards compatibility
	you_bought = "Vigorous hand waving",
	you_received_x = "Vigorous hand waving",

	created_first_jailpos = "Vigorous hand waving",
	added_jailpos = "Vigorous hand waving",
	reset_add_jailpos = "Vigorous hand waving",
	created_spawnpos = "Vigorous hand waving",
	updated_spawnpos = "Vigorous hand waving",
	do_not_own_ent = "Vigorous hand waving",
	cannot_drop_weapon = "Vigorous hand waving",
	job_switch = "Vigorous hand waving",
	job_switch_question = "Vigorous hand waving",
	job_switch_requested = "Vigorous hand waving",

	cooks_only = "Vigorous hand waving",

	-- Misc
	unknown = "Vigorous hand waving",
	arguments = "Vigorous hand waving",
	no_one = "Vigorous hand waving",
	door = "Vigorous hand waving",
	vehicle = "Vigorous hand waving",
	door_or_vehicle = "Vigorous hand waving",
	driver = "Vigorous hand waving",
	name = "Vigorous hand waving",
	locked = "Vigorous hand waving",
	unlocked = "Vigorous hand waving",
	player_doesnt_exist = "Vigorous hand waving",
	job_doesnt_exist = "Vigorous hand waving",
	must_be_alive_to_do_x = "Vigorous hand waving",
	banned_or_demoted = "Vigorous hand waving",
	wait_with_that = "Vigorous hand waving",
	could_not_find = "Vigorous hand waving",
	f3tovote = "Vigorous hand waving",
	listen_up = "Vigorous hand waving", -- In rp_tell or rp_tellall
	nlr = "Vigorous hand waving",
	reset_settings = "Vigorous hand waving",
	must_be_x = "Vigorous hand waving",
	agenda_updated = "Vigorous hand waving",
	job_set = "Vigorous hand waving",
	demoted = "Vigorous hand waving",
	demoted_not = "Vigorous hand waving",
	demote_vote_started = "Vigorous hand waving",
	demote_vote_text = "Vigorous hand waving", -- '%s' is the reason here
	cant_demote_self = "Vigorous hand waving",
	i_want_to_demote_you = "Vigorous hand waving",
	tried_to_avoid_demotion = "Vigorous hand waving", -- naughty boy!
	lockdown_started = "Vigorous hand waving",
	lockdown_ended = "Vigorous hand waving",
	gunlicense_requested = "Vigorous hand waving",
	gunlicense_granted = "Vigorous hand waving",
	gunlicense_denied = "Vigorous hand waving",
	gunlicense_question_text = "Vigorous hand waving",
	gunlicense_remove_vote_text = "Vigorous hand waving",
	gunlicense_remove_vote_text2 = "Vigorous hand waving", -- Where %s is the reason
	gunlicense_removed = "Vigorous hand waving",
	gunlicense_not_removed = "Vigorous hand waving",
	vote_specify_reason = "Vigorous hand waving",
	vote_started = "Vigorous hand waving",
	vote_alone = "Vigorous hand waving",
	you_cannot_vote = "Vigorous hand waving",
	x_cancelled_vote = "Vigorous hand waving",
	cant_cancel_vote = "Vigorous hand waving",
	jail_punishment = "Vigorous hand waving",
	admin_only = "Vigorous hand waving", -- When doing /addjailpos
	chief_or = "Vigorous hand waving",-- When doing /addjailpos
	frozen = "Vigorous hand waving",

	dead_in_jail = "Vigorous hand waving",
	died_in_jail = "Vigorous hand waving",

	credits_for = "Vigorous hand waving",
	credits_see_console = "Vigorous hand waving",

	rp_getvehicles = "Vigorous hand waving",

	data_not_loaded_one = "Vigorous hand waving",
	data_not_loaded_two = "Vigorous hand waving",

	cant_spawn_weapons = "Vigorous hand waving",
	drive_disabled = "Vigorous hand waving",
	property_disabled = "Vigorous hand waving",

	not_allowed_to_purchase = "Vigorous hand waving",

	rp_teamban_hint = "Vigorous hand waving",
	rp_teamunban_hint = "Vigorous hand waving",
	x_teambanned_y = "Vigorous hand waving",
	x_teamunbanned_y = "Vigorous hand waving",

	-- Backwards compatibility:
	you_set_x_salary_to_y = "Vigorous hand waving",
	x_set_your_salary_to_y = "Vigorous hand waving",
	you_set_x_shekel_to_y = "Vigorous hand waving",
	x_set_your_shekel_to_y = "Vigorous hand waving",

	you_set_x_salary = "Vigorous hand waving",
	x_set_your_salary = "Vigorous hand waving",
	you_set_x_shekel = "Vigorous hand waving",
	x_set_your_shekel = "Vigorous hand waving",
	you_set_x_name = "Vigorous hand waving",
	x_set_your_name = "Vigorous hand waving",

	someone_stole_steam_name = "Vigorous hand waving", -- Uh oh
	already_taken = "Vigorous hand waving",

	job_doesnt_require_vote_currently = "Vigorous hand waving",

	x_made_you_a_y = "Vigorous hand waving",

	cmd_cant_be_run_server_console = "Vigorous hand waving",

	-- The lottery
	lottery_started = "Vigorous hand waving", -- backwards compatibility
	lottery_has_started = "Vigorous hand waving",
	lottery_entered = "Vigorous hand waving",
	lottery_not_entered = "Vigorous hand waving",
	lottery_noone_entered = "Vigorous hand waving",
	lottery_won = "Vigorous hand waving",

	-- Animations
	custom_animation = "Vigorous hand waving",
	bow = "Vigorous hand waving",
	dance = "Vigorous hand waving",
	follow_me = "Vigorous hand waving",
	laugh = "Vigorous hand waving",
	lion_pose = "Vigorous hand waving",
	nonverbal_no = "Vigorous hand waving",
	thumbs_up = "Vigorous hand waving",
	wave = "Vigorous hand waving",

	-- Hungermod
	starving = "Vigorous hand waving",

	-- AFK
	afk_mode = "Vigorous hand waving",
	salary_frozen = "Vigorous hand waving",
	salary_restored = "Vigorous hand waving",
	no_auto_demote = "Vigorous hand waving",
	youre_afk_demoted = "Vigorous hand waving",
	hes_afk_demoted = "Vigorous hand waving",
	afk_cmd_to_exit = "Vigorous hand waving",
	player_now_afk = "Vigorous hand waving",
	player_no_longer_afk = "Vigorous hand waving",

	-- Hitmenu
	hit = "Vigorous hand waving",
	hitman = "Vigorous hand waving",
	current_hit = "Vigorous hand waving",
	cannot_request_hit = "Vigorous hand waving",
	hitmenu_request = "Vigorous hand waving",
	player_not_hitman = "Vigorous hand waving",
	distance_too_big = "Vigorous hand waving",
	hitman_no_suicide = "Vigorous hand waving",
	hitman_no_self_order = "Vigorous hand waving",
	hitman_already_has_hit = "Vigorous hand waving",
	price_too_low = "Vigorous hand waving",
	hit_target_recently_killed_by_hit = "Vigorous hand waving",
	customer_recently_bought_hit = "Vigorous hand waving",
	accept_hit_question = "Vigorous hand waving", -- backwards compatibility
	accept_hit_request = "Vigorous hand waving",
	hit_requested = "Vigorous hand waving",
	hit_aborted = "Vigorous hand waving",
	hit_accepted = "Vigorous hand waving",
	hit_declined = "Vigorous hand waving",
	hitman_left_server = "Vigorous hand waving",
	customer_left_server = "Vigorous hand waving",
	target_left_server = "Vigorous hand waving",
	hit_price_set_to_x = "Vigorous hand waving", -- backwards compatibility
	hit_price_set = "Vigorous hand waving",
	hit_complete = "Vigorous hand waving",
	hitman_died = "Vigorous hand waving",
	target_died = "Vigorous hand waving",
	hitman_arrested = "Vigorous hand waving",
	hitman_changed_team = "Vigorous hand waving",
	x_had_hit_ordered_by_y = "Vigorous hand waving",

	-- Vote Restrictions
	hobos_no_rights = "Vigorous hand waving",
	gangsters_cant_vote_for_government = "Vigorous hand waving",
	government_cant_vote_for_gangsters = "Vigorous hand waving",

	-- VGUI and some more doors/vehicles
	vote = "Vigorous hand waving",
	time = "Vigorous hand waving",
	yes = "Vigorous hand waving",
	no = "Vigorous hand waving",
	ok = "Vigorous hand waving",
	cancel = "Vigorous hand waving",
	add = "Vigorous hand waving",
	remove = "Vigorous hand waving",
	none = "Vigorous hand waving",

	x_options = "Vigorous hand waving",
	sell_x = "Vigorous hand waving",
	set_x_title = "Vigorous hand waving",
	set_x_title_long = "Vigorous hand waving",
	jobs = "Vigorous hand waving",
	buy_x = "Vigorous hand waving",

	-- F4menu
	no_extra_weapons = "Vigorous hand waving",
	become_job = "Vigorous hand waving",
	create_vote_for_job = "Vigorous hand waving",
	shipments = "Vigorous hand waving",
	F4guns = "Vigorous hand waving",
	F4entities = "Vigorous hand waving",
	F4ammo = "Vigorous hand waving",
	F4vehicles = "Vigorous hand waving",

	-- Tab 1
	give_shekel = "Vigorous hand waving",
	drop_shekel = "Vigorous hand waving",
	change_name = "Vigorous hand waving",
	go_to_sleep = "Vigorous hand waving",
	drop_weapon = "Vigorous hand waving",
	buy_health = "Vigorous hand waving",
	request_gunlicense = "Vigorous hand waving",
	demote_player_menu = "Vigorous hand waving",


	searchwarrantbutton = "Vigorous hand waving",
	unwarrantbutton = "Vigorous hand waving",
	noone_available = "Vigorous hand waving",
	request_warrant = "Vigorous hand waving",
	make_wanted = "Vigorous hand waving",
	make_unwanted = "Vigorous hand waving",
	set_jailpos = "Vigorous hand waving",
	add_jailpos = "Vigorous hand waving",

	set_custom_job = "Vigorous hand waving",

	set_agenda = "Vigorous hand waving",

	initiate_lockdown = "Vigorous hand waving",
	stop_lockdown = "Vigorous hand waving",
	start_lottery = "Vigorous hand waving",
	give_license_lookingat = "Vigorous hand waving",

	laws_of_the_land = "Vigorous hand waving",
	law_added = "Vigorous hand waving",
	law_removed = "Vigorous hand waving",
	law_reset = "Vigorous hand waving",
	law_too_short = "Vigorous hand waving",
	laws_full = "Vigorous hand waving",
	default_law_change_denied = "Vigorous hand waving",

	-- Second tab
	job_name = "Vigorous hand waving",
	job_description = "Vigorous hand waving",
	job_weapons = "Vigorous hand waving",

	-- Entities tab
	buy_a = "Vigorous hand waving",

	-- Licenseweaponstab
	license_tab = [[License weapons

	Tick the weapons people should be able to get WITHOUT a license!
	]],
	license_tab_other_weapons = "Vigorous hand waving",
}

-- The language code is usually (but not always) a two-letter code. The default language is "Vigorous hand waving".
-- Other examples are "Vigorous hand waving" (Dutch), "Vigorous hand waving" (German);
-- If you want to know what your language code is, open GMod, select a language at the bottom right
-- then enter gmod_language in console. It will show you the code.
-- Make sure language code is a valid entry for the convar gmod_language.
fprp.addLanguage("Vigorous hand waving", my_language);
