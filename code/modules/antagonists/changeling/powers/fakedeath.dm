/datum/action/changeling/fakedeath
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE
	var/revive_ready = FALSE

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fakedeath/sting_action(mob/living/user)
	if(revive_ready)
		if((user.stat != DEAD) && !(user.has_trait(TRAIT_FAKEDEATH)))//if they get cloned or something dont give them a free full heal
			revive_ready = FALSE
			name = "Reviving Stasis"
			desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
			button_icon_state = "fake_death"
			UpdateButtonIcon()
			chemical_cost = 15
			return FALSE
		user.cure_fakedeath("changeling")
		user.revive(full_heal = 1)
		var/list/missing = user.get_missing_limbs()
		missing -= "head" // headless changelings are funny
		if(missing.len)
			playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
			user.visible_message("<span class='warning'>[user]'s missing limbs \
			reform, making a loud, grotesque sound!</span>",
			"<span class='userdanger'>Your limbs regrow, making a \
			loud, crunchy sound and giving you great pain!</span>",
			"<span class='italics'>You hear organic matter ripping \
			and tearing!</span>")
			user.emote("scream")
			user.regenerate_limbs(0, list("head"))
		user.regenerate_organs()
		to_chat(user, "<span class='notice'>We have revived ourselves.</span>")
		revive_ready = FALSE
		name = "Reviving Stasis"
		desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
		button_icon_state = "fake_death"
		UpdateButtonIcon()
		chemical_cost = 15
		return TRUE

	to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
	if(user.stat != DEAD)
		user.emote("deathgasp")
		user.tod = worldtime2text()
	user.fakedeath("changeling") //play dead
	user.update_stat()
	user.update_canmove()

	addtimer(CALLBACK(src, .proc/ready_to_regenerate, user), LING_FAKEDEATH_TIME, TIMER_UNIQUE)
	return TRUE

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(user && user.mind)
		var/datum/antagonist/changeling/C = user.mind.has_antag_datum(/datum/antagonist/changeling)
		if(C && C.purchasedpowers)
			to_chat(user, "<span class='notice'>We are ready to revive.</span>")
			name = "Revive"
			desc = "We arise once more."
			button_icon_state = "revive"
			UpdateButtonIcon()
			chemical_cost = 0
			revive_ready = TRUE

/datum/action/changeling/fakedeath/can_sting(mob/living/user)
	if(user.has_trait(TRAIT_FAKEDEATH, "changeling"))
		to_chat(user, "<span class='warning'>We are already reviving.</span>")
		return
	if(!user.stat) //Confirmation for living changelings if they want to fake their death
		switch(alert("Are we sure we wish to fake our own death?",,"Yes", "No"))
			if("No")
				return
	return ..()
