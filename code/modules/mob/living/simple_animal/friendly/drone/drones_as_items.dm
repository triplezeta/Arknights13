#define DRONE_MINIMUM_AGE 14

///////////////////
//DRONES AS ITEMS//
///////////////////
//Drone shells

//DRONE SHELL
/obj/effect/mob_spawn/drone
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat" //yes reuse the _hat state.
	layer = BELOW_MOB_LAYER
	density = FALSE
	death = FALSE
	roundstart = FALSE
	mob_type = /mob/living/simple_animal/drone //Type of drone that will be spawned

	var/seasonal_hats = TRUE //If TRUE, and there are no default hats, different holidays will grant different hats
	var/static/list/possible_seasonal_hats //This is built automatically in build_seasonal_hats() but can also be edited by admins!

/obj/effect/mob_spawn/drone/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A drone shell has been created in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_DRONE, notify_suiciders = FALSE)
	GLOB.poi_list |= src
	if(isnull(possible_seasonal_hats))
		build_seasonal_hats()

/obj/effect/mob_spawn/drone/proc/build_seasonal_hats()
	possible_seasonal_hats = list()
	if(!length(SSevents.holidays))
		return //no holidays, no hats; we'll keep the empty list so we never call this proc again
	for(var/V in SSevents.holidays)
		var/datum/holiday/holiday = SSevents.holidays[V]
		if(holiday.drone_hat)
			possible_seasonal_hats += holiday.drone_hat

/obj/effect/mob_spawn/drone/Destroy()
	GLOB.poi_list -= src
	. = ..()

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/drone/attack_ghost(mob/user)
	if(CONFIG_GET(flag/use_age_restriction_for_jobs))
		if(!isnum(user.client.player_age)) //apparently what happens when there's no DB connected. just don't let anybody be a drone without admin intervention
			return
		if(user.client.player_age < DRONE_MINIMUM_AGE)
			to_chat(user, "<span class='danger'>You're too new to play as a drone! Please try again in [DRONE_MINIMUM_AGE - user.client.player_age] days.</span>")
			return
	. = ..()
