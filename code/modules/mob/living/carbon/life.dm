/mob/living/carbon/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return

	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(..()) //not dead
		handle_blood()

	if(stat != DEAD)
		for(var/X in internal_organs)
			var/obj/item/organ/O = X
			O.on_life()

	//Updates the number of stored chemicals for powers
	handle_changeling()

	if(stat != DEAD)
		return 1

///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing()
	if(SSmob.times_fired%4==2 || failed_last_breath)
		breathe() //Breathe per 4 ticks, unless suffocating
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	if(reagents.has_reagent("lexorin"))
		return
	if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(health <= HEALTH_THRESHOLD_CRIT || (pulledby && pulledby.grab_state >= GRAB_KILL && !getorganslot("breathing_tube")))
		losebreath++

	//Suffocate
	if(losebreath > 0)
		losebreath--
		if(prob(10))
			emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(!breath)

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_moles = 0
				if(environment)
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)
		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	check_breath(breath)

	if(breath)
		loc.assume_air(breath)
		air_update_turf()

/mob/living/carbon/proc/has_smoke_protection()
	return 0


//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if((status_flags & GODMODE))
		return

	var/lungs = getorganslot("lungs")
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || (breath.total_moles() == 0) || !lungs)
		if(reagents.has_reagent("epinephrine") && lungs)
			return
		adjustOxyLoss(1)
		failed_last_breath = 1
		throw_alert("oxy", /obj/screen/alert/oxy)
		return 0

	//old defaults for if we don't have a species for whatever reason
	var/safe_oxygen_min = 16
	var/safe_oxygen_max = 100
	var/safe_co2_max = 10
	var/safe_co2_min = 0
	var/safe_tox_max = 0.05
	var/safe_tox_min = 0
	var/SA_para_min = 1
	var/SA_sleep_min = 5

	if(dna && dna.species)
		safe_oxygen_min = dna.species.safe_oxygen_min
		safe_oxygen_max = dna.species.safe_oxygen_max
		safe_co2_max = dna.species.safe_co2_max
		safe_co2_min = dna.species.safe_co2_min
		safe_tox_max = dna.species.safe_toxins_max
		safe_tox_min = dna.species.safe_toxins_min
		SA_para_min = dna.species.SA_para_min
		SA_para_min = dna.species.SA_para_min

	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/list/breath_gases = breath.gases
	breath.assert_gases("o2","plasma","co2","n2o", "bz")

	var/O2_partialpressure = (breath_gases["o2"][MOLES]/breath.total_moles())*breath_pressure
	var/Toxins_partialpressure = (breath_gases["plasma"][MOLES]/breath.total_moles())*breath_pressure
	var/CO2_partialpressure = (breath_gases["co2"][MOLES]/breath.total_moles())*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxygen_min || O2_partialpressure > safe_oxygen_max) //Not enough oxygen
		if(prob(20))
			emote("gasp")
		if(O2_partialpressure > 0 && O2_partialpressure < safe_oxygen_min)
			var/ratio = safe_oxygen_min/O2_partialpressure
			adjustOxyLoss(min(5*ratio, 3))
			oxygen_used = breath_gases["o2"][MOLES]*ratio
		else if(O2_partialpressure > safe_oxygen_max)
			//we burn when breathing too much oxy
			adjustFireLoss(3)
		else
			adjustOxyLoss(3)
		failed_last_breath = 1
		throw_alert("oxy", /obj/screen/alert/oxy)

	else //Enough oxygen
		failed_last_breath = 0
		if(oxyloss)
			adjustOxyLoss(-5)
		oxygen_used = breath_gases["o2"][MOLES]
		clear_alert("oxy")

	breath_gases["o2"][MOLES] -= oxygen_used
	breath_gases["co2"][MOLES] += oxygen_used

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max || CO2_partialpressure < safe_co2_min)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Paralyse(3)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max || Toxins_partialpressure < safe_tox_min)
		if(dna && istype(dna.species, /datum/species/plasmaman))
			//give plasmamen oxyloss, but they get the tox alert. it makes sense
			adjustOxyLoss(3)
		else if(reagents)
			var/ratio = (breath_gases["plasma"][MOLES]/safe_tox_max) * 10
			reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		throw_alert("tox_in_air", /obj/screen/alert/tox_in_air)
	else
		clear_alert("tox_in_air")

	//NITROUS OXIDE
	if(breath_gases["n2o"])
		var/SA_partialpressure = (breath_gases["n2o"][MOLES]/breath.total_moles())*breath_pressure
		if(SA_partialpressure > SA_para_min)
			Paralyse(3)
			if(SA_partialpressure > SA_sleep_min)
				Sleeping(max(sleeping+2, 10))
		else if(SA_partialpressure > 0.01)
			if(prob(20))
				emote(pick("giggle","laugh"))

	//BZ (Facepunch port of their Agent B)
	if(breath_gases["bz"])
		var/bz_partialpressure = (breath_gases["bz"][MOLES]/breath.total_moles())*breath_pressure
		if(bz_partialpressure > 1)
			hallucination += 20
		else if(bz_partialpressure > 0.01)
			hallucination += 5//Removed at 2 per tick so this will slowly build up

	breath.garbage_collect()

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return 1

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(internal.loc != src)
			internal = null
			update_internals_hud_icon(0)
		else if ((!wear_mask || !(wear_mask.flags & MASKINTERNALS)) && !getorganslot("breathing_tube"))
			internal = null
			update_internals_hud_icon(0)
		else
			update_internals_hud_icon(1)
			return internal.remove_air_volume(volume_needed)

