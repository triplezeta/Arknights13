/**
 * Venomous element; which makes the attacks of the simplemob attached poison the enemy.
 *
 * Used for spiders and bees!
 */
/datum/element/venomous
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2

	/// The reagent added to the target.
	var/datum/reagent/venom
	/// How much of the reagent added. if it's a list, it'll pick a range with the range being list(lower_value, upper_value)
	var/list/amount_added
	/// How the venom gets into the target.
	var/methods

/datum/element/venomous/Attach(datum/target, datum/reagent/venom, amount_added, methods = TOUCH)
	. = ..()

	if(isgun(target))
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)
	else if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/item_afterattack)
	else if(ishostile(target) || isbasicmob(target))
		RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, .proc/hostile_attackingtarget)
	else
		return ELEMENT_INCOMPATIBLE

	src.venom = new venom
	src.amount_added = amount_added
	src.methods = methods

/datum/element/venomous/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_PROJECTILE_ON_HIT, COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_POST_ATTACKINGTARGET))
	return ..()

/datum/element/venomous/proc/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	add_reagent(target)

/datum/element/venomous/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	add_reagent(target)

/datum/element/venomous/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	add_reagent(target)

/datum/element/venomous/proc/add_reagent(mob/living/target)
	if(!istype(target))
		return
	if(target.stat == DEAD)
		return

	var/final_amount_added
	if(islist(amount_added))
		final_amount_added = rand(amount_added[1], amount_added[2])
	else
		final_amount_added = amount_added

	var/actual_amount_added
	if (target.reagents)
		final_amount_added = actual_amount_added = target.reagents.add_reagent(venom.type, final_amount_added)
		if(!actual_amount_added)
			return

	if (methods)
		target.expose_reagents(list((venom) = final_amount_added), null, methods, volume_modifier = 1, show_message = TRUE)
	if (actual_amount_added) // Yes, this var exists entirely so that we don't have to call target.reagents again.
		venom.on_transfer(target, methods, actual_amount_added)
