/*
//////////////////////////////////////

Coughing

	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmissibile.
	Low Level.

BONUS
	Will force the affected mob to drop small items!

//////////////////////////////////////
*/

/datum/symptom/cough

	name = "Cough"
	desc = "The virus irritates the throat of the host, causing occasional coughing. Each cough will try to infect bystanders who are within 1 tile of the host with the virus."
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 2
	level = 1
	severity = 1
	base_message_chance = 15
	symptom_delay_min = 2
	symptom_delay_max = 15
	var/spread_range = 1
	threshold_desc = "<b>Resistance 11:</b> The host will drop small items when coughing.<br>\
					  <b>Resistance 15:</b> Occasionally causes coughing fits that stun the host and spread the virus.<br>\
					  <b>Stage Speed 6:</b> Increases cough frequency.<br>\
					  <b>Transmission 7:</b> Coughing will now infect bystanders up to 2 tiles away.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/cough/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["transmittable"] >= 7)
		spread_range = 2
	if(A.properties["resistance"] >= 11) //strong enough to drop items
		power = 1.5
	if(A.properties["resistance"] >= 15) //strong enough to stun (occasionally)
		power = 2
	if(A.properties["stage_rate"] >= 6) //cough more often
		symptom_delay_max = 10

/datum/symptom/cough/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span notice='warning'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>")
		else
			M.emote("cough")
			A.spread(spread_range)
			if(power >= 1.5)
				var/obj/item/I = M.get_active_held_item()
				if(I && I.w_class == WEIGHT_CLASS_TINY)
					M.dropItemToGround(I)
			if(power >= 2 && prob(30))
				to_chat(M, "<span notice='userdanger'>[pick("You have a coughing fit!", "You can't stop coughing!")]</span>")
				M.Immobilize(20)
				addtimer(CALLBACK(M, /mob/.proc/emote, "cough"), 6)
				addtimer(CALLBACK(A, /disease/.proc/spread, spread_range), 6)
				addtimer(CALLBACK(M, /mob/.proc/emote, "cough"), 12)
				addtimer(CALLBACK(A, /disease/.proc/spread, spread_range), 12)
				addtimer(CALLBACK(M, /mob/.proc/emote, "cough"), 18)
				addtimer(CALLBACK(A, /disease/.proc/spread, spread_range), 18)
