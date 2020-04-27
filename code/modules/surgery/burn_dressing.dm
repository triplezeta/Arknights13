
/////BONE FIXING SURGERIES//////

///// Repair Hairline Fracture (Severe)
/datum/surgery/debride
	name = "Debride burnt flesh"
	steps = list(/datum/surgery_step/debride, /datum/surgery_step/disinfect, /datum/surgery_step/regenerate_flesh, /datum/surgery_step/dress)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE
	targetable_wound = /datum/wound/burn

/datum/surgery/debride/can_start(mob/living/user, mob/living/carbon/target)
	if(..())
		var/obj/item/bodypart/targeted_bodypart = target.get_bodypart(user.zone_selected)
		var/datum/wound/burn/burn_wound = targeted_bodypart.get_wound_type(targetable_wound)
		return(burn_wound && burn_wound.mortification > 0)


//SURGERY STEPS

///// Repair Hairline Fracture (Severe)
/datum/surgery_step/debride
	name = "debride ruined flesh"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_WIRECUTTER = 60, TOOL_SCALPEL = 70, TOOL_SAW = 40)
	time = 40
	repeatable = TRUE
	experience_given = MEDICAL_SKILL_MEDIUM

/datum/surgery_step/debride/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		if(surgery.operated_wound.mortification <= 0)
			to_chat(user, "<span class='notice'>[target]'s [parse_zone(user.zone_selected)] has no ruined flesh to remove!</span>")
			return
		display_results(user, target, "<span class='notice'>You begin to excise ruined flesh from [target]'s [parse_zone(user.zone_selected)]...</span>",
			"<span class='notice'>[user] begins to excise ruined flesh from [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
			"<span class='notice'>[user] begins to excise ruined flesh from [target]'s [parse_zone(user.zone_selected)].</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for [target]'s [parse_zone(user.zone_selected)].</span>", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")

/datum/surgery_step/debride/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		display_results(user, target, "<span class='notice'>You successfully excise some of the ruined flesh from [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] successfully excises some of the ruined flesh from [target]'s [parse_zone(target_zone)] with [tool]!</span>",
			"<span class='notice'>[user] successfully excises some of the ruined flesh from  [target]'s [parse_zone(target_zone)]!</span>")
		log_combat(user, target, "repaired a hairline fracture in", addition="INTENT: [uppertext(user.a_intent)]")
		surgery.operated_bodypart.receive_damage(brute=3, wound_bonus=CANT_WOUND)
		surgery.operated_wound.mortification -= 1
		if(surgery.operated_wound.mortification <= 0)
			repeatable = FALSE
	else
		to_chat(user, "<span class='warning'>[target] has no ruined flesh there!</span>")
	return ..()

/datum/surgery_step/debride/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	display_results(user, target, "<span class='notice'>You carve away some of the healthy flesh from [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] carves away some of the healthy flesh from [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='notice'>[user] carves away some of the healthy flesh from  [target]'s [parse_zone(target_zone)]!</span>")
	surgery.operated_bodypart.receive_damage(brute=rand(4,11), sharpness=TRUE)

///// Repair Hairline Fracture (Severe)
/datum/surgery_step/disinfect
	name = "disinfect ruined flesh"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_WIRECUTTER = 60, TOOL_SCALPEL = 70, TOOL_SAW = 40)
	time = 40
	repeatable = TRUE
	experience_given = MEDICAL_SKILL_MEDIUM

