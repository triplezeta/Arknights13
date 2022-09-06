#define SOURCE_PORTAL 1
#define DESTINATION_PORTAL 2

/* Teleportation devices.
 * Contains:
 * Locator
 * Hand-tele
 */

/*
 * Locator
 */
/obj/item/locator
	name = "bluespace locator"
	desc = "Used to track portable teleportation beacons and targets with embedded tracking implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/temp = null
	atom_flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=400)
	var/tracking_range = 20

/obj/item/locator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceLocator", name)
		ui.open()

/obj/item/locator/ui_data(mob/user)
	var/list/data = list()

	data["trackingrange"] = tracking_range;

	// Get our current turf location.
	var/turf/sr = get_turf(src)

	if (sr)
		// Check every teleport beacon.
		var/list/tele_beacons = list()
		for(var/obj/item/beacon/W in GLOB.teleportbeacons)

			// Get the tracking beacon's turf location.
			var/turf/tr = get_turf(W)

			// Make sure it's on a turf and that its Z-level matches the tracker's Z-level
			if (tr && tr.z == sr.z)
				// Get the distance between the beacon's turf and our turf
				var/distance = max(abs(tr.x - sr.x), abs(tr.y - sr.y))

				// If the target is too far away, skip over this beacon.
				if(distance > tracking_range)
					continue

				var/beacon_name

				if(W.renamed)
					beacon_name = W.name
				else
					var/area/A = get_area(W)
					beacon_name = A.name

				var/D = dir2text(get_dir(sr, tr))
				tele_beacons += list(list(name = beacon_name, direction = D, distance = distance))

		data["telebeacons"] = tele_beacons

		var/list/track_implants = list()

		for (var/obj/item/implant/tracking/W in GLOB.tracked_implants)
			if (!W.imp_in || !isliving(W.loc))
				continue
			else
				var/mob/living/M = W.loc
				if (M.stat == DEAD)
					if (M.timeofdeath + W.lifespan_postmortem < world.time)
						continue
			var/turf/tr = get_turf(W)
			var/distance = max(abs(tr.x - sr.x), abs(tr.y - sr.y))

			if(distance > tracking_range)
				continue

			var/D = dir2text(get_dir(sr, tr))
			track_implants += list(list(name = W.imp_in.name, direction = D, distance = distance))
		data["trackimplants"] = track_implants
	return data

#define PORTAL_LOCATION_DANGEROUS "portal_location_dangerous"
#define PORTAL_DANGEROUS_EDGE_LIMIT 8

/*
 * Hand-tele
 */
/obj/item/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology. One of the buttons opens a portal, the other re-opens your last destination."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=10000)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/active_portal_pairs
	var/max_portal_pairs = 3

	/**
	 * Represents the last place we teleported to, for making quick portals.
	 * Can be in the following states:
	 * - null, meaning either this hand tele hasn't been used yet, or the last place it was portalled to was removed.
	 * - PORTAL_LOCATION_DANGEROUS, meaning the last place it teleported to was the "None (Dangerous)" location.
	 * - A weakref to a /obj/machinery/computer/teleporter, meaning the last place it teleported to was a pre-setup location.
	*/
	var/last_portal_location

/obj/item/hand_tele/Initialize(mapload)
	. = ..()
	active_portal_pairs = list()

/obj/item/hand_tele/pre_attack(atom/target, mob/user, params)
	if(try_dispel_portal(target, user))
		return TRUE
	return ..()

/obj/item/hand_tele/proc/try_dispel_portal(atom/target, mob/user)
	if(is_parent_of_portal(target))
		qdel(target)
		to_chat(user, span_notice("You dispel [target] with \the [src]!"))
		return TRUE
	return FALSE

/obj/item/hand_tele/afterattack(atom/target, mob/user)
	try_dispel_portal(target, user)
	. = ..()

