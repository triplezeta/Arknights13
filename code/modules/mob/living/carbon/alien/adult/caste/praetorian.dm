/mob/living/carbon/alien/adult/royal/praetorian
	name = "alien praetorian"
	caste = "p"
	maxHealth = 250
	health = 250
	icon_state = "alienp"
	alien_speed = 0.5

/mob/living/carbon/alien/adult/royal/praetorian/Initialize(mapload)
	real_name = name

	var/static/list/innate_actions = list(
		/datum/action/cooldown/alien/evolve_to_queen,
		/datum/action/cooldown/spell/aoe/repulse/xeno,
	)

	grant_actions_by_list(innate_actions)

	return ..()

/mob/living/carbon/alien/adult/royal/praetorian/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel/large
	organs += new /obj/item/organ/internal/alien/resinspinner
	organs += new /obj/item/organ/internal/alien/acid
	organs += new /obj/item/organ/internal/alien/neurotoxin
	return ..()

/datum/action/cooldown/alien/evolve_to_queen
	name = "Evolve"
	desc = "Produce an internal egg sac capable of spawning children. Only one queen can exist at a time."
	button_icon_state = "alien_evolve_praetorian"
	plasma_cost = 500

/datum/action/cooldown/alien/evolve_to_queen/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE
	var/mob/living/carbon/alien/alien = get_alien_type(/mob/living/carbon/alien/adult/royal/queen)
	if(alien && alien.infertile == FALSE) //The crew can get infertile aliens, we dont want those going towards the queen cap
		return FALSE

	var/mob/living/carbon/alien/adult/royal/evolver = owner
	var/obj/item/organ/internal/alien/hivenode/node = evolver.get_organ_by_type(/obj/item/organ/internal/alien/hivenode)
	if(!node || node.recent_queen_death)
		return FALSE

	return TRUE

/datum/action/cooldown/alien/evolve_to_queen/Activate(atom/target)
	var/mob/living/carbon/alien/adult/royal/evolver = owner
	var/mob/living/carbon/alien/adult/royal/queen/new_queen = new(owner.loc)
	// If we are infertile, replace the queens eggsac with an eggsac that lays sterile eggs
	if (evolver.infertile == TRUE)
		var/obj/item/organ/internal/alien/eggsac/eggsac = new_queen.get_organ_slot(ORGAN_SLOT_XENO_EGGSAC)
		qdel(eggsac)
		var/obj/item/organ/internal/alien/eggsac/sterile/new_eggsac = new()
		new_queen.organs += new_eggsac
		new_eggsac.Insert(new_queen)

	evolver.alien_evolve(new_queen)
	return TRUE
