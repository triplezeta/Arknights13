//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/severe
	abstract_type = /datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Patient is completely unable to speak."
	scan_desc = "extensive damage to the brain's speech center"
	gain_text = span_warning("You forget how to speak!")
	lose_text = span_notice("You suddenly remember how to speak.")

/datum/brain_trauma/severe/mute/on_gain()
	ADD_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/mute/on_lose()
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/aphasia
	name = "Aphasia"
	desc = "Patient is unable to speak or understand any language."
	scan_desc = "extensive damage to the brain's language center"
	gain_text = span_warning("You have trouble forming words in your head...")
	lose_text = span_notice("You suddenly remember how languages work.")

/datum/brain_trauma/severe/aphasia/on_gain()
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/aphasia, LANGUAGE_APHASIA)
	owner.grant_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)
	..()

/datum/brain_trauma/severe/aphasia/on_lose()
	if(!QDELING(owner))
		owner.remove_blocked_language(subtypesof(/datum/language), LANGUAGE_APHASIA)
		owner.remove_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)

	..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Patient's brain is no longer connected to its eyes."
	scan_desc = "extensive damage to the brain's occipital lobe"
	gain_text = span_warning("You can't see!")
	lose_text = span_notice("Your vision returns.")

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Patient's brain can no longer control part of its motor functions."
	scan_desc = "cerebral paralysis"
	gain_text = ""
	lose_text = ""
	var/paralysis_type
	var/list/paralysis_traits = list()
	//for descriptions

/datum/brain_trauma/severe/paralysis/New(specific_type)
	if(specific_type)
		paralysis_type = specific_type
	if(!paralysis_type)
		paralysis_type = pick("full","left","right","arms","legs","r_arm","l_arm","r_leg","l_leg")
	var/subject
	switch(paralysis_type)
		if("full")
			subject = "your body"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("left")
			subject = "the left side of your body"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_L_LEG)
		if("right")
			subject = "the right side of your body"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_R_LEG)
		if("arms")
			subject = "your arms"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
		if("legs")
			subject = "your legs"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("r_arm")
			subject = "your right arm"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM)
		if("l_arm")
			subject = "your left arm"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM)
		if("r_leg")
			subject = "your right leg"
			paralysis_traits = list(TRAIT_PARALYSIS_R_LEG)
		if("l_leg")
			subject = "your left leg"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG)

	gain_text = span_warning("You can't feel [subject] anymore!")
	lose_text = span_notice("You can feel [subject] again!")

/datum/brain_trauma/severe/paralysis/on_gain()
	..()
	for(var/X in paralysis_traits)
		ADD_TRAIT(owner, X, TRAUMA_TRAIT)


/datum/brain_trauma/severe/paralysis/on_lose()
	..()
	for(var/X in paralysis_traits)
		REMOVE_TRAIT(owner, X, TRAUMA_TRAIT)


/datum/brain_trauma/severe/paralysis/paraplegic
	random_gain = FALSE
	paralysis_type = "legs"
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/paralysis/hemiplegic/left
	paralysis_type = "left"

/datum/brain_trauma/severe/paralysis/hemiplegic/right
	paralysis_type = "right"

/datum/brain_trauma/severe/narcolepsy
	name = "Narcolepsy"
	desc = "Patient may involuntarily fall asleep during normal activities."
	scan_desc = "traumatic narcolepsy"
	gain_text = span_warning("You have a constant feeling of drowsiness...")
	lose_text = span_notice("You feel awake and aware again.")

