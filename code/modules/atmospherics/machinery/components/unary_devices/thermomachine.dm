/obj/machinery/atmospherics/components/unary/thermomachine
	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"
	density = TRUE
	max_integrity = 300
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/min_temperature = 0
	var/max_temperature = 0
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.

/obj/machinery/atmospherics/components/unary/thermomachine/Initialize()
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/thermomachine/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/components/unary/thermomachine/examine(mob/user)
	..()
	if(!panel_open)
		to_chat(user, "<span class='notice'>The panel is <b>screwed</b> in place.</span>")
		return

	if(anchored)
		to_chat(user, "<span class='notice'>It looks <b>bolted</b> to the floor.</span>")
	else
		to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")
		to_chat(user, "<span class='notice'>It looks like it could be <b>bolted</b> down.</span>")

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	var/B
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		B += M.rating
	heat_capacity = 5000 * ((B - 1) ** 2)

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon()
	if(panel_open)
		icon_state = icon_state_open
	else if(on && is_operational())
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/unary/thermomachine/process_atmos()
	..()
	if(!on || !nodes[1])
		return
	var/datum/gas_mixture/air_contents = airs[1]

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = heat_capacity * target_temperature + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

	var/temperature_delta= abs(old_temperature - air_contents.temperature)
	if(temperature_delta > 1)
		active_power_usage = (heat_capacity * temperature_delta) / 10 + idle_power_usage
		update_parents()
	else
		active_power_usage = idle_power_usage
	return 1

/obj/machinery/atmospherics/components/unary/thermomachine/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/thermomachine/proc/disconnect_machine()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

/obj/machinery/atmospherics/components/unary/thermomachine/proc/reconnect_machine()
	atmosinit()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	build_network()

/obj/machinery/atmospherics/components/unary/thermomachine/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER || I.tool_behaviour == TOOL_WRENCH || I.tool_behaviour == TOOL_CROWBAR)
		if(user.a_intent != INTENT_HARM)
			return

	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/screwdriver_act(mob/living/user, obj/item/I)
	if(!anchored || on)
		return

	default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I)

/obj/machinery/atmospherics/components/unary/thermomachine/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return

	for(var/obj/machinery/atmospherics/M in loc)
		if(M != src)
			to_chat(user, "<span class='warning'>There is already a pipe at that location!</span>")
			return

	default_unfasten_wrench(user, I, 50)

/obj/machinery/atmospherics/components/unary/thermomachine/crowbar_act(mob/living/user, obj/item/I)
	default_deconstruction_crowbar(I)


/obj/machinery/atmospherics/components/unary/thermomachine/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	var/unanchoring = anchored
	if(..() != SUCCESSFUL_UNFASTEN)
		return

	if(unanchoring)
		disconnect_machine()
	else
		reconnect_machine()

/obj/machinery/atmospherics/components/unary/thermomachine/AltClick(mob/living/user)
	if(anchored)
		return

	setDir(turn(dir,-90))
	to_chat(user, "<span class='notice'>You rotate [src].</span>")

	SetInitDirections()

/obj/machinery/atmospherics/components/unary/thermomachine/ui_status(mob/user)
	if(interactive)
		return ..()
	return UI_CLOSE

/obj/machinery/atmospherics/components/unary/thermomachine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																	datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "thermomachine", name, 400, 240, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/components/unary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["initial"] = initial(target_temperature)

	var/datum/gas_mixture/air1 = airs[1]
	data["temperature"] = air1.temperature
	data["pressure"] = air1.return_pressure()
	return data

/obj/machinery/atmospherics/components/unary/thermomachine/ui_act(action, params)

	if(..())
		return

	switch(action)
		if("power")
			on = !on
			use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target ([min_temperature]-[max_temperature] K):", name, target_temperature) as num|null
				if(!isnull(target))
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = CLAMP(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)

	update_icon()

/obj/machinery/atmospherics/components/unary/thermomachine/freezer
	name = "freezer"
	icon_state = "freezer"
	icon_state_off = "freezer"
	icon_state_on = "freezer_1"
	icon_state_open = "freezer-o"
	max_temperature = T20C
	min_temperature = 170 //actual minimum temperature is defined by RefreshParts()
	circuit = /obj/item/circuitboard/machine/thermomachine/freezer

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/Initialize()
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/RefreshParts()
	..()
	var/L
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	min_temperature = max(T0C - (initial(min_temperature) + L * 15), TCMB) //73.15K with T1 stock parts

/obj/machinery/atmospherics/components/unary/thermomachine/heater
	name = "heater"
	icon_state = "heater"
	icon_state_off = "heater"
	icon_state_on = "heater_1"
	icon_state_open = "heater-o"
	max_temperature = 140 //actual maximum temperature is defined by RefreshParts()
	min_temperature = T20C
	circuit = /obj/item/circuitboard/machine/thermomachine/heater

/obj/machinery/atmospherics/components/unary/thermomachine/heater/RefreshParts()
	..()
	var/L
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	max_temperature = T20C + (initial(max_temperature) * L) //573.15K with T1 stock parts

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on
	on = TRUE
	icon_state = "freezer_1"

/obj/machinery/atmospherics/components/unary/thermomachine/heater/on
	on = TRUE
	icon_state = "heater_1"