/datum/surgery_step/debride/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		if(surgery.operated_wound.mortification <= 0)
			to_chat(user, "<span class='notice'>[target]'s [parse_zone(user.zone_selected)] has no ruined flesh to remove!</span>")
			return
		display_results(user, target, "<span class='notice'>You begin to excise ruined flesh from [target]'s [parse_zone(user.zone_selected)]...</span>",
			"<span class='notice'>[user] begins to excise ruined flesh from [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
			"<span class='notice'>[user] begins to excise ruined flesh from [target]'s [parse_zone(user.zone_selected)].</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for [target]'s [parse_zone(user.zone_selected)].</span>", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")

/datum/surgery_step/debride/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		display_results(user, target, "<span class='notice'>You successfully excise some of the ruined flesh from [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] successfully excises some of the ruined flesh from [target]'s [parse_zone(target_zone)] with [tool]!</span>",
			"<span class='notice'>[user] successfully excises some of the ruined flesh from  [target]'s [parse_zone(target_zone)]!</span>")
		log_combat(user, target, "repaired a hairline fracture in", addition="INTENT: [uppertext(user.a_intent)]")
		surgery.operated_bodypart.receive_damage(brute=3, wound_bonus=CANT_WOUND)
		surgery.operated_wound.mortification -= 1
		if(surgery.operated_wound.mortification <= 0)
			repeatable = FALSE
	else
		to_chat(user, "<span class='warning'>[target] has no ruined flesh there!</span>")
	return ..()

/datum/surgery_step/debride/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	display_results(user, target, "<span class='notice'>You carve away some of the healthy flesh from [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] carves away some of the healthy flesh from [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='notice'>[user] carves away some of the healthy flesh from  [target]'s [parse_zone(target_zone)]!</span>")
	surgery.operated_bodypart.receive_damage(brute=rand(4,11), sharpness=TRUE)


///// Reset Compound Fracture (Crticial)
/datum/surgery_step/dress
	name = "dress burns"
	implements = list(/obj/item/stack/medical/gauze = 100, /obj/item/stack/sticky_tape/surgical = 100)
	time = 40
	experience_given = MEDICAL_SKILL_MEDIUM

/datum/surgery_step/dress/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(user, target, "<span class='notice'>You begin to dress the burns on [target]'s [parse_zone(user.zone_selected)]...</span>",
			"<span class='notice'>[user] begins to dress the burns on [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
			"<span class='notice'>[user] begins to dress the burns on [target]'s [parse_zone(user.zone_selected)].</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for [target]'s [parse_zone(user.zone_selected)].</span>", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")

/datum/surgery_step/dress/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		display_results(user, target, "<span class='notice'>You successfully wrap [target]'s [parse_zone(target_zone)] with [used_stack].</span>",
			"<span class='notice'>[user] successfully wraps [target]'s [parse_zone(target_zone)] with [used_stack]!</span>",
			"<span class='notice'>[user] successfully wraps [target]'s [parse_zone(target_zone)]!</span>")
		log_combat(user, target, "reset a compound fracture in", addition="INTENT: [uppertext(user.a_intent)]")
		var/datum/wound/burn/burn_wound = surgery.operated_wound
		burn_wound.bandaged(tool)
	else
		to_chat(user, "<span class='warning'>[target] has no compound fracture there!</span>")
	return ..()

/datum/surgery_step/dress/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)


///// Repair Compound Fracture (Crticial)
/datum/surgery_step/repair_bone_compound
	name = "repair compound fracture"
	implements = list(/obj/item/stack/medical/bone_gel = 100, /obj/item/stack/sticky_tape/surgical = 100, /obj/item/stack/sticky_tape/super = 50, /obj/item/stack/sticky_tape = 30)
	time = 40
	experience_given = MEDICAL_SKILL_MEDIUM

/datum/surgery_step/repair_bone_compound/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(user, target, "<span class='notice'>You begin to repair the fracture in [target]'s [parse_zone(user.zone_selected)]...</span>",
			"<span class='notice'>[user] begins to repair the fracture in [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
			"<span class='notice'>[user] begins to repair the fracture in [target]'s [parse_zone(user.zone_selected)].</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for [target]'s [parse_zone(user.zone_selected)].</span>", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")

/datum/surgery_step/repair_bone_compound/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(istype(tool, /obj/item/stack))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(user, target, "<span class='notice'>You successfully repair the fracture in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)] with [tool]!</span>",
			"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)]!</span>")
		log_combat(user, target, "repaired a compound fracture in", addition="INTENT: [uppertext(user.a_intent)]")
		surgery.operated_wound.remove_wound()
	else
		to_chat(user, "<span class='warning'>[target] has no compound fracture there!</span>")
	return ..()

/datum/surgery_step/repair_bone_compound/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)
