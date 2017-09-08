/datum/disease/magnitis
	name = "Magnitis"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Iron"
	cures = list("iron")
	agent = "Fukkos Miracos"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 0.75
	desc = "This disease disrupts the magnetic field of your body, making it act as if a powerful magnet. Injections of iron help stabilize the field."
	severity = MEDIUM

/datum/disease/magnitis/stage_act()
	..()
	switch(stage)
		if(2)
			if(SSrng.probability(2))
				to_chat(affected_mob, "<span class='danger'>You feel a slight shock course through your body.</span>")
			if(SSrng.probability(2))
				for(var/obj/M in orange(2,affected_mob))
					if(!M.anchored && (M.flags_1 & CONDUCT_1))
						step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(2,affected_mob))
					if(isAI(S))
						continue
					step_towards(S,affected_mob)
		if(3)
			if(SSrng.probability(2))
				to_chat(affected_mob, "<span class='danger'>You feel a strong shock course through your body.</span>")
			if(SSrng.probability(2))
				to_chat(affected_mob, "<span class='danger'>You feel like clowning around.</span>")
			if(SSrng.probability(4))
				for(var/obj/M in orange(4,affected_mob))
					if(!M.anchored && (M.flags_1 & CONDUCT_1))
						var/i
						var/iter = SSrng.random(1,2)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(4,affected_mob))
					if(isAI(S))
						continue
					var/i
					var/iter = SSrng.random(1,2)
					for(i=0,i<iter,i++)
						step_towards(S,affected_mob)
		if(4)
			if(SSrng.probability(2))
				to_chat(affected_mob, "<span class='danger'>You feel a powerful shock course through your body.</span>")
			if(SSrng.probability(2))
				to_chat(affected_mob, "<span class='danger'>You query upon the nature of miracles.</span>")
			if(SSrng.probability(8))
				for(var/obj/M in orange(6,affected_mob))
					if(!M.anchored && (M.flags_1 & CONDUCT_1))
						var/i
						var/iter = SSrng.random(1,3)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(6,affected_mob))
					if(isAI(S))
						continue
					var/i
					var/iter = SSrng.random(1,3)
					for(i=0,i<iter,i++)
						step_towards(S,affected_mob)
	return