/mob/living/simple_animal/hostile/gorilla
	name = "Gorilla"
	desc = "A ground-dwelling, predominantly herbivorous ape that inhabits the forests of central Africa."
	icon_state = "gorilla"
	icon_living = "gorilla"
	icon_dead = "gorilla_dead"
	speak_chance = 80
	maxHealth = 220
	health = 220
	loot = list(/obj/effect/gibspawner/generic)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/gorilla = 4)
	response_help  = "prods"
	response_disarm = "challenges"
	response_harm   = "thumps"
	speed = 1
	melee_damage_lower = 15
	melee_damage_upper = 18
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1.5)
	obj_damage = 20
	environment_smash = 2
	attacktext = "pummels"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("jungle")
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	minbodytemp = 270
	maxbodytemp = 350

// Gorillas like to dismember limbs from unconcious mobs.
// Returns null when the target is not an unconcious carbon mob; a list of limbs (possibly empty) otherwise.
/mob/living/simple_animal/hostile/gorilla/proc/target_bodyparts(atom/the_target)
	var/list/parts = list()
	if(iscarbon(the_target))
		var/mob/living/carbon/C = the_target
		if(C.stat >= UNCONSCIOUS)
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/BP = X
				if(BP.body_part != HEAD && BP.body_part != CHEST)
					if(BP.dismemberable)
						parts += BP
			return parts

/mob/living/simple_animal/hostile/gorilla/AttackingTarget()
	var/list/parts = target_bodyparts(target)
	if(parts != null)
		if(LAZYLEN(parts) == 0)
			return FALSE
		var/obj/item/bodypart/BP = pick(parts)
		BP.dismember()
		return ..()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(prob(80))
			var/atom/throw_target = get_edge_target_turf(L, dir)
			L.throw_at(throw_target, rand(1,2), 7, src) 
		else
			L.Knockdown(20)
			visible_message("<span class='danger'>[src] knocks [L] down!</span>")

/mob/living/simple_animal/hostile/gorilla/CanAttack(atom/the_target)
	. = ..()
	if(. && istype(the_target, /mob/living/carbon/monkey))
		return FALSE
	var/list/parts = target_bodyparts(the_target)
	if(parts != null && LAZYLEN(parts) <= 3) // Don't remove all of their limbs.
		return FALSE

/mob/living/simple_animal/hostile/gorilla/handle_automated_speech(var/override)
	set waitfor = FALSE
	if(speak_chance)
		if(override || (target && prob(speak_chance)))
			playsound(loc, "sound/creatures/gorilla.ogg", 200)
	..()

