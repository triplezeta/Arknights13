// Base chasm, defaults to oblivion but can be overridden
/turf/open/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturfs = /turf/open/chasm
	icon = 'icons/turf/floors/chasms.dmi'
	icon_state = "chasms-255"
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_TURF_CHASM)
	canSmoothWith = list(SMOOTH_GROUP_TURF_CHASM)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	bullet_bounce_sound = null //abandon all hope ye who enter
	var/chasm_path = /datum/component/chasm

/turf/open/chasm/Initialize(mapload)
	. = ..()
	AddComponent(chasm_path, SSmapping.get_turf_below(src))

/// Lets people walk into chasms.
/turf/open/chasm/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	return TRUE

/turf/open/chasm/proc/set_target(turf/target)
	var/datum/component/chasm/chasm_component = GetComponent(/datum/component/chasm)
	chasm_component.target_turf = target

/turf/open/chasm/proc/drop(atom/movable/AM)
	var/datum/component/chasm/chasm_component = GetComponent(/datum/component/chasm)
	chasm_component.drop(AM)

/turf/open/chasm/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/chasm/MakeDry()
	return

/turf/open/chasm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/chasm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a floor."))
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/chasm/rust_heretic_act()
	return FALSE

/turf/open/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return
		if(!R.use(1))
			to_chat(user, span_warning("You need one rod to build a lattice."))
			return
		to_chat(user, span_notice("You construct a lattice."))
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		// Create a lattice, without reverting to our baseturf
		new /obj/structure/lattice(src)
		return
	else if(istype(C, /obj/item/stack/tile/iron))
		build_with_floor_tiles(C, user)

// Chasms for Lavaland, with planetary atmos and lava glow
/turf/open/chasm/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/chasm/lavaland
	light_range = 1.9 //slightly less range than lava
	light_power = 0.65 //less bright, too
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right

// Chasms for Ice moon, with planetary atmos and glow
/turf/open/chasm/icemoon
	icon = 'icons/turf/floors/icechasms.dmi'
	icon_state = "icechasms-255"
	base_icon_state = "icechasms"
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/chasm/icemoon
	light_range = 1.9
	light_power = 0.65
	light_color = LIGHT_COLOR_PURPLE

// The default turf for the Gas Giant. Instead of deleting you when you fall down, instead it kills you with brute and your body is deposited via Fulton at Arrivals.
/turf/open/chasm/gas_giant
	name = "gas giant stratosphere"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_highchance"
	initial_gas_mix = GASGIANT_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/chasm/gas_giant
	light_range = 1.9
	light_power = 0.65
	light_color = LIGHT_COLOR_BROWN
	smoothing_flags = 0
	smoothing_groups = null
	canSmoothWith = null
	chasm_path = /datum/component/chasm/gas_giant
	plane = PLANE_SPACE
	layer = SPACE_LAYER

// Chasms for the jungle, with planetary atmos and a different icon
/turf/open/chasm/jungle
	icon = 'icons/turf/floors/junglechasm.dmi'
	icon_state = "junglechasm-255"
	base_icon_state = "junglechasm"
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	baseturfs = /turf/open/chasm/jungle

/turf/open/chasm/jungle/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "dirt"
	return TRUE
