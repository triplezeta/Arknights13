/**
 * A component to reset the parent to its previous state after some time passes
 */
/datum/component/dejavu

	///message sent when dejavu rewinds
	var/rewind_message = "You remember a time not so long ago..."
	///message sent when dejavu is out of rewinds
	var/no_rewinds_message = "But the memory falls out of your reach."

	/// The turf the parent was on when this components was applied, they get moved back here after the duration
	var/turf/starting_turf
	/// Determined by the type of the parent so different behaviours can happen per type
	var/rewind_type
	/// How many rewinds will happen before the effect ends
	var/rewinds_remaining
	/// How long to wait between each rewind
	var/rewind_interval

	/// The starting value of clone loss at the beginning of the effect
	var/clone_loss = 0
	/// The starting value of toxin loss at the beginning of the effect
	var/tox_loss = 0
	/// The starting value of oxygen loss at the beginning of the effect
	var/oxy_loss = 0
	/// The starting value of stamina loss at the beginning of the effect
	var/stamina_loss = 0
	/// The starting value of brain loss at the beginning of the effect
	var/brain_loss = 0
	/// The starting value of brute loss at the beginning of the effect
	/// This only applies to simple animals
	var/brute_loss
	/// The starting value of integrity at the beginning of the effect
	/// This only applies to objects
	var/integrity
	/// A list of body parts saved at the beginning of the effect
	var/list/datum/saved_bodypart/saved_bodyparts

/datum/component/dejavu/Initialize(rewinds = 1, interval = 10 SECONDS)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	starting_turf = get_turf(parent)
	rewinds_remaining = rewinds
	rewind_interval = interval

	if(isliving(parent))
		var/mob/living/L = parent
		clone_loss = L.getCloneLoss()
		tox_loss = L.getToxLoss()
		oxy_loss = L.getOxyLoss()
		stamina_loss = L.getStaminaLoss()
		brain_loss = L.getOrganLoss(ORGAN_SLOT_BRAIN)
		rewind_type = PROC_REF(rewind_living)

	if(iscarbon(parent))
		var/mob/living/carbon/C = parent
		saved_bodyparts = C.save_bodyparts()
		rewind_type = PROC_REF(rewind_carbon)

	else if(isanimal(parent))
		var/mob/living/simple_animal/M = parent
		brute_loss = M.bruteloss
		rewind_type = PROC_REF(rewind_animal)

	else if(isobj(parent))
		var/obj/O = parent
		integrity = O.get_integrity()
		rewind_type = PROC_REF(rewind_obj)

	addtimer(CALLBACK(src, rewind_type), rewind_interval)

/datum/component/dejavu/Destroy()
	starting_turf = null
	saved_bodyparts = null
	return ..()

/datum/component/dejavu/proc/rewind()
	to_chat(parent, span_notice(rewind_message))

	//comes after healing so new limbs comically drop to the floor
	if(starting_turf)
		var/area/destination_area = starting_turf.loc
		if(destination_area.area_flags & NOTELEPORT)
			to_chat(parent, span_warning("For some reason, your head aches and fills with mental fog when you try to think of where you were... It feels like you're now going against some dull, unstoppable universal force."))
		else
			var/atom/movable/master = parent
			master.forceMove(starting_turf)

	rewinds_remaining --
	if(rewinds_remaining)
		addtimer(CALLBACK(src, rewind_type), rewind_interval)
	else
		to_chat(parent, span_notice(no_rewinds_message))
		qdel(src)

/datum/component/dejavu/proc/rewind_living()
	var/mob/living/master = parent
	master.setCloneLoss(clone_loss)
	master.setToxLoss(tox_loss)
	master.setOxyLoss(oxy_loss)
	master.setStaminaLoss(stamina_loss)
	master.setOrganLoss(ORGAN_SLOT_BRAIN, brain_loss)
	rewind()

/datum/component/dejavu/proc/rewind_carbon()
	if(saved_bodyparts)
		var/mob/living/carbon/master = parent
		master.apply_saved_bodyparts(saved_bodyparts)
	rewind_living()

/datum/component/dejavu/proc/rewind_animal()
	var/mob/living/simple_animal/master = parent
	master.bruteloss = brute_loss
	master.updatehealth()
	rewind_living()

/datum/component/dejavu/proc/rewind_obj()
	var/obj/master = parent
	master.update_integrity(integrity)
	rewind()

///differently themed dejavu for modsuits.
/datum/component/dejavu/timeline
	rewind_message = "Your suit rewinds, pulling you through spacetime!"
	no_rewinds_message = "\"Rewind complete. You have arrived at: 10 seconds ago.\""

/datum/component/dejavu/timeline/rewind()
	playsound(get_turf(parent), 'sound/items/modsuit/rewinder.ogg')
	. = ..()
