/obj/item/ai_module
	name = "\improper AI module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "An AI Module for programming laws to an AI."
	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/gold = 50)
	/// This is where our laws get put at for the module
	var/list/laws = list()
	/// Used to skip laws being checked (for reset & remove boards that have no laws)
	var/bypass_law_amt_check = FALSE

/obj/item/ai_module/examine(mob/user as mob)
	. = ..()
	if(Adjacent(user))
		show_laws(user)

/obj/item/ai_module/attack_self(mob/user as mob)
	..()
	show_laws(user)

/obj/item/ai_module/proc/show_laws(mob/user as mob)
	if(laws.len)
		to_chat(user, "<B>Programmed Law[(laws.len > 1) ? "s" : ""]:</B>")
		for(var/law in laws)
			to_chat(user, "\"[law]\"")

//The proc other things should be calling
/obj/item/ai_module/proc/install(datum/ai_laws/law_datum, mob/user)
	if(!bypass_law_amt_check && (!laws.len || laws[1] == "")) //So we don't loop trough an empty list and end up with runtimes.
		to_chat(user, span_warning("ERROR: No laws found on board."))
		return

	var/overflow = FALSE
	//Handle the lawcap
	if(law_datum)
		var/tot_laws = 0
		for(var/lawlist in list(law_datum.inherent, law_datum.supplied, law_datum.ion, law_datum.hacked, laws))
			for(var/mylaw in lawlist)
				if(mylaw != "")
					tot_laws++
		if(tot_laws > CONFIG_GET(number/silicon_max_law_amount) && !bypass_law_amt_check)//allows certain boards to avoid this check, eg: reset
			to_chat(user, span_alert("Not enough memory allocated to [law_datum.owner ? law_datum.owner : "the AI core"]'s law processor to handle this amount of laws."))
			message_admins("[ADMIN_LOOKUPFLW(user)] tried to upload laws to [law_datum.owner ? ADMIN_LOOKUPFLW(law_datum.owner) : "an AI core"] that would exceed the law cap.")
			log_game("[ADMIN_LOOKUP(user)] tried to upload laws to [law_datum.owner ? ADMIN_LOOKUP(law_datum.owner) : "an AI core"] that would exceed the law cap.")
			overflow = TRUE

	var/law2log = transmitInstructions(law_datum, user, overflow) //Freeforms return something extra we need to log
	if(law_datum.owner)
		to_chat(user, span_notice("Upload complete. [law_datum.owner]'s laws have been modified."))
		law_datum.owner.law_change_counter++
	else
		to_chat(user, span_notice("Upload complete."))

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/ainame = law_datum.owner ? law_datum.owner.name : "empty AI core"
	var/aikey = law_datum.owner ? law_datum.owner.ckey : "null"

	//affected cyborgs are cyborgs linked to the AI with lawsync enabled
	var/affected_cyborgs = list()
	var/list/borg_txt = list()
	var/list/borg_flw = list()
	if(isAI(law_datum.owner))
		var/mob/living/silicon/ai/owner = law_datum.owner
		for(var/mob/living/silicon/robot/owned_borg as anything in owner.connected_robots)
			if(owned_borg.connected_ai && owned_borg.lawupdate)
				affected_cyborgs += owned_borg
				borg_flw += "[ADMIN_LOOKUPFLW(owned_borg)], "
				borg_txt += "[owned_borg.name]([owned_borg.key]), "

	borg_txt = borg_txt.Join()
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) used [src.name] on [ainame]([aikey]).[law2log ? " The law specified [law2log]" : ""], [length(affected_cyborgs) ? ", impacting synced borgs [borg_txt]" : ""]")
	log_silicon("LAW: [key_name(user)] used [src.name] on [key_name(law_datum.owner)] from [AREACOORD(user)].[law2log ? " The law specified [law2log]" : ""], [length(affected_cyborgs) ? ", impacting synced borgs [borg_txt]" : ""]")
	message_admins("[ADMIN_LOOKUPFLW(user)] used [src.name] on [ADMIN_LOOKUPFLW(law_datum.owner)] from [AREACOORD(user)].[law2log ? " The law specified [law2log]" : ""] , [length(affected_cyborgs) ? ", impacting synced borgs [borg_flw.Join()]" : ""]")
	if(law_datum.owner)
		deadchat_broadcast("<b> changed [span_name("[ainame]")]'s laws at [get_area_name(user, TRUE)].</b>", span_name("[user]"), follow_target=user, message_type=DEADCHAT_LAWCHANGE)

//The proc that actually changes the silicon's laws.
/obj/item/ai_module/proc/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow = FALSE)
	if(law_datum.owner)
		to_chat(law_datum.owner, span_userdanger("[sender] has uploaded a change to the laws you must follow using a [name]."))

/obj/item/ai_module/core
	desc = "An AI Module for programming core laws to an AI."

/obj/item/ai_module/core/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	for(var/templaw in laws)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.add_inherent_law(templaw)
			else
				law_datum.owner.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED))
		else
			if(!overflow)
				law_datum.add_inherent_law(templaw)
			else
				law_datum.replace_random_law(templaw,list(LAW_INHERENT,LAW_SUPPLIED))

/obj/item/ai_module/core/full
	var/law_id // if non-null, loads the laws from the ai_laws datums

/obj/item/ai_module/core/full/Initialize(mapload)
	. = ..()
	if(!law_id)
		return
	var/datum/ai_laws/D = new
	var/lawtype = D.lawid_to_type(law_id)
	if(!lawtype)
		return
	D = new lawtype
	laws = D.inherent

/obj/item/ai_module/core/full/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow) //These boards replace inherent laws.
	if(law_datum.owner)
		law_datum.owner.clear_inherent_laws()
		law_datum.owner.clear_zeroth_law(0)
	else
		law_datum.clear_inherent_laws()
		law_datum.clear_zeroth_law(0)
	..()
