/datum/component/deployable
	var/deploy_time = 5 SECONDS //Default time it takes to deploy the item
	var/obj/thing_to_be_deployed //What do we spawn when the item is deployed successfully?
	var/deployed_name //For getting the name of an object for examines later on
	var/delete_on_use = TRUE //Do we delete the item being used when the object is deployed

/datum/component/deployable/Initialize(thing_to_be_deployed)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.thing_to_be_deployed = thing_to_be_deployed
	src.delete_on_use = delete_on_use

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/deploy)

	var/obj/item/typecast = thing_to_be_deployed
	deployed_name = initial(typecast.name)

/datum/component/deployable/proc/examine(datum/src, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(thing_to_be_deployed) //Tells the player what this item can deploy into
		examine_list += span_notice("It looks like it can be deployed into a [deployed_name].")
	else //Also tells the player if you are bad at coding
		examine_list += span_notice("It appears that you should be able to deploy this, but you can't see how, better report this to Central!")

/datum/component/deployable/proc/deploy(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/finish_deploy, source, user, location, direction)

/datum/component/deployable/proc/finish_deploy(datum/source, mob/user, location, direction) //If there's no user, location and direction are used
	var/obj/deploy_item = source //I got errors for not using this, so be it
	var/obj/deployed_object //Used for spawning the deployed object
	var/turf/deploy_location //Where our deployed_object gets put
	var/new_direction //What direction do we want our deployed object in
	if(user)
		if(!ishuman(user))
			return

		deploy_location = get_step(user, user.dir)
		if(deploy_location.is_blocked_turf(TRUE))
			user.balloon_alert(user, "insufficient room to deploy here.")
			return
		new_direction = user.dir
		user.balloon_alert(user, "deploying...")
		if(!do_after(user, deploy_time))
			return
	else
		deploy_location = location
		new_direction = direction

	deployed_object = new thing_to_be_deployed(deploy_location) //Creates thing_to_be_deployed at a location in front of the user
	deployed_object.setDir(new_direction) //Changes the direction of the deployed object to be that of where the user was facing

	//Sets the integrity of the new deployed machine to that of the object it came from
	deployed_object.max_integrity = deploy_item.max_integrity
	deployed_object.update_integrity(deploy_item.get_integrity())
	deployed_object.update_icon_state()

	if(delete_on_use)
		qdel(source)
