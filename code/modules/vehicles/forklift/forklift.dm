#define HOLOGRAM_FADE_TIME (15 SECONDS)
#define DESTRUCTIVE_SCAN_COOLDOWN (HOLOGRAM_FADE_TIME + 1 SECONDS)
#define FORKLIFT_UPGRADE_SEATING "seating_upgrade"
#define FORKLIFT_UPGRADE_BUILD_2 "build2_upgrade"
#define FORKLIFT_UPGRADE_BUILD_3 "build3_upgrade"
#define FORKLIFT_UPGRADE_STORAGE "storage_upgrade"
#define FORKLIFT_UPGRADE_JETPACK "jetpack_upgrade"
#define FORKLIFT_LIGHT_UPGRADE "light_upgrade"
/**
 * # Forklifts
 */
/obj/vehicle/ridden/forklift
	name = "rapid construction forklift"
	desc = "A forklift for rapidly constructing in an area."
	icon_state = "rat"
	key_type = /obj/item/key/forklift
	movedelay = 1
	///What module is selected for each occupant? Different occupants can have different modules selected.
	var/list/selected_modules = list() // list(mob = module)
	///What forklift modules are available?
	var/list/available_modules = list(
		/datum/forklift_module/furniture,
		/datum/forklift_module/walls,
		/datum/forklift_module/floors,
		/datum/forklift_module/airlocks,
		/datum/forklift_module/shuttle,
	)
	var/starting_module_path = /datum/forklift_module/furniture
	///How many sheets of materials can this hold?
	var/maximum_materials = SHEET_MATERIAL_AMOUNT * 125 // 125 sheets of materials. Ideally 50 iron, 50 glass, 25 of anything else.
	///What construction holograms do we got?
	var/list/holograms = list()
	///How much building can we do at once?
	var/max_simultaneous_build = 1
	///How much deconstructing can we do at once?
	var/max_simultaneous_deconstruct = 1
	///What path do we use for the ridable component? Needed for key overrides.
	var/ridable_path = /datum/component/riding/vehicle/forklift
	///What upgrades have been applied?
	var/list/applied_upgrades = list()
	COOLDOWN_DECLARE(build_cooldown)
	COOLDOWN_DECLARE(destructive_scan_cooldown)
	COOLDOWN_DECLARE(deconstruction_cooldown)

/obj/vehicle/ridden/forklift/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "rat_overlays", ABOVE_MOB_LAYER))
	var/static/list/materials_list = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
		/datum/material/plastic,
		/datum/material/wood,
		)
	AddComponent(/datum/component/material_container, materials_list, maximum_materials, MATCONTAINER_EXAMINE, allowed_items=/obj/item/stack)
	AddElement(/datum/element/ridable, ridable_path)

/obj/vehicle/ridden/forklift/add_occupant(mob/M, control_flags)
	. = ..()
	if(!.)
		return FALSE
	RegisterSignal(M, COMSIG_MOUSE_SCROLL_ON, .proc/on_scroll_wheel)
	RegisterSignal(M, COMSIG_MOB_CLICKON, .proc/on_click)
	RegisterSignal(M, COMSIG_MOB_SAY, .proc/fortnite_check)
	RegisterSignal(M, COMSIG_MOUSE_ENTERED_ON_CHEAP, .proc/on_mouse_entered)
	var/datum/forklift_module/new_module = new starting_module_path
	new_module.my_forklift = src
	selected_modules[M] = new_module