/datum/brain_trauma/severe/narcolepsy/on_life(seconds_per_tick, times_fired)
	if(owner.IsSleeping())
		return

	var/sleep_chance = 1
	var/drowsy = !!owner.has_status_effect(/datum/status_effect/drowsiness)
	if(owner.move_intent == MOVE_INTENT_RUN)
		sleep_chance += 2
	if(drowsy)
		sleep_chance += 3

	if(SPT_PROB(0.5 * sleep_chance, seconds_per_tick))
		to_chat(owner, span_warning("You fall asleep."))
		owner.Sleeping(6 SECONDS)

	else if(!drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
		to_chat(owner, span_warning("You feel tired..."))
		owner.adjust_drowsiness(20 SECONDS)

/datum/brain_trauma/severe/monophobia
	name = "Monophobia"
	desc = "Patient feels sick and distressed when not around other people, leading to potentially lethal levels of stress."
	scan_desc = "monophobia"
	gain_text = ""
	lose_text = span_notice("You feel like you could be safe on your own.")
	var/stress = 0

/datum/brain_trauma/severe/monophobia/on_gain()
	..()
	if(check_alone())
		to_chat(owner, span_warning("You feel really lonely..."))
	else
		to_chat(owner, span_notice("You feel safe, as long as you have people around you."))

/datum/brain_trauma/severe/monophobia/on_life(seconds_per_tick, times_fired)
	..()
	if(check_alone())
		stress = min(stress + 0.5, 100)
		if(stress > 10 && SPT_PROB(2.5, seconds_per_tick))
			stress_reaction()
	else
		stress = max(stress - (2 * seconds_per_tick), 0)

/datum/brain_trauma/severe/monophobia/proc/check_alone()
	var/check_radius = 7
	if(owner.is_blind())
		check_radius = 1
	for(var/mob/M in oview(owner, check_radius))
		if(!isliving(M)) //ghosts ain't people
			continue
		if(istype(M, /mob/living/simple_animal/pet) || istype(M, /mob/living/basic/pet) || M.ckey)
			return FALSE
	return TRUE

/datum/brain_trauma/severe/monophobia/proc/stress_reaction()
	if(owner.stat != CONSCIOUS)
		return

	var/high_stress = (stress > 60) //things get psychosomatic from here on
	switch(rand(1, 6))
		if(1)
			if(high_stress)
				to_chat(owner, span_warning("You feel really sick at the thought of being alone!"))
			else
				to_chat(owner, span_warning("You feel sick..."))
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living/carbon, vomit), high_stress), 50) //blood vomit if high stress
		if(2)
			if(high_stress)
				to_chat(owner, span_warning("You feel weak and scared! If only you weren't alone..."))
				owner.adjustStaminaLoss(50)
			else
				to_chat(owner, span_warning("You can't stop shaking..."))

			owner.adjust_dizzy(40 SECONDS)
			owner.adjust_confusion(20 SECONDS)
			owner.set_jitter_if_lower(40 SECONDS)

		if(3, 4)
			if(high_stress)
				to_chat(owner, span_warning("You're going mad with loneliness!"))
				owner.adjust_hallucinations(60 SECONDS)
			else
				to_chat(owner, span_warning("You feel really lonely..."))

		if(5)
			if(high_stress)
				if(prob(15) && ishuman(owner))
					var/mob/living/carbon/human/H = owner
					H.set_heartattack(TRUE)
					to_chat(H, span_userdanger("You feel a stabbing pain in your heart!"))
				else
					to_chat(owner, span_userdanger("You feel your heart lurching in your chest..."))
					owner.adjustOxyLoss(8)
			else
				to_chat(owner, span_warning("Your heart skips a beat."))
				owner.adjustOxyLoss(8)

		else
			//No effect
			return

/datum/brain_trauma/severe/discoordination
	name = "Discoordination"
	desc = "Patient is unable to use complex tools or machinery."
	scan_desc = "extreme discoordination"
	gain_text = span_warning("You can barely control your hands!")
	lose_text = span_notice("You feel in control of your hands again.")

/datum/brain_trauma/severe/discoordination/on_gain()
	. = ..()
	owner.apply_status_effect(/datum/status_effect/discoordinated)

/datum/brain_trauma/severe/discoordination/on_lose()
	owner.remove_status_effect(/datum/status_effect/discoordinated)
	return ..()

/datum/brain_trauma/severe/pacifism
	name = "Traumatic Non-Violence"
	desc = "Patient is extremely unwilling to harm others in violent ways."
	scan_desc = "pacific syndrome"
	gain_text = span_notice("You feel oddly peaceful.")
	lose_text = span_notice("You no longer feel compelled to not harm.")

