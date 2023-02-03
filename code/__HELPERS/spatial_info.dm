/turf
	///what /mob/oranges_ear instance is already assigned to us as there should only ever be one.
	///used for guaranteeing there is only one oranges_ear per turf when assigned, speeds up view() iteration
	var/mob/oranges_ear/assigned_oranges_ear

/** # Oranges Ear
 *
 * turns out view() spends a significant portion of its processing time generating lists of contents of viewable turfs which includes EVERYTHING on it visible
 * and the turf itself. there is an optimization to view() which makes it only iterate through either /obj or /mob contents, as well as normal list typechecking filters
 *
 * a fuckton of these are generated as part of its SS's init and stored in a list, when requested for a list of movables returned by the spatial grid or by some
 * superset of the final output that must be narrowed down by view(), one of these gets put on every turf that contains the movables that need filtering
 * and each is given references to the movables they represent. that way you can do for(var/mob/oranges_ear/ear in view(...)) and check what they reference
 * as opposed to for(var/atom/movable/target in view(...)) and checking if they have the properties you want which leads to much larger lists generated by view()
 * and also leads to iterating through more movables to filter them.
 *
 * TLDR: iterating through just mobs is much faster than all movables when iterating through view() on average, this system leverages that to boost speed
 * enough to offset the cost of allocating the mobs
 *
 * named because the idea was first made by oranges and i didn't know what else to call it (note that this system was originally made for get_hearers_in_view())
 */
/mob/oranges_ear
	icon_state = null
	density = FALSE
	move_resist = INFINITY
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	logging = null
	held_items = null //all of these are list objects that should not exist for something like us
	faction = null
	alerts = null
	screens = null
	client_colours = null
	hud_possible = null
	/// references to everything "on" the turf we are assigned to, that we care about. populated in assign() and cleared in unassign().
	/// movables iside of other movables count as being "on" if they have get_turf(them) == our turf. intentionally not a lazylist
	var/list/references = list()

/mob/oranges_ear/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	return INITIALIZE_HINT_NORMAL

/mob/oranges_ear/Destroy(force)
	var/old_length = length(SSspatial_grid.pregenerated_oranges_ears)
	SSspatial_grid.pregenerated_oranges_ears -= src
	if(length(SSspatial_grid.pregenerated_oranges_ears) < old_length)
		SSspatial_grid.number_of_oranges_ears -= 1

	var/turf/our_loc = get_turf(src)
	if(our_loc && our_loc.assigned_oranges_ear == src)
		our_loc.assigned_oranges_ear = null

	. = ..()

/mob/oranges_ear/Move()
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("SOMEHOW A /mob/oranges_ear MOVED")
	return FALSE

/mob/oranges_ear/abstract_move(atom/destination)
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("SOMEHOW A /mob/oranges_ear MOVED")
	return FALSE

/mob/oranges_ear/Bump()
	SHOULD_CALL_PARENT(FALSE)
	return FALSE

///clean this oranges_ear up for future use
/mob/oranges_ear/proc/unassign()
	var/turf/turf_loc = loc
	turf_loc.assigned_oranges_ear = null//trollface. our loc should ALWAYS be a turf, no exceptions. if it isn't then this doubles as an error message ;)
	loc = null
	references.Cut()

/**
 * returns every hearaing movable in view to the turf of source not taking into account lighting
 * useful when you need to maintain always being able to hear something if a sound is emitted from it and you can see it (and you're in range).
 * otherwise this is just a more expensive version of get_hearers_in_LOS()
 *
 * * view_radius - what radius search circle we are using, worse performance as this increases
 * * source - object at the center of our search area. everything in get_turf(source) is guaranteed to be part of the search area
 */