// Officially requested by the headcoder.
/obj/vehicle/ridden/forklift/proc/fortnite_check(mob/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(findtext(message, "fortnite"))
		source.balloon_alert_to_viewers("smited by God for [source.p_their()] crimes!")
		var/mob/living/living_mob = source
		living_mob.gib(TRUE) // no coming back from fortnite

/obj/vehicle/ridden/forklift/remove_occupant(mob/M)
	UnregisterSignal(M, list(COMSIG_MOUSE_SCROLL_ON, COMSIG_MOB_CLICKON, COMSIG_MOUSE_ENTERED_ON_CHEAP, COMSIG_MOB_SAY))
	qdel(selected_modules[M])
	..()

/obj/vehicle/ridden/forklift/key_inserted()
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/ridden/forklift/process(delta_time)
	var/amount_of_building = 0
	var/currently_building = FALSE
	var/amount_of_deconstructing = 0
	var/currently_deconstructing = FALSE
	for(var/hologram in holograms)
		var/obj/structure/building_hologram/found_hologram = hologram
		if(get_dist(src, found_hologram) > 7)
			continue
		if(istype(found_hologram, /obj/structure/building_hologram/deconstruction))
			if(currently_deconstructing)
				continue
			if(found_hologram.building)
				amount_of_deconstructing++
				if(amount_of_deconstructing >= max_simultaneous_deconstruct)
					currently_deconstructing = TRUE
					continue
		else
			if(currently_building)
				continue
			if(found_hologram.building)
				amount_of_building++
				if(amount_of_building >= max_simultaneous_build)
					amount_of_building = TRUE
					continue
		found_hologram.begin_building()
		break

	if(COOLDOWN_FINISHED(src, destructive_scan_cooldown))
		COOLDOWN_START(src, destructive_scan_cooldown, DESTRUCTIVE_SCAN_COOLDOWN)
		rcd_scan(src, play_sound = FALSE)
	..()

/obj/vehicle/ridden/forklift/key_removed()
	STOP_PROCESSING(SSfastprocess, src)

/obj/vehicle/ridden/forklift/proc/on_scroll_wheel(mob/source, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	var/scrolled_up = (delta_y > 0)
	var/datum/forklift_module/current_module = selected_modules[source]
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		var/datum/forklift_module/next_module
		if(scrolled_up)
			next_module = next_list_item(current_module.type, available_modules)
		else
			next_module = previous_list_item(current_module.type, available_modules)
		next_module = new next_module
		next_module.my_forklift = src
		next_module.last_turf_moused_over = current_module.last_turf_moused_over
		LAZYREMOVE(source.client.images, current_module.preview_image)
		qdel(current_module.preview_image)
		next_module.update_preview_icon()
		next_module.preview_image.loc = next_module.last_turf_moused_over
		LAZYOR(source.client.images, next_module.preview_image)
		selected_modules[source] = next_module
		balloon_alert(source, next_module.name)
		qdel(current_module)
	else if(LAZYACCESS(modifiers, CTRL_CLICK))
		current_module.on_ctrl_scrollwheel(source, A, scrolled_up)
	else if(LAZYACCESS(modifiers, ALT_CLICK))
		current_module.on_alt_scrollwheel(source, A, scrolled_up)
	else
		current_module.on_scrollwheel(source, A, scrolled_up)

/obj/vehicle/ridden/forklift/proc/on_click(mob/source, atom/clickingon, list/modifiers)
	SIGNAL_HANDLER
	if(modifiers[ALT_CLICK] || modifiers[SHIFT_CLICK])
		return // Allow removing the keys from the forklift and examining things.
	if(clickingon == src)
		return // Allow the person to unbuckle from the forklift.
	if(!inserted_key)
		balloon_alert(source, "no key!")
		return // No key, can't do shit.
	var/datum/forklift_module/current_module = selected_modules[source]
	if(modifiers[RIGHT_CLICK])
		current_module.on_right_click(source, clickingon)
		return COMSIG_MOB_CANCEL_CLICKON
	else if(modifiers[LEFT_CLICK])
		current_module.on_left_click(source, clickingon)
		return COMSIG_MOB_CANCEL_CLICKON
	else if(modifiers[MIDDLE_CLICK])
		current_module.on_middle_click(source, clickingon)
		return COMSIG_MOB_CANCEL_CLICKON

/obj/vehicle/ridden/forklift/proc/on_mouse_entered(mob/source, atom/A)
	SIGNAL_HANDLER
	var/datum/forklift_module/current_module = selected_modules[source]
	current_module.on_mouse_entered(source, A)

/obj/vehicle/ridden/forklift/attackby(obj/item/possible_upgrade, mob/user, params)
	. = ..()
	if(istype(possible_upgrade, /obj/item/forklift_upgrade))
		var/obj/item/forklift_upgrade/applied_upgrade = possible_upgrade
		if(applied_upgrades.Find(applied_upgrade.upgrade_type))
			user.balloon_alert(user, "already has this upgrade!")
			return
		else
			user.balloon_alert(user, "upgrade applied")
			applied_upgrades.Add(applied_upgrade.upgrade_type)
			switch(applied_upgrade.upgrade_type)
				if(FORKLIFT_LIGHT_UPGRADE)
					available_modules.Add(/datum/forklift_module/lighting)
				if(FORKLIFT_UPGRADE_STORAGE)
					var/datum/component/material_container/forklift_container = GetComponent(/datum/component/material_container)
					forklift_container.max_amount *= 3
				if(FORKLIFT_UPGRADE_SEATING)
					max_drivers = 1 // just making sure
					max_occupants = 3
				if(FORKLIFT_UPGRADE_BUILD_2)
					max_simultaneous_build += 2
					max_simultaneous_deconstruct += 2
				if(FORKLIFT_UPGRADE_BUILD_3)
					max_simultaneous_build += 3
					max_simultaneous_deconstruct += 3
			qdel(applied_upgrade)

/obj/vehicle/ridden/forklift/engineering
	name = "engineering forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Days since supermatter incident: 0\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/furniture,
		/datum/forklift_module/walls,
		/datum/forklift_module/floors,
		/datum/forklift_module/airlocks,
		/datum/forklift_module/shuttle,
		/datum/forklift_module/department_machinery/engineering,
		// /datum/forklift_module/atmos,
	)
	icon = 'icons/obj/vehicles_large.dmi'
	pixel_x = -16
	pixel_y = -16
	starting_module_path = /datum/forklift_module/furniture
	key_type = /obj/item/key/forklift/engineering
	ridable_path = /datum/component/riding/vehicle/forklift/engineering

/obj/vehicle/ridden/forklift/medical
	name = "medical forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Clean hands save lives!\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/plumbing,
		/datum/forklift_module/department_machinery/medical,
	)
	starting_module_path = /datum/forklift_module/plumbing
	key_type = /obj/item/key/forklift/medbay
	ridable_path = /datum/component/riding/vehicle/forklift/medical

