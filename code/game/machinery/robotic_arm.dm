//Automated arm for picking up loose items and placing them into machines or on the ground. Method done is via an attack, uses a dummy mob to emulate this.

/obj/machinery/robotic_arm
	icon = 'icons/obj/machines/robotic_arm.dmi'
	icon_state = "robot_arm"
	name = "automatic robotic arm"
	desc = "A cyborg arm on a stationary base."
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	active_power_usage = 100
	layer = BELOW_OBJ_LAYER
	dir = 1
	anchored = FALSE
	var/r_arm = TRUE //False if we need to return a left arm upon disassembly
	var/moving = FALSE
	var/obj/machinery/target
	var/turf/source
	var/turf/dest
	var/obj/item/held
	var/mob/living/simple_animal/dummy //A dummy mob to use when inserting objects.

/obj/machinery/robotic_arm/lefty
	r_arm = FALSE

/obj/machinery/robotic_arm/Initialize()
	. = ..()
	dummy = new /mob/living/simple_animal(src)
	source_update()

/obj/machinery/robotic_arm/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/robotic_arm/proc/can_be_rotated(mob/user,rotation_type)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/machinery/robotic_arm/Moved() //In case we get moved while still anchored (admemes, shuttle, whatever)
	. = ..()
	if(!anchored)
		return
	set_turfs()

/obj/machinery/robotic_arm/wrench_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 5, volume=50))
		return
	anchored = !anchored
	if(!anchored)
		STOP_PROCESSING(SSmachines, src)
	else
		set_turfs()
		START_PROCESSING(SSmachines, src)

/obj/machinery/robotic_arm/screwdriver_act(mob/living/user, obj/item/I)
	if(I.use_tool(src, user, 5, volume=50))
		if(r_arm)
			new /obj/item/bodypart/r_arm/robot(get_turf(src))
		else
			new /obj/item/bodypart/l_arm/robot(get_turf(src))
		new /obj/item/robotic_arm_base/steptwo(get_turf(src))
		qdel(src)

/obj/machinery/robotic_arm/Destroy()
	target = null
	source = null
	dest = null
	if(held)
		held.forceMove(get_turf(src))
	held = null
	if(dummy)
		qdel(dummy)
	. = ..()

/obj/machinery/robotic_arm/proc/set_turfs()
	if(source)
		UnregisterSignal(source, COMSIG_TURF_CONTENTS_CHANGE)
	if(dest)
		UnregisterSignal(dest, COMSIG_TURF_CONTENTS_CHANGE)
	source = get_step(src, turn(dir,-180))
	RegisterSignal(source, COMSIG_TURF_CONTENTS_CHANGE, .proc/source_update)
	dest = get_step(src, dir)
	RegisterSignal(dest, COMSIG_TURF_CONTENTS_CHANGE, .proc/destination_update)

/obj/machinery/robotic_arm/process()
	..()
	if(!anchored || moving)
		return
	for(var/O in source.contents)
		if(istype(O, /obj/item))
			held = O
			held.forceMove(src)
			animate_move()
			addtimer(CALLBACK(src, /obj/machinery/robotic_arm/proc/deposit), 1 SECONDS, TIMER_UNIQUE)
			moving = TRUE
			return
	if(!moving) //If we didn't find jack
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/robotic_arm/proc/deposit()
	destination_update()
	if(target)
		held.melee_attack_chain(dummy, target)
	if(held.loc == src) //If the above didn't take it from us
		held.forceMove(dest)
	held = null
	animate_return()
	sleep(1)
	moving = FALSE

/obj/machinery/robotic_arm/proc/animate_move()
	icon_state = "robot_arm_dropping"
	flick("robot_arm_move", src)
	return

obj/machinery/robotic_arm/proc/animate_return()
	icon_state = "robot_arm"
	flick("robot_arm_return", src)
	return

/obj/machinery/robotic_arm/proc/source_update()
	START_PROCESSING(SSmachines, src)
	return

/obj/machinery/robotic_arm/proc/destination_update()
	if(target && !QDELETED(target) && get_turf(target) == dest)
		return
	target = null
	for(var/M in dest)
		if(istype(M, /obj/machinery))
			if(istype(M,/obj/machinery/atmospherics))
				continue
			target = M
			break

////////////////////////

obj/item/robotic_arm_base
	icon = 'icons/obj/machines/robotic_arm.dmi'
	icon_state = "base01"
	name = "robotic arm base"
	desc = "A base frame to support an automatic robotic arm."
	var/step = 1

obj/item/robotic_arm_base/steptwo
	icon_state = "base02"
	step = 2

obj/item/robotic_arm_base/screwdriver_act(mob/living/user, obj/item/I)
	if(step == 1)
		if(I.use_tool(src, user, 5, volume=50))
			new /obj/item/stack/rods(get_turf(src),3)
			qdel(src)
	else
		. = ..()

obj/item/robotic_arm_base/crowbar_act(mob/living/user, obj/item/I)
	if(step == 2)
		if(I.use_tool(src, user, 5, volume=50))
			new /obj/item/stack/tile/plasteel(get_turf(src)) //Great job naming the normal metal tiles, guys
			step = 1
			icon_state = "base01"
	else
		. = ..()

obj/item/robotic_arm_base/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/tile/plasteel))
		if(step == 1 && W.use(1))
			step = 2
			icon_state = "base02"
			return

	if(istype(W, /obj/item/bodypart/r_arm/robot))
		if(step == 2 && user.transferItemToLoc(W, src))
			new /obj/machinery/robotic_arm(get_turf(src))
			qdel(src)
			return

	if(istype(W, /obj/item/bodypart/l_arm/robot))
		if(step == 2 && user.transferItemToLoc(W, src))
			new /obj/machinery/robotic_arm/lefty(get_turf(src))
			qdel(src)
			return

	. = ..()