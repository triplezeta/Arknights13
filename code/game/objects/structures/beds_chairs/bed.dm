/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * Beds
 * Medical beds
 * Roller beds
 * Pet beds
 */

/// Beds

/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	icon = 'icons/obj/bed.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	/// What material this bed is made of
	var/build_stack_type = /obj/item/stack/sheet/iron
	/// How many mats to drop when deconstructed
	var/build_stack_amount = 2
	/// If someone's buckled to it
	var/occupied = FALSE

/obj/structure/bed/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/soft_landing)
	register_context()

/obj/structure/bed/examine(mob/user)
	. = ..()
	if(!(flags_1 & NODECONSTRUCT_1))
		. += span_notice("It's held together by a couple of <b>bolts</b>.")

/obj/structure/bed/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(held_item)
		if(held_item.tool_behaviour != TOOL_WRENCH || flags_1 & NODECONSTRUCT_1)
			return

		context[SCREENTIP_CONTEXT_RMB] = "Dismantle"
		return CONTEXTUAL_SCREENTIP_SET

	else if(occupied)
		context[SCREENTIP_CONTEXT_LMB] = "Unbuckle"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(build_stack_type)
			new build_stack_type(loc, build_stack_amount)
	..()

/obj/structure/bed/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/bed/wrench_act_secondary(mob/living/user, obj/item/weapon)
	if(flags_1 & NODECONSTRUCT_1)
		return TRUE

	..()
	weapon.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return TRUE

/obj/structure/bed/post_buckle_mob(mob/living/buckled_mob)
	occupied = TRUE

/obj/structure/bed/post_unbuckle_mob(mob/living/unbuckled_mob)
	occupied = FALSE

/// Medical beds

/obj/structure/bed/medical
	name = "medical bed"
	icon = 'icons/obj/medical/medical_bed.dmi'
	desc = "A medical bed with wheels for assisted patient movement or medbay racing tournaments."
	icon_state = "med_down"
	base_icon_state = "med"
	anchored = FALSE
	resistance_flags = NONE
	build_stack_type = /obj/item/stack/sheet/mineral/titanium
	build_stack_amount = 1
	/// The item it spawns when it's folded up.
	var/foldable_type

/obj/structure/bed/medical/anchored
	anchored = TRUE

/obj/structure/bed/medical/emergency
	name = "emergency medical bed"
	desc = "A compact medical bed. This emergency version can be folded and carried for quick transport."
	icon_state = "emerg_down"
	base_icon_state = "emerg"
	foldable_type = /obj/item/emergency_bed

/obj/structure/bed/medical/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noisy_movement)

/obj/structure/bed/medical/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	context[SCREENTIP_CONTEXT_ALT_LMB] = "[anchored ? "Release brakes" : "Apply brakes"]"
	if(!isnull(foldable_type) && !buckled)
		context[SCREENTIP_CONTEXT_RMB] = "Fold up"

	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/bed/medical/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("The brakes are applied. They can be released with an Alt-click.")
	else
		. += span_notice("The brakes can be applied with an Alt-click.")

	if(!isnull(foldable_type))
		. += span_notice("You can fold it up with a Right-click.")

/obj/structure/bed/medical/AltClick(mob/user)
	. = ..()
	anchored = !anchored
	balloon_alert(user, "brakes [anchored ? "applied" : "released"]")
	update_appearance()

/obj/structure/bed/medical/post_buckle_mob(mob/living/patient)
	set_density(TRUE)
	occupied = TRUE
	icon_state = "[base_icon_state]_up"
	// Push them up from the normal lying position
	patient.pixel_y = patient.base_pixel_y
	update_appearance()

/obj/structure/bed/medical/post_unbuckle_mob(mob/living/patient)
	set_density(FALSE)
	occupied = FALSE
	icon_state = "[base_icon_state]_down"
	// Set them back down to the normal lying position
	patient.pixel_y = patient.base_pixel_y + patient.body_position_pixel_y_offset
	update_appearance()

/obj/structure/bed/medical/update_overlays()
	. = ..()
	if(!anchored)
		return

	switch(occupied)
		if(TRUE)
			. += mutable_appearance(icon, "brakes_up")
			. += emissive_appearance(icon, "brakes_up", src, alpha = src.alpha)
		if(FALSE)
			. += mutable_appearance(icon, "brakes_down")
			. += emissive_appearance(icon, "brakes_down", src, alpha = src.alpha)

/obj/structure/bed/medical/emergency/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/emergency_bed/silicon))
		var/obj/item/emergency_bed/silicon/silicon_bed = item
		if(silicon_bed.loaded)
			to_chat(user, span_warning("You already have a medical bed docked!"))
			return

		if(has_buckled_mobs())
			if(buckled_mobs.len > 1)
				unbuckle_all_mobs()
				user.visible_message(span_notice("[user] unbuckles all creatures from [src]."))
			else
				user_unbuckle_mob(buckled_mobs[1],user)
		else
			silicon_bed.loaded = src
			forceMove(silicon_bed)
			user.visible_message(span_notice("[user] collects [src]."), span_notice("You collect [src]."))
		return TRUE
	else
		return ..()

