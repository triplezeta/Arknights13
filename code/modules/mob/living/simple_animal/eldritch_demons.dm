/mob/living/simple_animal/hostile/eldritch
	name = "Demon"
	real_name = "Demon"
	desc = ""
	gender = NEUTER
	mob_biotypes = NONE
	speak_emote = list("screams")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "reaps"
	response_harm_simple = "tears"
	speak_chance = 1
	icon = 'icons/mob/eldritch_mobs.dmi'
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	AIStatus = AI_ON
	attack_sound = 'sound/weapons/punch1.ogg'
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = 0
	faction = list("e_cult")
	movement_type = GROUND
	pressure_resistance = 100
	del_on_death = TRUE
	deathmessage = "implodes into itself"

/mob/living/simple_animal/hostile/eldritch/raw_prophet
	name = "Raw Prophet"
	real_name = "Raw Prophet"
	desc = "Abomination made from severed limbs."
	icon_state = "raw_prophet"
	status_flags = CANPUSH
	icon_living = "raw_prophet"
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 75
	health = 75
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Initialize()
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/telepathy/eldritch)

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Login()
	. = ..()
	client?.view_size.setTo(11)

/mob/living/simple_animal/hostile/eldritch/armsy
	name = "Terror of the night"
	real_name = "Armsy"
	desc = "Abomination made from severed limbs."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	var/mob/living/simple_animal/hostile/eldritch/armsy/back
	var/mob/living/simple_animal/hostile/eldritch/armsy/front
	var/oldloc
	var/allow_pulling = FALSE
	var/stacks_to_grow = 5
	var/current_stacks = 0

/mob/living/simple_animal/hostile/eldritch/armsy/New(spawn_more = TRUE,len = 6)
	. = ..()
	oldloc = loc
	if(!spawn_more)
		return
	allow_pulling = TRUE
	var/mob/living/simple_animal/hostile/eldritch/armsy/next
	var/mob/living/simple_animal/hostile/eldritch/armsy/prev
	var/mob/living/simple_animal/hostile/eldritch/armsy/current
	for(var/i = 0, i <= len,i++)
		prev = current
		//i tried using switch, but byond is really fucky and it didnt work as intended. Im sorry
		if(i == 0)
			current = new type(drop_location(),spawn_more = FALSE)
			current.icon_state = "armsy_mid"
			current.icon_living = "armsy_mid"
			current.front = src
			current.AIStatus = AI_OFF
			back = current
		else if(i > 0 && i < len)
			current = new type(drop_location(),spawn_more = FALSE)
			prev.back = current
			prev.icon_state = "armsy_mid"
			prev.icon_living = "armsy_mid"
			prev.front = next
			prev.AIStatus = AI_OFF
		else
			prev.icon_state = "armsy_end"
			prev.icon_living = "armsy_end"
			prev.front = next
			prev.AIStatus = AI_OFF
		next = prev

/mob/living/simple_animal/hostile/eldritch/armsy/Moved()

	if(pulledby && !allow_pulling)
		pulledby.stop_pulling()
		loc = oldloc

	if(back && back.loc != oldloc)
		for(var/i = 0, i < max(get_dist(loc,back.loc),10),i++)
			step_towards(back,oldloc)
			if(loc == back.loc)
				break
		back.loc = oldloc//just in case

	if(front && loc != front.oldloc)
		for(var/i = 0, i < max(get_dist(loc,front.loc),10),i++)
			step_towards(src,front.oldloc)
			if(loc == front.loc)
				break
		loc = front.oldloc//just in case

	oldloc = loc
	gib_trail()
	. = ..()

/mob/living/simple_animal/hostile/eldritch/armsy/proc/gib_trail()
	if(back)
		return
	var/chosen_decal = pick(typesof(/obj/effect/decal/cleanable/blood/gibs))
	var/obj/effect/decal/cleanable/blood/gibs/decal = new chosen_decal(drop_location())
	decal.setDir(dir)

