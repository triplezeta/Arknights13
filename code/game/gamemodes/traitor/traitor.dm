/datum/game_mode
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	antag_flag = ROLE_TRAITOR
	false_report_weight = 20 //Reports of traitors are pretty common.
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "There are Syndicate agents on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors succeed!"

	var/list/datum/mind/pre_traitors = list()
	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.
	var/antag_datum = ANTAG_DATUM_TRAITOR //what type of antag to create


/datum/game_mode/traitor/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/num_traitors = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_traitors = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = pick(antag_candidates)
		pre_traitors += traitor
		traitor.special_role = traitor_name
		traitor.restricted_roles = restricted_jobs
		log_game("[traitor.key] (ckey) has been selected as a [traitor_name]")
		antag_candidates.Remove(traitor)

	return pre_traitors.len > 0


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/new_antag = new antag_datum(traitor)
		new_antag.should_specialise = TRUE
		addtimer(CALLBACK(traitor, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
	if(!exchange_blue)
		exchange_blue = -1 //Block latejoiners from getting exchange objectives
	..()
	return TRUE

/datum/game_mode/traitor/make_antag_chance(mob/living/carbon/human/character) //Assigns traitor to latejoiners
	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	var/traitorcap = min(round(GLOB.joined_player_list.len / (tsc * 2)) + 2 + num_modifier, round(GLOB.joined_player_list.len / tsc) + num_modifier)
	if((SSticker.mode.traitors.len + pre_traitors.len) >= traitorcap) //Upper cap for number of latejoin antagonists
		return
	if((SSticker.mode.traitors.len + pre_traitors.len) <= (traitorcap - 2) || prob(100 / (tsc * 2)))
		if(ROLE_TRAITOR in character.client.prefs.be_special)
			if(!jobban_isbanned(character, ROLE_TRAITOR) && !jobban_isbanned(character, "Syndicate"))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						add_latejoin_traitor(character.mind)

/datum/game_mode/traitor/proc/add_latejoin_traitor(datum/mind/character)
	var/datum/antagonist/traitor/new_antag = new antag_datum(character)
	new_antag.should_specialise = TRUE
	character.add_antag_datum(new_antag)



/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.


/datum/game_mode/proc/auto_declare_completion_traitor()
	if(traitors.len)
		var/text = "<br><font size=3><b>The [traitor_name]s were:</b></font>"
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = TRUE

			text += printplayer(traitor)

			var/TC_uses = 0
			var/uplink_true = FALSE
			var/purchases = ""
			for(var/obj/item/device/uplink/H in GLOB.uplinks)
				if(H && H.owner && H.owner == traitor.key)
					TC_uses += H.spent_telecrystals
					uplink_true = TRUE
					purchases += H.purchase_log

			var/objectives = ""
			if(traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in traitor.objectives)
					if(objective.check_completion())
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						SSblackbox.add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						SSblackbox.add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = FALSE
					count++

			if(uplink_true)
				text += " (used [TC_uses] TC) [purchases]"
				if(TC_uses==0 && traitorwin)
					var/static/icon/badass = icon('icons/badass.dmi', "badass")
					text += "<BIG>[icon2html(badass, world)]</BIG>"

			text += objectives

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"


			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				SSblackbox.add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				SSblackbox.add_details("traitor_success","FAIL")

			text += "<br>"

		text += "<br><b>The code phrases were:</b> <font color='red'>[GLOB.syndicate_code_phrase]</font><br>\
		<b>The code responses were:</b> <font color='red'>[GLOB.syndicate_code_response]</font><br>"
		to_chat(world, text)

	return TRUE

/datum/game_mode/traitor/generate_report()
	return "Although more specific threats are commonplace, you should always remain vigilant for Syndicate agents aboard your station. Syndicate communications have implied that many \
		Nanotrasen employees are Syndicate agents with hidden memories that may be activated at a moment's notice, so it's possible that these agents might not even know their positions."


/datum/game_mode/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, "traitor")

/datum/game_mode/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, null)
