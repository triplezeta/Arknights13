/obj/item/weapon/gun/grenadelauncher
	name = "syndicate grenade launcher"
	desc = "A grenade launcher furnished with a 6-slot rotating cylinder that can hold a wide variety of grenades. The stenciled label marks this as a creation of the Gorlex Marauders. "
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = 4.0
	throw_speed = 2.5
	throw_range = 8
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 6
	m_amt = 2000

/obj/item/weapon/gun/grenadelauncher/examine(mob/user)
	..()
	user << "[grenades.len] / [max_grenades] grenades loaded."

/obj/item/weapon/gun/grenadelauncher/attackby(obj/item/I as obj, mob/user as mob, params)

	if((istype(I, /obj/item/weapon/grenade)))
		if(grenades.len < max_grenades)
			user.drop_item()
			I.loc = src
			grenades += I
			user << "<span class='notice'>You put the grenade in the syndicate grenade launcher.</span>"
			user << "<span class='notice'>[grenades.len] / [max_grenades] Grenades.</span>"
		else
			usr << "<span class='danger'>The syndicate grenade launcher cannot hold more grenades.</span>"

/obj/item/weapon/gun/grenadelauncher/afterattack(obj/target, mob/user , flag)

	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(grenades.len)
		spawn(0) fire_grenade(target,user)
	else
		usr << "<span class='danger'>The syndicate grenade launcher is empty.</span>"

/obj/item/weapon/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	user.visible_message("<span class='danger'>[user] fires the syndicate grenade launcher!</span>", \
						"<span class='danger'>You fire the syndicate grenade launcher!</span>")
	var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.loc = user.loc
	F.throw_at(target, 30, 2)
	message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a syndicate grenade launcher ([src.name]).")
	log_game("[key_name(user)] fired a grenade ([F.name]) from a syndicate grenade launcher ([src.name]).")
	F.active = 1
	F.icon_state = initial(icon_state) + "_active"
	playsound(user.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(15)
		F.prime()