/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_changeling()
	if(mind && hud_used && hud_used.lingchemdisplay)
		if(mind.changeling)
			mind.changeling.regenerate(src)
			hud_used.lingchemdisplay.invisibility = 0
			hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(mind.changeling.chem_charges)]</font></div>"
		else
			hud_used.lingchemdisplay.invisibility = INVISIBILITY_ABSTRACT


/mob/living/carbon/handle_mutations_and_radiation()
	if(dna && dna.temporary_mutations.len)
		var/datum/mutation/human/HM
		for(var/mut in dna.temporary_mutations)
			if(dna.temporary_mutations[mut] < world.time)
				if(mut == UI_CHANGED)
					if(dna.previous["UI"])
						dna.uni_identity = merge_text(dna.uni_identity,dna.previous["UI"])
						updateappearance(mutations_overlay_update=1)
						dna.previous.Remove("UI")
					dna.temporary_mutations.Remove(mut)
					continue
				if(mut == UE_CHANGED)
					if(dna.previous["name"])
						real_name = dna.previous["name"]
						name = real_name
						dna.previous.Remove("name")
					if(dna.previous["UE"])
						dna.unique_enzymes = dna.previous["UE"]
						dna.previous.Remove("UE")
					if(dna.previous["blood_type"])
						dna.blood_type = dna.previous["blood_type"]
						dna.previous.Remove("blood_type")
					dna.temporary_mutations.Remove(mut)
					continue
				HM = mutations_list[mut]
				HM.force_lose(src)
				dna.temporary_mutations.Remove(mut)

	if(radiation)

		switch(radiation)
			if(0 to 50)
				radiation = max(radiation-1,0)
				if(prob(25))
					adjustToxLoss(1)

			if(50 to 75)
				radiation = max(radiation-2,0)
				adjustToxLoss(1)
				if(prob(5))
					radiation = max(radiation-5,0)

			if(75 to 100)
				radiation = max(radiation-3,0)
				adjustToxLoss(3)
			else
				radiation = Clamp(radiation, 0, 100)

/mob/living/carbon/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)


/mob/living/carbon/handle_stomach()
	set waitfor = 0
	for(var/mob/living/M in stomach_contents)
		if(M.loc != src)
			stomach_contents.Remove(M)
			continue
		if(istype(M, /mob/living/carbon) && stat != DEAD)
			if(M.stat == DEAD)
				M.death(1)
				stomach_contents.Remove(M)
				qdel(M)
				continue
			if(SSmob.times_fired%3==1)
				if(!(M.status_flags & GODMODE))
					M.adjustBruteLoss(5)
				nutrition += 10

//this updates all special effects: stunned, sleeping, weakened, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects()
	..()

	if(staminaloss)
		if(sleeping)
			adjustStaminaLoss(-10)
		else
			adjustStaminaLoss(-3)

	if(sleeping)
		handle_dreams()
		AdjustSleeping(-1)
		if(prob(10) && health>HEALTH_THRESHOLD_CRIT)
			emote("snore")

	var/restingpwr = 1 + 4 * resting

	//Dizziness
	if(dizziness)
		var/client/C = client
		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/temp
		var/saved_dizz = dizziness
		if(C)
			var/oldsrc = src
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70 // This shit is annoying at high strength
			src = null
			spawn(0)
				if(C)
					temp = amplitude * sin(0.008 * saved_dizz * world.time)
					pixel_x_diff += temp
					C.pixel_x += temp
					temp = amplitude * cos(0.008 * saved_dizz * world.time)
					pixel_y_diff += temp
					C.pixel_y += temp
					sleep(3)
					if(C)
						temp = amplitude * sin(0.008 * saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(0.008 * saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
					sleep(3)
					if(C)
						C.pixel_x -= pixel_x_diff
						C.pixel_y -= pixel_y_diff
			src = oldsrc
		dizziness = max(dizziness - restingpwr, 0)

	if(drowsyness)
		drowsyness = max(drowsyness - restingpwr, 0)
		blur_eyes(2)
		if(prob(5))
			AdjustSleeping(1)
			Paralyse(5)

	//Jitteryness
	if(jitteriness)
		do_jitter_animation(jitteriness)
		jitteriness = max(jitteriness - restingpwr, 0)

	if(stuttering)
		stuttering = max(stuttering-1, 0)

	if(slurring)
		slurring = max(slurring-1,0)

	if(cultslurring)
		cultslurring = max(cultslurring-1, 0)

	if(silent)
		silent = max(silent-1, 0)

	if(druggy)
		adjust_drugginess(-1)

	if(hallucination)
		spawn handle_hallucinations()
		hallucination = max(hallucination-2,0)

//used in human and monkey handle_environment()
/mob/living/carbon/proc/natural_bodytemperature_stabilization()
	var/body_temperature_difference = 310.15 - bodytemperature
	switch(bodytemperature)
		if(-INFINITY to 260.15) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
			bodytemperature += max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		if(260.15 to 310.15)
			bodytemperature += max(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, min(body_temperature_difference, BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(310.15 to 360.15)
			bodytemperature += min(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, max(body_temperature_difference, -BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(360.15 to INFINITY) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
			//We totally need a sweat system cause it totally makes sense...~
			bodytemperature += min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers
