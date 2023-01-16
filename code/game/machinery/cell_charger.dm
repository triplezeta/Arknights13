/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger"
	power_channel = AREA_USAGE_EQUIP
	circuit = /obj/item/circuitboard/machine/cell_charger
	pass_flags = PASSTABLE
	var/obj/item/stock_parts/cell/charging = null
	var/charge_rate = 250

/obj/machinery/cell_charger/update_overlays()
	. = ..()

	if(!charging)
		return

	if(!(machine_stat & (BROKEN|NOPOWER)))
		var/newlevel = round(charging.percent() * 4 / 100)
		. += "ccharger-o[newlevel]"
	. += image(charging.icon, charging.icon_state)
	if(charging.grown_battery)
		. += mutable_appearance('icons/obj/power.dmi', "grown_wires")
	. += "ccharger-[charging.connector_type]-on"
	if((charging.charge > 0.01) && charging.charge_light_type)
		. += mutable_appearance('icons/obj/power.dmi', "cell-[charging.charge_light_type]-o[(charging.percent() >= 99.5) ? 2 : 1]")

/obj/machinery/cell_charger/examine(mob/user)
	. = ..()
	. += "There's [charging ? "\a [charging]" : "no cell"] in the charger."
	if(charging)
		. += "Current charge: [round(charging.percent(), 1)]%."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Charging power: <b>[charge_rate]W</b>.")

/obj/machinery/cell_charger/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(charging)
		return FALSE
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/cell_charger/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell) && !panel_open)
		if(machine_stat & BROKEN)
			to_chat(user, span_warning("[src] is broken!"))
			return
		if(!anchored)
			to_chat(user, span_warning("[src] isn't attached to the ground!"))
			return
		if(charging)
			to_chat(user, span_warning("There is already a cell in the charger!"))
			return
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, span_warning("[src] blinks red as you try to insert the cell!"))
				return
			if(!user.transferItemToLoc(W,src))
				return

			charging = W
			user.visible_message(span_notice("[user] inserts a cell into [src]."), span_notice("You insert a cell into [src]."))
			update_appearance()
	else
		if(!charging && default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			return
		if(default_deconstruction_crowbar(W))
			return
		return ..()

/obj/machinery/cell_charger/deconstruct()
	if(charging)
		charging.forceMove(drop_location())
	return ..()

/obj/machinery/cell_charger/Destroy()
	QDEL_NULL(charging)
	return ..()

/obj/machinery/cell_charger/proc/removecell()
	charging.update_appearance()
	charging = null
	update_appearance()

/obj/machinery/cell_charger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message(span_notice("[user] removes [charging] from [src]."), span_notice("You remove [charging] from [src]."))

	removecell()


/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!charging)
		return

	charging.forceMove(loc)
	to_chat(user, span_notice("You telekinetically remove [charging] from [src]."))

	removecell()
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_CONTENTS)
		return

	if(charging)
		charging.emp_act(severity)

/obj/machinery/cell_charger/RefreshParts()
	. = ..()
	charge_rate = 250
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		charge_rate *= capacitor.tier

/obj/machinery/cell_charger/process(delta_time)
	if(!charging || !anchored || (machine_stat & (BROKEN|NOPOWER)))
		return

	if(charging.percent() >= 100)
		return

	var/main_draw = use_power_from_net(charge_rate * delta_time, take_any = TRUE) //Pulls directly from the Powernet to dump into the cell
	if(!main_draw)
		return
	charging.give(main_draw)
	use_power(charge_rate / 100) //use a small bit for the charger itself, but power usage scales up with the part tier

	update_appearance()
