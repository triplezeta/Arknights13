/mob/living/simple_animal/hostile/sabbat
	name = "Sabbatziege"
	desc = "FAT MOTHERFUCKER NOW LOOK WHOS IN TROUBLE"
	icon = 'icons/mob/sabbatziege.dmi'
	icon_state = "sabbatziege"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	AIStatus = AI_OFF
	maxHealth = 10000
	health = 10000
	pixel_y = -32
	pixel_x= -96
	dextrous = TRUE
	light_color = COLOR_WHITE
	light_range = 10
	held_items = list(null, null)
	weather_immunities = list("lava","ash")
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	movement_type = UNSTOPPABLE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	light_power = 0.7
	light_range = 15
	light_color = COLOR_WHITE
	mouse_opacity = MOUSE_OPACITY_ICON