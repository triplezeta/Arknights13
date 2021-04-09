/// Slippery component, for making anything slippery. Of course.
/datum/component/slippery
	/// If the slip forces you to drop held items.
	var/force_drop_items = FALSE
	/// How long the slip keeps you knocked down.
	var/knockdown_time = 0
	/// How long the slip paralyzes for.
	var/paralyze_time = 0
	/// Flags for how slippery the parent is. See [__DEFINES/mobs.dm]
	var/lube_flags
	/// A proc callback to call on slip.
	var/datum/callback/callback
	/// If parent is an item, this is the person currently holding/wearing the parent (or the parent if no one is holding it)
	var/mob/living/holder
	/// Whitelist of item slots the parent can be equipped in that make the holder slippery. If null or empty, it will always make the holder slippery.
	var/list/slot_whitelist
	///what we give to connect_loc by default, makes slippable mobs moving over us slip
	var/static/list/default_connections = list(
			COMSIG_MOVABLE_CROSSED = .proc/Slip,
		)

	///what we give to connect_loc if we're an item and get equipped by a mob. makes slippable mobs moving over our holder slip
	var/static/list/holder_connections = list(
			COMSIG_MOVABLE_CROSSED = .proc/Slip_on_wearer,
		)

/datum/component/slippery/Initialize(knockdown, lube_flags = NONE, datum/callback/callback, paralyze, force_drop = FALSE, slot_whitelist)
	src.knockdown_time = max(knockdown, 0)
	src.paralyze_time = max(paralyze, 0)
	src.force_drop_items = force_drop
	src.lube_flags = lube_flags
	src.callback = callback
	src.slot_whitelist = slot_whitelist

	parent.AddElement(/datum/element/connect_loc, default_connections)
	//TODOKYLER: all removes of connect_loc NEED the arguments creating it specified!
	if(isitem(parent))
		holder = parent
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/Slip)

/*
 * The proc that does the sliping. Invokes the slip callback we have set.
 *
 * source - the source of the signal
 * AM - the atom/movable that is being slipped.
 */
/datum/component/slippery/proc/Slip(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/mob/victim = AM
	if(istype(victim) && !(victim.movement_type & FLYING) && victim.slip(knockdown_time, parent, lube_flags, paralyze_time, force_drop_items) && callback)
		callback.Invoke(victim)

/*
 * Gets called when COMSIG_ITEM_EQUIPPED is sent to parent.
 * This proc register slip signals to the equipper.
 * If we have a slot whitelist, we only register the signals if the slot is valid (ex: clown PDA only slips in ID or belt slot).
 *
 * source - the source of the signal
 * equipper - the mob we're equipping the slippery thing to
 * slot - the slot we're equipping the slippery thing to on the equipper.
 */
/datum/component/slippery/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if((!LAZYLEN(slot_whitelist) || (slot in slot_whitelist)) && isliving(equipper))
		holder = equipper
		holder.AddElement(/datum/element/connect_loc, holder_connections)
		RegisterSignal(holder, COMSIG_PARENT_PREQDELETED, .proc/holder_deleted)

/*
 * Detects if the holder mob is deleted.
 * If our holder mob is the holder set in this component, we null it.
 *
 * source - the source of the signal
 * possible_holder - the mob being deleted.
 */
/datum/component/slippery/proc/holder_deleted(datum/source, datum/possible_holder)
	SIGNAL_HANDLER

	if(possible_holder == holder)
		holder = null

/*
 * Gets called when COMSIG_ITEM_DROPPED is sent to parent.
 * Makes our holder mob un-slippery.
 *
 * source - the source of the signal
 * user - the mob that was formerly wearing our slippery item.
 */
/datum/component/slippery/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	holder.RemoveElement(/datum/element/connect_loc, holder_connections)
	holder = null

/*
 * The slip proc, but for equipped items.
 * Slips the person who crossed us if we're lying down and unbuckled.
 *
 * source - the source of the signal
 * AM - the atom/movable that slipped on us.
 */
/datum/component/slippery/proc/Slip_on_wearer(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(holder.body_position == LYING_DOWN && !holder.buckled)
		Slip(source, AM)

/datum/component/slippery/UnregisterFromParent() //TODOKYLER: all removes of connect_loc need to specify the arguments that created it!
	. = ..()
	if(holder)
		holder.RemoveElement(/datum/element/connect_loc, holder_connections)
	parent.RemoveElement(/datum/element/connect_loc, default_connections)

/// Used for making the clown PDA only slip if the clown is wearing his shoes and the elusive banana-skin belt
/datum/component/slippery/clowning

/datum/component/slippery/clowning/Slip_on_wearer(datum/source, atom/movable/AM)
	var/obj/item/I = holder.get_item_by_slot(ITEM_SLOT_FEET)
	if(holder.body_position == LYING_DOWN && !holder.buckled)
		if(istype(I, /obj/item/clothing/shoes/clown_shoes))
			Slip(source, AM)
		else
			to_chat(holder,"<span class='warning'>[parent] failed to slip anyone. Perhaps I shouldn't have abandoned my legacy...</span>")
