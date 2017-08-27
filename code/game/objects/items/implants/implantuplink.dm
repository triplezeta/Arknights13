/obj/item/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"
	var/starting_tc = 0

/obj/item/implant/uplink/Initialize()
	. = ..()
	AddComponent(/datum/component/uplink, null, TRUE, FALSE, null, starting_tc)

/obj/item/implant/uplink/implant(mob/living/target, mob/user, silent = 0)
	for(var/X in target.implants)
		var/datum/D = X
		GET_COMPONENT_FROM(uplink, /datum/component/uplink, D)
		if(uplink)
			D.TakeComponent(GetComponent(/datum/component/uplink))
			qdel(src)
			return TRUE

	if(..())
		GET_COMPONENT(uplink, /datum/component/uplink)
		uplink.owner = user.key
		return 1
	return 0

/obj/item/implant/uplink/activate()
	GET_COMPONENT(uplink, /datum/component/uplink)
	uplink.Open(usr)

/obj/item/implanter/uplink
	name = "implanter (uplink)"
	imp_type = /obj/item/implant/uplink

/obj/item/implanter/uplink/precharged
	name = "implanter (precharged uplink)"
	imp_type = /obj/item/implant/uplink/precharged

/obj/item/implant/uplink/precharged
	starting_tc = 10
