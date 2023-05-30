/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/dualsaber
	icon = 'icons/obj/weapons/transforming_energy.dmi'
	icon_state = "dualsaber0"
	inhand_icon_state = "dualsaber0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_SMALL
	hitsound = SFX_SWING_HIT
	armour_penetration = 35
	light_system = MOVABLE_LIGHT
	light_range = 6 //TWICE AS BRIGHT AS A REGULAR ESWORD
	light_color = LIGHT_COLOR_ELECTRIC_GREEN
	light_on = FALSE
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	block_chance = 75
	block_sound = 'sound/weapons/block_blade.ogg'
	max_integrity = 200
	armor_type = /datum/armor/item_dualsaber
	resistance_flags = FIRE_PROOF
	wound_bonus = -10
	bare_wound_bonus = 20
	demolition_mod = 1.5 //1.5x damage to objects, robots, etc.
	item_flags = NO_BLOOD_ON_ITEM
	attack_style = /datum/attack_style/melee_weapon/swing/requires_wield/desword
	weapon_sprite_angle = 45

	var/w_class_on = WEIGHT_CLASS_BULKY
	var/saber_color = "green"
	var/two_hand_force = 34
	var/hacked = FALSE
	var/list/possible_colors = list("red", "blue", "green", "purple")

/datum/armor/item_dualsaber
	fire = 100
	acid = 70

/obj/item/dualsaber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = force, \
		force_wielded = two_hand_force, \
		wieldsound = 'sound/weapons/saberon.ogg', \
		unwieldsound = 'sound/weapons/saberoff.ogg', \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)

/// Triggered on wield of two handed item
/// Specific hulk checks due to reflection chance for balance issues and switches hitsounds.
/obj/item/dualsaber/proc/on_wield(obj/item/source, mob/living/carbon/user)
	if(user?.has_dna())
		if(user.dna.check_mutation(/datum/mutation/human/hulk))
			to_chat(user, span_warning("You lack the grace to wield this!"))
			return COMPONENT_TWOHANDED_BLOCK_WIELD
	w_class = w_class_on
	hitsound = 'sound/weapons/blade1.ogg'
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)
	blocking_ability = 1

/// Triggered on unwield of two handed item
/// switch hitsounds
/obj/item/dualsaber/proc/on_unwield(obj/item/source, mob/living/carbon/user)
	w_class = initial(w_class)
	hitsound = SFX_SWING_HIT
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE)
	blocking_ability = initial(blocking_ability)

/obj/item/dualsaber/get_sharpness()
	return HAS_TRAIT(src, TRAIT_WIELDED) && sharpness

/obj/item/dualsaber/update_icon_state()
	icon_state = inhand_icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "dualsaber[saber_color][HAS_TRAIT(src, TRAIT_WIELDED)]" : "dualsaber0"
	return ..()

/obj/item/dualsaber/suicide_act(mob/living/carbon/user)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		user.visible_message(span_suicide("[user] begins spinning way too fast! It looks like [user.p_theyre()] trying to commit suicide!"))

		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)//stole from chainsaw code
		var/obj/item/organ/internal/brain/B = user.get_organ_slot(ORGAN_SLOT_BRAIN)
		B.organ_flags &= ~ORGAN_VITAL //this cant possibly be a good idea
		var/randdir
		for(var/i in 1 to 24)//like a headless chicken!
			if(user.is_holding(src))
				randdir = pick(GLOB.alldirs)
				user.Move(get_step(user, randdir),randdir)
				user.emote("spin")
				if (i == 3 && myhead)
					myhead.drop_limb()
				sleep(0.3 SECONDS)
			else
				user.visible_message(span_suicide("[user] panics and starts choking to death!"))
				return OXYLOSS

	else
		user.visible_message(span_suicide("[user] begins beating [user.p_them()]self to death with \the [src]'s handle! It probably would've been cooler if [user.p_they()] turned it on first!"))
	return BRUTELOSS

/obj/item/dualsaber/Initialize(mapload)
	. = ..()
	if(LAZYLEN(possible_colors))
		saber_color = pick(possible_colors)
		switch(saber_color)
			if("red")
				set_light_color(COLOR_SOFT_RED)
			if("green")
				set_light_color(LIGHT_COLOR_GREEN)
			if("blue")
				set_light_color(LIGHT_COLOR_LIGHT_CYAN)
			if("purple")
				set_light_color(LIGHT_COLOR_LAVENDER)

