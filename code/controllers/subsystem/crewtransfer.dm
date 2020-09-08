/** Auto crew transfer vote SS
  *
  * Tracks information about auto crew transfer votes and calls transfer votes.area
  *
  * calls a vote [minimum_transfer_time] into the round, and every [minimum_time_between_votes] after that
  * stops calling votes automatically afer [auto_votes_allowed] attemps. all of these values are set in the config.
  *
  */
SUBSYSTEM_DEF(crewtransfer)
	name = "Crew Transfer Vote"
	wait = 600
	priority = FIRE_PRIORITY_CREW_TRANSFER
	runlevels = RUNLEVEL_GAME
	init_order = INIT_ORDER_CREW_TRANSFER
	/// Minimum shift length before automatic votes begin - from config.
	var/minimum_transfer_time = 0
	/// Minimum length of time between automatic votes - from config.
	var/minimum_time_between_votes = 0
	/// We stop calling votes if a vote passed
	var/transfer_vote_successful = FALSE

/datum/controller/subsystem/crewtransfer/Initialize(timeofday)

	if(!CONFIG_GET(flag/transfer_auto_vote_enabled))
		can_fire = FALSE
		return ..()

	minimum_transfer_time = CONFIG_GET(number/transfer_time_min_allowed)
	minimum_time_between_votes = CONFIG_GET(number/transfer_time_between_auto_votes)
	wait = minimum_transfer_time //first vote will fire at [minimum_transfer_time]

	return ..()

/datum/controller/subsystem/crewtransfer/fire()
	//we can't vote if we don't have a functioning democracy
	if(!SSvote)
		disable_vote()
		CRASH("Voting subsystem not found, but the crew transfer vote subsystem is!")

	//if it fires before it's supposed to be allowed, cut it out
	if(world.time - SSticker.round_start_time < minimum_transfer_time)
		return

	//if the shuttle is called and uncreallable, docked or beyond, or a transfer vote succeeded, stop firing
	if((!SSshuttle.canRecall() && SSshuttle.emergency.mode == SHUTTLE_CALL) || EMERGENCY_AT_LEAST_DOCKED || transfer_vote_successful)
		disable_vote()
		return

	//time to actually call the transfer vote.
	//if the transfer vote is unable to be called, try again in 2 minutes.
	//if the transfer vote begins successfully, then we'll come back in [minimum_time_between_votes]
	wait = SSvote.crew_transfer_vote() ? minimum_time_between_votes : 2 MINUTES

/// prevents the crew transfer SS from firing.
/datum/controller/subsystem/crewtransfer/proc/disable_vote()
	can_fire = FALSE
	message_admins("[name] system has been disabled and automatic votes will no longer be called.")
	return TRUE

/// initiates the shuttle call and logs it.
/datum/controller/subsystem/crewtransfer/proc/initiate_crew_transfer()
	if(EMERGENCY_IDLE_OR_RECALLED)
		/// The multiplier on the shuttle's timer
		var/shuttle_time_mult = 1
		/// Security level (for timer multiplier)
		var/security_num = seclevel2num(get_security_level())
		switch(security_num)
			if(SEC_LEVEL_GREEN)
				shuttle_time_mult = 2 // = ~20 minutes
			if(SEC_LEVEL_BLUE)
				shuttle_time_mult = 1.5 // = ~15 minutes
			else
				shuttle_time_mult = 1 // = ~10 minutes

		SSshuttle.emergency.request(reason = "\nReason:\n\nCrew transfer vote successful, dispatching shuttle for shift transfer.", set_coefficient = shuttle_time_mult)

		log_shuttle("A crew transfer vote has passed. The shuttle has been called, and recalling the shuttle ingame is disabled.")
		message_admins("A crew transfer vote has passed. The shuttle has been called, and recalling the shuttle ingame is disabled. You can still manually manipulate the shuttle if you want.")
		deadchat_broadcast("A crew transfer vote has passed. The shuttle is being dispatched.",  message_type = DEADCHAT_ANNOUNCEMENT)
		SSblackbox.record_feedback("text", "shuttle_reason", 1, "Crew Transfer Vote")
	else
		message_admins("A crew transfer vote has passed, but the shuttle was already called. Recalling the shuttle ingame is disabled. You can still manually manipulate the shuttle if you want.")
		to_chat(world, "<span style='boldannounce'>Crew transfer vote failed on account of shuttle being called.</span>")
	SSshuttle.emergencyNoRecall = TRUE // Don't let one guy overrule democracy by recalling afterwards
	transfer_vote_successful = TRUE //any successful vote, even non-auto ones are marked
