///Collect and command
/datum/lift_master
	var/list/lift_platforms = list()

/datum/lift_master/New(obj/structure/lift/lift_platform)
	Rebuild_lift_plaform(lift_platform)

///Collect all bordered platforms
/datum/lift_master/proc/Rebuild_lift_plaform(obj/structure/lift/base_lift_platform)
	lift_platforms |= base_lift_platform
	var/list/possible_expansions = list(base_lift_platform)
	while(possible_expansions.len)
		for(var/obj/structure/lift/borderline in possible_expansions)
			var/list/result = borderline.lift_platform_expansion(src)
			if(result && result.len)
				for(var/obj/structure/lift/lift_platform in result)
					if(!lift_platforms.Find(lift_platform))
						lift_platform.LMaster = src
						lift_platforms |= lift_platform
						possible_expansions |= lift_platform
			possible_expansions -= borderline

///Move all platforms together
/datum/lift_master/proc/MoveLift(going, mob/user)
	for(var/obj/structure/lift/lift_platform in lift_platforms)
		lift_platform.travel(going)

/datum/lift_master/proc/MoveLiftOnZ(going, z) //NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST
	var/max_x = 1
	var/max_y = 1
	var/min_x = world.maxx
	var/min_y = world.maxy
	
	for(var/obj/structure/lift/lift_platform in lift_platforms)
		max_x = max(max_x, lift_platform.x)
		max_y = max(max_y, lift_platform.y)
		min_x = min(min_x, lift_platform.x)
		min_y = min(min_y, lift_platform.y)
		
	//This must be safe way to tile to border tile move of bordered platforms, that excludes platform overlapping.
	if( going & ( EAST | NORTH | SOUTH ))
		//Go along the X axis from min to max, from left to right
		for(var/x = min_x; x <= max_x; x++)
			if( going & NORTH )
				//Go along the Y axis from max to min, from up to down
				for(var/y = max_y; y >= min_y; y--)
					var/obj/structure/lift/lift_platform = locate(/obj/structure/lift, locate(x, y, z))
					lift_platform.travel(going)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y = min_y; y <= max_y; y++)
					var/obj/structure/lift/lift_platform = locate(/obj/structure/lift, locate(x, y, z))
					lift_platform.travel(going)	
	else	
		//Go along the X axis from max to min, from right to left
		for(var/x = max_x; x >= min_x; x--)
			if( going & NORTH )
				//Go along the Y axis from max to min, from up to down
				for(var/y = max_y; y >= min_y; y--)
					var/obj/structure/lift/lift_platform = locate(/obj/structure/lift, locate(x, y, z))
					lift_platform.travel(going)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y = min_y; y <= max_y; y++)
					var/obj/structure/lift/lift_platform = locate(/obj/structure/lift, locate(x, y, z))
					lift_platform.travel(going)		

///Check destination turfs
/datum/lift_master/proc/Check_lift_move(check_dir)
	for(var/obj/structure/lift/lift_platform in lift_platforms)
		var/turf/T = get_step_multiz(lift_platform, check_dir)
		if(!T)// || !isopenturf(T))
			return FALSE
	return TRUE

/obj/structure/lift
	name = "lift platform"
	desc = "A lightweight lift platform. It moves up and down."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	canSmoothWith = list(/obj/structure/lift)
	smooth = SMOOTH_MORE
	//	flags = CONDUCT_1
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN

	var/list/lift_load = list() //things to move
	var/datum/lift_master/LMaster    //control from

/obj/structure/lift/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/AddItemOnLift)
	RegisterSignal(loc, COMSIG_ATOM_CREATED, .proc/AddItemOnLift)//For atoms created on platform
	RegisterSignal(src, COMSIG_MOVABLE_UNCROSSED, .proc/RemoveItemFromLift)

	if(!LMaster)
		LMaster = new(src)

/obj/structure/lift/Move(atom/newloc, direct)
	UnregisterSignal(loc, COMSIG_ATOM_CREATED)
	. = ..()
	RegisterSignal(loc, COMSIG_ATOM_CREATED, .proc/AddItemOnLift)//For atoms created on platform

/obj/structure/lift/proc/RemoveItemFromLift(datum/source, atom/movable/AM)
	lift_load -= AM

/obj/structure/lift/proc/AddItemOnLift(datum/source, atom/movable/AM)
	lift_load |= AM

/obj/structure/lift/proc/lift_platform_expansion(datum/lift_master/LMaster)
	. = list()
	for(var/D in GLOB.cardinals)
		var/turf/T = get_step(src, D)
		. |= locate(/obj/structure/lift) in T

/obj/structure/lift/proc/travel(going)
	var/list/things2move = lift_load.Copy()
	var/turf/destination
	if(!isturf(going))
		destination = get_step_multiz(src, going)
	else
		destination = going
	forceMove(destination)
	for(var/atom/movable/AM in things2move)
		AM.forceMove(destination)

/obj/structure/lift/proc/use(mob/user, is_ghost=FALSE)
	if (is_ghost && !in_range(src, user))
		return

	var/list/tool_list = list(
		"Up" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"Down" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)
		)

	var/turf/can_move_up = LMaster.Check_lift_move(UP)
	var/turf/can_move_up_down = LMaster.Check_lift_move(DOWN)

	if (can_move_up || can_move_up_down)
		var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
		if (!is_ghost && !in_range(src, user))
			return  // nice try
		switch(result)
			if("Up")
				if(can_move_up)
					LMaster.MoveLift(UP, user)
					show_fluff_message(TRUE, user)
					use(user)
				else
					to_chat(user, "<span class='warning'>[src] doesn't seem to able move up!</span>")
					use(user)
			if("Down")
				if(can_move_up_down)
					LMaster.MoveLift(DOWN, user)
					show_fluff_message(FALSE, user)
					use(user)
				else
					to_chat(user, "<span class='warning'>[src] doesn't seem to able move down!</span>")
					use(user)
			if("Cancel")
				return
	else
		to_chat(user, "<span class='warning'>[src] doesn't seem to able move anywhere!</span>")

	add_fingerprint(user)

/obj/structure/lift/proc/check_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/structure/lift/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	use(user)

/obj/structure/lift/attack_paw(mob/user)
	return use(user)

/obj/structure/lift/attackby(obj/item/W, mob/user, params)
	return use(user)

/obj/structure/lift/attack_robot(mob/living/silicon/robot/R)
	if(R.Adjacent(src))
		return use(R)

/obj/structure/lift/proc/show_fluff_message(going_up, mob/user)
	if(going_up)
		user.visible_message("<span class='notice'>[user] move lift up.</span>", "<span class='notice'>Lift move up.</span>")
	else
		user.visible_message("<span class='notice'>[user] move lift down.</span>", "<span class='notice'>Lift move down.</span>")
