/datum/round_event_control/vent_clog
	name = "Clogged Vents: Normal"
	typepath = /datum/round_event/vent_clog
	weight = 10
	max_occurrences = 3
	min_players = 25

/datum/round_event/vent_clog
	announceWhen	= 1
	startWhen		= 5
	endWhen			= 35
	var/interval 	= 2
	var/list/vents  = list()
	var/randomProbability = 1
	var/reagentsAmount = 100
	var/list/saferChems = list("water","carbon","flour","cleaner","nutriment","condensedcapsaicin","mushroomhallucinogen","lube","pink_glitter",
						 "plantbgone","blood","charcoal","space_drugs","morphine","holywater","ethanol","hot_coco","sacid","mindbreaker","rotatium",
						 "pax","laughter","concentrated_barbers_aid","colorful_reagent","dizzysolution","tiresolution")

/datum/round_event/vent_clog/announce()
	priority_announce("The scrubbers network is experiencing a backpressure surge. Some ejection of contents may occur.", "Atmospherics alert")

/datum/round_event/vent_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			vents += temp_vent
	if(!vents.len)
		return kill()

/datum/round_event/vent_clog/start()
	for(var/obj/machinery/atmospherics/components/unary/vent in vents)
		if(vent && vent.loc)
			var/datum/reagents/R = new/datum/reagents(1000)
			R.my_atom = vent
			if (prob(randomProbability))
				R.add_reagent(get_random_reagent_id(), reagentsAmount)
			else
				R.add_reagent(pick(saferChems), reagentsAmount)

			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(200, get_turf(vent), R)
			foam.start()

			var/cockroaches = prob(33) ? 3 : 0
			while(cockroaches)
				new /mob/living/simple_animal/cockroach(get_turf(vent))
				cockroaches--
		CHECK_TICK

/datum/round_event_control/vent_clog/threatening
	name = "Clogged Vents: Threatening"
	typepath = /datum/round_event/vent_clog/threatening
	weight = 4
	min_players = 35
	max_occurrences = 1
	earliest_start = 35 MINUTES

/datum/round_event/vent_clog/threatening
	randomProbability = 10
	reagentsAmount = 200

/datum/round_event_control/vent_clog/catastrophic
	name = "Clogged Vents: Catastrophic"
	typepath = /datum/round_event/vent_clog/catastrophic
	weight = 2
	min_players = 45
	max_occurrences = 1
	earliest_start = 45 MINUTES

/datum/round_event/vent_clog/catastrophic
	randomProbability = 30
	reagentsAmount = 250
