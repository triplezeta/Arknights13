var/list/doppler_arrays = list()

/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = 1
	anchored = 1

/obj/machinery/doppler_array/New()
	..()
	doppler_arrays += src

/obj/machinery/doppler_array/Destroy()
	doppler_arrays -= src
	..()

/obj/machinery/doppler_array/process()
	return PROCESS_KILL

/obj/machinery/doppler_array/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			anchored = 1
			power_change()
			user << "<span class='notice'>You fasten [src].</span>"
		else if(anchored)
			anchored = 0
			power_change()
			user << "<span class='notice'>You unfasten [src].</span>"
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)

/obj/machinery/doppler_array/MouseDrop(over,src_loc,over_loc)
	..()
	var/d = get_dir_sane(usr,src_loc,over_loc)
	if(d in cardinal)
		dir = d

/obj/machinery/doppler_array/proc/sense_explosion(var/x0,var/y0,var/z0,var/devastation_range,var/heavy_impact_range,var/light_impact_range,
												  var/took,var/orig_dev_range,var/orig_heavy_range,var/orig_light_range)
	if(stat & NOPOWER)	return
	if(z != z0)			return

	var/dx = abs(x0-x)
	var/dy = abs(y0-y)
	var/distance
	var/direct

	if(dx > dy)
		distance = dx
		if(x0 > x)	direct = EAST
		else		direct = WEST
	else
		distance = dy
		if(y0 > y)	direct = NORTH
		else		direct = SOUTH

	if(distance > 100)		return
	if(!(direct & dir))	return

	var/list/messages = list("Explosive disturbance detected.", \
							 "Epicenter at: grid ([x0],[y0]). Temporal displacement of tachyons: [took] seconds.", \
							 "Factual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say it's theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."

	for(var/message in messages)
		say(message)

/obj/machinery/doppler_array/say_quote(text)
	return "states coldly, \"[text]\""

/obj/machinery/doppler_array/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered() && anchored)
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			icon_state = "[initial(icon_state)]-off"
			stat |= NOPOWER