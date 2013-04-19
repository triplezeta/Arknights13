//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/get_active_hand()
	return module_active



/*-------TODOOOOOOOOOO--------*/
/mob/living/silicon/robot/proc/uneq_active()
	if(isnull(module_active))
		return

	if(istype(module_active, /obj/item/part/cyborg/equipment/sight))
		var/obj/item/part/cyborg/equipment/sight/S = module_active
		sight_mode &= ~S.sight_mode

	else if(istype(module_active, /obj/item/tool/flashlight))
		var/obj/item/tool/flashlight/F = module_active
		if(F.on)
			F.on = 0
			F.update_brightness(src)

	if(module_active == module_state_1)
		if (client)
			client.screen -= module_state_1
		contents -= module_state_1
		module_state_1 = null
		inv1.icon_state = "inv1"
	else if(module_active == module_state_2)
		if (client)
			client.screen -= module_state_2
		contents -= module_state_2
		module_state_2 = null
		inv2.icon_state = "inv2"
	else if(module_active == module_state_3)
		if (client)
			client.screen -= module_state_3
		contents -= module_state_3
		module_state_3 = null
		inv3.icon_state = "inv3"

	module_active = null


/mob/living/silicon/robot/proc/uneq_all()
	module_active = null

	if(module_state_1)
		if(istype(module_state_1,/obj/item/part/cyborg/equipment/sight))
			sight_mode &= ~module_state_1:sight_mode
		if (client)
			client.screen -= module_state_1
		contents -= module_state_1
		module_state_1 = null
		inv1.icon_state = "inv1"
	if(module_state_2)
		if(istype(module_state_2,/obj/item/part/cyborg/equipment/sight))
			sight_mode &= ~module_state_2:sight_mode
		if (client)
			client.screen -= module_state_2
		contents -= module_state_2
		module_state_2 = null
		inv2.icon_state = "inv2"
	if(module_state_3)
		if(istype(module_state_3,/obj/item/part/cyborg/equipment/sight))
			sight_mode &= ~module_state_3:sight_mode
		if (client)
			client.screen -= module_state_3
		contents -= module_state_3
		module_state_3 = null
		inv3.icon_state = "inv3"


/mob/living/silicon/robot/proc/activated(obj/item/O)
	if(module_state_1 == O)
		return 1
	else if(module_state_2 == O)
		return 1
	else if(module_state_3 == O)
		return 1
	else
		return 0