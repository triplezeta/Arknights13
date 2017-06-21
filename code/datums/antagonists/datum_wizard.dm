/datum/antagonist/wizard
	name = "Wizard"
	var/special_role = "wizard"
	var/list/objectives_given
	var/mob/living/carbon/human/summoner //To remain null on a real wizard.

/datum/antagonist/wizard/apprentice
	name = "Wizard Apprentice"
	special_role = "apprentice"
	var/school = "robeless"

/datum/antagonist/wizard/can_be_owned()
	if(!ishuman(owner.current))
		return FALSE
	return ..()

/datum/antagonist/wizard/on_gain()
	SSticker.mode.wizards += owner
	owner.special_role = special_role
	return ..()

/datum/antagonist/wizard/proc/forge_wizard_objectives()
	switch(rand(1,100))
		if(1 to 30)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
			
			forge_escape_objective()

		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)
			
			forge_escape_objective()

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)
			
			forge_escape_objective()

		else if(!(locate(/datum/objective/hijack) in owner.objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
	return

/datum/antagonist/wizard/proc/forge_escape_objective()
	if(!(locate(/datum/objective/escape) in owner.objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)

/datum/antagonist/wizard/apply_innate_effects()
	forge_wizard_objectives()
	var/mob/living/carbon/human/H = owner.current
	H.equipOutfit(pick(/datum/outfit/wizard,/datum/outfit/wizard/red,/datum/outfit/wizard/weeb), summoner)
	finalize_wizard()
	INVOKE_ASYNC(src, name_wizard(summoner))
	return

/datum/antagonist/wizard/proc/finalize_wizard()
	to_chat(owner, "You will find a list of available spells in your spell book. Choose your magic arsenal carefully.")
	to_chat(owner, "The spellbook is bound to you, and others cannot use it.")
	to_chat(owner, "In your pockets you will find a teleport scroll. Use it as needed.")
	owner.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	SSticker.mode.update_wiz_icons_added(owner)
	return

/datum/antagonist/wizard/greet()
	to_chat(owner, "<span class='boldannounce'>You are the Space Wizard!</span>")
	to_chat(owner, "<B>The Space Wizards Federation has given you the following tasks:</B>")
	owner.announce_objectives()
	return

/datum/antagonist/wizard/proc/name_wizard()
	var/randomname = "[pick(GLOB.wizard_first)] [pick(GLOB.wizard_second)]"
	var/message = summoner ? "You are [summoner.real_name]'s apprentice." : "You are a 'diplomat' of the Wizard Federation."
	var/newname = copytext(sanitize(input(owner.current, "[message] Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)
	var/mob/living/carbon/human/H = owner.current
	if(!newname)
		newname = randomname
	H.real_name = newname
	H.name = newname
	owner.name = newname
	if(summoner)
		H.age = rand(AGE_MIN, WIZARD_AGE_MIN - 1)
	else if(H.age < WIZARD_AGE_MIN)
		H.age = WIZARD_AGE_MIN
	H.dna.update_dna_identity()
	return

/datum/antagonist/wizard/apprentice/forge_wizard_objectives()
	if(summoner)
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = owner
		new_objective.target = summoner.mind
		new_objective.explanation_text = "Protect [summoner.real_name], the wizard."
		add_objective(new_objective)
	else
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
	return

/datum/antagonist/wizard/apprentice/greet()
	if(summoner)
		to_chat(owner, "<B>You are [summoner.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals.</B>")
	else
		to_chat(owner, "<B>You are an apprentice of the Wizard Federation! You are bound by magic contract to serve the Federation for the rest of your immortal life.</B>")
	switch(school)
		if("destruction")
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile)
			owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball)
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying, you have learned powerful, destructive spells. You are able to cast magic missile and fireball.</B>")
		if("bluespace")
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt)
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying, you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt.</B>")
		if("healing")
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall)
			owner.current.put_in_hands_or_del(new /obj/item/weapon/gun/magic/staff/healing)
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying, you have learned livesaving survival spells. You are able to cast charge and forcewall.</B>")
		else
			owner.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer)
			to_chat(owner, "<B>Your service has not gone unrewarded, however. Studying, you have learned stealthy, robeless spells. You are able to cast knock and mindswap.</B>")

/datum/antagonist/wizard/proc/add_objective(var/datum/objective/O)
	owner.objectives += O
	LAZYADD(objectives_given, O)

/datum/antagonist/wizard/proc/remove_objective(var/datum/objective/O)
	owner.objectives -= O
	LAZYREMOVE(objectives_given, O)

/datum/antagonist/wizard/on_removal() 
	SSticker.mode.wizards -= owner
	for(var/O in objectives_given)
		owner.objectives -= O
	LAZYCLEARLIST(objectives_given)
	owner.special_role = null
	SSticker.mode.update_wiz_icons_removed(owner)
	..()
