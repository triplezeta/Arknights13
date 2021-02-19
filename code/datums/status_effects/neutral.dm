//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/atom/movable/screen/alert/status_effect/in_love
	name = "In Love"
	desc = "You feel so wonderfully in love!"
	icon_state = "in_love"

/datum/status_effect/in_love
	id = "in_love"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/in_love
	var/hearts

/datum/status_effect/in_love/on_creation(mob/living/new_owner, mob/living/date)
	. = ..()
	if(!.)
		return

	linked_alert.desc = "You're in love with [date.real_name]! How lovely."
	hearts = WEAKREF(date.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"in_love",
		image(icon = 'icons/effects/effects.dmi', icon_state = "love_hearts", loc = date),
		new_owner,
	))

/datum/status_effect/in_love/on_remove()
	QDEL_NULL(hearts)

/datum/status_effect/throat_soothed
	id = "throat_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/throat_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/throat_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/bounty
	id = "bounty"
	status_type = STATUS_EFFECT_UNIQUE
	var/mob/living/rewarded

/datum/status_effect/bounty/on_creation(mob/living/new_owner, mob/living/caster)
	. = ..()
	if(.)
		rewarded = caster

/datum/status_effect/bounty/on_apply()
	to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>You have been marked for death by [rewarded]. If you die, they will be rewarded.</span>")
	playsound(owner, 'sound/weapons/gun/shotgun/rack.ogg', 75, FALSE)
	return ..()

/datum/status_effect/bounty/tick()
	if(owner.stat == DEAD)
		rewards()
		qdel(src)

/datum/status_effect/bounty/proc/rewards()
	if(rewarded && rewarded.mind && rewarded.stat != DEAD)
		to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>Bounty claimed.</span>")
		playsound(owner, 'sound/weapons/gun/shotgun/shot.ogg', 75, FALSE)
		to_chat(rewarded, "<span class='greentext'>You feel a surge of mana flow into you!</span>")
		for(var/obj/effect/proc_holder/spell/spell in rewarded.mind.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_icon()
		rewarded.adjustBruteLoss(-25)
		rewarded.adjustFireLoss(-25)
		rewarded.adjustToxLoss(-25)
		rewarded.adjustOxyLoss(-25)
		rewarded.adjustCloneLoss(-25)

// heldup is for the person being aimed at
/datum/status_effect/grouped/heldup
	id = "heldup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /atom/movable/screen/alert/status_effect/heldup

/atom/movable/screen/alert/status_effect/heldup
	name = "Held Up"
	desc = "Making any sudden moves would probably be a bad idea!"
	icon_state = "aimed"

/datum/status_effect/grouped/heldup/on_apply()
	owner.apply_status_effect(STATUS_EFFECT_SURRENDER)
	return ..()

/datum/status_effect/grouped/heldup/on_remove()
	owner.remove_status_effect(STATUS_EFFECT_SURRENDER)
	return ..()

// holdup is for the person aiming
/datum/status_effect/holdup
	id = "holdup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/holdup

/atom/movable/screen/alert/status_effect/holdup
	name = "Holding Up"
	desc = "You're currently pointing a gun at someone."
	icon_state = "aimed"

// this status effect is used to negotiate the high-fiving capabilities of all concerned parties
/datum/status_effect/high_fiving
	id = "high_fiving"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// The carbons who were offered the ability to partake in the high-five
	var/list/possible_takers
	/// The actual slapper item
	var/obj/item/slapper/slap_item

/datum/status_effect/high_fiving/on_creation(mob/living/new_owner, obj/item/slap)
	. = ..()
	if(!.)
		return

	slap_item = slap
	owner.visible_message("<span class='notice'>[owner] raises [owner.p_their()] arm, looking for a high-five!</span>", \
		"<span class='notice'>You post up, looking for a high-five!</span>", null, 2)

	for(var/mob/living/carbon/possible_taker in orange(1, owner))
		if(!owner.CanReach(possible_taker) || possible_taker.incapacitated())
			continue
		register_candidate(possible_taker)

	if(!possible_takers) // in case we tried high-fiving with only a dead body around or something
		owner.visible_message("<span class='danger'>[owner] realizes no one within range is actually capable of high-fiving, lowering [owner.p_their()] arm in shame...</span>", \
			"<span class='warning'>You realize a moment too late that no one within range is actually capable of high-fiving you, oof...</span>", null, 2)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five_alone)
		qdel(src)
		return

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/check_owner_in_range)
	RegisterSignal(slap_item, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED), .proc/dropped_slap)
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE_MORE, .proc/check_fake_out)

