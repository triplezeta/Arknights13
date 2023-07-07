/// Place some grappling tentacles underfoot
/datum/action/cooldown/goliath_tentacles
	name = "Unleash Tentacles"
	desc = "Unleash burrowed tentacles at a targetted location, grappling targets after a delay."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0
	/// Furthest range we can activate ability at
	var/max_range = 7

/datum/action/cooldown/goliath_tentacles/Activate(atom/target)
	target = get_turf(target)
	if (get_dist(owner, target) > max_range)
		return FALSE

	. = ..()
	new /obj/effect/goliath_tentacle(target)
	var/list/directions = GLOB.cardinals.Copy()
	for(var/i in 1 to 3)
		var/spawndir = pick_n_take(directions)
		var/turf/adjacent_target = get_step(target, spawndir)
		if(adjacent_target)
			new /obj/effect/goliath_tentacle(adjacent_target)
	return TRUE

/// Place grappling tentacles around you to grab attackers
/datum/action/cooldown/tentacle_burst
	name = "Tentacle Burst"
	desc = "Unleash burrowed tentacles in an area around you, grappling targets after a delay."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	cooldown_time = 24 SECONDS
	melee_cooldown_time = 0

/datum/action/cooldown/tentacle_burst/Activate(atom/target)
	. = ..()
	var/list/directions = GLOB.alldirs.Copy()
	for (var/dir in directions)
		var/turf/adjacent_target = get_step(target, dir)
		if(adjacent_target)
			new /obj/effect/goliath_tentacle(adjacent_target)
	return TRUE

/// Summon a line of tentacles towards the target
/datum/action/cooldown/tentacle_grasp
	name = "Tentacle Grasp"
	desc = "Unleash burrowed tentacles in a line towards a targetted location, grappling targets after a delay."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0

/datum/action/cooldown/tentacle_grasp/Activate(atom/target)
	. = ..()
	new /obj/effect/temp_visual/effect_trail/burrowed_tentacle(owner.loc, target)
	return TRUE

/// An invisible effect which chases a target, spawning tentacles every so often.
/obj/effect/temp_visual/effect_trail/burrowed_tentacle
	name = "burrowed_tentacle"
	duration = 2 SECONDS
	move_speed = 2
	homing = FALSE
	spawn_interval = 0.1 SECONDS
	spawned_effect = /obj/effect/goliath_tentacle
