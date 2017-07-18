/datum/component/slippery
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/intensity
	var/lube_flags = NONE
	var/mob/slip_victim

/datum/component/slippery/New(datum/P, _intensity, _lube_flags)
	..()
	intensity = _intensity
	lube_flags = _lube_flags
	if(ismovableatom(P))
		RegisterSignal(COMSIG_MOVABLE_CROSSED, .proc/Slip)
	else
		RegisterSignal(COMSIG_ATOM_ENTERED, .proc/Slip)

/datum/component/slippery/Destroy()
	slip_victim = null
	return ..()

/datum/component/slippery/proc/Slip(atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && !victim.is_flying() && victim.slip(intensity, null, parent, lube_flags))
		slip_victim = victim
		addtimer(CALLBACK(src, .proc/ClearMobRef), 0, TIMER_UNIQUE)
		return TRUE

/datum/component/slippery/proc/ClearMobRef()
	slip_victim = null
