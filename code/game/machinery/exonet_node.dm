/obj/machinery/exonet_node
	name = "exonet node"
	desc = null // Gets written in New()
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "exonet_node"
	idle_power_usage = 25
	var/on = TRUE
	var/toggle = 1
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/exonet_node
	max_integrity = 300
	integrity_failure = 100
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)
	desc = "This machine is exonet node."
	var/list/logs = list() // Gets written to by exonet's send_message() function.
	var/opened = FALSE

// Proc: New()
// Parameters: None
// Description: Adds components to the machine for deconstruction.
/*
/obj/machinery/exonet_node/map/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/exonet_node(src)
	component_parts += new /obj/item/stock_parts/subspace/ansible(src)
	component_parts += new /obj/item/stock_parts/subspace/filter(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/subspace/crystal(src)
	component_parts += new /obj/item/stock_parts/subspace/treatment(src)
	component_parts += new /obj/item/stock_parts/subspace/treatment(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)
	RefreshParts()
*/


// Proc: update_icon()
// Parameters: None
// Description: Self explanatory.
/obj/machinery/exonet_node/update_icon()
	if(on)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_off"

// Proc: update_power()
// Parameters: None
// Description: Sets the device on/off and adjusts power draw based on stat and toggle variables.
/obj/machinery/exonet_node/proc/update_power()
	if(toggle)
		if(!is_operational())
			on = FALSE
		else
			on = TRUE
	else
		on = FALSE
	use_power = on
	update_icon()

// Proc: emp_act()
// Parameters: 1 (severity - how strong the EMP is, with lower numbers being stronger)
// Description: Shuts off the machine for awhile if an EMP hits it.  Ion anomalies also call this to turn it off.
/obj/machinery/exonet_node/emp_act(severity)
	if(!(stat & EMPED))
		stat |= EMPED
		var/duration = (300 * 10)/severity
		addtimer(CALLBACK(src, /obj/machinery/exonet_node/proc/unemp_act), rand(duration - 20, duration + 20))
		spawn()
			stat &= ~EMPED
	update_icon()
	..()

/obj/machinery/exonet_node/proc/unemp_act(severity)
	stat &= ~EMPED

// Proc: attackby()
// Parameters: 2 (I - the item being whacked against the machine, user - the person doing the whacking)
// Description: Handles deconstruction.
/obj/machinery/exonet_node/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/screwdriver))
		default_deconstruction_screwdriver(user, I)
	else if(istype(I, /obj/item/crowbar))
		default_deconstruction_crowbar(user, I)
	else
		return ..()

// Proc: attack_ai()
// Parameters: 1 (user - the AI clicking on the machine)
// Description: Redirects to attack_hand()
/obj/machinery/exonet_node/attack_ai(mob/user)
	ui_interact(user)


// Proc: attack_hand()
// Parameters: 1 (user - the person clicking on the machine)
// Description: Opens the NanoUI interface with ui_interact()
/obj/machinery/exonet_node/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/exonet_node/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, var/force_open = 1,datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "exonet_node", name, 600, 300, master_ui, state)
		ui.open()

/obj/machinery/exonet_node/ui_data(mob/user)
	var/list/data = list()
	data["toggle"] = toggle
	data["logs"] = logs
	return data

/obj/machinery/exonet_node/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle_power")
			toggle = !toggle
			update_power()
			if(!toggle)
				var/msg = "[usr.client.key] ([usr]) has turned [src] off, at [x],[y],[z]."
				message_admins(msg)
				log_game(msg)
			. = TRUE
	update_icon()
	add_fingerprint(usr)


// Proc: get_exonet_node()
// Parameters: None
// Description: Helper proc to get a reference to an Exonet node.
/proc/get_exonet_node()
	for(var/obj/machinery/exonet_node/E in GLOB.machines)
		if(E.on)
			return E


/obj/machinery/exonet_node/proc/write_log(var/origin_address, var/target_address, var/data_type, var/content)
	var/msg = "[time2text(world.time, "hh:mm:ss")] | FROM [origin_address] TO [target_address] | TYPE: [data_type] | CONTENT: [content]"
	logs.Add(msg)