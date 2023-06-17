// the underfloor wiring terminal for the APC
// autogenerated when an APC is placed
// all conduit connects go to this object instead of the APC
// using this solves the problem of having the APC in a wall yet also inside an area

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal, used to draw power from the grid."
	layer = WIRE_TERMINAL_LAYER //a bit above wires
	var/obj/machinery/power/master = null


/obj/machinery/power/terminal/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, use_alpha = TRUE)

/obj/machinery/power/terminal/Destroy()
	if(master)
		master.disconnect_terminal()
		master = null
	return ..()

/obj/machinery/power/terminal/examine(mob/user)
	. = ..()
	if(!QDELETED(powernet))
			. += span_notice("It's [QDELETED(powernet) "disconnected from" : "operating on"] the [lowertext(GLOB.cable_layer_to_name["[cable_layer]"])].")
		else
			. += span_warning("It's disconnected from the [lowertext(GLOB.cable_layer_to_name["[cable_layer]"]))

/obj/machinery/power/terminal/should_have_node()
	return TRUE

/obj/machinery/power/proc/can_terminal_dismantle()
	. = FALSE

/obj/machinery/power/apc/can_terminal_dismantle()
	. = FALSE
	if(opened)
		. = TRUE

/obj/machinery/power/smes/can_terminal_dismantle()
	. = FALSE
	if(panel_open)
		. = TRUE

/obj/machinery/power/terminal/proc/dismantle(mob/living/user, obj/item/I)
	if(isturf(loc))
		var/turf/T = loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			balloon_alert(user, "must expose the cable terminal!")
			return

	if(master && !master.can_terminal_dismantle())
		return

	user.visible_message(span_notice("[user.name] dismantles the cable terminal from [master]."))
	balloon_alert(user, "cutting the cables...")

	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	if(I.use_tool(src, user, 50))
		if(master && !master.can_terminal_dismantle())
			return

		if(prob(50) && electrocute_mob(user, powernet, src, 1, TRUE))
			do_sparks(5, TRUE, master)
			return

		var/obj/item/stack/cable_coil/cable = new (drop_location(), 10)
		qdel(src)
		cable.balloon_alert(user, "cable terminal dismantled")

/obj/machinery/power/terminal/wirecutter_act(mob/living/user, obj/item/I)
	..()
	dismantle(user, I)
	return TRUE