/datum/status_effect/high_fiving/Destroy()
	QDEL_NULL(slap_item)
	for(var/i in possible_takers)
		var/mob/living/carbon/lost_hope = i
		remove_candidate(lost_hope)
	LAZYCLEARLIST(possible_takers)
	return ..()

/// Hook up the specified carbon mob for possible high-fiving, give them the alert and signals and all
/datum/status_effect/high_fiving/proc/register_candidate(mob/living/carbon/possible_candidate)
	var/atom/movable/screen/alert/highfive/G = possible_candidate.throw_alert("[owner]", /atom/movable/screen/alert/highfive)
	if(!G)
		return
	LAZYADD(possible_takers, possible_candidate)
	RegisterSignal(possible_candidate, COMSIG_MOVABLE_MOVED, .proc/check_taker_in_range)
	G.setup(possible_candidate, owner, slap_item)

/// Remove the alert and signals for the specified carbon mob
/datum/status_effect/high_fiving/proc/remove_candidate(mob/living/carbon/removed_candidate)
	removed_candidate.clear_alert("[owner]")
	LAZYREMOVE(possible_takers, removed_candidate)
	UnregisterSignal(removed_candidate, COMSIG_MOVABLE_MOVED)

/// We failed to high-five broh, either because there's no one viable next to us anymore, or we lost the slapper, or what
/datum/status_effect/high_fiving/proc/fail()
	owner.visible_message("<span class='danger'>[owner] slowly lowers [owner.p_their()] arm, realizing no one will high-five [owner.p_them()]! How embarassing...</span>", \
		"<span class='warning'>You realize the futility of continuing to wait for a high-five, and lower your arm...</span>", null, 2)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/left_hanging)
	qdel(src)

/// Yeah broh! This is where we do the high-fiving (or high-tenning :o)
/datum/status_effect/high_fiving/proc/we_did_it(mob/living/carbon/successful_taker)
	var/open_hands_taker
	var/slappers_owner
	for(var/i in successful_taker.held_items) // see how many hands the taker has open for high'ing
		if(isnull(i))
			open_hands_taker++

	if(!open_hands_taker)
		to_chat(successful_taker, "<span class='warning'>You can't high-five [owner] with no open hands!</span>")
		SEND_SIGNAL(successful_taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five_full_hand) // not so successful now!
		return

	for(var/i in owner.held_items)
		var/obj/item/slapper/slap_check = i
		if(istype(slap_check))
			slappers_owner++

	if(!slappers_owner) // THE PRANKAGE
		too_slow_p1(successful_taker)
		return

	if(slappers_owner >= 2) // we only check this if it's already established the taker has 2+ hands free
		owner.visible_message("<span class='notice'>[successful_taker] enthusiastically high-tens [owner]!</span>", "<span class='nicegreen'>Wow! You're high-tenned [successful_taker]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", ignored_mobs=successful_taker)
		to_chat(successful_taker, "<span class='nicegreen'>You give high-tenning [owner] your all!</span>")
		playsound(owner, 'sound/weapons/slap.ogg', 100, TRUE, 1)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_ten)
		SEND_SIGNAL(successful_taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_ten)
	else
		owner.visible_message("<span class='notice'>[successful_taker] high-fives [owner]!</span>", "<span class='nicegreen'>All right! You're high-fived by [successful_taker]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", ignored_mobs=successful_taker)
		to_chat(successful_taker, "<span class='nicegreen'>You high-five [owner]!</span>")
		playsound(owner, 'sound/weapons/slap.ogg', 50, TRUE, -1)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five)
		SEND_SIGNAL(successful_taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five)
	qdel(src)

