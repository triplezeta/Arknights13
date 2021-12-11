/**
 * StonedMC
 *
 * Designed to properly split up a given tick among subsystems
 * Note: if you read parts of this code and think "why is it doing it that way"
 * Odds are, there is a reason
 *
 **/

//Init the debugger datum first so we can debug Master
//You might wonder why not just create the debugger datum global in its own file, since its loaded way earlier than this DM file
//Well for whatever reason then the Master gets created first and then the debugger when doing that
//So thats why this code lives here now, until someone finds out how Byond inits globals
GLOBAL_REAL(Debugger, /datum/debugger) = new
//This is the ABSOLUTE ONLY THING that should init globally like this
//2019 update: the failsafe,config and Global controllers also do it
GLOBAL_REAL(Master, /datum/controller/master) = new

//THIS IS THE INIT ORDER
//Master -> SSPreInit -> GLOB -> world -> config -> SSInit -> Failsafe
//GOT IT MEMORIZED?

/datum/controller/master
	name = "Master"

	/// Are we processing (higher values increase the processing delay by n ticks)
	var/processing = TRUE
	/// How many times have we ran
	var/iteration = 0
	/// Stack end detector to detect stack overflows that kill the mc's main loop
	var/datum/stack_end_detector/stack_end_detector

	/// world.time of last fire, for tracking lag outside of the mc
	var/last_run

	/// List of subsystems to process().
	var/list/subsystems

	// Vars for keeping track of tick drift.
	var/init_timeofday
	var/init_time
	///smoothed running average of how much the game has fallen behind the time it should be at, in number of ticks.
	///every time a tick is delayed from the time it was supposed to start (50 milliseconds after it started), this is increased.
	var/tickdrift = 0
	///running average of how much each tick is already used when the MC is resumed to run by byond.
	///this exists because sleeping procs are scheduled to resume by byond which we cant control, so procs that sleep can resume before the MC
	var/average_starting_tick_usage = 0
	
	///running average of how much time was spent resuming other sleeping procs after the mc went back to sleep
	///this exists because sleeping procs are scheduled to resume by byond which we cant control, so procs that sleep can resume after the MC
	var/average_sleeping_tick_usage = 0

	///running average of how much overtime (in percents of a tick) was spent was spent resuming other sleeping procs after the mc went back to sleep
	///this exists because sleeping procs are scheduled to resume by byond which we cant control, so procs that sleep can resume after the MC
	var/average_sleeping_overtime_usage = 0

	/// How long is the MC sleeping between runs, read only (set by Loop() based off of anti-tick-contention heuristics)
	var/sleep_delta = 1

	/// Only run ticker subsystems for the next n ticks.
	var/skip_ticks = 0

	/// makes the mc main loop runtime
	var/make_runtime = FALSE

	var/initializations_finished_with_no_players_logged_in //I wonder what this could be?

	/// The type of the last subsystem to be fire()'d.
	var/last_type_processed

	///!Start of queue linked list
	var/datum/controller/subsystem/queue_head
	///!End of queue linked list (used for appending to the list)
	var/datum/controller/subsystem/queue_tail
	///Running total of all queued subsystem priorities so that we don't have to loop thru the queue each run to split up the tick
	var/queue_priority_count = 0
	///running total of queued subsystem priority but for background subsystems
	var/queue_priority_count_bg = 0
	///!Are we loading in a new map?
	var/map_loading = FALSE

	///!for scheduling different subsystems for different stages of the round
	var/current_runlevel
	var/sleep_offline_after_initializations = TRUE

	/// During initialization, will be the instanced subsytem that is currently initializing.
	/// Outside of initialization, returns null.
	var/current_initializing_subsystem = null

	var/static/restart_clear = 0
	var/static/restart_timeout = 0
	var/static/restart_count = 0

	var/static/random_seed

	///current tick limit, assigned before running a subsystem.
	///used by CHECK_TICK as well so that the procs subsystems call can obey that SS's tick limits
	var/static/current_ticklimit = TICK_LIMIT_RUNNING

