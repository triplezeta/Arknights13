/obj/item/modkit
	name = "modification kit"
	desc = "A one-use kit, which enables kinetic accelerators to be fired with only one hand."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	var/uses = 1

/obj/item/modkit/afterattack(var/obj/item/weapon/gun/energy/kinetic_accelerator/C, mob/user)
	..()
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		user << "<span class='warning'>This kit can only modify kinetic accelerators!</span>"
		return ..()
	user <<"<span class='notice'>You modify the [C], making it less unwieldy.</span>"
	C.name = "compact [C.name]"
	C.weapon_weight = WEAPON_LIGHT
	uses --
	if(!uses)
		qdel(src)