/obj/vehicle/ridden/forklift/science
	name = "science forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Have you read your SICP today?\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/plumbing,
		// /datum/forklift_module/atmos,
		/datum/forklift_module/department_machinery/science,
	)
	starting_module_path = /datum/forklift_module/plumbing
	key_type = /obj/item/key/forklift/science
	ridable_path = /datum/component/riding/vehicle/forklift/science

/obj/vehicle/ridden/forklift/security
	name = "security forklift"
	desc = "A forklift for rapidly constructing in an area. It's lifted, and there's a pair of truck nuts dangling from the hitch on the back."
	available_modules = list(
		/datum/forklift_module/department_machinery/security,
	)
	starting_module_path = /datum/forklift_module/department_machinery/security
	key_type = /obj/item/key/forklift/security
	ridable_path = /datum/component/riding/vehicle/forklift/security

/obj/vehicle/ridden/forklift/service
	name = "service forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"How's my driving? PDA the HoP!\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/department_machinery/service,
	)
	starting_module_path = /datum/forklift_module/department_machinery/service
	key_type = /obj/item/key/forklift/service
	ridable_path = /datum/component/riding/vehicle/forklift/service

/obj/vehicle/ridden/forklift/cargo
	name = "cargo forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Every worker a member of the board!\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/department_machinery/cargo,
	)
	starting_module_path = /datum/forklift_module/department_machinery/cargo
	key_type = /obj/item/key/forklift/cargo
	ridable_path = /datum/component/riding/vehicle/forklift/cargo