/datum/controller/master/New()
	if(!config)
		config = new
	// Highlander-style: there can only be one! Kill off the old and replace it with the new.

	if(!random_seed)
		#ifdef UNIT_TESTS
		random_seed = 29051994
		#else
		random_seed = rand(1, 1e9)
		#endif
		rand_seed(random_seed)

	var/list/_subsystems = list()
	subsystems = _subsystems
	if (Master != src)
		if (istype(Master)) //If there is an existing MC take over his stuff and delete it
			Recover()
			qdel(Master)
			Master = src
		else
			//Code used for first master on game boot or if existing master got deleted
			Master = src
			var/list/subsytem_types = subtypesof(/datum/controller/subsystem)
			sortTim(subsytem_types, /proc/cmp_subsystem_init)
			//Find any abandoned subsystem from the previous master (if there was any)
			var/list/existing_subsystems = list()
			for(var/global_var in global.vars)
				if (istype(global.vars[global_var], /datum/controller/subsystem))
					existing_subsystems += global.vars[global_var]
			//Either init a new SS or if an existing one was found use that
			for(var/I in subsytem_types)
				var/datum/controller/subsystem/existing_subsystem = locate(I) in existing_subsystems
				if (istype(existing_subsystem))
					_subsystems += existing_subsystem
				else
					_subsystems += new I

	if(!GLOB)
		new /datum/controller/global_vars

/datum/controller/master/Destroy()
	..()
	// Tell qdel() to Del() this object.
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/master/Shutdown()
	processing = FALSE
	sortTim(subsystems, /proc/cmp_subsystem_init)
	reverse_range(subsystems)
	for(var/datum/controller/subsystem/ss in subsystems)
		log_world("Shutting down [ss.name] subsystem...")
		ss.Shutdown()
	log_world("Shutdown complete")

// Returns 1 if we created a new mc, 0 if we couldn't due to a recent restart,
// -1 if we encountered a runtime trying to recreate it
/proc/Recreate_MC()
	. = -1 //so if we runtime, things know we failed
	if (world.time < Master.restart_timeout)
		return 0
	if (world.time < Master.restart_clear)
		Master.restart_count *= 0.5

	var/delay = 50 * ++Master.restart_count
	Master.restart_timeout = world.time + delay
	Master.restart_clear = world.time + (delay * 2)
	if (Master) //Can only do this if master hasn't been deleted
		Master.processing = FALSE //stop ticking this one
	try
		new/datum/controller/master()
	catch
		return -1
	return 1


/datum/controller/master/Recover()
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for (var/varname in Master.vars)
		switch (varname)
			if("name", "tag", "bestF", "type", "parent_type", "vars", "statclick") // Built-in junk.
				continue
			else
				var/varval = Master.vars[varname]
				if (istype(varval, /datum)) // Check if it has a type var.
					var/datum/D = varval
					msg += "\t [varname] = [D]([D.type])\n"
				else
					msg += "\t [varname] = [varval]\n"
	log_world(msg)

	var/datum/controller/subsystem/BadBoy = Master.last_type_processed
	var/FireHim = FALSE
	if(istype(BadBoy))
		msg = null
		LAZYINITLIST(BadBoy.failure_strikes)
		switch(++BadBoy.failure_strikes[BadBoy.type])
			if(2)
				msg = "The [BadBoy.name] subsystem was the last to fire for 2 controller restarts. It will be recovered now and disabled if it happens again."
				FireHim = TRUE
			if(3)
				msg = "The [BadBoy.name] subsystem seems to be destabilizing the MC and will be offlined."
				BadBoy.flags |= SS_NO_FIRE
		if(msg)
			to_chat(GLOB.admins, span_boldannounce("[msg]"))
			log_world(msg)

	if (istype(Master.subsystems))
		if(FireHim)
			Master.subsystems += new BadBoy.type //NEW_SS_GLOBAL will remove the old one
		subsystems = Master.subsystems
		current_runlevel = Master.current_runlevel
		StartProcessing(10)
	else
		to_chat(world, span_boldannounce("The Master Controller is having some issues, we will need to re-initialize EVERYTHING"))
		Initialize(20, TRUE)


