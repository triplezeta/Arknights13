#define PROB_MOUSE_SPAWN 98
#define PROB_SPIDER_REPLACEMENT 50

SUBSYSTEM_DEF(minor_mapping)
	name = "Minor Mapping"
	init_order = INIT_ORDER_MINOR_MAPPING
	flags = SS_NO_FIRE

/datum/controller/subsystem/minor_mapping/Initialize()
	#ifdef UNIT_TESTS // This whole subsystem just introduces a lot of odd confounding variables into unit test situations, so let's just not bother with doing an initialize here.
	return SS_INIT_NO_NEED
	#else
	trigger_migration(CONFIG_GET(number/mice_roundstart))
	place_satchels(satchel_amount = 2)
	place_selfish_brain()
	return SS_INIT_SUCCESS
	#endif // the mice are easily the bigger problem, but let's just avoid anything that could cause some bullshit.

/// Spawns some critters on exposed wires, usually but not always mice
/datum/controller/subsystem/minor_mapping/proc/trigger_migration(to_spawn=10)
	var/list/exposed_wires = find_exposed_wires()
	var/turf/open/proposed_turf
	while((to_spawn > 0) && exposed_wires.len)
		proposed_turf = pick_n_take(exposed_wires)
		if (!valid_mouse_turf(proposed_turf))
			continue

		to_spawn--
		if(HAS_TRAIT(SSstation, STATION_TRAIT_SPIDER_INFESTATION) && prob(PROB_SPIDER_REPLACEMENT))
			new /mob/living/basic/spider/maintenance(proposed_turf)
			return

		if (prob(PROB_MOUSE_SPAWN))
			new /mob/living/basic/mouse(proposed_turf)
		else
			new /mob/living/basic/regal_rat/controlled(proposed_turf)

/// Returns true if a mouse won't die if spawned on this turf
/datum/controller/subsystem/minor_mapping/proc/valid_mouse_turf(turf/open/proposed_turf)
	if(!istype(proposed_turf))
		return FALSE
	var/datum/gas_mixture/turf/turf_gasmix = proposed_turf.air
	var/turf_temperature = proposed_turf.temperature
	return turf_gasmix.has_gas(/datum/gas/oxygen, 5) && turf_temperature < NPC_DEFAULT_MAX_TEMP && turf_temperature > NPC_DEFAULT_MIN_TEMP

/datum/controller/subsystem/minor_mapping/proc/place_satchels(satchel_amount)
	var/list/turfs = find_satchel_suitable_turfs()
	///List of areas where satchels should not be placed.
	var/list/blacklisted_area_types = list(
		/area/station/holodeck,
		)

	while(turfs.len && satchel_amount > 0)
		var/turf/turf = pick_n_take(turfs)
		if(is_type_in_list(get_area(turf), blacklisted_area_types))
			continue
		var/obj/item/storage/backpack/satchel/flat/flat_satchel = new(turf)

		SEND_SIGNAL(flat_satchel, COMSIG_OBJ_HIDE, turf.underfloor_accessibility)
		satchel_amount--

///Roll for a chance to place a /obj/structure/selfish_brain in maintenance
///If it rolls for one, place one
/datum/controller/subsystem/minor_mapping/proc/place_selfish_brain()
	var/chance_to_spawn_selfish_brain = 100
	//Roll to spawn the selfish brain
	if (!prob(chance_to_spawn_selfish_brain))
		return

	var/list/possible_spawn_locations = find_unblocked_maint_turfs()
	var/turf/open/floor/chosen_turf = pick(possible_spawn_locations)
	new /obj/structure/selfish_brain(chosen_turf)

/proc/find_exposed_wires()
	var/list/exposed_wires = list()

	var/list/all_turfs
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += Z_TURFS(z)
	for(var/turf/open/floor/plating/T in all_turfs)
		if(T.is_blocked_turf())
			continue
		//dont include multiz cables in the list because repairing them sucks
		var/cable = locate(/obj/structure/cable) in T
		if(cable && !istype(cable, /obj/structure/cable/multilayer/multiz))
			exposed_wires += T

	return shuffle(exposed_wires)

/proc/find_satchel_suitable_turfs()
	var/list/suitable = list()

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/detected_turf as anything in Z_TURFS(z))
			if(isfloorturf(detected_turf) && detected_turf.underfloor_accessibility == UNDERFLOOR_HIDDEN)
				suitable += detected_turf

	return shuffle(suitable)

/// Find station maintenance turfs that are not blocked
/proc/find_unblocked_maint_turfs()
	var/list/current_turfs = list()
	var/list/all_turfs = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += Z_TURFS(z)
	for(var/turf/open/floor/this_floor in all_turfs)
		var/area/this_floor_area = get_area(this_floor)
		//We want to spawn the selfish brain in station maintenance
		if (!istype(this_floor_area, /area/station/maintenance))
			continue
		if(this_floor.is_blocked_turf())
			continue
		current_turfs += this_floor

	return current_turfs


#undef PROB_MOUSE_SPAWN
#undef PROB_SPIDER_REPLACEMENT
