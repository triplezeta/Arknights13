/mob/living/basic/heretic_summon/rust_spirit
	name = "Rust Walker"
	real_name = "Rusty"
	desc = "A grinding, clanking construct which leaches life from its surroundings with every armoured step."
	icon_state = "rust_walker_s"
	icon_living = "rust_walker_s"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	speed = 1
	ai_controller = /datum/ai_controller/basic_controller/rust_walker

/mob/living/basic/heretic_summon/rust_spirit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_RUST)
	var/datum/action/cooldown/spell/aoe/rust_conversion/small/conversion = new(src)
	conversion.Grant(src)
	ai_controller?.set_blackboard_key(BB_GENERIC_ACTION, conversion)

	var/datum/action/cooldown/spell/basic_projectile/rust_wave/short/wave = new(src)
	wave.Grant(src)
	ai_controller?.set_blackboard_key(BB_TARGETTED_ACTION, wave)

/mob/living/basic/heretic_summon/rust_spirit/setDir(newdir)
	. = ..()
	if(dir & NORTH)
		icon_state = "rust_walker_n"
	else if(dir & SOUTH)
		icon_state = "rust_walker_s"

/mob/living/basic/heretic_summon/rust_spirit/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(stat == DEAD)
		return ..()

	var/turf/our_turf = get_turf(src)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		adjustBruteLoss(-1.5 * seconds_per_tick, FALSE)
		adjustFireLoss(-1.5 * seconds_per_tick, TRUE)

	return ..()

/// Converts unconverted terrain, sprays pocket sand around
/datum/ai_controller/basic_controller/rust_walker
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/rust
	planning_subtrees = list(
		/datum/ai_planning_subtree/use_mob_ability/rust_walker,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Moves a lot if healthy and on rust (to find more tiles to rust) or unhealthy and not on rust (to find healing rust)
/// Still moving in random directions though we're not really seeking it out
/datum/idle_behavior/idle_random_walk/rust

/datum/idle_behavior/idle_random_walk/rust/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/our_mob = controller.pawn
	var/turf/our_turf = get_turf(our_mob)
	if (HAS_TRAIT(our_turf, TRAIT_RUSTY))
		walk_chance = (our_mob.health < our_mob.maxHealth) ? 10 : 50
	else
		walk_chance = (our_mob.health < our_mob.maxHealth) ? 50 : 10
	return ..()

/// Use if we're not stood on rust right now
/datum/ai_planning_subtree/use_mob_ability/rust_walker

/datum/ai_planning_subtree/use_mob_ability/rust_walker/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/turf/our_turf = get_turf(controller.pawn)
	if (HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return
	return ..()