/// If we don't have any slappers in hand when someone goes to high-five us, we prank the hell out of them
/datum/status_effect/high_fiving/proc/too_slow_p1(mob/living/carbon/rube)
	owner.visible_message("<span class='notice'>[rube] rushes in to high-five [owner], but-</span>", "<span class='nicegreen'>[rube] falls for your trick just as planned, lunging for a high-five that no longer exists! Classic!</span>", ignored_mobs=rube)
	to_chat(rube, "<span class='nicegreen'>You go in for [owner]'s high-five, but-</span>")
	addtimer(CALLBACK(src, .proc/too_slow_p2, rube), 0.5 SECONDS)

/// Part two of the ultimate prank
/datum/status_effect/high_fiving/proc/too_slow_p2(mob/living/carbon/rube)
	if(!owner || !rube)
		qdel(src)
		return
	owner.visible_message("<span class='danger'>[owner] pulls away from [rube]'s slap at the last second, dodging the high-five entirely!</span>", "<span class='nicegreen'>[rube] fails to make contact with your hand, making an utter fool of [rube.p_them()]self!</span>", "<span class='hear'>You hear a disappointing sound of flesh not hitting flesh!</span>", ignored_mobs=rube)
	var/all_caps_for_emphasis = uppertext("NO! [owner] PULLS [owner.p_their()] HAND AWAY FROM YOURS! YOU'RE TOO SLOW!")
	to_chat(rube, "<span class='userdanger'>[all_caps_for_emphasis]</span>")
	playsound(owner, 'sound/weapons/thudswoosh.ogg', 100, TRUE, 1)
	rube.Knockdown(1 SECONDS)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/down_low)
	SEND_SIGNAL(rube, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/too_slow)
	qdel(src)

/// If someone examine_more's us while we don't have a slapper in hand, it'll tip them off to our trickster ways
/datum/status_effect/high_fiving/proc/check_fake_out(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!slap_item)
		examine_list += "<span class='warning'>[owner]'s arm appears tensed up, as if [owner.p_they()] plan on pulling it back suddenly...</span>\n"

/// One of our possible takers moved, see if they left us hanging
/datum/status_effect/high_fiving/proc/check_taker_in_range(mob/living/carbon/taker)
	SIGNAL_HANDLER
	if(owner.CanReach(taker) && !taker.incapacitated())
		return

	to_chat(taker, "<span class='warning'>You left [owner] hanging!</span>")
	remove_candidate(taker)
	if(!possible_takers)
		fail()

/// The propositioner moved, see if anyone is out of range now
/datum/status_effect/high_fiving/proc/check_owner_in_range(mob/living/carbon/source)
	SIGNAL_HANDLER

	for(var/i in possible_takers)
		var/mob/living/carbon/checking_taker = i
		if(!istype(checking_taker) || !owner.CanReach(checking_taker) || checking_taker.incapacitated())
			remove_candidate(checking_taker)

	if(!possible_takers)
		fail()

/// Something fishy is going on here...
/datum/status_effect/high_fiving/proc/dropped_slap(obj/item/source)
	slap_item = null

//this effect gives the user an alert they can use to surrender quickly
/datum/status_effect/grouped/surrender
	id = "surrender"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/surrender

/atom/movable/screen/alert/status_effect/surrender
	name = "Surrender"
	desc = "Looks like you're in trouble now, bud. Click here to surrender. (Warning: You will be incapacitated.)"
	icon_state = "surrender"