/proc/get_hearers_in_view(view_radius, atom/source)
	var/turf/center_turf = get_turf(source)
	if(!center_turf)
		return

	. = list()

	if(view_radius <= 0)//special case for if only source cares
		for(var/atom/movable/target as anything in center_turf)
			var/list/recursive_contents = target.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]
			if(recursive_contents)
				. += recursive_contents
		return .

	var/list/hearables_from_grid = SSspatial_grid.orthogonal_range_search(source, RECURSIVE_CONTENTS_HEARING_SENSITIVE, view_radius)

	if(!length(hearables_from_grid))//we know that something is returned by the grid, but we dont know if we need to actually filter down the output
		return .

	var/list/assigned_oranges_ears = SSspatial_grid.assign_oranges_ears(hearables_from_grid)

	var/old_luminosity = center_turf.luminosity
	center_turf.luminosity = 6 //man if only we had an inbuilt dview()

	//this is the ENTIRE reason all this shit is worth it due to how view() and the contents list works and can be optimized
	//internally, the contents list is secretly two linked lists, one for /obj's and one for /mob's (/atom/movable counts as /obj here)
	//by default, for(var/atom/name in view()) iterates through both the /obj linked list then the /mob linked list of each turf
	//but because what we want are only a tiny proportion of all movables, most of the things in the /obj contents list are not what we're looking for
	//while every mob can hear. for this case view() has an optimization to only look through 1 of these lists if it can (eg you're only looking for mobs)
	//so by representing every hearing contents on a turf with a single /mob/oranges_ear containing references to all of them, we are:
	//1. making view() only go through the smallest of the two linked lists per turf, which contains the type we're looking for at the end
	//2. typechecking all mobs in the output to only actually return mobs of type /mob/oranges_ear
	//on a whole this can outperform iterating through all movables in view() by ~2x especially when hearables are a tiny percentage of movables in view
	for(var/mob/oranges_ear/ear in view(view_radius, center_turf))
		. += ear.references

	for(var/mob/oranges_ear/remaining_ear as anything in assigned_oranges_ears)//we need to clean up our mess
		remaining_ear.unassign()

	center_turf.luminosity = old_luminosity
	return .

/**
 * Returns a list of movable atoms that are hearing sensitive in view_radius and line of sight to source
 * the majority of the work is passed off to the spatial grid if view_radius > 0
 * because view() isn't a raycasting algorithm, this does not hold symmetry to it. something in view might not be hearable with this.
 * if you want that use get_hearers_in_view() - however that's significantly more expensive
 *
 * * view_radius - what radius search circle we are using, worse performance as this increases but not as much as it used to
 * * source - object at the center of our search area. everything in get_turf(source) is guaranteed to be part of the search area
 */
/proc/get_hearers_in_LOS(view_radius, atom/source)
	var/turf/center_turf = get_turf(source)
	if(!center_turf)
		return

	if(view_radius <= 0)//special case for if only source cares
		. = list()
		for(var/atom/movable/target as anything in center_turf)
			var/list/hearing_contents = target.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]
			if(hearing_contents)
				. += hearing_contents
		return

	. = SSspatial_grid.orthogonal_range_search(source, SPATIAL_GRID_CONTENTS_TYPE_HEARING, view_radius)

	for(var/atom/movable/target as anything in .)
		var/turf/target_turf = get_turf(target)

		var/distance = get_dist(center_turf, target_turf)

		if(distance > view_radius)
			. -= target
			continue

		else if(distance < 2) //we should always be able to see something 0 or 1 tiles away
			continue

		//this turf search algorithm is the worst scaling part of this proc, scaling worse than view() for small-moderate ranges and > 50 length contents_to_return
		//luckily its significantly faster than view for large ranges in large spaces and/or relatively few contents_to_return
		//i can do things that would scale better, but they would be slower for low volume searches which is the vast majority of the current workload
		//maybe in the future a high volume algorithm would be worth it
		var/turf/inbetween_turf = center_turf

		//this is the lowest overhead way of doing a loop in dm other than a goto. distance is guaranteed to be >= steps taken to target by this algorithm
		for(var/step_counter in 1 to distance)
			inbetween_turf = get_step_towards(inbetween_turf, target_turf)

			if(inbetween_turf == target_turf)//we've gotten to target's turf without returning due to turf opacity, so we must be able to see target
				break

			if(IS_OPAQUE_TURF(inbetween_turf))//this turf or something on it is opaque so we cant see through it
				. -= target
				break

