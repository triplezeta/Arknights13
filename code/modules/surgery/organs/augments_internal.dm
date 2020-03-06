#define OWNER 0
#define OVERRIDER 1
/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

/obj/item/organ/cyberimp/New(var/mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()



//[[[[BRAIN]]]]

/obj/item/organ/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "Injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/brain/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/stun_amount = 200/severity
	owner.Stun(stun_amount)
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")


/obj/item/organ/cyberimp/brain/anti_drop
	name = "anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = 0
	var/list/stored_items = list()
	implant_color = "#DE7E00"
	slot = ORGAN_SLOT_BRAIN_ANTIDROP
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		for(var/obj/item/I in owner.held_items)
			stored_items += I

		var/list/L = owner.get_empty_held_indexes()
		if(LAZYLEN(L) == owner.held_items.len)
			to_chat(owner, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = 0
			stored_items = list()
		else
			for(var/obj/item/I in stored_items)
				to_chat(owner, "<span class='notice'>Your [owner.get_held_index_name(owner.get_held_index_of_item(I))]'s grip tightens.</span>")
				ADD_TRAIT(I, TRAIT_NODROP, ANTI_DROP_IMPLANT_TRAIT)

	else
		release_items()
		to_chat(owner, "<span class='notice'>Your hands relax...</span>")


/obj/item/organ/cyberimp/brain/anti_drop/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	if(active)
		release_items()
	for(var/obj/item/I in stored_items)
		A = pick(oview(range))
		I.throw_at(A, range, 2)
		to_chat(owner, "<span class='warning'>Your [owner.get_held_index_name(owner.get_held_index_of_item(I))] spasms and throws the [I.name]!</span>")
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/proc/release_items()
	for(var/obj/item/I in stored_items)
		REMOVE_TRAIT(I, TRAIT_NODROP, ANTI_DROP_IMPLANT_TRAIT)
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/Remove(var/mob/living/carbon/M, special = 0)
	if(active)
		ui_action_click()
	..()

/obj/item/organ/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	slot = ORGAN_SLOT_BRAIN_ANTISTUN

	var/static/list/signalCache = list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_PARALYZE,
	)

	var/stun_cap_amount = 40

/obj/item/organ/cyberimp/brain/anti_stun/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	UnregisterSignal(M, signalCache)

/obj/item/organ/cyberimp/brain/anti_stun/Insert()
	. = ..()
	RegisterSignal(owner, signalCache, .proc/on_signal)

/obj/item/organ/cyberimp/brain/anti_stun/proc/on_signal(datum/source, amount)
	if(!(organ_flags & ORGAN_FAILING) && amount > 0)
		addtimer(CALLBACK(src, .proc/clear_stuns), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/cyberimp/brain/anti_stun/proc/clear_stuns()
	if(owner || !(organ_flags & ORGAN_FAILING))
		owner.SetStun(0)
		owner.SetKnockdown(0)
		owner.SetImmobilized(0)
		owner.SetParalyzed(0)

/obj/item/organ/cyberimp/brain/anti_stun/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, .proc/reboot), 90 / severity)

/obj/item/organ/cyberimp/brain/anti_stun/proc/reboot()
	organ_flags &= ~ORGAN_FAILING

//[[[[MOUTH]]]]
/obj/item/organ/cyberimp/mouth
	zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/mouth/breathing_tube/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(60/severity))
		to_chat(owner, "<span class='warning'>Your breathing tube suddenly closes!</span>")
		owner.losebreath += 2

/obj/item/organ/cyberimp/brain/neural_override
	name = "neural override implant"
	desc = "This cybernetic brain implant is imprinted with a sentient mind, and can take over the patient's body at will."
	slot = ORGAN_SLOT_BRAIN_OVERRIDE
	icon_state = "neural_override"
	w_class = WEIGHT_CLASS_MEDIUM
	var/current_controller = OWNER
	var/obj/item/organ/brain/overrider_brain ///The brain stored inside the implant
	var/mob/living/neural_storage/overrider/override_backseat ///Contains the implant mind's client when not controlling the mob
	var/mob/living/neural_storage/victim/original_backseat ///Contains the original mind's client when not controlling the mob
	var/datum/action/innate/override_implant/cease/return_control ///Action to return control of the body to the original owner