/datum/brain_trauma/severe/pacifism/on_gain()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/pacifism/on_lose()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/hypnotic_stupor
	name = "Hypnotic Stupor"
	desc = "Patient is prone to episodes of extreme stupor that leaves them extremely suggestible."
	scan_desc = "oneiric feedback loop"
	gain_text = span_warning("You feel somewhat dazed.")
	lose_text = span_notice("You feel like a fog was lifted from your mind.")

/datum/brain_trauma/severe/hypnotic_stupor/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_stupor/on_life(seconds_per_tick, times_fired)
	..()
	if(SPT_PROB(0.5, seconds_per_tick) && !owner.has_status_effect(/datum/status_effect/trance))
		owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)

/datum/brain_trauma/severe/hypnotic_trigger
	name = "Hypnotic Trigger"
	desc = "Patient has a trigger phrase set in their subconscious that will trigger a suggestible trance-like state."
	scan_desc = "oneiric feedback loop"
	gain_text = span_warning("You feel odd, like you just forgot something important.")
	lose_text = span_notice("You feel like a weight was lifted from your mind.")
	random_gain = FALSE
	var/trigger_phrase = "Nanotrasen"

/datum/brain_trauma/severe/hypnotic_trigger/New(phrase)
	..()
	if(phrase)
		trigger_phrase = phrase

/datum/brain_trauma/severe/hypnotic_trigger/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_trigger/handle_hearing(datum/source, list/hearing_args)
	if(!owner.can_hear() || owner == hearing_args[HEARING_SPEAKER])
		return

	var/regex/reg = new("(\\b[REGEX_QUOTE(trigger_phrase)]\\b)","ig")

	if(findtext(hearing_args[HEARING_RAW_MESSAGE], reg))
		addtimer(CALLBACK(src, PROC_REF(hypnotrigger)), 10) //to react AFTER the chat message
		hearing_args[HEARING_RAW_MESSAGE] = reg.Replace(hearing_args[HEARING_RAW_MESSAGE], span_hypnophrase("*********"))

/datum/brain_trauma/severe/hypnotic_trigger/proc/hypnotrigger()
	to_chat(owner, span_warning("The words trigger something deep within you, and you feel your consciousness slipping away..."))
	owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)

/datum/brain_trauma/severe/dyslexia
	name = "Dyslexia"
	desc = "Patient is unable to read or write."
	scan_desc = "dyslexia"
	gain_text = span_warning("You have trouble reading or writing...")
	lose_text = span_notice("You suddenly remember how to read and write.")

/datum/brain_trauma/severe/dyslexia/on_gain()
	ADD_TRAIT(owner, TRAIT_ILLITERATE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/dyslexia/on_lose()
	REMOVE_TRAIT(owner, TRAIT_ILLITERATE, TRAUMA_TRAIT)
	..()

/*
 * Brain traumas that eldritch paintings apply
 * This one is for "The Sister and He Who Wept" or /obj/structure/sign/painting/eldritch
 */
/datum/brain_trauma/severe/weeping
	name = "The Weeping"
	desc = "Patient hallucinates everyone as a figure called He Who Wept"
	scan_desc = "H_E##%%%WEEP6%11S!!,)()"
	gain_text = span_warning("HE WEEPS AND I WILL SEE HIM ONCE MORE")
	lose_text = span_notice("You feel the tendrils of something slip from your mind.")
	random_gain = FALSE
	/// Our cooldown declare for causing hallucinations
	COOLDOWN_DECLARE(weeping_hallucinations)

/datum/brain_trauma/severe/weeping/on_life(seconds_per_tick, times_fired)
	if(owner.stat != CONSCIOUS || owner.IsSleeping() || owner.IsUnconscious())
		return
	// If they have examined a painting recently
	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return
	if(!COOLDOWN_FINISHED(src, weeping_hallucinations))
		return
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)
	COOLDOWN_START(src, weeping_hallucinations, 10 SECONDS)
	..()

//This one is for "The First Desire" or /obj/structure/sign/painting/eldritch/desire
/datum/brain_trauma/severe/flesh_desire
	name = "The Desire for Flesh"
	desc = "Patient seems to only be able to eat organs or raw flesh for nutrients, also seems to become hungrier at a faster rate"
	scan_desc = "H_(82882)G3E:__))9R"
	gain_text = span_warning("I feel a hunger, only organs and flesh will feed it...")
	lose_text = span_notice("Your stomach no longer craves flesh, and your tongue feels duller.")
	random_gain = FALSE
	/// How much faster we loose hunger
	var/hunger_rate = 15

