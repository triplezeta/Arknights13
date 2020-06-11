/datum/round_event_control/spawn_swarmer
	name = "Spawn Swarmer Beacon"
	typepath = /datum/round_event/spawn_swarmer
	weight = 8
	max_occurrences = 1 //Only once okay fam
	earliest_start = 30 MINUTES
	min_players = 15

/datum/round_event/spawn_swarmer/announce(fake)
	priority_announce("Our long-range sensors have detected that your station's defenses have been breached by some sort of alien device.  We suggest searching for and destroying it as soon as possible.", "[command_name()] High-Priority Update")

/datum/round_event/spawn_swarmer
	announceWhen = 70

/datum/round_event/spawn_swarmer/start()
	var/list/spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T
	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	var/obj/structure/swarmer_beacon/new_beacon = new /obj/structure/swarmer_beacon(pick(spawn_locs))
	log_game("A Swarmer Beacon was spawned via an event.")
	notify_ghosts("\A Swarmer Beacon has spawned!", source = new_beacon, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Swarmer Beacon Spawned")
