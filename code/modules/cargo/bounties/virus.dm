/datum/bounty/virus
	reward = CARGO_CRATE_VALUE * 10
	var/shipped = FALSE
	var/stat_value = 0
	var/stat_name = ""

/datum/bounty/virus/New()
	..()
	stat_value = rand(4, 11)
	if(rand(3) == 1)
		stat_value *= -1
	name = "Virus ([stat_name] of [stat_value])"
	description = "Nanotrasen is interested in a virus with a [stat_name] stat of exactly [stat_value]. Central Command will pay handsomely for such a virus."
	reward += rand(0, 4) * CARGO_CRATE_VALUE

/datum/bounty/virus/can_claim()
	return ..() && shipped

/datum/bounty/virus/applies_to(obj/O)
	if(shipped)
		return FALSE
	if(O.atom_flags & HOLOGRAM)
		return FALSE
	if(!istype(O, /obj/item/reagent_containers || !O.reagents || !O.reagents.reagent_list))
		return FALSE
	var/datum/reagent/blood/B = locate() in O.reagents.reagent_list
	if(!B)
		return FALSE
	for(var/V in B.get_diseases())
		if(!istype(V, /datum/disease/advance))
			continue
		if(accepts_virus(V))
			return TRUE
	return FALSE

/datum/bounty/virus/ship(obj/O)
	if(!applies_to(O))
		return
	shipped = TRUE


/datum/bounty/virus/proc/accepts_virus(V)
	return TRUE

/datum/bounty/virus/resistance
	stat_name = "resistance"

/datum/bounty/virus/resistance/accepts_virus(V)
	var/datum/disease/advance/A = V
	return A.totalResistance() == stat_value

/datum/bounty/virus/stage_speed
	stat_name = "stage speed"

/datum/bounty/virus/stage_speed/accepts_virus(V)
	var/datum/disease/advance/A = V
	return A.totalStageSpeed() == stat_value

/datum/bounty/virus/stealth
	stat_name = "stealth"

/datum/bounty/virus/stealth/accepts_virus(V)
	var/datum/disease/advance/A = V
	return A.totalStealth() == stat_value

/datum/bounty/virus/transmit
	stat_name = "transmissible"

/datum/bounty/virus/transmit/accepts_virus(V)
	var/datum/disease/advance/A = V
	return A.totalTransmittable() == stat_value

