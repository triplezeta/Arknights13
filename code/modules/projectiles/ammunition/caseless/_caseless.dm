/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."
	firing_effect_type = null
	heavy_metal = FALSE

/obj/item/ammo_casing/caseless/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread)
	if (..()) //successfully firing
		moveToNullspace()
		qdel(src)
		return TRUE
	else
		return FALSE

/obj/item/ammo_casing/caseless/update_icon()
	..()
	icon_state = "[initial(icon_state)]"
