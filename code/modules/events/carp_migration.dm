/datum/round_event_control/carp_migration
	name = "Carp Migration"
	typepath = /datum/round_event/carp_migration
	weight = 15
	min_players = 2
	earliest_start = 10 MINUTES
	max_occurrences = 6

/datum/round_event/carp_migration
	announceWhen	= 3
	startWhen = 50

/datum/round_event/carp_migration/setup()
	startWhen = rand(40, 60)

/datum/round_event/carp_migration/announce(fake)
	priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")


/datum/round_event/carp_migration/start()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(prob(95))
			var/mob/living/simple_animal/hostile/carp/fish = new (C.loc)
			if (!atom_of_interest)
				atom_of_interest = fish //Assign the atom of interest to the first carp to spawn
		else
			if (!atom_of_interest)
				atom_of_interest = fish //Assign the atom of interest to the first carp to spawn
			new /mob/living/simple_animal/hostile/carp/megacarp(C.loc)