/obj/structure/bed/medical/emergency/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!ishuman(user) || !user.can_perform_action(src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(has_buckled_mobs())
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	user.visible_message(span_notice("[user] collapses [src]."), span_notice("You collapse [src]."))
	var/obj/structure/bed/medical/emergency/folding_bed = new foldable_type(get_turf(src))
	user.put_in_hands(folding_bed)
	qdel(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/emergency_bed
	name = "roller bed"
	desc = "A collapsed medical bed that can be carried around."
	icon = 'icons/obj/medical/medical_bed.dmi'
	icon_state = "emerg_folded"
	inhand_icon_state = "emergencybed"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL // No more excuses, stop getting blood everywhere

/obj/item/emergency_bed/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/emergency_bed/silicon))
		var/obj/item/emergency_bed/silicon/silicon_bed = item
		if(silicon_bed.loaded)
			to_chat(user, span_warning("[silicon_bed] already has a roller bed loaded!"))
			return

		user.visible_message(span_notice("[user] loads [src]."), span_notice("You load [src] into [silicon_bed]."))
		silicon_bed.loaded = new/obj/structure/bed/medical/emergency(silicon_bed)
		qdel(src) //"Load"
		return

	else
		return ..()

/obj/item/emergency_bed/attack_self(mob/user)
	deploy_bed(user, user.loc)

/obj/item/emergency_bed/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(isopenturf(target))
		deploy_bed(user, target)

/obj/item/emergency_bed/proc/deploy_bed(mob/user, atom/location)
	var/obj/structure/bed/medical/emergency/deployed = new /obj/structure/bed/medical/emergency(location)
	deployed.add_fingerprint(user)
	qdel(src)

/obj/item/emergency_bed/silicon // ROLLER ROBO DA!
	name = "emergency bed dock"
	desc = "A collapsed medical bed that can be ejected for emergency use. Must be collected or replaced after use."
	var/obj/structure/bed/medical/emergency/loaded = null

/obj/item/emergency_bed/silicon/Initialize(mapload)
	. = ..()
	loaded = new(src)

/obj/item/emergency_bed/silicon/examine(mob/user)
	. = ..()
	. += "The dock is [loaded ? "loaded" : "empty"]."

/obj/item/emergency_bed/silicon/deploy_bed(mob/user, atom/location)
	if(loaded)
		loaded.forceMove(location)
		user.visible_message(span_notice("[user] deploys [loaded]."), span_notice("You deploy [loaded]."))
		loaded = null
	else
		to_chat(user, span_warning("The dock is empty!"))

/// Dog bed

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, in case the gravity turns off."
	anchored = FALSE
	build_stack_type = /obj/item/stack/sheet/mineral/wood
	build_stack_amount = 10
	var/owned = FALSE

/obj/structure/bed/dogbed/ian
	desc = "Ian's bed! Looks comfy."
	name = "Ian's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/cayenne
	desc = "Seems kind of... fishy."
	name = "Cayenne's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/lia
	desc = "Seems kind of... fishy."
	name = "Lia's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/mcgriff
	desc = "McGriff's bed, because even crimefighters sometimes need a nap."
	name = "McGriff's bed"

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

///Used to set the owner of a dogbed, returns FALSE if called on an owned bed or an invalid one, TRUE if the possesion succeeds
/obj/structure/bed/dogbed/proc/update_owner(mob/living/furball)
	if(owned || type != /obj/structure/bed/dogbed) //Only marked beds work, this is hacky but I'm a hacky man
		return FALSE //Failed

	owned = TRUE
	name = "[furball]'s bed"
	desc = "[furball]'s bed! Looks comfy."
	return TRUE // Let any callers know that this bed is ours now

/obj/structure/bed/dogbed/buckle_mob(mob/living/furball, force, check_loc)
	. = ..()
	update_owner(furball)

/obj/structure/bed/maint
	name = "dirty mattress"
	desc = "An old grubby mattress. You try to not think about what could be the cause of those stains."
	icon_state = "dirty_mattress"

/obj/structure/bed/maint/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 25)

// Double Beds, for luxurious sleeping, i.e. the captain and maybe heads- if people use this for ERP, send them to skyrat
/obj/structure/bed/double
	name = "double bed"
	desc = "A luxurious double bed, for those too important for small dreams."
	icon_state = "bed_double"
	build_stack_amount = 4
	max_buckled_mobs = 2
	/// The mob who buckled to this bed second, to avoid other mobs getting pixel-shifted before he unbuckles.
	var/mob/living/goldilocks

/obj/structure/bed/double/post_buckle_mob(mob/living/target)
	if(buckled_mobs.len > 1 && !goldilocks) // Push the second buckled mob a bit higher from the normal lying position
		target.pixel_y = target.base_pixel_y + 6
		goldilocks = target

/obj/structure/bed/double/post_unbuckle_mob(mob/living/target)
	target.pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset
	if(target == goldilocks)
		goldilocks = null
