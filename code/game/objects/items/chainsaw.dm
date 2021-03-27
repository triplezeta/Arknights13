ds
// CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "chainsaw_off"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 13
	var/force_on = 24
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	custom_materials = list(/datum/material/iron=13000)
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = "swing_hit"
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/startchainsaw)
	tool_behaviour = TOOL_SAW
	toolspeed = 0.5
	var/on = FALSE
	var/wielded = FALSE // track wielded status on item

/obj/item/chainsaw/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/chainsaw/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 30, 100, 0, 'sound/weapons/chainsawhit.ogg', TRUE)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/// triggered on wield of two handed item
/obj/item/chainsaw/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/chainsaw/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = FALSE

/obj/item/chainsaw/suicide_act(mob/living/carbon/user)
	if(on)
		user.visible_message("<span class='suicide'>[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/weapons/chainsawhit.ogg', 100, TRUE)
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			myhead.dismember()
	else
		user.visible_message("<span class='suicide'>[user] smashes [src] into [user.p_their()] neck, destroying [user.p_their()] esophagus! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/weapons/genhit1.ogg', 100, TRUE)
	return(BRUTELOSS)

/obj/item/chainsaw/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops moving."]")
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(force)
	icon_state = "chainsaw_[on ? "on" : "off"]"
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = on

	if(on)
		hitsound = 'sound/weapons/chainsawhit.ogg'
	else
		hitsound = "swing_hit"

	if(src == user.get_active_held_item()) //update inhands
		user.update_inv_hands()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/chainsaw/afterattack(atom/A, mob/user, proximity)
	if(!on)
		return ..()

	var/lignocellulose = counterlist_sum(A.has_material_type(/datum/material/wood))

	if(!lignocellulose)
		return ..()

	user.visible_message("<span class='notice'>[user] starts sawing [A] to pieces!</span>", "<span class='notice'>You start sawing [A] to pieces!</span>")

	var/dust_harvest = lignocellulose * 0.1 //you lose 10% as sawdust
	lignocellulose *= 0.9
	dust_harvest = round((lignocellulose % MINERAL_MATERIAL_AMOUNT) / 100) //the leftover wood material also becomes sawdust.
	var/plank_harvest = round(lignocellulose / (MINERAL_MATERIAL_AMOUNT))


	if(plank_harvest >= 3)
		if(!do_after(user, 2 SECONDS, target = A))
			return

	if(plank_harvest)
		new /obj/item/stack/sheet/mineral/wood(get_turf(A),plank_harvest) //spawn an amount of planks equal to plank_harvest

	if(lignocellulose % MINERAL_MATERIAL_AMOUNT)
		new /obj/effect/decal/cleanable/sawdust(get_turf(A), dust_harvest) //spawn an amount of cellulose inside the decal equal to dust_harvest.
	playsound(src, 'sound/weapons/chainsawhit.ogg', 50, TRUE)

	if(isturf(A))
		var/turf/scrape_target = A
		scrape_target.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	else
		qdel(A)

/obj/item/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration = 100
	force_on = 30

/obj/item/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
		return TRUE
	return FALSE
