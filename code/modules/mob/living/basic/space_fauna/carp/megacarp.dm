/**
 * ## Mega Space Carp
 *
 * A bigger space carp with more health and greater ability to smash objects.
 * Brings in some buddies when it enters combat.
 * Has mildly randomised stats for some inexplicable reason, makes it somewhat more like a randomised Diablo mob.
 */
/mob/living/basic/carp/mega
	icon = 'icons/mob/simple/broadMobs.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	health_doll_icon = "megacarp"
	maxHealth = 20
	health = 20
	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	random_colour = FALSE
	obj_damage = 80
	cell_line = CELL_LINE_TABLE_MEGACARP
	butcher_results = list(/obj/item/food/fishmeat/carp = 2, /obj/item/stack/sheet/animalhide/carp = 3)

/mob/living/simple_animal/hostile/carp/megacarp/Initialize(mapload)
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(2, 10)
	melee_damage_upper += rand(10,20)
	maxHealth += rand(30,60)
	move_to_delay = rand(3,7)
