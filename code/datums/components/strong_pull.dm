
/*
This component attaches to mobs, and makes their pulls !strong!
Basically, the items they pull cannot be pulled (except by the puller)
*/
/datum/component/strong_pull
	var/atom/movable/strongpulling

/datum/component/strong_pull/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/strong_pull/Destroy(force, silent)
	if(strongpulling)
		lose_strong_grip()
	return ..()

/datum/component/strong_pull/register_with_parent()
	. = ..()
	register_signal(parent, COMSIG_LIVING_START_PULL, .proc/on_pull)

/**
 * Called when the parent grabs something, adds signals to the object to reject interactions
 */
/datum/component/strong_pull/proc/on_pull(datum/source, atom/movable/pulled, state, force)
	SIGNAL_HANDLER
	strongpulling = pulled
	register_signal(strongpulling, COMSIG_ATOM_CAN_BE_PULLED, .proc/reject_further_pulls)
	register_signal(strongpulling, COMSIG_ATOM_NO_LONGER_PULLED, .proc/on_no_longer_pulled)
	if(istype(strongpulling, /obj/structure/closet) && !istype(strongpulling, /obj/structure/closet/body_bag))
		var/obj/structure/closet/grabbed_closet = strongpulling
		grabbed_closet.strong_grab = TRUE

/**
 * Signal for rejecting further grabs
 */
/datum/component/strong_pull/proc/reject_further_pulls(datum/source, mob/living/puller)
	SIGNAL_HANDLER
	if(puller != parent) //for increasing grabs, you need to have a valid pull. thus, parent should be able to pull the same object again
		return COMSIG_ATOM_CANT_PULL

/*
 * Unregisters signals and stops any buffs to pulling.
 */
/datum/component/strong_pull/proc/lose_strong_grip()
	unregister_signal(strongpulling, list(COMSIG_ATOM_CAN_BE_PULLED, COMSIG_ATOM_NO_LONGER_PULLED))
	if(istype(strongpulling, /obj/structure/closet))
		var/obj/structure/closet/ungrabbed_closet = strongpulling
		ungrabbed_closet.strong_grab = FALSE
	strongpulling = null

/**
 * Called when the hooked object is no longer pulled and removes the strong grip.
 */
/datum/component/strong_pull/proc/on_no_longer_pulled(datum/source, atom/movable/last_puller)
	SIGNAL_HANDLER
	lose_strong_grip()
