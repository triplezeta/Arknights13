/obj/effect/decal
	name = "decal"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/decal/Initialize()
	. = ..()
	if(!isturf(loc) || NeverShouldHaveComeHere(loc))
		return INITIALIZE_HINT_QDEL

/obj/effect/decal/proc/NeverShouldHaveComeHere(turf/T)
	return isspaceturf(T) || isclosedturf(T) || islava(T) || istype(T, /turf/open/water) || ischasm(T)

/obj/effect/decal/ex_act(severity, target)
	qdel(src)

/obj/effect/decal/fire_act(exposed_temperature, exposed_volume)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)

/obj/effect/decal/HandleTurfChange(turf/T)
	..()
	if(T == loc && NeverShouldHaveComeHere(T))
		qdel(src)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	layer = TURF_DECAL_LAYER

/obj/effect/turf_decal/Initialize()
	..()
	return INITIALIZE_HINT_QDEL

/obj/effect/turf_decal/ComponentInitialize()
	. = ..()
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")
	T.AddComponent(/datum/component/decal, icon, icon_state, dir)

/obj/effect/turf_decal/weather
	name = "sandy floor"
	icon_state = "sandyfloor"

/obj/effect/turf_decal/weather/snow
	name = "snowy floor"
	icon_state = "snowyfloor"

/obj/effect/turf_decal/weather/snow/corner
	name = "snow corner piece"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow_corner"

/obj/effect/turf_decal/stripes/line
	icon_state = "warningline"

/obj/effect/turf_decal/stripes/end
	icon_state = "warn_end"

/obj/effect/turf_decal/stripes/corner
	icon_state = "warninglinecorner"

/obj/effect/turf_decal/stripes/box
	icon_state = "warn_box"

/obj/effect/turf_decal/stripes/full
	icon_state = "warn_full"

/obj/effect/turf_decal/stripes/asteroid/line
	icon_state = "ast_warn"

/obj/effect/turf_decal/stripes/asteroid/end
	icon_state = "ast_warn_end"

/obj/effect/turf_decal/stripes/asteroid/corner
	icon_state = "ast_warn_corner"

/obj/effect/turf_decal/stripes/asteroid/box
	icon_state = "ast_warn_box"

/obj/effect/turf_decal/stripes/asteroid/full
	icon_state = "ast_warn_full"

/obj/effect/turf_decal/stripes/white/line
	icon_state = "warningline_white"

/obj/effect/turf_decal/stripes/white/end
	icon_state = "warn_end_white"

/obj/effect/turf_decal/stripes/white/corner
	icon_state = "warninglinecorner_white"

/obj/effect/turf_decal/stripes/white/box
	icon_state = "warn_box_white"

/obj/effect/turf_decal/stripes/white/full
	icon_state = "warn_full_white"

/obj/effect/turf_decal/stripes/red/line
	icon_state = "warningline_red"

/obj/effect/turf_decal/stripes/red/end
	icon_state = "warn_end_red"

/obj/effect/turf_decal/stripes/red/corner
	icon_state = "warninglinecorner_red"

/obj/effect/turf_decal/stripes/red/box
	icon_state = "warn_box_red"

/obj/effect/turf_decal/stripes/red/full
	icon_state = "warn_full_red"

/obj/effect/turf_decal/delivery
	icon_state = "delivery"

/obj/effect/turf_decal/delivery/white
	icon_state = "delivery_white"

/obj/effect/turf_decal/delivery/red
	icon_state = "delivery_red"

/obj/effect/turf_decal/bot
	icon_state = "bot"

/obj/effect/turf_decal/bot/right
	icon_state = "bot_right"

/obj/effect/turf_decal/bot/left
	icon_state = "bot_left"

/obj/effect/turf_decal/bot_white
	icon_state = "bot_white"

/obj/effect/turf_decal/bot_white/right
	icon_state = "bot_right_white"

/obj/effect/turf_decal/bot_white/left
	icon_state = "bot_left_white"

/obj/effect/turf_decal/bot_red
	icon_state = "bot_red"

/obj/effect/turf_decal/bot_red/right
	icon_state = "bot_right_red"

/obj/effect/turf_decal/bot_red/left
	icon_state = "bot_left_red"

/obj/effect/turf_decal/loading_area
	icon_state = "loadingarea"

/obj/effect/turf_decal/loading_area/white
	icon_state = "loadingarea_white"

/obj/effect/turf_decal/loading_area/red
	icon_state = "loadingarea_red"

/obj/effect/turf_decal/sand
	icon_state = "sandyfloor"

/obj/effect/turf_decal/sand/plating
	icon_state = "sandyplating"

/obj/effect/turf_decal/plaque
	icon_state = "plaque"

/obj/effect/turf_decal/caution
	icon_state = "caution"

/obj/effect/turf_decal/caution/white
	icon_state = "caution_white"

/obj/effect/turf_decal/caution/red
	icon_state = "caution_red"

/obj/effect/turf_decal/caution/stand_clear
	icon_state = "stand_clear"

/obj/effect/turf_decal/caution/stand_clear/white
	icon_state = "stand_clear_white"

/obj/effect/turf_decal/caution/stand_clear/red
	icon_state = "stand_clear_red"

/obj/effect/turf_decal/arrows
	icon_state = "arrows"

/obj/effect/turf_decal/arrows/white
	icon_state = "arrows_white"

/obj/effect/turf_decal/arrows/red
	icon_state = "arrows_red"

/obj/effect/turf_decal/box
	icon_state = "box"

/obj/effect/turf_decal/box/corners
	icon_state = "box_corners"

/obj/effect/turf_decal/box/white
	icon_state = "box_white"

/obj/effect/turf_decal/box/white/corners
	icon_state = "box_corners_white"

/obj/effect/turf_decal/box/red
	icon_state = "box_red"

/obj/effect/turf_decal/box/red/corners
	icon_state = "box_corners_red"

