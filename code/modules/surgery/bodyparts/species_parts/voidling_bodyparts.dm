/obj/item/bodypart/head/voidling
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidling.dmi'
	limb_id = SPECIES_VOIDLING
	is_dimorphic = FALSE
	bodypart_traits = list(TRAIT_MUTE)
	head_flags = NONE

	damage_overlay_color = list(0, 0, 2, 0,
								0, 5, 0, 0,
								0, 0, 5, 0,
								0, 0, 0, 1,
								0, 0, 0, 0) //turn the damage overlays glassy

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/chest/voidling
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidling.dmi'
	limb_id = SPECIES_VOIDLING
	is_dimorphic = FALSE

	damage_overlay_color = /obj/item/bodypart/head/voidling::damage_overlay_color //im not copypasting the huge ass matrix everywheredd

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/arm/left/voidling
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidling.dmi'
	limb_id = SPECIES_VOIDLING
	is_dimorphic = FALSE
	attack_type = STAMINA
	unarmed_damage_low = 20
	unarmed_damage_high = 20

	damage_overlay_color = /obj/item/bodypart/head/voidling::damage_overlay_color

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/arm/right/voidling
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidling.dmi'
	limb_id = SPECIES_VOIDLING
	is_dimorphic = FALSE
	attack_type = STAMINA
	unarmed_damage_low = 20
	unarmed_damage_high = 20

	damage_overlay_color = /obj/item/bodypart/head/voidling::damage_overlay_color

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/leg/left/voidling
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidling.dmi'
	limb_id = SPECIES_VOIDLING
	is_dimorphic = FALSE

	damage_overlay_color = /obj/item/bodypart/head/voidling::damage_overlay_color

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)

/obj/item/bodypart/leg/right/voidling
	texture_bodypart_overlay = /datum/bodypart_overlay/texture/spacey
	icon_greyscale = 'icons/mob/human/species/voidling.dmi'
	limb_id = SPECIES_VOIDLING
	is_dimorphic = FALSE

	damage_overlay_color = /obj/item/bodypart/head/voidling::damage_overlay_color

	light_brute_msg = "splintered"
	medium_brute_msg = "cracked"
	heavy_brute_msg = "shattered"

	light_burn_msg = "bent"
	medium_burn_msg = "deformed"
	heavy_burn_msg = "warped"

	damage_examines = list(
		BRUTE = GLASSY_BRUTE_EXAMINE_TEXT,
		BURN = GLASSY_BURN_EXAMINE_TEXT,
	)
