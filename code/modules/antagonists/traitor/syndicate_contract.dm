/datum/syndicate_contract
	var/id = 0
	var/status = CONTRACT_STATUS_INACTIVE
	var/datum/objective/contract/contract = new()
	var/ransom = 0

	var/list/victim_belongings = list()

/datum/syndicate_contract/New(owner, type, blacklist)
	generate(owner, type)

/datum/syndicate_contract/proc/generate(owner, type, blacklist)
	contract.owner = owner
	contract.find_target(null, blacklist)

	if (type == CONTRACT_PAYOUT_LARGE)
		contract.payout_bonus = rand(8,12)
	else if (type == CONTRACT_PAYOUT_MEDIUM)
		contract.payout_bonus = rand(5,7)
	else
		contract.payout_bonus = rand(2,4)

	contract.payout = rand(0, 3)
	contract.generate_dropoff()

	ransom = 100 * rand(18, 45)

/datum/syndicate_contract/proc/handle_extraction(var/mob/living/user)
	if (contract.target && contract.dropoff_check(user, contract.target.current))

		var/list/turfs = RANGE_TURFS(3, user)
		var/list/possible_drop_loc = list()

		for(var/T in turfs)
			var/turf/found_turf = T
			var/area/turf_area = get_area(found_turf)

			// We check if both the turf is a floor, and that it's actually in the area. 
			// We also want a location that's clear of any obstructions.
			var/location_clear = TRUE
			if (isfloorturf(found_turf) && istype(turf_area, contract.dropoff))
				for (var/content in found_turf.contents)
					if (istype(content, /obj/machinery) || istype(content, /obj/structure))
						location_clear = FALSE
				if (location_clear)
					possible_drop_loc.Add(found_turf)

		// Need at least one free location.
		if (possible_drop_loc.len < 1)
			return FALSE

		var/pod_rand_loc = rand(1, possible_drop_loc.len)

		// We've got a valid location, launch.
		launch_extraction_pod(possible_drop_loc[pod_rand_loc])
		return 1
	return 0

// Launch the pod to collect our victim.
/datum/syndicate_contract/proc/launch_extraction_pod(turf/empty_pod_turf)
	var/obj/structure/closet/supplypod/extractionpod/empty_pod = new()
	
	RegisterSignal(empty_pod, COMSIG_ATOM_ENTERED, .proc/enter_check)

	empty_pod.stay_after_drop = TRUE
	empty_pod.reversing = TRUE
	empty_pod.explosionSize = list(0,0,2,1)
	empty_pod.leavingSound = 'sound/effects/podwoosh.ogg'

	new /obj/effect/DPtarget(empty_pod_turf, empty_pod)

/datum/syndicate_contract/proc/enter_check(datum/source, sent_mob)
	if (istype(source, /obj/structure/closet/supplypod/extractionpod))
		if (isliving(sent_mob))
			var/mob/living/M = sent_mob
			var/datum/antagonist/traitor/traitor_data = contract.owner.has_antag_datum(/datum/antagonist/traitor)
			
			if (M == contract.target.current)
				traitor_data.contract_TC_to_redeem += contract.payout

				if (M.stat != DEAD)
					traitor_data.contract_TC_to_redeem += contract.payout_bonus

				status = CONTRACT_STATUS_COMPLETE

				if (traitor_data.current_contract == src) 
					traitor_data.current_contract = null
	
			else
				status = CONTRACT_STATUS_ABORTED // Sending a target that wasn't even yours is as good as just aborting it
				
				if (traitor_data.current_contract == src) 
					traitor_data.current_contract = null

			for(var/obj/item/W in M)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if(W == H.w_uniform)
						continue //So all they're left with are shoes and uniform.
					if(W == H.shoes)
						continue
				
				M.transferItemToLoc(W)
				victim_belongings.Add(W)

			handleVictimExperience(M)

			// This is slightly delayed because of the sleep calls above to handle the narrative. 
			// We don't want to tell the station instantly.
			var/points_to_check
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)

			if(D)
				points_to_check = D.account_balance

			if(points_to_check >= ransom)
				D.adjust_money(-ransom)
			else 
				D.adjust_money(-points_to_check)
			
			priority_announce("One of your crew was captured by a rival organisation - we've needed to pay their ransom to bring them back. \
								As is policy we've taken a portion of the station's funds to offset the overall cost.", null, 'sound/ai/attention.ogg', null, "Nanotrasen Asset Protection")

// They're off to holding - handle the return timer and give some text about what's going on.
/datum/syndicate_contract/proc/handleVictimExperience(var/mob/living/M)
	// Ship 'em back - dead or alive, it depends on if the Syndicate get paid... 5 minutes wait.
	// Even if they weren't the target, we're still treating them the same.
	addtimer(CALLBACK(src, .proc/returnVictim, M), (60 * 10) * 5)

	if (M.stat != DEAD)
		M.flash_act()
		M.confused += 10
		M.blur_eyes(5)
		to_chat(M, "<span class='warning'>You feel strange...</span>")
		sleep(60)
		to_chat(M, "<span class='warning'>That pod did something to you...</span>")
		M.Dizzy(35)
		sleep(65)
		to_chat(M, "<span class='warning'>Your head pounds... It feels like it's going to burst out your skull!</span>")
		M.flash_act()
		M.confused += 20
		M.blur_eyes(3)
		sleep(30)
		to_chat(M, "<span class='warning'>Your head pounds...</span>")
		sleep(100)
		M.flash_act()
		M.Unconscious(200)
		to_chat(M, "<span class='reallybig hypnophrase'>A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
					we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
					so it's only a matter of time before we ship you back...\"</i></span>")
		M.blur_eyes(10)
		M.Dizzy(15)
		M.confused += 20

// We're returning the victim
/datum/syndicate_contract/proc/returnVictim(var/mob/living/M)
	var/list/possible_drop_loc = list()

	for (var/turf/possible_drop in contract.dropoff.contents)
		var/location_clear = TRUE
		// We don't care as much about what we land on than we did for sending the pod down.
		if (!isspaceturf(possible_drop) && !isclosedturf(possible_drop))
			for (var/content in possible_drop.contents)
				if (istype(content, /obj/machinery) || istype(content, /obj/structure))
					location_clear = FALSE
			if (location_clear)
				possible_drop_loc.Add(possible_drop)

	if (possible_drop_loc.len > 0)
		var/pod_rand_loc = rand(1, possible_drop_loc.len)
		
		var/obj/structure/closet/supplypod/return_pod = new()
		return_pod.bluespace = TRUE
		return_pod.explosionSize = list(0,0,0,0)
		return_pod.style = STYLE_SYNDICATE

		do_sparks(8, FALSE, M)
		M.visible_message("<span class='notice'>[M] vanishes...</span>")

		for(var/obj/item/W in M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(W == H.w_uniform)
					continue //So all they're left with are shoes and uniform.
				if(W == H.shoes)
					continue
			M.dropItemToGround(W)

		for(var/obj/item/W in victim_belongings)
			W.forceMove(return_pod)
		
		M.forceMove(return_pod)

		M.flash_act()
		M.blur_eyes(30)
		M.Dizzy(35)
		M.confused += 20

		new /obj/effect/DPtarget(possible_drop_loc[pod_rand_loc], return_pod)
	else
		to_chat(M, "<span class='reallybig hypnophrase'>A million voices echo in your head... <i>\"Seems where you got sent here from won't \
					be able to handle our pod... You will die here instead.\"</i></span>")
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.can_heartattack())
				C.set_heartattack(TRUE)