/proc/get_hearers_in_radio_ranges(list/obj/item/radio/radios)
	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	for(var/obj/item/radio/radio as anything in radios)
		. |= get_hearers_in_LOS(radio.canhear_range, radio, FALSE)

///Calculate if two atoms are in sight, returns TRUE or FALSE
/proc/inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
	var/turf/T
	if(X1 == X2)
		if(Y1 == Y2)
			return TRUE //Light cannot be blocked on same tile
		else
			var/s = SIGN(Y2-Y1)
			Y1+=s
			while(Y1 != Y2)
				T=locate(X1,Y1,Z)
				if(IS_OPAQUE_TURF(T))
					return FALSE
				Y1+=s
	else
		var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
		var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
		var/signX = SIGN(X2-X1)
		var/signY = SIGN(Y2-Y1)
		if(X1<X2)
			b+=m
		while(X1 != X2 || Y1 != Y2)
			if(round(m*X1+b-Y1))
				Y1+=signY //Line exits tile vertically
			else
				X1+=signX //Line exits tile horizontally
			T=locate(X1,Y1,Z)
			if(IS_OPAQUE_TURF(T))
				return FALSE
	return TRUE


/proc/is_in_sight(atom/first_atom, atom/second_atom)
	var/turf/first_turf = get_turf(first_atom)
	var/turf/second_turf = get_turf(second_atom)

	if(!first_turf || !second_turf)
		return FALSE

	return inLineOfSight(first_turf.x, first_turf.y, second_turf.x, second_turf.y, first_turf.z)

///Returns all atoms present in a circle around the center
/proc/circle_range(center = usr,radius = 3)

	var/turf/center_turf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius + 0.5)

	for(var/atom/checked_atom as anything in range(radius, center_turf))
		var/dx = checked_atom.x - center_turf.x
		var/dy = checked_atom.y - center_turf.y
		if(dx * dx + dy * dy <= rsq)
			atoms += checked_atom

	return atoms

///Returns all atoms present in a circle around the center but uses view() instead of range() (Currently not used)
/proc/circle_view(center=usr,radius=3)

	var/turf/center_turf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius + 0.5)

	for(var/atom/checked_atom as anything in view(radius, center_turf))
		var/dx = checked_atom.x - center_turf.x
		var/dy = checked_atom.y - center_turf.y
		if(dx * dx + dy * dy <= rsq)
			atoms += checked_atom

	return atoms

///Returns the distance between two atoms
/proc/get_dist_euclidian(atom/first_location as turf|mob|obj, atom/second_location as turf|mob|obj)
	var/dx = first_location.x - second_location.x
	var/dy = first_location.y - second_location.y

	var/dist = sqrt(dx ** 2 + dy ** 2)

	return dist

///Returns a list of turfs around a center based on RANGE_TURFS()
/proc/circle_range_turfs(center = usr, radius = 3)

	var/turf/center_turf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius + 0.5)

	for(var/turf/checked_turf as anything in RANGE_TURFS(radius, center_turf))
		var/dx = checked_turf.x - center_turf.x
		var/dy = checked_turf.y - center_turf.y
		if(dx * dx + dy * dy <= rsq)
			turfs += checked_turf
	return turfs

///Returns a list of turfs around a center based on view()
/proc/circle_view_turfs(center=usr,radius=3) //Is there even a diffrence between this proc and circle_range_turfs()? // Yes
	var/turf/center_turf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius + 0.5)

	for(var/turf/checked_turf in view(radius, center_turf))
		var/dx = checked_turf.x - center_turf.x
		var/dy = checked_turf.y - center_turf.y
		if(dx * dx + dy * dy <= rsq)
			turfs += checked_turf
	return turfs