/mob/living/simple_animal/hostile/eldritch/armsy/Destroy()
	if(front)
		front.icon_state = "armsy_end"
		front.icon_living = "armsy_end"
	if(back)
		back.Destroy() // chain destruction baby
	return ..()


/mob/living/simple_animal/hostile/eldritch/armsy/proc/heal()
	if(health == maxHealth)
		if(back)
			back.heal()
			return
		else
			current_stacks++
			if(current_stacks >= stacks_to_grow)
				var/mob/living/simple_animal/hostile/eldritch/armsy/prev = new type(drop_location(),spawn_more = FALSE)
				icon_state = "armsy_mid"
				icon_living =  "armsy_mid"
				back = prev
				prev.icon_state = "armsy_end"
				prev.icon_living = "armsy_end"
				prev.front = src
				prev.AIStatus = AI_OFF

				current_stacks = 0

	adjustBruteLoss(-maxHealth * 0.5, FALSE)
	adjustFireLoss(-maxHealth * 0.5 FALSE)
	adjustToxLoss(-maxHealth * 0.5 FALSE)
	adjustOxyLoss(-maxHealth * 0.5)

/mob/living/simple_animal/hostile/eldritch/armsy/AttackingTarget()
	if(istype(target,/obj/item/bodypart/r_arm) || istype(target,/obj/item/bodypart/l_arm))
		target.Destroy()
		heal()
		return
	if(back)
		back.target = target
		back.AttackingTarget()
	if(!Adjacent(target))
		return
	do_attack_animation(target)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
			return
		var/list/parts = list()
		for(var/X in C.bodyparts)
			var/obj/item/bodypart/BP = X
			if(BP.body_part != HEAD && BP.body_part != CHEST && BP.body_part != LEG_LEFT && BP.body_part != LEG_RIGHT)
				if(BP.dismemberable)
					parts += BP
		if(length(parts) && prob(10))
			var/obj/item/bodypart/BP = pick(parts)
			BP.dismember()

	return ..()


/mob/living/simple_animal/hostile/eldritch/armsy/prime
	name = "Lord of the Night"
	real_name = "Master of Decay"
	maxHealth = 400
	health = 400
	melee_damage_lower = 20
	melee_damage_upper = 25

/mob/living/simple_animal/hostile/eldritch/armsy/prime/New(spawn_more, len)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(1.4,1.4)
	transform = matrix_transformation

/mob/living/simple_animal/hostile/eldritch/rust_spirit
	name = "Rust Walker"
	real_name = "Rusty"
	desc = "Incomprehensible abomination actively seeping life out of it's surrounding."
	icon_state = "rust_walker"
	status_flags = CANPUSH
	icon_living = "rust_walker"
	maxHealth = 50
	health = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Initialize()
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short)

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Life()
	. = ..()
	if(stat == DEAD)
		return
	var/turf/T = get_turf(src)
	if(istype(T,/turf/open/floor/plating/rust))
		adjustBruteLoss(-3, FALSE)
		adjustFireLoss(-3, FALSE)
		adjustToxLoss(-3, FALSE)
		adjustOxyLoss(-1)

/mob/living/simple_animal/hostile/eldritch/ash_spirit
	name = "Ash Man"
	real_name = "Ashy"
	desc = "Incomprehensible abomination actively seeping life out of it's surrounding."
	icon_state = "ash_walker"
	status_flags = CANPUSH
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS

/mob/living/simple_animal/hostile/eldritch/ash_spirit/Initialize()
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash)
	AddSpell(new /obj/effect/proc_holder/spell/pointed/ash_cleave/long)
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade)

/mob/living/simple_animal/hostile/eldritch/stalker
	name = "Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "Abomination made from severed limbs."
	icon_state = "stalker"
	status_flags = CANPUSH
	icon_living = "stalker"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS

/mob/living/simple_animal/hostile/eldritch/stalker/Initialize()
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/eldritch)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/emplosion/eldritch)