// Please don't stuff random bullshit here,
// Make a subsystem, give it the SS_NO_FIRE flag, and do your work in it's Initialize()
/datum/controller/master/Initialize(delay, init_sss, tgs_prime)
	set waitfor = 0

	if(delay)
		sleep(delay)

	if(init_sss)
		init_subtypes(/datum/controller/subsystem, subsystems)

	to_chat(world, span_boldannounce("Initializing subsystems..."))

	// Sort subsystems by init_order, so they initialize in the correct order.
	sortTim(subsystems, /proc/cmp_subsystem_init)

	var/start_timeofday = REALTIMEOFDAY
	// Initialize subsystems.
	current_ticklimit = CONFIG_GET(number/tick_limit_mc_init)
	for (var/datum/controller/subsystem/SS in subsystems)
		if (SS.flags & SS_NO_INIT || SS.initialized) //Don't init SSs with the correspondig flag or if they already are initialzized
			continue
		current_initializing_subsystem = SS
		SS.Initialize(REALTIMEOFDAY)
		CHECK_TICK
	current_initializing_subsystem = null
	current_ticklimit = TICK_LIMIT_RUNNING
	var/time = (REALTIMEOFDAY - start_timeofday) / 10

	var/msg = "Initializations complete within [time] second[time == 1 ? "" : "s"]!"
	to_chat(world, span_boldannounce("[msg]"))
	log_world(msg)

	if (!current_runlevel)
		SetRunLevel(1)

	// Sort subsystems by display setting for easy access.
	sortTim(subsystems, /proc/cmp_subsystem_display)
	// Set world options.
	world.change_fps(CONFIG_GET(number/fps))
	var/initialized_tod = REALTIMEOFDAY

	if(tgs_prime)
		world.TgsInitializationComplete()

	if(sleep_offline_after_initializations)
		world.sleep_offline = TRUE
	sleep(1)

	if(sleep_offline_after_initializations && CONFIG_GET(flag/resume_after_initializations))
		world.sleep_offline = FALSE
	initializations_finished_with_no_players_logged_in = initialized_tod < REALTIMEOFDAY - 10
	// Loop.
	Master.StartProcessing(0)

/datum/controller/master/proc/SetRunLevel(new_runlevel)
	var/old_runlevel = current_runlevel
	if(isnull(old_runlevel))
		old_runlevel = "NULL"

	testing("MC: Runlevel changed from [old_runlevel] to [new_runlevel]")
	current_runlevel = log(2, new_runlevel) + 1
	if(current_runlevel < 1)
		CRASH("Attempted to set invalid runlevel: [new_runlevel]")

// Starts the mc, and sticks around to restart it if the loop ever ends.
/datum/controller/master/proc/StartProcessing(delay)
	set waitfor = 0
	if(delay)
		sleep(delay)
	testing("Master starting processing")
	var/rtn = Loop()
	if (rtn > 0 || processing < 0)
		return //this was suppose to happen.
	//loop ended, restart the mc
	log_game("MC crashed or runtimed, restarting")
	message_admins("MC crashed or runtimed, restarting")
	var/rtn2 = Recreate_MC()
	if (rtn2 <= 0)
		log_game("Failed to recreate MC (Error code: [rtn2]), it's up to the failsafe now")
		message_admins("Failed to recreate MC (Error code: [rtn2]), it's up to the failsafe now")
		Failsafe.defcon = 2

