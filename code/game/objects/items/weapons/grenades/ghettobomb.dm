//improvised explosives//

/obj/item/weapon/grenade/iedcasing
	name = "improvised firebomb"
	desc = "A weak, improvised incendiary device."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	slot_flags = SLOT_BELT
	active = 0
	det_time = 50
	display_timer = 0
	var/range = 3
	var/times = list()

/obj/item/weapon/grenade/iedcasing/New(loc)
	..()
	add_overlay(image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled"))
	add_overlay(image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_wired"))
	times = list("5" = 10, "-1" = 20, "[rand(30,80)]" = 50, "[rand(65,180)]" = 20)// "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pickweight(times))
	if(det_time < 0) //checking for 'duds'
		range = 1
		det_time = rand(30,80)
	else
		range = pick(2,2,2,3,3,3,4)

/obj/item/weapon/grenade/iedcasing/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/reagent_containers/food/drinks/soda_cans/can = locate() in contents
	if(can)
		var/muh_layer = can.layer
		var/muh_plane = can.plane
		can.layer = FLOAT_LAYER
		can.plane = FLOAT_PLANE
		underlays += can
		can.layer = muh_layer
		can.plane = muh_plane


/obj/item/weapon/grenade/iedcasing/attack_self(mob/user) //
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You light the [name]!</span>")
			active = 1
			cut_overlay(image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled"), TRUE)	//this line make no sense
			icon_state = initial(icon_state) + "_active"
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)

			message_admins("[ADMIN_LOOKUPFLW(user)] has primed a [name] for detonation at [ADMIN_COORDJMP(bombturf)].")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] [COORD(bombturf)].")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			addtimer(CALLBACK(src, .proc/prime), det_time)

/obj/item/weapon/grenade/iedcasing/prime() //Blowing that can up
	update_mob()
	explosion(src.loc,-1,-1,2, flame_range = 4)	// small explosion, plus a very large fireball.
	qdel(src)

/obj/item/weapon/grenade/iedcasing/examine(mob/user)
	..()
	to_chat(user, "You can't tell when it will explode!")