/datum/brain_trauma/severe/flesh_desire/on_gain()
	// Allows them to eat faster, mainly for flavor
	ADD_TRAIT(owner, TRAIT_VORACIOUS, REF(src))
	// If they have a tongue, make it crave meat
	var/obj/item/organ/internal/tongue/tongue = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.liked_foodtypes = GORE | MEAT
	..()

/datum/brain_trauma/severe/flesh_desire/on_life(seconds_per_tick, times_fired)
	// Causes them to need to eat at 10x the normal rate
	owner.adjust_nutrition(-hunger_rate * HUNGER_FACTOR)
	if(SPT_PROB(20, seconds_per_tick))
		to_chat(owner, span_notice("You feel a ravenous hunger for flesh..."))
	owner.overeatduration = max(owner.overeatduration - 200 SECONDS, 0)

	var/obj/item/organ/internal/tongue/tongue = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	// In case they switch tongues or their food type is changed for whatever reason
	if(tongue.liked_foodtypes == GORE | MEAT)
		return
	tongue.liked_foodtypes = GORE | MEAT

/datum/brain_trauma/severe/flesh_desire/on_lose()
	REMOVE_TRAIT(owner, TRAIT_VORACIOUS, REF(src))
	var/obj/item/organ/internal/tongue/tongue = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.liked_foodtypes = initial(tongue.liked_foodtypes)
	return ..()

// This one is for "Lady out of gates" or /obj/item/wallframe/painting/eldritch/beauty
/datum/brain_trauma/severe/eldritch_beauty
	name = "The Pursuit of Perfection"
	desc = "Patient seems to furiously scratch at their body, the only way to make them cease is for them to remove their jumpsuit."
	scan_desc = "I_)8(P_E##R&&F(E)C__T)"
	gain_text = span_warning("I WILL RID MY FLESH FROM IMPERFECTION!! I WILL BE PERFECT WITHOUT MY SUITS!!")
	lose_text = span_notice("You feel the influence of something slip your mind, and you feel content as you are.")
	random_gain = FALSE
	/// How much damage we deal with each scratch
	var/scratch_damage = 0.5

/datum/brain_trauma/severe/eldritch_beauty/on_life(seconds_per_tick, times_fired)
	// Jumpsuits ruin the "perfection" of the body
	if(!owner.get_item_by_slot(ITEM_SLOT_ICLOTHING))
		return

	// Scratching code
	var/obj/item/bodypart/bodypart = owner.get_bodypart(owner.get_random_valid_zone(even_weights = TRUE))
	if(!(bodypart && IS_ORGANIC_LIMB(bodypart)) && bodypart.bodypart_flags & BODYPART_PSEUDOPART)
		return
	if(owner.incapacitated())
		return
	bodypart.receive_damage(scratch_damage)
	if(SPT_PROB(33, seconds_per_tick))
		to_chat(owner, span_notice("You scratch furiously at [bodypart] to ruin the cloth that hides the beauty!"))

// This one is for "Climb over the rusted mountain" or /obj/structure/sign/painting/eldritch/rust
/datum/brain_trauma/severe/rusting
	name = "The Rusted Climb"
	desc = "Patient seems to oxidise things around them at random, and seem to believe they are aiding a creature in climbing a mountin."
	scan_desc = "C_)L(#_I_##M;B"
	gain_text = span_warning("The rusted climb shall finish at the peak")
	lose_text = span_notice("The rusted climb? Whats that? An odd dream to be sure.")
	random_gain = FALSE

/datum/brain_trauma/severe/rusting/on_life(seconds_per_tick, times_fired)
	var/atom/tile = get_turf(owner)
	// Examining a painting should stop this effect
	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	if(SPT_PROB(50, seconds_per_tick))
		to_chat(owner, span_notice("You feel eldritch energies pulse from your body!"))
		tile.rust_heretic_act()