/// Main loop. unimportant.
/datum/controller/master/proc/Loop()
	. = -1
	//Prep the loop (most of this is because we want MC restarts to reset as much state as we can, and because
	// local vars rock

	//all this shit is here so that flag edits can be refreshed by restarting the MC. (and for speed)
	var/list/tickersubsystems = list()
	var/list/runlevel_sorted_subsystems = list(list()) //ensure we always have at least one runlevel
	var/timer = world.time
	for (var/datum/controller/subsystem/subsystem as anything in subsystems)
		if (subsystem.flags & SS_NO_FIRE)
			continue
		subsystem.queued_time = 0
		subsystem.queue_next = null
		subsystem.queue_prev = null
		subsystem.state = SS_IDLE
		if (subsystem.flags & SS_TICKER)
			tickersubsystems += subsystem
			timer += world.tick_lag * rand(1, 5)
			subsystem.next_fire = timer
			continue

		var/ss_runlevels = subsystem.runlevels
		var/added_to_any = FALSE
		for(var/I in 1 to GLOB.bitflags.len)
			if(ss_runlevels & GLOB.bitflags[I])
				while(runlevel_sorted_subsystems.len < I)
					runlevel_sorted_subsystems += list(list())
				runlevel_sorted_subsystems[I] += subsystem
				added_to_any = TRUE
		if(!added_to_any)
			WARNING("[subsystem.name] subsystem is not SS_NO_FIRE but also does not have any runlevels set!")

	queue_head = null
	queue_tail = null
	//these sort by lower priorities first to reduce the number of loops needed to add subsequent subsystem's to the queue
	//(higher subsystems will be sooner in the queue, adding them later in the loop means we don't have to loop thru them next queue add)
	sortTim(tickersubsystems, /proc/cmp_subsystem_priority)
	for(var/I in runlevel_sorted_subsystems)
		sortTim(runlevel_sorted_subsystems, /proc/cmp_subsystem_priority)
		I += tickersubsystems

	var/cached_runlevel = current_runlevel
	var/list/current_runlevel_subsystems = runlevel_sorted_subsystems[cached_runlevel]

	init_timeofday = REALTIMEOFDAY
	init_time = world.time

	iteration = 1
	var/error_level = 0
	var/sleep_delta = 1
	var/list/subsystems_to_check

	//setup the stack overflow detector
	stack_end_detector = new()
	var/datum/stack_canary/canary = stack_end_detector.prime_canary()
	canary.use_variable()
	//the actual loop.
	while (1)
		tickdrift = max(0, MC_AVERAGE_FAST(tickdrift, (((REALTIMEOFDAY - init_timeofday) - (world.time - init_time)) / world.tick_lag)))
		var/starting_tick_usage = TICK_USAGE

		average_starting_tick_usage = MC_AVG_FAST_UP_SLOW_DOWN(average_starting_tick_usage, starting_tick_usage)

		if (processing <= 0)
			current_ticklimit = TICK_LIMIT_RUNNING
			sleep(10)
			continue

		//Anti-tick-contention heuristics:
		//if there are mutiple sleeping procs running before us hogging the cpu, we have to run later.
		// (because sleeps are processed in the order received, longer sleeps are more likely to run first)
		if (starting_tick_usage > TICK_LIMIT_MC) //if there isn't enough time to bother doing anything this tick, sleep a bit.
			sleep_delta *= 2
			current_ticklimit = TICK_LIMIT_RUNNING * 0.5
			sleep(world.tick_lag * (processing * sleep_delta))
			continue

		//Byond resumed us late. assume it might have to do the same next tick
		if (last_run + CEILING(world.tick_lag * (processing * sleep_delta), world.tick_lag) < world.time)
			sleep_delta += 1

		sleep_delta = MC_AVERAGE_FAST(sleep_delta, 1) //decay sleep_delta

		if (starting_tick_usage > (TICK_LIMIT_MC*0.75)) //we ran 3/4 of the way into the tick
			sleep_delta += 1

		//debug
		if (make_runtime)
			var/datum/controller/subsystem/SS
			SS.can_fire = 0

		if (!Failsafe || (Failsafe.processing_interval > 0 && (Failsafe.lasttick+(Failsafe.processing_interval*5)) < world.time))
			new/datum/controller/failsafe() // (re)Start the failsafe.

		//now do the actual stuff
		if (!skip_ticks)

			var/checking_runlevel = current_runlevel

			if(cached_runlevel != checking_runlevel)
				//resechedule subsystems

				cached_runlevel = checking_runlevel
				current_runlevel_subsystems = runlevel_sorted_subsystems[cached_runlevel]
				var/stagger = world.time

				for(var/datum/controller/subsystem/SS as anything in current_runlevel_subsystems)
					if(SS.next_fire <= world.time)
						stagger += world.tick_lag * rand(1, 5)
						SS.next_fire = stagger

			subsystems_to_check = current_runlevel_subsystems
		else
			subsystems_to_check = tickersubsystems

		if (CheckQueue(subsystems_to_check) <= 0)
			if (!SoftReset(tickersubsystems, runlevel_sorted_subsystems))
				log_world("MC: SoftReset() failed, crashing")
				return
			if (!error_level)
				iteration++
			error_level++
			current_ticklimit = TICK_LIMIT_RUNNING
			sleep(10)
			continue

		if (queue_head)
			if (RunQueue() <= 0)
				if (!SoftReset(tickersubsystems, runlevel_sorted_subsystems))
					log_world("MC: SoftReset() failed, crashing")
					return
				if (!error_level)
					iteration++
				error_level++
				current_ticklimit = TICK_LIMIT_RUNNING
				sleep(10)
				continue
		error_level--
		if (!queue_head) //reset the counts if the queue is empty, in the off chance they get out of sync
			queue_priority_count = 0
			queue_priority_count_bg = 0

		iteration++
		last_run = world.time

		if (skip_ticks)
			skip_ticks--

		src.sleep_delta = MC_AVERAGE_FAST(src.sleep_delta, sleep_delta)
		current_ticklimit = TICK_LIMIT_RUNNING

		if (processing * sleep_delta <= world.tick_lag)
			current_ticklimit -= (TICK_LIMIT_RUNNING * 0.25) //reserve the tail 1/4 of the next tick for the mc if we plan on running next tick
		
		//setup code to track when the last sleep ends
		var/slept_worldtime = world.time
		var/slept_tickusage = TICK_USAGE
		//from testing, sleeping for 0 will sleep to the end of the current tick, but not always.
		spawn(0) //do not convert to add timer
			if (world.time == slept_worldtime && TICK_USAGE >= slept_tickusage) //make sure we woke up during the same tick
				average_sleeping_tick_usage = MC_AVG_FAST_UP_SLOW_DOWN(average_sleeping_tick_usage, TICK_USAGE - slept_tickusage)
				average_sleeping_overtime_usage = MC_AVG_FAST_UP_SLOW_DOWN(average_sleeping_overtime_usage, min(0, TICK_USAGE - 100))
		
		sleep(world.tick_lag * (processing * sleep_delta))




