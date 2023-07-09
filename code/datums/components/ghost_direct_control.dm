/**
 * Component which lets ghosts click on a mob to take control of it
 */
/datum/component/ghost_direct_control
	/// String describing this role to ghosts who are polled
	var/poll_role_string
	/// Key used to ignore polls of this type
	var/poll_ignore_key
	/// Message to display upon successful possession
	var/assumed_control_message
	/// Callback run after someone successfully takes over the body
	var/datum/callback/after_assumed_control

/datum/component/ghost_direct_control/Initialize(
	poll_candidates = TRUE,
	poll_role_string = null,
	poll_ignore_key = POLL_IGNORE_SENTIENCE_POTION,
	assumed_control_message = null,
	datum/callback/after_assumed_control,
)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if (!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		return INITIALIZE_HINT_QDEL

	src.poll_role_string = isnull(poll_role_string) ? "[parent]" : poll_role_string
	src.poll_ignore_key = poll_ignore_key
	src.after_assumed_control= after_assumed_control
	src.assumed_control_message = isnull(assumed_control_message) ? "You are [parent]!" : poll_role_string

	if (poll_candidates)
		INVOKE_ASYNC(src, PROC_REF(request_ghost_control))

/datum/component/ghost_direct_control/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_ghost_clicked))

/datum/component/ghost_direct_control/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST)
	return ..()

/// Send out a request for a brain
/datum/component/ghost_direct_control/proc/request_ghost_control()
	var/list/mob/dead/observer/candidates = poll_ghost_candidates(
		question = "Do you want to play as [poll_role_string]?",
		jobban_type = ROLE_SENTIENCE,
		be_special_flag = ROLE_SENTIENCE,
		poll_time = 10 SECONDS,
		ignore_category = poll_ignore_key,
	)
	var/mob/living/to_become = parent
	if (to_become.mind || !LAZYLEN(candidates))
		return
	assume_direct_control(pick(candidates))

/// A ghost clicked on us, they want to get in this body
/datum/component/ghost_direct_control/proc/on_ghost_clicked(mob/our_mob, mob/dead/observer/hopeful_ghost)
	SIGNAL_HANDLER
	if (!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) || our_mob.key)
		qdel(src)
		return
	if (!hopeful_ghost.client)
		return
	if (our_mob.stat == DEAD)
		to_chat(hopeful_ghost, span_warning("This body has passed away, it is of no use!"))
		return
	if (!SSticker.HasRoundStarted())
		to_chat(hopeful_ghost, span_warning("You cannot assume control of this until after the round has started!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(src, PROC_REF(attempt_possession), our_mob, hopeful_ghost)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// We got far enough to establish that this mob is a valid target, let's try to posssess it
/datum/component/ghost_direct_control/proc/attempt_possession(mob/our_mob, mob/dead/observer/hopeful_ghost)
	var/ghost_asked = tgui_alert(usr, "Become [poll_role_string]?", "Are you sure?", list("Yes", "No"))
	if (ghost_asked != "Yes" || QDELETED(our_mob))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if (our_mob.key)
		to_chat(hopeful_ghost, span_warning("It has already become sapient!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	assume_direct_control(hopeful_ghost)

/// Grant possession of our mob, component is now no longer required
/datum/component/ghost_direct_control/proc/assume_direct_control(mob/harbinger)
	var/mob/living/new_body = parent
	harbinger.log_message("took control of [new_body].", LOG_GAME)
	new_body.key = harbinger.key
	to_chat(new_body, span_notice(assumed_control_message))
	after_assumed_control?.Invoke(harbinger)
	qdel(src)
