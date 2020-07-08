/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	inhand_icon_state = "megaphone"
	lefthand_file = 'icons/mob/inhands/misc/megaphone_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/megaphone_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	/// when can we next play 'megaphone.ogg'? note that this DOESN'T affect the text embiggening, just the special megaphone noise that plays
	var/spamcheck = 0
	var/list/voicespan = list(SPAN_COMMAND)

/obj/item/megaphone/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is using \the [src] to amplify a very special message! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.say(";ONE DAY WHILE ANDY WAS-", forced="megaphone suicide") //WAIT NO DON'T
	addtimer(CALLBACK(src, .proc/manual_suicide, user), 20) //we'll give you 2 seconds to contemplate your mistake
	return MANUAL_SUICIDE

/obj/item/megaphone/proc/manual_suicide(mob/living/user) //modeled after/copied from the code for the timer suicide
	playsound(loc, 'sound/effects/adminhelp.ogg', 100, TRUE) //B A N B O T S
	user.adjustOxyLoss(200)
	user.death(0)

/obj/item/megaphone/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_HANDS)
		RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/proc/handle_speech(mob/living/carbon/user, list/speech_args)
	if (user.get_active_held_item() == src)
		if(spamcheck > world.time)
			to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		else
			playsound(loc, 'sound/items/megaphone.ogg', 100, FALSE, TRUE)
			spamcheck = world.time + 50
		speech_args[SPEECH_SPANS] |= voicespan

/obj/item/megaphone/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
	obj_flags |= EMAGGED
	voicespan = list(SPAN_REALLYBIG, "userdanger")

/obj/item/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"
	inhand_icon_state = "megaphone-sec"

/obj/item/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"
	inhand_icon_state = "megaphone-command"

/obj/item/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"
	inhand_icon_state = "megaphone-cargo"

/obj/item/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	inhand_icon_state = "megaphone-clown"
	voicespan = list(SPAN_CLOWN)