/// This is what decides if something should run.
/datum/controller/master/proc/CheckQueue(list/subsystems_to_check)
	. = 0 //so the mc knows if we runtimed

	var/SS_flags

	for (var/datum/controller/subsystem/subsystem as anything in subsystems_to_check)
		if (!subsystem)
			subsystems_to_check -= subsystem
		if (subsystem.state != SS_IDLE)
			continue
		if (subsystem.can_fire <= 0)
			continue
		if (subsystem.next_fire > world.time)
			continue
		SS_flags = subsystem.flags
		if (SS_flags & SS_NO_FIRE)
			subsystems_to_check -= subsystem
			continue
		if ((SS_flags & (SS_TICKER|SS_KEEP_TIMING)) == SS_KEEP_TIMING && subsystem.last_fire + (subsystem.wait * 0.75) > world.time)
			continue
		if (subsystem.postponed_fires >= 1)
			subsystem.postponed_fires--
			subsystem.update_nextfire()
			continue
		subsystem.enqueue()
	. = 1


/// Run through the queue of subsystems to run, running them while balancing out their allocated tick precentage
/datum/controller/master/proc/RunQueue()
	. = 0
	var/datum/controller/subsystem/queue_node
	var/queue_node_flags
	var/queue_node_priority
	var/queue_node_paused


	var/current_tick_budget

	///how much of the remaining tick the currently running subsystem should be allowed to have
	var/tick_precentage

	var/tick_remaining

	var/ran = TRUE //this is right

	///have we switched current_tick_budget to background mode yet?
	var/running_through_background_subsystems = FALSE

	///tracks how much of the tick the currently running subsystem has taken
	var/tick_usage

	//keep running while we have stuff to run and we haven't gone over a tick
	// this is so subsystems paused eariler can use tick time that later subsystems never used
	while (ran && queue_head && TICK_USAGE < TICK_LIMIT_MC)
		ran = FALSE
		running_through_background_subsystems = FALSE
		current_tick_budget = queue_priority_count
		queue_node = queue_head
		while (queue_node)
			if (ran && TICK_USAGE > TICK_LIMIT_RUNNING)
				break
			queue_node_flags = queue_node.flags
			queue_node_priority = queue_node.queued_priority

			if (!(queue_node_flags & SS_TICKER) && skip_ticks)
				queue_node = queue_node.queue_next
				continue

			if (!running_through_background_subsystems && (queue_node_flags & SS_BACKGROUND))
				current_tick_budget = queue_priority_count_bg
				running_through_background_subsystems = TRUE

			tick_remaining = TICK_LIMIT_RUNNING - TICK_USAGE

			if (current_tick_budget > 0 && queue_node_priority > 0)
				//Give the subsystem a precentage of the remaining tick based on the remaning priority
				tick_precentage = tick_remaining * (queue_node_priority / current_tick_budget)
			else
				tick_precentage = tick_remaining

			tick_precentage = max(tick_precentage*0.5, tick_precentage - queue_node.tick_overrun)

			current_ticklimit = round(TICK_USAGE + tick_precentage)

			ran = TRUE

			queue_node_paused = (queue_node.state == SS_PAUSED || queue_node.state == SS_PAUSING)
			last_type_processed = queue_node

			queue_node.state = SS_RUNNING

			tick_usage = TICK_USAGE
			var/subsystem_state_after_fire = queue_node.ignite(queue_node_paused)
			tick_usage = TICK_USAGE - tick_usage

			if (subsystem_state_after_fire == SS_RUNNING)
				subsystem_state_after_fire = SS_IDLE
			current_tick_budget -= queue_node_priority


			if (tick_usage < 0)
				tick_usage = 0
			queue_node.tick_overrun = max(0, MC_AVG_FAST_UP_SLOW_DOWN(queue_node.tick_overrun, tick_usage - tick_precentage))
			queue_node.state = subsystem_state_after_fire

			if (subsystem_state_after_fire == SS_PAUSED)
				queue_node.paused_ticks++
				queue_node.paused_tick_usage += tick_usage
				queue_node = queue_node.queue_next
				continue

			queue_node.ticks = MC_AVERAGE(queue_node.ticks, queue_node.paused_ticks)
			tick_usage += queue_node.paused_tick_usage

			queue_node.tick_usage = MC_AVERAGE_FAST(queue_node.tick_usage, tick_usage)

			queue_node.cost = MC_AVERAGE_FAST(queue_node.cost, TICK_DELTA_TO_MS(tick_usage))
			queue_node.paused_ticks = 0
			queue_node.paused_tick_usage = 0

			if (running_through_background_subsystems) //update our running total
				queue_priority_count_bg -= queue_node_priority
			else
				queue_priority_count -= queue_node_priority

			queue_node.last_fire = world.time
			queue_node.times_fired++

			queue_node.update_nextfire()

			queue_node.queued_time = 0

			//remove from queue
			queue_node.dequeue()

			queue_node = queue_node.queue_next

	. = 1

