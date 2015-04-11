// the underfloor wiring terminal for the APC
// autogenerated when an APC is placed
// all conduit connects go to this object instead of the APC
// using this solves the problem of having the APC in a wall yet also inside an area

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	layer = TURF_LAYER
	var/obj/machinery/power/master = null
	anchored = 1
	layer = 2.6 // a bit above wires


/obj/machinery/power/terminal/New()
	..()
	var/turf/T = src.loc
	if(level==1) hide(T.intact)
	return

/obj/machinery/power/terminal/Destroy()
	if(master)
		master.disconnect_terminal()
	return ..()

/obj/machinery/power/terminal/hide(var/i)
	if(i)
		invisibility = 101
		icon_state = "term-f"
	else
		invisibility = 0
		icon_state = "term"


/obj/machinery/power/proc/can_terminal_dismantle()
	. = 0

/obj/machinery/power/apc/can_terminal_dismantle()
	. = 0
	if(opened && has_electronics != 2)
		. = 1

/obj/machinery/power/smes/can_terminal_dismantle()
	. = 0
	if(panel_open)
		. = 1


/obj/machinery/power/terminal/proc/dismantle(var/mob/living/user)
	if(istype(loc, /turf/simulated))
		var/turf/simulated/T = loc
		if(T.intact)
			user << "<span class='alert'>You must first expose the power terminal!</span>"
			return

		if(master && master.can_terminal_dismantle())
			user.visible_message("<span class='warning'>[user.name] dismantles the power terminal from [master].</span>", \
								"<span class='notice'>You begin to cut the cables...</span>")

			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if(do_after(user, 50))
				if(master && master.can_terminal_dismantle())
					if(prob(50) && electrocute_mob(user, powernet, src))
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(5, 1, master)
						s.start()
						return
					new /obj/item/stack/cable_coil(loc, 10)
					user << "<span class='notice'>You cut the cables and dismantle the power terminal.</span>"
					qdel(src)


/obj/machinery/power/terminal/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/weapon/wirecutters))
		dismantle(user)
		return

	..()
