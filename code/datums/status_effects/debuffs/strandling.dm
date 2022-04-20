/// A multiplier to the time it takes to remove durathread strangling when using a tool instead of your hands
#define STRANGLING_TOOL_MULTIPLIER 0.4

//get it, strand as in durathread strand + strangling = strandling hahahahahahahahahahhahahaha i want to die
/datum/status_effect/strandling
	id = "strandling"
	examine_text = span_warning("SUBJECTPRONOUN seems to be being choked by some durathread strands! You may be able to help, or <b>cut</b> them off.")
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/strandling
	/// How long it takes to remove the status effect via [proc/try_remove_effect]
	var/time_to_remove = 3.5 SECONDS

/datum/status_effect/strandling/on_apply()
	RegisterSignal(owner, COMSIG_CARBON_PRE_BREATHE, .proc/on_breathe)
	RegisterSignal(owner, COMSIG_ATOM_TOOL_ACT(TOOL_WIRECUTTER), .proc/on_cut)
	RegisterSignal(owner, COMSIG_CARBON_PRE_HELP_ACT, .proc/on_self_check)
	return TRUE

/datum/status_effect/strandling/on_remove()
	UnregisterSignal(owner, list(COMSIG_CARBON_PRE_BREATHE, COMSIG_ATOM_TOOL_ACT(TOOL_WIRECUTTER), COMSIG_CARBON_PRE_HELP_ACT))

/// Signal proc for [COMSIG_CARBON_PRE_BREATHE], causes losebreath whenever we're trying to breathe
/datum/status_effect/strandling/proc/on_breathe(mob/living/source)
	SIGNAL_HANDLER

	if(source.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		return

	source.losebreath++

/// Signal proc for [COMSIG_ATOM_TOOL_ACT] with [TOOL_WIRECUTTER], allowing wirecutters to remove the effect (from others / themself)
/datum/status_effect/strandling/proc/on_cut(mob/living/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	if(DOING_INTERACTION(user, REF(src)))
		return

	INVOKE_ASYNC(src, .proc/try_remove_effect, user, tool)
	return COMPONENT_BLOCK_TOOL_ATTACK

/// Signal proc for [COMSIG_CARBON_PRE_HELP_ACT], allowing someone to remove the effect by hand
/datum/status_effect/strandling/proc/on_self_check(mob/living/carbon/source, mob/living/helper)
	SIGNAL_HANDLER

	if(DOING_INTERACTION(helper, REF(src)))
		return

	INVOKE_ASYNC(src, .proc/try_remove_effect, helper)
	return COMPONENT_BLOCK_HELP_ACT

/**
 * Attempts a do_after to remove the effect and stop the strangling.
 *
 * user - the mob attempting to remove the strangle. Can be the same as the owner.
 * tool - the tool the user's using to remove the strange. Can be null.
 */
/datum/status_effect/strandling/proc/try_remove_effect(mob/user, obj/item/tool)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	user.visible_message(
		span_notice("[user] attempts to [tool ? "cut":"remove"] the strand from around [owner == user ? "[owner.p_their()]":"[owner]'s"] neck..."),
		span_notice("You attempt to [tool ? "cut":"remove"] the strand from around [owner == user ? "your":"[owner]'s"] neck..."),
	)

	// Play a sound if we have a tool
	tool?.play_tool_sound(owner)

	// Now try to remove the effect with a doafter. If we have a tool, we'll even remove it 60% faster.
	if(!do_mob(user, owner, time_to_remove * (tool ? STRANGLING_TOOL_MULTIPLIER : 1), interaction_key = REF(src)))
		to_chat(user, span_warning("You fail to [tool ? "cut":"remove"] the strand from around [owner == user ? "your":"[owner]'s"] neck!"))
		return FALSE

	// Play another sound after we're done
	tool?.play_tool_sound(owner)

	user.visible_message(
		span_notice("[user] successfully [tool ? "cut":"remove"] the strand from around [owner == user ? "[owner.p_their()]":"[owner]'s"] neck."),
		span_notice("You successfully [tool ? "cut":"remove"] the strand from around [owner == user ? "your":"[owner]'s"] neck."),
	)
	qdel(src)
	return TRUE

/atom/movable/screen/alert/status_effect/strandling
	name = "Choking strand"
	desc = "Strands of Durathread are wrapped around your neck, preventing you from breathing! Click this icon to remove the strand."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/atom/movable/screen/alert/status_effect/strandling/Click(location, control, params)
	. = ..()
	if(!.)
		return

	if(!isliving(owner))
		return

	var/datum/status_effect/strandling/strangle_effect = attached_effect
	if(!istype(strangle_effect))
		return

	strangle_effect.try_remove_effect(owner)

#undef STRANGLING_TOOL_MULTIPLIER