///resets the queue, and all subsystems, while filtering out the subsystem lists
/// called if any mc's queue procs runtime or exit improperly.
/datum/controller/master/proc/SoftReset(list/ticker_SS, list/runlevel_SS)
	. = 0
	log_world("MC: SoftReset called, resetting MC queue state.")
	if (!istype(subsystems) || !istype(ticker_SS) || !istype(runlevel_SS))
		log_world("MC: SoftReset: Bad list contents: '[subsystems]' '[ticker_SS]' '[runlevel_SS]'")
		return
	var/subsystems_to_check = subsystems + ticker_SS
	for(var/I in runlevel_SS)
		subsystems_to_check |= I

	for (var/datum/controller/subsystem/subsystem as anything in subsystems_to_check)
		if (!istype(subsystem))
			//list(SS) is so if a list makes it in the subsystem list, we remove the list, not the contents
			subsystems -= list(subsystem)
			ticker_SS -= list(subsystem)
			for(var/I in runlevel_SS)
				I -= list(subsystem)
			log_world("MC: SoftReset: Found bad entry in subsystem list, '[subsystem]'")
			continue
		if (subsystem.queue_next && !istype(subsystem.queue_next))
			log_world("MC: SoftReset: Found bad data in subsystem queue, queue_next = '[subsystem.queue_next]'")
		subsystem.queue_next = null
		if (subsystem.queue_prev && !istype(subsystem.queue_prev))
			log_world("MC: SoftReset: Found bad data in subsystem queue, queue_prev = '[subsystem.queue_prev]'")
		subsystem.queue_prev = null
		subsystem.queued_priority = 0
		subsystem.queued_time = 0
		subsystem.state = SS_IDLE
	if (queue_head && !istype(queue_head))
		log_world("MC: SoftReset: Found bad data in subsystem queue, queue_head = '[queue_head]'")
	queue_head = null
	if (queue_tail && !istype(queue_tail))
		log_world("MC: SoftReset: Found bad data in subsystem queue, queue_tail = '[queue_tail]'")
	queue_tail = null
	queue_priority_count = 0
	queue_priority_count_bg = 0
	log_world("MC: SoftReset: Finished.")
	. = 1

