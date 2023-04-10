/datum/mafia_ability
	var/name = "Mafia Ability"
	var/ability_action = "brutally murder"
	///When the ability can be used: (MAFIA_PHASE_DAY | MAFIA_PHASE_NIGHT)
	var/valid_use_period = MAFIA_PHASE_NIGHT

	///Boolean on whether the ability was selected to be used during the proper period.
	var/using_ability = FALSE
	///The mafia role that holds this ability.
	var/datum/mafia_role/host_role
	///The mafia role this ability is targeting, if necessary.
	var/datum/mafia_role/target_role

/datum/mafia_ability/New(datum/mafia_role/host_role)
	. = ..()
	src.host_role = host_role

/datum/mafia_ability/Destroy(force, ...)
	. = ..()
	host_role = null
	target_role = null

/**
 * Called when attempting to use the ability.
 * All abilities are called at the end of each phase, and this is called when performing the action.
 * Args:
 * game - The Mafia controller that holds reference to the game.
 */
/datum/mafia_ability/proc/validate_action_target(datum/mafia_controller/game)
	SHOULD_CALL_PARENT(TRUE)

	if(game.phase != valid_use_period)
		return FALSE
	if((host_role.role_flags & ROLE_ROLEBLOCKED))
		to_chat(host_role.body, span_warning("You were roleblocked!"))
		return FALSE
	if(SEND_SIGNAL(host_role, COMSIG_MAFIA_ON_VISIT, game, host_role) & MAFIA_VISIT_INTERRUPTED) //visited a warden. something that prevents you by visiting that person
		to_chat(host_role.body, span_danger("Your [name] was interrupted!"))
		return FALSE
	return TRUE

/**
 * Called when using the ability
 * Unsets the target, so it's meant to be called at the end.'
 * Args:
 * game - The Mafia controller that holds reference to the game.
 */
/datum/mafia_ability/proc/perform_action(datum/mafia_controller/game)
	SHOULD_CALL_PARENT(TRUE)
	target_role = null
	using_ability = initial(using_ability)

/datum/mafia_ability/proc/set_target(datum/mafia_role/new_target)
	if(target_role == new_target)
		target_role = null
		to_chat(host_role.body, span_notice("You will not [ability_action] [new_target.body]."))
		return
	target_role = new_target
	to_chat(host_role.body, span_notice("You will now [ability_action] [target_role.body]"))