/atom/movable/screen/alert/status_effect/surrender/Click(location, control, params)
	. = ..()
	owner.emote("surrender")

/*
 * A status effect used for preventing caltrop message spam
 *
 * While a mob has this status effect, they won't recieve any messages about
 * stepping on caltrops. But they will be stunned and damaged regardless.
 *
 * The status effect itself has no effect, other than to disappear after
 * a second.
 */
/datum/status_effect/caltropped
	id = "caltropped"
	duration = 1 SECONDS
	tick_interval = INFINITY
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/eigenstasium
	id = "eigenstasium"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	///So we know what cycle we're in during the status
	var/current_cycle = 0 //keep track of our calls
	///The addiction looper for addiction stage 3
	var/phase_3_cycle = 0
	///Your clone from another reality
	var/mob/living/carbon/alt_clone = null

///Convert this effect to process slowly instead
/datum/status_effect/eigenstasium/on_creation(mob/living/new_owner, ...)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSprocessing, src) //this lasts a while, so SSfastprocess isn't needed.

/datum/status_effect/eigenstasium/Destroy()
	QDEL_NULL(alt_clone)
	. = ..()
	STOP_PROCESSING(SSprocessing, src)


/datum/status_effect/eigenstasium/tick()
	. = ..()
	//This stuff runs every cycle
	if(prob(5)
		do_sparks(5, FALSE, owner)
	if(owner.has_reagent(/datum/reagent/bluespace) || owner.has_reagent(/datum/reagent/eigenstate))
		current_cycle = max(-25, (current_cycle - 0.5)) //cap to -25
		return ..()

	switch(current_cycle)
		if(0)
			to_chat(owner, "<span class='userdanger'>Your wavefunction feels like it's been ripped in half. You feel empty inside.</span>")
		//phase 1
		if(1 to 10)
			owner.Jitter(10)
			owner.adjust_nutrition(-owner.nutrition/15)

		//phase 2
		if(10 to 30)
			if(current_cycle == 11)
				to_chat(owner, "<span class='userdanger'>You start to convlse violently as you feel your consciousness split and merge across realities as your possessions fly wildy off your body.</span>")
				owner.Jitter(200)
				owner.Stun(80)
			var/items = owner.get_contents()
			if(!LAZYLEN(items))
				return ..()
			var/obj/item/item = pick(items)
			owner.dropItemToGround(item, TRUE)
			do_sparks(5,FALSE,item)
			do_teleport(item, get_turf(item), 5, no_effects=TRUE);
			do_sparks(5,FALSE,item)

		//phase 3
		if(30 to 42)
			//Clone function - spawns a clone then deletes it - simulates multiple copies of the player teleporting in
			switch(phase_3_cycle) //Loops 0 -> 1 -> 2 -> 1 -> 2 -> 1 ...ect.
				if(0)
					owner.Jitter(100)
					to_chat(owner, "<span class='userdanger'>Your eigenstate starts to rip apart, drawing in alternative reality versions of yourself!</span>")
				if(1)
					var/typepath = owner.type
					alt_clone = new typepath(owner.loc)
					var/mob/living/carbon/clone = alt_clone
					alt_clone.appearance = owner.appearance
					alt_clone.real_name = owner.real_name
					owner.visible_message("[owner] collapses in from an alternative reality!")
					do_teleport(alt_clone, get_turf(alt_clone), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
					do_sparks(5,FALSE,alt_clone)
					alt_clone.emote("spin")
					owner.emote("spin")
					var/static/list/say_phrases = list(
						"Bugger me, whats all this then?",
						"Sacre bleu! Ou suis-je?!",
						"I knew powering the station using a singularity engine would lead to something like this...",
						"Wow, I can't believe in your universe Cencomm got rid of cloning.",
						"WHAT IS HAPPENING?!",
						"YOU'VE CREATED A TIME PARADOX!",
						"You trying to steal my job?",
						"So that's what I'd look like if I was ugly...",
						"So, two alternate universe twins walk into a bar...",
						"YOU'VE DOOMED THE TIMELINE!",
						"Ruffle a cat once in a while!",
						"Why haven't you gotten around to starting that band?!",
						"I bet we can finally take the clown now.",
						"LING DISGUISED AS ME!",
						"At long last! My evil twin!",
						"Keep going lets see if more of us show up.",
						"No! Dark spirits, do not torment me with these visions of my future self! It's horrible!",
						"Good. Now that the council is assembled the meeting can begin.",
						"Listen! I only have so much time before I'm ripped away. The secret behind the gas giants are...",
						"Das ist nicht deutschland. Das ist nicht akzeptabel!!!",
						"I've come from the future to warn you about eigenstasium! Oh no! I'm too late!",
						"You fool! You took too much eigenstasium! You've doomed us all!",
						"What...what's with these teleports? It's like one of my Japanese animes...!",
						"Ik stond op het punt om mehki op tafel te zetten, en nu, waar ben ik?",
						"Wake the fuck up spaceman we have a gas giant to burn",
						"This is one hell of a beepsky smash.",
						"Now neither of us will be virgins!")
					alt_clone.say(pick(say_phrases))
				if(2)
					do_sparks(5,FALSE,alt_clone)
					qdel(alt_clone) //Deletes CLONE, or was that you?
					owner.visible_message("[owner] is snapped across to a different alternative reality!")
					addictCyc3 = 0 //counter
					alt_clone = null
			addictCyc3++
			do_teleport(owner, get_turf(owner), 2, no_effects=TRUE) //Teleports player randomly
			do_sparks(5, FALSE, owner)

		//phase 4
		if(42 to INFINITY)
			if(alt_clone)//catch any stragilers
				do_sparks(5,FALSE,alt_clone)
				qdel(alt_clone)
				owner.visible_message("[owner] is snapped across to a different alternative reality!")
				alt_clone = null
			//clean up and remove status
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "Eigentrip", /datum/mood_event/eigentrip, creation_purity)
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "Eigenstasium wild rides ridden")
			do_sparks(5, FALSE, owner)
			do_teleport(owner, get_turf(owner), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
			do_sparks(5, FALSE, owner)
			owner.Sleeping(100)
			owner.Jitter(50)
			to_chat(owner, "<span class='warning'>You feel your eigenstate settle, snapping an alternative version of yourself into reality.</span>")
			owner.emote("me",1,"flashes into reality suddenly, gasping as they gaze around in a bewildered and highly confused fashion!",TRUE)
			log_game("FERMICHEM: [owner] ckey: [owner.key] has become an alternative universe version of themselves.")
			//new you new stuff
			SSquirks.randomise_quirks(owner)
			owner.reagents.remove_all(1000)
			var/datum/component/mood/mood = owner.GetComponent(/datum/component/mood)
			mood.remove_temp_moods() //New you, new moods.
			var/mob/living/carbon/human/human_mob = owner
			if(!human_mob)
				return
			if(prob(1))//low chance of the alternative reality returning to monkey
				var/obj/item/organ/tail/monkey/monkey_tail = new (human_mob.loc)
				monkey_tail.Insert(human_mob)
			if(!creator)
				human_mob.dna?.species?.randomize_main_appearance_element(human_mob)
				human_mob.dna?.species?.randomize_active_underwear(human_mob)
			else
				human_mob.appearance = creator.appearance
				human_mob.name = creator.name
			owner.remove_status_effect(STATUS_EFFECT_EIGEN)

	//Finally increment cycle
	current_cycle++

/datum/status_effect/eigenstasium/on_remove()
	if(alt_clone)//catch any stragilers
		do_sparks(5,FALSE,alt_clone)
		qdel(alt_clone)
		owner.visible_message("[owner] is snapped across to a different alternative reality!")
		alt_clone = null
	. = ..()
