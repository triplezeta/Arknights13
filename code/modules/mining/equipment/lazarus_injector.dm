/**
 * Players can revive simplemobs with this.
 *
 * In-game item that can be used to revive a simplemob once. This makes the mob friendly.
 * Becomes useless after use.
 * Becomes malfunctioning when EMP'd.
 * If a hostile mob is revived with a malfunctioning injector, it will be hostile to everyone except whoever revived it and gets robust searching enabled.
 */
/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	///Can this still be used?
	var/loaded = TRUE
	///Injector malf?
	var/malfunctioning = FALSE
	///So you can't revive boss monsters or robots with it
	var/revive_type = SENTIENCE_ORGANIC

/obj/item/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!loaded || !(isliving(target) && proximity_flag) )
		return
	if(!isanimal(target))
		to_chat(user, span_info("[src] is only effective on lesser beings."))
		return

	var/mob/living/simple_animal/M = target
	if(M.sentience_type != revive_type)
		to_chat(user, span_info("[src] does not work on this sort of creature."))
		return
	if(M.stat != DEAD)
		to_chat(user, span_info("[src] is only effective on the dead."))
		return

	M.faction = list("neutral")
	M.revive(full_heal = TRUE, admin_revive = TRUE)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = M
		if(malfunctioning)
			H.faction |= list("lazarus", "[REF(user)]")
			H.robust_searching = 1
			H.friends += user
			H.attack_same = 1
			log_game("[key_name(user)] has revived hostile mob [key_name(target)] with a malfunctioning lazarus injector")
		else
			H.attack_same = 0
	loaded = FALSE
	user.visible_message(span_notice("[user] injects [M] with [src], reviving it."))
	SSblackbox.record_feedback("tally", "lazarus_injector", 1, M.type)
	playsound(src,'sound/effects/refill.ogg',50,TRUE)
	icon_state = "lazarus_empty"

/obj/item/lazarus_injector/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!malfunctioning)
		malfunctioning = TRUE

/obj/item/lazarus_injector/examine(mob/user)
	. = ..()
	if(!loaded)
		. += span_info("[src] is empty.")
	if(malfunctioning)
		. += span_info("The display on [src] seems to be flickering.")