///Returns the list of turfs around the outside of a center based on RANGE_TURFS()
/proc/border_diamond_range_turfs(atom/center = usr, radius = 3)
	var/turf/center_turf = get_turf(center)
	var/list/turfs = list()

	for(var/turf/checked_turf as anything in RANGE_TURFS(radius, center_turf))
		var/dx = checked_turf.x - center_turf.x
		var/dy = checked_turf.y - center_turf.y
		var/abs_sum = abs(dx) + abs(dy)
		if(abs_sum == radius)
			turfs += checked_turf
	return turfs

///Returns a slice of a list of turfs, defined by the ones that are inside the inner/outer angle's bounds
/proc/slice_off_turfs(atom/center, list/turf/turfs, inner_angle, outer_angle)
	var/turf/center_turf = get_turf(center)
	var/list/sliced_turfs = list()

	for(var/turf/checked_turf as anything in turfs)
		var/angle_to = get_angle(center_turf, checked_turf)
		if(angle_to < inner_angle || angle_to > outer_angle)
			continue
		sliced_turfs += checked_turf
	return sliced_turfs

/**
 * Get a bounding box of a list of atoms.
 *
 * Arguments:
 * - atoms - List of atoms. Can accept output of view() and range() procs.
 *
 * Returns: list(x1, y1, x2, y2)
 */
/proc/get_bbox_of_atoms(list/atoms)
	var/list/list_x = list()
	var/list/list_y = list()
	for(var/_a in atoms)
		var/atom/a = _a
		list_x += a.x
		list_y += a.y
	return list(
		min(list_x),
		min(list_y),
		max(list_x),
		max(list_y))

/// Like view but bypasses luminosity check
/proc/get_hear(range, atom/source)
	var/lum = source.luminosity
	source.luminosity = 6

	. = view(range, source)
	source.luminosity = lum

///Returns the open turf next to the center in a specific direction
/proc/get_open_turf_in_dir(atom/center, dir)
	var/turf/open/get_turf = get_ranged_target_turf(center, dir, 1)
	if(istype(get_turf))
		return get_turf

///Returns a list with all the adjacent open turfs. Clears the list of nulls in the end.
/proc/get_adjacent_open_turfs(atom/center)
	. = list(
		get_open_turf_in_dir(center, NORTH),
		get_open_turf_in_dir(center, SOUTH),
		get_open_turf_in_dir(center, EAST),
		get_open_turf_in_dir(center, WEST)
		)
	list_clear_nulls(.)

///Returns a list with all the adjacent areas by getting the adjacent open turfs
/proc/get_adjacent_open_areas(atom/center)
	. = list()
	var/list/adjacent_turfs = get_adjacent_open_turfs(center)
	for(var/near_turf in adjacent_turfs)
		. |= get_area(near_turf)

/**
 * Returns a list with the names of the areas around a center at a certain distance
 * Returns the local area if no distance is indicated
 * Returns an empty list if the center is null
**/
/proc/get_areas_in_range(distance = 0, atom/center = usr)
	if(!distance)
		var/turf/center_turf = get_turf(center)
		return center_turf ? list(center_turf.loc) : list()
	if(!center)
		return list()

	var/list/turfs = RANGE_TURFS(distance, center)
	var/list/areas = list()
	for(var/turf/checked_turf as anything in turfs)
		areas |= checked_turf.loc
	return areas

///Returns a list of all areas that are adjacent to the center atom's area, clear the list of nulls at the end.
/proc/get_adjacent_areas(atom/center)
	. = list(
		get_area(get_ranged_target_turf(center, NORTH, 1)),
		get_area(get_ranged_target_turf(center, SOUTH, 1)),
		get_area(get_ranged_target_turf(center, EAST, 1)),
		get_area(get_ranged_target_turf(center, WEST, 1))
		)
	list_clear_nulls(.)

///Checks if the mob provided (must_be_alone) is alone in an area
/proc/alone_in_area(area/the_area, mob/must_be_alone, check_type = /mob/living/carbon)
	var/area/our_area = get_area(the_area)
	for(var/carbon in GLOB.alive_mob_list)
		if(!istype(carbon, check_type))
			continue
		if(carbon == must_be_alone)
			continue
		if(our_area == get_area(carbon))
			return FALSE
	return TRUE