/// Warns us that the end of tick byond map_update will be laggier then normal, so that we can just skip running subsystems this tick.
/datum/controller/master/proc/laggy_byond_map_update_incoming()
	if (!skip_ticks)
		skip_ticks = 1


/datum/controller/master/stat_entry(msg)
	msg = "(TickRate:[Master.processing]) (Iteration:[Master.iteration]) (TickLimit: [round(Master.current_ticklimit, 0.1)]) (Average Starting Tick Usage: [round(Master.average_starting_tick_usage, 0.1)])"
	return msg


/datum/controller/master/StartLoadingMap()
	//disallow more than one map to load at once, multithreading it will just cause race conditions
	while(map_loading)
		stoplag()
	for(var/datum/controller/subsystem/subsystem as anything in subsystems)
		subsystem.StartLoadingMap()
	map_loading = TRUE

/datum/controller/master/StopLoadingMap(bounds = null)
	map_loading = FALSE
	for(var/datum/controller/subsystem/subsystem as anything in subsystems)
		subsystem.StopLoadingMap()


/datum/controller/master/proc/UpdateTickRate()
	if (!processing)
		return
	var/client_count = length(GLOB.clients)
	if (client_count < CONFIG_GET(number/mc_tick_rate/disable_high_pop_mc_mode_amount))
		processing = CONFIG_GET(number/mc_tick_rate/base_mc_tick_rate)
	else if (client_count > CONFIG_GET(number/mc_tick_rate/high_pop_mc_mode_amount))
		processing = CONFIG_GET(number/mc_tick_rate/high_pop_mc_tick_rate)

/datum/controller/master/proc/OnConfigLoad()
	for (var/datum/controller/subsystem/subsystem as anything in subsystems)
		subsystem.OnConfigLoad()