/obj/item/organ/cyberimp/brain/neural_override/Insert(mob/living/carbon/C, special = 0, drop_if_replaced = TRUE)
	..()
	original_backseat = new(owner)

/obj/item/organ/cyberimp/brain/neural_override/Remove(mob/living/carbon/C, special = FALSE)
	//Make sure the original owner is left in control
	if(current_controller == OVERRIDE)
		switch_control()
	QDEL_NULL(return_control) //Delete the action, since it's still associated with the mob
	QDEL_NULL(original_backseat)
	return ..()

/obj/item/organ/cyberimp/brain/neural_override/Destroy()
	//Even if it would normally be handled by Remove, this needs to be done before removing the brain or the controllers will remain permanently switched
	if(owner && current_controller == OVERRIDE)
		switch_control()
	remove_brain()

	return ..()

///Switches control of the mob from the original to the overrider and viceversa
/obj/item/organ/cyberimp/brain/neural_override/proc/switch_control()
	if(QDELETED(owner) || QDELETED(override_backseat) || QDELETED(original_backseat))
		return

	var/mob/living/neural_storage/current_backseat
	var/mob/living/neural_storage/free_backseat
	if(current_controller == OWNER)
		current_backseat = override_backseat
		free_backseat = original_backseat
	else
		current_backseat = original_backseat
		free_backseat = override_backseat

	if(!current_backseat.mind)
		return

	log_game("[key_name(current_backseat)] assumed control of [key_name(owner)] due to [src]. (Original owner: [current_controller == OWNER ? owner.key : current_backseat.key])")
	if(current_controller == OWNER)
		to_chat(owner, "<span class='userdanger'>You suddenly lose control of your body!</span>")
		to_chat(current_backseat, "<span class='notice'>You assume direct control of [owner]'s body.</span>")
	else
		to_chat(owner, "<span class='notice'>You release control of [owner]'s body.</span>")
		to_chat(current_backseat, "<span class='userdanger'>You regain control of your body!</span>")

	if(owner.mind)
		owner.mind.transfer_to(free_backseat)
	current_backseat.mind.transfer_to(owner)

	current_controller = !current_controller

	if(current_controller == OVERRIDE)
		if(!return_control)
			return_control = new(owner, src)
		return_control.Grant(owner)
	else
		if(return_control)
			return_control.Remove(owner)

///The implant can be hit with a brain to install it as the overrider backseat
/obj/item/organ/cyberimp/brain/neural_override/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/organ/brain))
		var/obj/item/organ/brain/brain = I
		if(brain.brainmob && brain.brainmob.mind && (brain.brainmob.client || brain.brainmob.grab_ghost())) //Check that the brain has a player controlling it
			if(override_backseat) //Replace existing backseat with new one
				remove_brain()
			override_backseat = new(src, src)
			to_chat(user, "<span class='notice'>You install [brain] into [src].</span>")
			if(brain.brainmob.mind)
				brain.brainmob.mind.transfer_to(override_backseat)
		else
			to_chat(user, "<span class='warning'>The implant's interface rejects the brain. It appears that it is no longer sentient.</span>")
	else
		return ..()

///Removes the inserted brain and places the owner back inside
/obj/item/organ/cyberimp/brain/neural_override/proc/remove_brain()
	if(QDELETED(override_backseat) || QDELETED(overrider_brain))
		return
	overrider_brain.forceMove(drop_location())
	if(override_backseat.mind)
		override_backseat.mind.transfer_to(brain.brainmob)
		to_chat(brain.brainmob, "<span class='warning'>You've been removed from [src].</span>")
	QDEL_NULL(override_backseat)
	overrider_brain = null


