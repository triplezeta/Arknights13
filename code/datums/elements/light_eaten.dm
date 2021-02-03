/**
 * Makes anything that it attaches to incapable of producing light
 */
/datum/element/light_eaten
	element_flags = ELEMENT_DETACH

/datum/element/light_eaten/Attach(atom/target)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()
	RegisterSignal(target, COMSIG_ATOM_SET_LIGHT_POWER, .proc/block_light_power)
	RegisterSignal(target, COMSIG_ATOM_SET_LIGHT_RANGE, .proc/block_light_range)
	RegisterSignal(target, COMSIG_ATOM_SET_LIGHT_ON, .proc/block_light_on)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	target.set_light(0, 0, null, FALSE)

/datum/element/light_eaten/Detach(datum/source, force)
	UnregisterSignal(source, list(
		COMSIG_ATOM_SET_LIGHT_POWER,
		COMSIG_ATOM_SET_LIGHT_RANGE,
		COMSIG_ATOM_SET_LIGHT_ON,
		COMSIG_PARENT_EXAMINE,
	))
	return ..()

/// Prevents the light power of the target atom from exceeding 0.
/datum/element/light_eaten/proc/block_light_power(atom/eaten_light, new_power, old_power)
	SIGNAL_HANDLER
	if(new_power <= 0)
		return NONE

	eaten_light.set_light_power(min(old_power, 0))
	return NONE

/// Prevents the light range of the target atom from exceeding 0 while the light power is greater than 0.
/datum/element/light_eaten/proc/block_light_range(atom/eaten_light, new_range, old_range)
	SIGNAL_HANDLER
	if(eaten_light.light_power <= 0 || new_range <= 0)
		return NONE

	eaten_light.set_light_range(min(old_range, 0))
	return NONE

/// Prevents the light from turning on while the light power is greater than 0.
/datum/element/light_eaten/proc/block_light_on(atom/eaten_light, new_on, old_on)
	SIGNAL_HANDLER
	if(eaten_light.light_power <= 0 || !new_on)
		return NONE

	eaten_light.set_light_on(FALSE)
	return NONE

/// Signal handler for light eater flavortext
/datum/element/light_eaten/proc/on_examine(atom/eaten_light, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "<span class='warning'>It's dark and empty...</span>"
	if(isliving(examiner) && prob(20))
		var/mob/living/target = examiner
		examine_text += "<span class='danger'>You can feel something in [eaten_light.p_them()] gnash at your eyes!</span>"
		target.blind_eyes(5)
		target.blur_eyes(10)
	return NONE
