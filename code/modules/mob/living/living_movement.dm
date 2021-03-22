/mob/living/Moved()
	. = ..()
	update_turf_movespeed(loc)


/mob/living/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		return (!density || (body_position == LYING_DOWN) || (mover.throwing.thrower == src && !ismob(mover)))
	if(buckled == mover)
		return TRUE
	if(ismob(mover) && (mover in buckled_mobs))
		return TRUE
	return !mover.density || body_position == LYING_DOWN

/mob/living/toggle_move_intent()
	. = ..()
	update_move_intent_slowdown()

/mob/living/update_config_movespeed()
	update_move_intent_slowdown()
	return ..()

/mob/living/proc/update_move_intent_slowdown()
	add_movespeed_modifier((m_intent == MOVE_INTENT_WALK)? /datum/movespeed_modifier/config_walk_run/walk : /datum/movespeed_modifier/config_walk_run/run)

/mob/living/proc/update_turf_movespeed(turf/open/T)
	if(isopenturf(T))
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown, multiplicative_slowdown = T.slowdown)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown)


/mob/living/proc/update_pull_movespeed()
	if(pulling)
		if(isliving(pulling))
			var/mob/living/L = pulling
			if(!slowed_by_drag || L.body_position == STANDING_UP || L.buckled || grab_state >= GRAB_AGGRESSIVE)
				remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
				return
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = PULL_PRONE_SLOWDOWN)
			return
		if(isobj(pulling))
			var/obj/structure/S = pulling
			if(!slowed_by_drag || !S.drag_slowdown)
				remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
				return
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = S.drag_slowdown)
			return
	remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)

/mob/living/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(z_move_flags & ZMOVE_FALL_CHECKS && buckled && (buckled.anchored || buckled.movement_type & FLYING || buckled.throwing || !buckled.has_gravity(start)))
		z_move_flags &= ~ZMOVE_FALL_CHECKS //safe against falling since they're buckled to something that shouldn't fall.
	. = ..()
	if(!.)
		return
	if(z_move_flags & ZMOVE_INCAPACITATED_CHECKS && incapacitated())
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(z_move_flags & ZMOVE_CAN_FLY_CHECKS)
		if(buckled && !isvehicle(buckled))
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(src, "<span class='notice'>Unbuckle from [buckled] first.<span>")
			return FALSE
		if(buckled && !(buckled.movement_type & (FLYING|FLOATING)) && buckled.has_gravity(start))
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(src, "<span class='notice'>Your [buckled.name] is not capable of flight.<span>")
			return FALSE
		if(!buckled && !(movement_type & (FLYING|FLOATING)))
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(src, "<span class='notice'>You are not Superman.<span>")
			return FALSE


/mob/living/keybind_face_direction(direction)
	if(stat > SOFT_CRIT)
		return
	return ..()
