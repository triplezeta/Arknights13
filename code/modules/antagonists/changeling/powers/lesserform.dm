/datum/action/changeling/lesserform
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 1
	req_human = 1

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return FALSE
	to_chat(user, "<span class='warning'>Our genes cry out!</span>")
	..()
	user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE | TR_KEEPSTAMINADAMAGE)

	// Remove all old stolen skillchip traits.
	for(var/T in user.status_traits)
		if(CHANGELING_SKILLCHIP_TRAIT in user.status_traits[T])
			REMOVE_TRAIT(user, T, CHANGELING_SKILLCHIP_TRAIT)

	return TRUE
