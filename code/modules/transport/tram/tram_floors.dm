/turf/open/floor/noslip/tram
	name = "high-traction platform"
	icon_state = "noslip_tram"
	base_icon_state = "noslip_tram"
	floor_tile = /obj/item/stack/tile/noslip/tram

/turf/open/floor/noslip/tram_plate
	name = "linear induction plate"
	desc = "The linear induction plate that powers the tram."
	icon_state = "tram_plate"
	base_icon_state = "tram_plate"
	floor_tile = /obj/item/stack/tile/noslip/tram_plate
	slowdown = 0
	flags_1 = NONE

/turf/open/floor/noslip/tram_plate/energized
	desc = "The linear induction plate that powers the tram. It is currently energized."
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound
	/// Transport ID of the tram
	var/specific_transport_id = TRAMSTATION_LINE_1

/turf/open/floor/noslip/tram_platform
	name = "tram platform"
	icon_state = "tram_platform"
	base_icon_state = "tram_platform"
	floor_tile = /obj/item/stack/tile/noslip/tram_platform
	slowdown = 0

/turf/open/floor/noslip/tram_plate/broken_states()
	return list("tram_plate-damaged1","tram_plate-damaged2")

/turf/open/floor/noslip/tram_plate/burnt_states()
	return list("tram_plate-scorched1","tram_plate-scorched2")

/turf/open/floor/noslip/tram_plate/energized/broken_states()
	return list("energized_plate_damaged")

/turf/open/floor/noslip/tram_plate/energized/burnt_states()
	return list("energized_plate_damaged")

/turf/open/floor/noslip/tram_platform/broken_states()
	return list("tram_platform-damaged1","tram_platform-damaged2")

/turf/open/floor/noslip/tram_platform/burnt_states()
	return list("tram_platform-scorched1","tram_platform-scorched2")

/turf/open/floor/noslip/tram_plate/energized/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/energized, inbound, outbound, specific_transport_id)

/turf/open/floor/noslip/attackby(obj/item/object, mob/living/user, params)
	. = ..()
	if(istype(object, /obj/item/stack/thermoplastic))
		build_with_transport_tiles(object, user)
	else if(istype(object, /obj/item/stack/sheet/mineral/titanium))
		build_with_titanium(object, user)

/turf/open/floor/noslip/tram_plate/energized/proc/bad_omen(mob/living/unlucky)
	return

/turf/open/floor/glass/reinforced/tram/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

/turf/open/floor/glass/reinforced/tram
	name = "tram bridge"
	desc = "It shakes a bit when you step, but lets you cross between sides quickly!"

/obj/structure/thermoplastic
	name = "tram"
	desc = "A lightweight thermoplastic flooring."
	icon = 'icons/turf/floors.dmi'
	icon_state = "tram_dark"
	density = FALSE
	anchored = TRUE
	max_integrity = 150
	integrity_failure = 0.75
	armor_type = /datum/armor/tram_floor
	layer = TRAM_FLOOR_LAYER
	plane = FLOOR_PLANE
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_OUT_UP
	appearance_flags = PIXEL_SCALE|KEEP_TOGETHER
	var/secured = TRUE
	var/floor_tile = /obj/item/stack/thermoplastic
	var/damaged_icon_state = "honk"

/datum/armor/tram_floor
	melee = 40
	bullet = 10
	laser = 10
	bomb = 45
	fire = 90
	acid = 100

/obj/structure/thermoplastic/light
	icon_state = "tram_light"
	floor_tile = /obj/item/stack/thermoplastic/light

/obj/structure/thermoplastic/examine(mob/user)
	. = ..()

	if(secured)
		. += span_notice("It is secured with a set of [EXAMINE_HINT("screws.")]")
	else
		. += span_notice("You can [EXAMINE_HINT("crowbar")] to remove the tile.")
		. += span_notice("It can be re-secured using a [EXAMINE_HINT("screwdriver.")]")