/obj/item/hand_tele/pre_attack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	var/portal_location = last_portal_location

	if (isweakref(portal_location))
		var/datum/weakref/last_portal_location_ref = last_portal_location
		portal_location = last_portal_location_ref.resolve()

	if (isnull(portal_location))
		to_chat(user, span_warning("[src] flashes briefly. No target is locked in."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	try_create_portal_to(user, portal_location)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/hand_tele/attack_self(mob/user)
	if (!can_teleport_notifies(user))
		return

	var/list/locations = list()
	for(var/obj/machinery/computer/teleporter/computer in GLOB.machines)
		var/atom/target = computer.target_ref?.resolve()
		if(!target)
			computer.target_ref = null
			continue
		var/area/computer_area = get_area(target)
		if(!computer_area || (computer_area.area_flags & NOTELEPORT))
			continue
		if(computer.power_station?.teleporter_hub && computer.power_station.engaged)
			locations["[get_area(target)] (Active)"] = computer
		else
			locations["[get_area(target)] (Inactive)"] = computer

	locations["None (Dangerous)"] = PORTAL_LOCATION_DANGEROUS

	var/teleport_location_key = tgui_input_list(user, "Teleporter to lock on", "Hand Teleporter", sort_list(locations))
	if (isnull(teleport_location_key))
		return
	if(user.get_active_held_item() != src || user.incapacitated())
		return

	// Not always a datum, but needed for IS_WEAKREF_OF to cast properly.
	var/datum/teleport_location = locations[teleport_location_key]
	if (!try_create_portal_to(user, teleport_location))
		return

	if (teleport_location == PORTAL_LOCATION_DANGEROUS)
		last_portal_location = PORTAL_LOCATION_DANGEROUS
	else if (!IS_WEAKREF_OF(teleport_location, last_portal_location))
		if (isweakref(teleport_location))
			var/datum/weakref/about_to_replace_location_ref = last_portal_location
			var/obj/machinery/computer/teleporter/about_to_replace_location = about_to_replace_location_ref.resolve()
			if (about_to_replace_location)
				UnregisterSignal(about_to_replace_location, COMSIG_TELEPORTER_NEW_TARGET)

		RegisterSignal(teleport_location, COMSIG_TELEPORTER_NEW_TARGET, .proc/on_teleporter_new_target)

		last_portal_location = WEAKREF(teleport_location)

/// Takes either PORTAL_LOCATION_DANGEROUS or an /obj/machinery/computer/teleport/computer.
/obj/item/hand_tele/proc/try_create_portal_to(mob/user, teleport_location)
	if (length(active_portal_pairs) >= max_portal_pairs)
		user.show_message(span_notice("[src] is recharging!"))
		return

	var/atom/teleport_target

	if (teleport_location == PORTAL_LOCATION_DANGEROUS)
		var/list/dangerous_turfs = list()
		for(var/turf/dangerous_turf in urange(10, orange=1))
			if(dangerous_turf.x > world.maxx - PORTAL_DANGEROUS_EDGE_LIMIT || dangerous_turf.x < PORTAL_DANGEROUS_EDGE_LIMIT)
				continue //putting them at the edge is dumb
			if(dangerous_turf.y > world.maxy - PORTAL_DANGEROUS_EDGE_LIMIT || dangerous_turf.y < PORTAL_DANGEROUS_EDGE_LIMIT)
				continue
			var/area/dangerous_area = dangerous_turf.loc
			if(dangerous_area.area_flags & NOTELEPORT)
				continue
			dangerous_turfs += dangerous_turf

		teleport_target = pick(dangerous_turfs)
	else
		var/obj/machinery/computer/teleporter/computer = teleport_location
		var/atom/target = computer.target_ref?.resolve()
		if(!target)
			computer.target_ref = null
		teleport_target = target

	if (teleport_target == null)
		to_chat(user, span_notice("[src] vibrates, then stops. Maybe you should try something else."))
		return

	var/area/teleport_area = get_area(teleport_target)
	if (teleport_area.area_flags & NOTELEPORT)
		to_chat(user, span_notice("[src] is malfunctioning."))
		return

	if (!can_teleport_notifies(user))
		return

	var/list/obj/effect/portal/created = create_portal_pair(get_turf(user), get_teleport_turf(get_turf(teleport_target)), 300, 1, null)
	if(LAZYLEN(created) != 2)
		return

	var/obj/effect/portal/portal1 = created[1]
	var/obj/effect/portal/portal2 = created[2]

	RegisterSignal(portal1, COMSIG_PARENT_QDELETING, .proc/on_portal_destroy)
	RegisterSignal(portal2, COMSIG_PARENT_QDELETING, .proc/on_portal_destroy)

	try_move_adjacent(portal1, user.dir)
	active_portal_pairs[portal1] = portal2

	investigate_log("was used by [key_name(user)] at [AREACOORD(user)] to create a portal pair with destinations [AREACOORD(portal1)] and [AREACOORD(portal2)].", INVESTIGATE_PORTAL)
	add_fingerprint(user)

	user.show_message(span_notice("Locked in."), MSG_AUDIBLE)

	return TRUE

/obj/item/hand_tele/proc/can_teleport_notifies(mob/user)
	var/turf/current_location = get_turf(user)
	var/area/current_area = current_location.loc
	if (!current_location || (current_area.area_flags & NOTELEPORT) || is_away_level(current_location.z) || !isturf(user.loc))
		to_chat(user, span_notice("[src] is malfunctioning."))
		return FALSE

	return TRUE

/obj/item/hand_tele/proc/on_teleporter_new_target(datum/source)
	SIGNAL_HANDLER

	if (IS_WEAKREF_OF(source, last_portal_location))
		last_portal_location = null
		UnregisterSignal(source, COMSIG_TELEPORTER_NEW_TARGET)

/obj/item/hand_tele/proc/on_portal_destroy(obj/effect/portal/P)
	SIGNAL_HANDLER

	active_portal_pairs -= P //If this portal pair is made by us it'll be erased along with the other portal by the portal.

/obj/item/hand_tele/proc/is_parent_of_portal(obj/effect/portal/P)
	if(!istype(P))
		return FALSE
	if(active_portal_pairs[P])
		return SOURCE_PORTAL
	for(var/i in active_portal_pairs)
		if(active_portal_pairs[i] == P)
			return DESTINATION_PORTAL
	return FALSE

/obj/item/hand_tele/suicide_act(mob/user)
	if(iscarbon(user))
		user.visible_message(span_suicide("[user] is creating a weak portal and sticking [user.p_their()] head through! It looks like [user.p_theyre()] trying to commit suicide!"))
		var/mob/living/carbon/itemUser = user
		var/obj/item/bodypart/head/head = itemUser.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			head.drop_limb()
			var/list/safeLevels = SSmapping.levels_by_any_trait(list(ZTRAIT_SPACE_RUINS, ZTRAIT_LAVA_RUINS, ZTRAIT_STATION, ZTRAIT_MINING))
			head.forceMove(locate(rand(1, world.maxx), rand(1, world.maxy), pick(safeLevels)))
			itemUser.visible_message(span_suicide("The portal snaps closed taking [user]'s head with it!"))
		else
			itemUser.visible_message(span_suicide("[user] looks even further depressed as they realize they do not have a head...and suddenly dies of shame!"))
		return (BRUTELOSS)

/obj/item/syndicate_teleporter
	name = "experimental teleporter"
	desc = "A reverse-engineered version of the Nanotrasen portable handheld teleporter. Lacks the advanced safety features of its counterpart. A three-headed serpent can be seen on the back."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-tele"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	atom_flags = CONDUCT
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	//Uses of the device left
	var/charges = 4
	//The maximum number of stored uses
	var/max_charges = 4
	///Minimum distance to teleport user forward
	var/minimum_teleport_distance = 4
	///Maximum distance to teleport user forward
	var/maximum_teleport_distance = 8
	//How far the emergency teleport checks for a safe position
	var/parallel_teleport_distance = 3

/obj/item/syndicate_teleporter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/syndicate_teleporter/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/syndicate_teleporter/examine(mob/user)
	. = ..()
	. += span_notice("[src] has <b>[charges]</b> out of [max_charges] charges left.")

/obj/item/syndicate_teleporter/attack_self(mob/user)
	. = ..()
	if(.)
		return
	attempt_teleport(user = user, triggered_by_emp = FALSE)
	return TRUE

/obj/item/syndicate_teleporter/process(delta_time, times_fired)
	if(DT_PROB(10, delta_time) && charges < max_charges)
		charges++
		if(ishuman(loc))
			var/mob/living/carbon/human/holder = loc
			balloon_alert(holder, "teleporter beeps")
		playsound(src, 'sound/machines/twobeep.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

/obj/item/syndicate_teleporter/emp_act(severity)
	if(!prob(50/severity))
		return
	var/teleported_something = FALSE
	if(ishuman(loc))
		var/mob/living/carbon/human/holder = loc
		balloon_alert(holder, "teleporter buzzes!")
		attempt_teleport(user = holder, triggered_by_emp = TRUE)
	else
		var/turf/teleport_turf = get_turf(src)
		for(var/mob/living/mob_on_same_tile in teleport_turf)
			if(!teleported_something)
				teleported_something = TRUE
			attempt_teleport(user = mob_on_same_tile, triggered_by_emp = TRUE, not_holding_tele = TRUE)
		if(!teleported_something)
			visible_message(span_danger("[src] blinks out of existence!"))
			do_sparks(2, 1, src)
			qdel(src)

/**
 * Tries to teleport the user forward based on random number between min/max teleport distance vars.
 * If destination is closed turf, try to save user from gibbing via a panic teleport.
 * Wearing bag of holding or triggering teleport via EMP removes panic teleport, higher chance of being gibbed.
 * Mobs on same tile as destination get telefragged.
 **/
/obj/item/syndicate_teleporter/proc/attempt_teleport(mob/user, triggered_by_emp = FALSE, not_holding_tele = FALSE)
	if(!charges && !triggered_by_emp)
		balloon_alert(user, "recharging!")
		return

	var/turf/current_location = get_turf(user)

	if(malfunctioning(user, current_location))
		if(not_holding_tele)
			return
		balloon_alert(user, "malfunctioning!")
		return

	var/teleport_distance = rand(minimum_teleport_distance, maximum_teleport_distance)
	var/turf/destination = get_teleport_loc(current_location, user, teleport_distance)
	var/bagholdingcheck = FALSE
	if(iscarbon(user))
		var/mob/living/carbon/teleporting_guy = user
		if(locate(/obj/item/storage/backpack/holding) in teleporting_guy.get_all_gear())
			bagholdingcheck = TRUE

	if(isclosedturf(destination))
		if(!triggered_by_emp && !bagholdingcheck)
			panic_teleport(user, destination) //We're in a wall, engage emergency parallel teleport.
		else
			if(bagholdingcheck && !not_holding_tele)
				to_chat(user, span_warning("The bluespace interface on your bag of holding interferes with the teleport!"))
			get_fragged(user, destination, not_holding_tele) //EMP teleported you into a wall? Wearing a BoH? You're dead.
	else
		telefrag(destination, user)
		do_teleport(user, destination, channel = TELEPORT_CHANNEL_FREE)
		charges = max(charges - 1, 0)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(current_location)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
		playsound(current_location, SFX_SPARKS, 50, 1, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(destination, 'sound/effects/phasein.ogg', 25, 1, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(destination, SFX_SPARKS, 50, 1, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/syndicate_teleporter/proc/malfunctioning(mob/guy_teleporting, turf/current_location)
	var/area/current_area = get_area(current_location)
	if(!current_location)
		return TRUE
	if(current_area.area_flags & NOTELEPORT)
		return TRUE
	if(is_away_level(current_location.z))
		return TRUE
	if(is_centcom_level(current_location.z))
		return TRUE
	if(is_reserved_level(current_location.z))
		return TRUE
	if(!isturf(guy_teleporting.loc))
		return TRUE
	return FALSE

/**
 * Checks parallel_teleport_distance amount of tiles parallel to user's teleport destination.
 * If no valid closed turfs found, gib user.
 **/
/obj/item/syndicate_teleporter/proc/panic_teleport(mob/user, turf/destination)
	var/turf/mobloc = get_turf(user)
	var/turf/emergency_destination = get_teleport_loc(destination, user, distance = 0, closed_turf_check = TRUE, errorx = parallel_teleport_distance)

	if(emergency_destination)
		telefrag(emergency_destination, user)
		do_teleport(user, emergency_destination, channel = TELEPORT_CHANNEL_FREE)
		charges = max(charges - 1, 0)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(emergency_destination)
		balloon_alert(user, "emergency teleport triggered!")
		playsound(mobloc, SFX_SPARKS, 50, 1, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(emergency_destination, 'sound/effects/phasein.ogg', 25, 1, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(emergency_destination, SFX_SPARKS, 50, 1, SHORT_RANGE_SOUND_EXTRARANGE)
	else //We tried to save. We failed. Death time.
		get_fragged(user, destination)

///Force move victim to destination, explode destination, drop all victim's items, gib them
/obj/item/syndicate_teleporter/proc/get_fragged(mob/living/victim, turf/destination, not_holding_tele = FALSE)
	var/turf/mobloc = get_turf(victim)
	victim.forceMove(destination)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
	playsound(mobloc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, "sound/magic/disintegrate.ogg", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(!not_holding_tele)
		to_chat(victim, span_userdanger("You teleport into [destination], [src] tries to save you, but..."))
	else
		to_chat(victim, span_userdanger("You teleport into [destination]."))
	destination.ex_act(EXPLODE_HEAVY)
	victim.unequip_everything()
	victim.gib()

///Damage and stun all mobs in fragging_location turf, called after a teleport
/obj/item/syndicate_teleporter/proc/telefrag(turf/fragging_location, mob/user) // Don't let this gib. Never let this gib.
	for(var/mob/living/victim in fragging_location)//Hit everything in the turf
		victim.apply_damage(20, BRUTE)
		victim.Paralyze(6 SECONDS)
		to_chat(victim, span_warning("[user] teleports into you, knocking you to the floor with the bluespace wave!"))

/obj/item/paper/syndicate_teleporter
	name = "Teleporter Guide"
	default_raw_text = {"
		<b>Instructions on your new prototype teleporter:</b><br>
		<br>
		This teleporter will teleport the user 4-8 meters in the direction they are facing.<br>
		<br>
		It has 4 charges, and will recharge over time randomly. No, sticking the teleporter into an APC, microwave, or electrified airlock will not make it charge faster.<br>
		<br>
		<b>Warning:</b> Teleporting into walls will activate a failsafe teleport parallel up to 3 meters, but the user will be ripped apart if it fails to find a safe location.<br>
		<br>
		Do not expose the teleporter to electromagnetic pulses. Unwanted malfunctions may occur.
		"}

/obj/item/storage/box/syndie_kit/syndicate_teleporter
	name = "syndicate teleporter kit"

/obj/item/storage/box/syndie_kit/syndicate_teleporter/PopulateContents()
	new /obj/item/syndicate_teleporter(src)
	new /obj/item/paper/syndicate_teleporter(src)

/obj/effect/temp_visual/teleport_abductor/syndi_teleporter
	duration = 5

#undef PORTAL_LOCATION_DANGEROUS
#undef PORTAL_DANGEROUS_EDGE_LIMIT