/obj/item/dualsaber/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/dualsaber/attack(mob/target, mob/living/carbon/human/user)
	if(user.has_dna())
		if(user.dna.check_mutation(/datum/mutation/human/hulk))
			to_chat(user, span_warning("You grip the blade too hard and accidentally drop it!"))
			if(HAS_TRAIT(src, TRAIT_WIELDED))
				user.dropItemToGround(src, force=TRUE)
				return
	..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
		impale(user)
		return

/obj/item/dualsaber/proc/jedi_spin(mob/living/user)
	dance_rotate(user, CALLBACK(user, TYPE_PROC_REF(/mob, dance_flip)))

/obj/item/dualsaber/proc/impale(mob/living/user)
	to_chat(user, span_warning("You twirl around a bit before losing your balance and impaling yourself on [src]."))
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		user.take_bodypart_damage(20,25,check_armor = TRUE)
	else
		user.adjustStaminaLoss(25)

/obj/item/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return 0

/obj/item/dualsaber/process()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(hacked)
			set_light_color(pick(COLOR_SOFT_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER))
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/dualsaber/IsReflect()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return 1

/obj/item/dualsaber/ignition_effect(atom/A, mob/user)
	// same as /obj/item/melee/energy, mostly
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ""
	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [user.p_their()] nose"
	. = span_warning("[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [A.loc == user ? "[user.p_their()] [A.name]" : A] in the process.")
	playsound(loc, hitsound, get_clamped_volume(), TRUE, -1)
	add_fingerprint(user)
	// Light your candles while spinning around the room
	INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

/obj/item/dualsaber/green
	possible_colors = list("green")

/obj/item/dualsaber/red
	possible_colors = list("red")

/obj/item/dualsaber/blue
	possible_colors = list("blue")

/obj/item/dualsaber/purple
	possible_colors = list("purple")

/obj/item/dualsaber/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			to_chat(user, span_warning("2XRNBW_ENGAGE"))
			saber_color = "rainbow"
			update_appearance()
		else
			to_chat(user, span_warning("It's starting to look like a triple rainbow - no, nevermind."))
	else
		return ..()

// Attack style for desword
/datum/attack_style/melee_weapon/swing/requires_wield/desword
	cd = CLICK_CD_MELEE * 1.25
	reverse_for_lefthand = FALSE
	time_per_turf = 0.05 SECONDS

/datum/attack_style/melee_weapon/swing/requires_wield/desword/get_swing_description()
	return "It swings out to all adjacent tiles besides directly behind you. It must be active to swing. Right-clicking will swing in the opposite direction."

/datum/attack_style/melee_weapon/swing/requires_wield/desword/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	var/list/turfs_in_order = list()
	turfs_in_order |= get_turfs_and_adjacent_in_direction(attacker, turn(attack_direction, 90))
	turfs_in_order |= get_step(attacker, attack_direction)
	turfs_in_order |= get_turfs_and_adjacent_in_direction(attacker, turn(attack_direction, -90))
	if(right_clicking)
		reverse_range(turfs_in_order)
	return turfs_in_order

/datum/attack_style/melee_weapon/swing/requires_wield/desword/execute_attack(mob/living/attacker, obj/item/dualsaber/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	. = ..()
	if(prob(50) && !(. & ATTACK_STYLE_CANCEL))
		INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item/dualsaber, jedi_spin), attacker)

// melbert todo
/datum/attack_style/melee_weapon/swing/requires_wield/desword/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	if(length(affecting) < 3)
		// Affecting will only get this small if we're in a super weird place like, say, in the corner of the map
		return

	var/initial_angle = -weapon.weapon_sprite_angle + get_angle(attacker, affecting[1])
	var/final_angle = -weapon.weapon_sprite_angle + get_angle(attacker, affecting[3]) // Only go up to the third turf, since we're two sided baby
	var/image/attack_image = create_attack_image(attacker, weapon, get_turf(attacker), initial_angle)
	var/matrix/final_transform = turn(attack_image.transform, final_angle)
	var/anim_time = 8 * time_per_turf // basically, travel 3 turfs at 2x the speed. then 2 turfs time for fade out.

	attacker.do_attack_animation(affecting[ROUND_UP(length(affecting) / 2)], no_effect = TRUE)
	flick_overlay_global(attack_image, GLOB.clients, anim_time)
	animate(
		attack_image,
		time = anim_time * 0.75,
		transform = final_transform,
		alpha = 175,
		easing = CUBIC_EASING|EASE_OUT,
	)
	animate(
		time = anim_time * 0.25,
		alpha = 0,
		easing = CIRCULAR_EASING|EASE_OUT,
	)