/obj/structure/thermoplastic/atom_break()
	. = ..()
	icon_state = damaged_icon_state
	update_appearance()

/obj/structure/thermoplastic/atom_fix()
	. = ..()
	icon_state = initial(icon_state)
	update_appearance()

/obj/structure/thermoplastic/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(secured)
		user.visible_message(span_notice("[user] begins to unscrew the tile..."),
		span_notice("You begin to unscrew the tile..."))
		if(tool.use_tool(src, user, 1 SECONDS, volume = 50))
			secured = FALSE
			to_chat(user, span_notice("The screws come out, and a gap forms around the edge of the tile."))
	else
		user.visible_message(span_notice("[user] begins to fasten the tile..."),
		span_notice("You begin to fasten the tile..."))
		if(tool.use_tool(src, user, 1 SECONDS, volume = 50))
			secured = TRUE
			to_chat(user, span_notice("The tile is securely screwed in place."))

	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/thermoplastic/crowbar_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(secured)
		to_chat(user, span_warning("The security screws need to be removed first!"))
		return FALSE

	else
		user.visible_message(span_notice("[user] wedges \the [tool] into the tile's gap in the edge and starts prying..."),
		span_notice("You wedge \the [tool] into the tram panel's gap in the frame and start prying..."))
		if(tool.use_tool(src, user, 1 SECONDS, volume = 50))
			to_chat(user, span_notice("The panel pops out of the frame."))
			var/obj/item/stack/thermoplastic/pulled_tile = new()
			pulled_tile.update_integrity(atom_integrity)
			user.put_in_hands(pulled_tile)
			qdel(src)

	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/thermoplastic/welder_act(mob/living/user, obj/item/tool)
	if(atom_integrity >= max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!tool.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, span_notice("You begin repairing [src]..."))
	var/integrity_to_repair = max_integrity - atom_integrity
	if(tool.use_tool(src, user, integrity_to_repair * 0.5, volume = 50))
		atom_integrity = max_integrity
		to_chat(user, span_notice("You repair [src]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/stack/thermoplastic
	name = "thermoplastic tram tile"
	singular_name = "thermoplastic tram tile"
	desc = "A high-traction floor tile. It sparkles in the light."
	icon = 'icons/obj/tiles.dmi'
	lefthand_file = 'icons/mob/inhands/items/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/tiles_righthand.dmi'
	icon_state = "tile_textured_white_large"
	inhand_icon_state = "tile-tile_textured_white_large"
	color = COLOR_TRAM_BLUE
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	novariants = TRUE
	merge_type = /obj/item/stack/thermoplastic
	var/tile_type = /obj/structure/thermoplastic
	/// Cached associative lazy list to hold the radial options for tile reskinning. See tile_reskinning.dm for more information. Pattern: list[type] -> image
	var/list/tile_reskin_types = list(
		/obj/item/stack/thermoplastic/light,
	)

/obj/item/stack/thermoplastic/light
	color = COLOR_TRAM_LIGHT_BLUE
	tile_type = /obj/structure/thermoplastic/light

/obj/item/stack/thermoplastic/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little
	//if(tile_reskin_types)
	//	tile_reskin_types = tile_reskin_list(tile_reskin_types)

/obj/item/stack/thermoplastic/examine(mob/user)
	. = ..()
	if(throwforce && !is_cyborg) //do not want to divide by zero or show the message to borgs who can't throw
		var/damage_value
		switch(CEILING(MAX_LIVING_HEALTH / throwforce, 1)) //throws to crit a human
			if(1 to 3)
				damage_value = "superb"
			if(4 to 6)
				damage_value = "great"
			if(7 to 9)
				damage_value = "good"
			if(10 to 12)
				damage_value = "fairly decent"
			if(13 to 15)
				damage_value = "mediocre"
		if(!damage_value)
			return
		. += span_notice("Those could work as a [damage_value] throwing weapon.")