///Shuts down the overrider and prevents them from taking control for 2-3 minutes
/obj/item/organ/cyberimp/brain/neural_override/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(current_controller == OVERRIDER)
		switch_control()
		override_backseat.next_control = world.time + rand(1200, 1800)

///Backseat mob holder for the [override implant] [/obj/item/organ/cyberimp/brain/neural_override].
/mob/living/neural_storage
	name = "neural storage"
	real_name = "unknown conscience"
	var/mob/living/carbon/body
	var/obj/item/organ/cyberimp/brain/neural_override/implant

///Original owner of the body, powerless while not in control
/mob/living/neural_storage/victim

///Sentience inside the implant, can control the body at will
/mob/living/neural_storage/overrider
	var/next_control = 0 ///Time until the overrider is allowed to take control again
	var/datum/action/innate/override_implant/assume_control

/mob/living/neural_storage/victim/Initialize(mapload, _implant)
	implant = _implant
	return ..()

/mob/living/neural_storage/overrider/Initialize(mapload, _implant)
	implant = _implant
	assume_control = new(src, implant)
	assume_control.Grant(src)
	return ..()

/mob/living/neural_storage/victim/Destroy()
	implant = null
	return ..()

/mob/living/neural_storage/overrider/Destroy()
	implant = null
	assume_control.Remove(src)
	QDEL_NULL(assume_control)
	return ..()

/mob/living/neural_storage/victim/Login()
	..()
	to_chat(src, "<span class='notice'>You're currently not in control of your body.</span>")

/mob/living/neural_storage/overrider/Login()
	..()
	to_chat(src, "<span class='notice'>You're the mind inside [src]. Once installed into a body, you can assume control of it at any time.</span>")

/mob/living/neural_storage/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>You cannot speak, you're not in control of your body!</span>")
	return FALSE

/mob/living/neural_storage/overrider/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!implant.owner)
		to_chat(src, "<span class='warning'>You cannot speak, you're not implanted inside anyone!</span>")
		return FALSE
	to_chat(src, "<b>Projected Thought:</b> \"[message]\"")
	to_chat(implant.owner, "<span class='danger'><b>\[OVERRIDE\]:</b></span> \"[message]\"")
	return FALSE

/mob/living/neural_storage/emote(act, m_type = null, message = null, intentional = FALSE)
	return FALSE

///Action that triggers the [override implant][/obj/item/organ/cyberimp/brain/neural_override]'s mindswap function.
/datum/action/innate/override_implant
	name = "Assume Direct Control"
	desc = "Override control of the body you're implanted in."
	check_flags = NONE
	button_icon_state = "slimeuse1" //todo
	icon_icon = 'icons/mob/actions/actions_slime.dmi' //todo
	background_icon_state = "bg_alien" //todo
	var/obj/item/organ/cyberimp/brain/neural_override/implant

/datum/action/innate/override_implant/New(_implant)
	..()
	implant = _implant

/datum/action/innate/override_implant/IsAvailable()
	if(..())
		if(implant && implant.owner && (world.time > implant.next_control))
			return TRUE
		return FALSE

/datum/action/innate/override_implant/Activate()
	if(!implant || !implant.owner)
		return
	implant.switch_control()

///Same as its parent, but with a different name/desc to show that it's returning control
/datum/action/innate/override_implant/cease
	name = "Stop Direct Control"
	desc = "Stop overriding control of the body you're implanted in."

/datum/action/innate/override_implant/cease/IsAvailable()
	if(..())
		if(implant.current_controller == OVERRIDE)
			return TRUE
		return FALSE

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implants"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"
	var/list/boxed = list(
		/obj/item/autosurgeon/syndicate/thermal_eyes,
		/obj/item/autosurgeon/syndicate/xray_eyes,
		/obj/item/autosurgeon/syndicate/anti_stun,
		/obj/item/autosurgeon/syndicate/reviver)
	var/amount = 5

/obj/item/storage/box/cyber_implants/PopulateContents()
	var/implant
	while(contents.len <= amount)
		implant = pick(boxed)
		new implant(src)

#undef OWNER
#undef OVERRIDER
