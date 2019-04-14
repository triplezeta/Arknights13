/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth that is extremely effective at stopping bleeding, but does not heal wounds."
	gender = PLURAL
	singular_name = "medical gauze"
	icon_state = "gauze"
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	max_amount = 12
	var/self_delay = 20
	var/stop_bleeding = 1800
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/gauze/attack(mob/living/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.bleedsuppress)
			to_chat(user, "<span class='warning'>[H]'s bleeding is already bandaged!</span>")
			return
		else if(!H.bleed_rate)
			to_chat(user, "<span class='warning'>[H] isn't bleeding!</span>")
			return
		else
			H.suppress_bloodloss(stop_bleeding)
			use(1)
			to_chat(user, "You bandage [H].")
	return ..()

/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.is_sharp())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("[user] cuts [src] into pieces of cloth with [I].", \
					 "<span class='notice'>You cut [src] into pieces of cloth with [I].</span>", \
					 "<span class='italics'>You hear cutting.</span>")
		use(2)
	else
		return ..()

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins tightening \the [src] around [user.p_their()] neck! It looks like [user.p_they()] forgot how to use medical supplies!</span>")
	return OXYLOSS

/obj/item/stack/medical/bruise_pack
/obj/item/stack/medical/ointment
/obj/item/stack/medical/gauze
/obj/item/stack/medical/gauze/large
	amount = 12

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = 900

/obj/item/stack/medical/gauze/cyborg
	materials = list()
	is_cyborg = 1
	cost = 250