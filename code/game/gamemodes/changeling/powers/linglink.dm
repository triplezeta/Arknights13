/obj/effect/proc_holder/changeling/linglink
	name = "Hivemind Link"
	desc = "Link your victim's mind into the hivemind for personal interrogation"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/linglink/can_sting(mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.islinking)
		user << "<span class='warning'>We have already formed a link with the victim!</span>"
		return
  if(!target.mind)
    user << "<span class='warning'>The victim has no mind to link to!</span>"
		return
	if(target.mind.changeling)
	  user << "<span class='warning'>The victim is already a part of the hivemind!</span>"
		return	
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		user << "<span class='warning'>We must be tightly grabbing a creature in our active hand to link with them!</span>"
		return
	if(G.state <= GRAB_NECK)
		user << "<span class='warning'>We must have a tighter grip to absorb this creature!</span>"
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)



/obj/effect/proc_holder/changeling/linglink/sting_action(mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	changeling.islinking = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				user << "<span class='notice'>We stealthily stab [target] with a minor proboscis...</span>")
				target << "<span class='userdanger'>You experience a stabbing sensation and your ears begin to ring...</span>"
			if(3)
        user << "<span class='notice'>You mold the [target]'s mind like clay, they can now speak in the hivemind!</span>")
				target << "<span class='userdanger'>A migraine throbs behind your eyes, you hear yourself screaming - but your mouth has not opened!</span>"
				var/datum/mind/linglink = target.mind
				linglinkID = target.name
				target << "<font color=#800040><span class='boldannounce'>You can now communicate in the changeling hivemind, say \":g message\" to communicate!</span>"
				sleep(1800)
				
		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 20))
			user << "<span class='warning'>Our link with the [target] has ended!</span>"
			changeling.islinking = 0
			return

	changeling.islinking = 0
	target.mind.linglink = 0
	user << "<span class='notice'>You cannot sustain the connection any longer, your victim fades from the hivemind</span>")
	target << "<span class='userdanger'>The link cannot be sustained any long, your connection to the hivemind has faded!</span>"
