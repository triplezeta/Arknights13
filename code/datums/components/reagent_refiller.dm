/**
 * ## Reagent refiller
 * Refills any drinks poured out of the reagent container (and is allowed within the whitelisted reagents).
 */
/datum/component/reagent_refiller
	///Time to refill
	var/time_to_refill
	///Cell to use power of
	var/datum/weakref/cell_to_use
	///Amount of power to use from the cell
	var/power_to_draw
	///Whitelist of reagents allowed to be synthesized
	var/list/whitelisted_reagents

/datum/component/reagent_refiller/Initialize(
	time_to_refill = 60 SECONDS,
	obj/item/stock_parts/cell/cell,
	power_to_draw = 30,
	whitelisted_reagents = list(/datum/reagent/consumable)
)
	if(!istype(parent, /obj/item/reagent_containers))
		return COMPONENT_INCOMPATIBLE

	src.time_to_refill = time_to_refill
	if (!isnull(cell))
		src.cell_to_use = WEAKREF(cell)
	src.power_to_draw = power_to_draw
	src.whitelisted_reagents = whitelisted_reagents

	return ..()

/datum/component/reagent_refiller/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/refill)
	RegisterSignal(parent, COMSIG_ATOM_EXITED, .proc/delete_self)
	return ..()

/datum/component/reagent_refiller/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ATOM_EXITED))
	return ..()

/datum/component/reagent_refiller/proc/delete_self()
	SIGNAL_HANDLER

	qdel(src)

///Preps the reagent container for being refilled
/datum/component/reagent_refiller/proc/refill()
	SIGNAL_HANDLER

	var/obj/item/reagent_containers/container = parent
	var/refill = container.reagents.get_master_reagent_id()
	var/amount = min((container.amount_per_transfer_from_this + container.reagents.total_volume), container.reagents.total_volume)

	if (amount == 0)
		return
	if (!is_path_in_list(refill, whitelisted_reagents))
		return

	addtimer(CALLBACK(src, .proc/add_reagents, container, container.loc, refill, amount), time_to_refill)

///Refills the reagent container, and uses cell power if applicable
/datum/component/reagent_refiller/proc/add_reagents(obj/item/reagent_containers/target, oldloc, reagent_to_refill, amount)
	if (target.loc != oldloc)
		return

	target.reagents.add_reagent(reagent_to_refill, amount)

	if (!isnull(cell_to_use))
		var/obj/item/stock_parts/cell/cell = cell_to_use.resolve()
		cell.use(power_to_draw)
