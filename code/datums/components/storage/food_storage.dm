/// --Food storage component--
/// This component lets you slide one item into large foods, such as bread, cheese wheels, or cakes.
/// Consuming food storages with an item inside can cause unique interactions, such as eating glass shards.

/datum/component/food_storage
	//what we have in our food
	var/obj/item/stored_item
	/// The amount of volume the food has on creation
	var/initial_volume = 10
	/// Minimum size items that can be inserted
	var/minimum_weight_class = WEIGHT_CLASS_SMALL
	/// What are the odds we bite the stored item?
	var/bad_chance_of_discovery = 0
	/// What are the odds we see the stored item, but don't bite it?
	var/good_chance_of_discovery = 100
	/// We've found the item in the food
	var/discovered = FALSE

/datum/component/food_storage/Initialize(_initial_volume = 10, _minimum_weight_class = WEIGHT_CLASS_SMALL, _bad_chance = 0, _good_chance = 100)

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/try_inserting_food)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/try_destroying_food)
	RegisterSignal(parent, COMSIG_FOOD_EATEN, .proc/consume_food_storage)

	if(_initial_volume) //initial volume should not be 0
		initial_volume =  _initial_volume
	minimum_weight_class = _minimum_weight_class
	bad_chance_of_discovery = _bad_chance
	good_chance_of_discovery = _good_chance

/** Begins the process of inserted an item.
  *
  * Clicking on the food storage with an item on disarm intent will begin a do_after, which if successful inserts the item.
  *
  * Arguments
  *	inserted_item - the item being placed into the food
  * user - the person inserting the item
  */
/datum/component/food_storage/proc/try_inserting_food(datum/source, obj/item/inserted_item, mob/user, params)
	if(istype(inserted_item, /obj/item/storage) || istype(inserted_item, /obj/item/reagent_containers/food/snacks))
		return

	if(inserted_item.w_class > minimum_weight_class)
		to_chat(user, "<span class='warning'>[inserted_item.name] won't fit in \the [parent].</span>")
		return

	if(!QDELETED(stored_item))
		to_chat(user, "<span class='warning'>There's something in \the [parent].</span>")
		return

	user.visible_message("<span class='notice'>[user.name] begins inserting [inserted_item.name] into \the [parent].</span>", \
					"<span class='notice'>You start to insert the [inserted_item.name] into \the [parent].</span>")

	INVOKE_ASYNC(src, .proc/insert_item, inserted_item, user)
	return COMPONENT_ITEM_NO_ATTACK

/** Begins the process of attempting to remove the stored item.
  *
  * Clicking on food storage on grab intent will begin a do_after, which if successful removes the stored_item.
  *
  * Arguments
  *	user - the person removing the item.
  */
/datum/component/food_storage/proc/try_destroying_food(datum/source, mob/user)
	if(user.a_intent != INTENT_GRAB)
		return

	if(QDELETED(stored_item))
		return

	user.visible_message("<span class='notice'>[user.name] begins tearing at \the [parent].</span>", \
					"<span class='notice'>You start to rip into \the [parent].</span>")

	INVOKE_ASYNC(src, .proc/try_remove_item, user)
	return COMPONENT_ITEM_NO_ATTACK

/** Inserts the item into the food, after a do_after.
  *
  * Arguments
  * inserted_item - The item being inserted.
  *	user - the person inserting the item.
  */
/datum/component/food_storage/proc/insert_item(obj/item/inserted_item, mob/user)
	if(do_after(user, 1.5 SECONDS, target = parent))
		var/atom/food = parent
		to_chat(user, "<span class='notice'>You slip [inserted_item.name] inside \the [parent].</span>")
		inserted_item.forceMove(food)
		user.log_message("[key_name(user)] inserted [inserted_item] into [parent] at [AREACOORD(user)]", LOG_ATTACK)
		food.add_fingerprint(user)
		inserted_item.add_fingerprint(user)

		stored_item = inserted_item

/** Removes the item from the food, after a do_after.
  *
  * Arguments
  * user - person removing the item.
  */
/datum/component/food_storage/proc/try_remove_item(mob/user)
	if(do_after(user, 10 SECONDS, target = parent))
		remove_item(user)

/** Removes the stored item, putting it in the user's hands, or on the ground, then updates the reference.
  *
  * Returns the result of put_in_hands - TRUE if placed in hands, FALSE if placed on the ground.
  */
/datum/component/food_storage/proc/remove_item(mob/user)
	. = user.put_in_hands(stored_item)
	update_stored_item()
	return

/** Checks for stored items when the food is eaten.
  *
  * If the food is eaten while an item is stored in it, calculates the odds that the item will be found.
  * Then, if the item is found before being bitten, the item is removed.
  * If the item is found by biting into it, calls on_accidental_consumption on the stored item.
  * Afterwards, removes the item from the food if it was discovered.
  *
  * Arguments
  * target - person doing the eating (can be the same as user)
  * user - person causing the eating to happen
  * bitecount - how many times the current food has been bitten
  * bitesize - how large bties are for this food
  */
/datum/component/food_storage/proc/consume_food_storage(datum/source, mob/living/target, mob/living/user, bitecount, bitesize)
	if(QDELETED(stored_item)) //if the stored item was deleted/null...
		if(!update_stored_item()) //check if there's a replacement item
			return

	/// Chance of biting the held item = amount of bites / (intitial reagents / reagents per bite) * 100
	bad_chance_of_discovery = (bitecount / (initial_volume / bitesize))*100
	/// Chance of finding the held item = bad chance - 50
	good_chance_of_discovery = bad_chance_of_discovery - 50

	if(prob(good_chance_of_discovery)) //finding the item, without biting it
		discovered = TRUE
		to_chat(target, "<span class='warning'>It feels like there's something in \the [parent]...!</span>")

	else if(prob(bad_chance_of_discovery)) //finding the item, BY biting it
		target.log_message("[key_name(user)] just fed [key_name(target)] a/an [stored_item] which was hidden in [parent] at [AREACOORD(target)]", LOG_ATTACK)
		discovered = stored_item.on_accidental_consumption(target, user, parent)
		update_stored_item() //make sure if the item was changed, the reference changes as well

	if(!QDELETED(stored_item) && discovered)
		if(remove_item(user)) //the moment when you slowly pull out whatever you just bit into in your food
			user.visible_message("<span class='warning'>[target.name] slowly pulls [stored_item.name] out of \the [parent].</span>", \
								"<span class='warning'>You slowly pull [stored_item.name] out of \the [parent].</span>")
		else
			stored_item.visible_message("<span class='warning'>[stored_item.name] falls out of \the [parent].</span>")

/** Updates the reference of the stored item.
  *
  * Checks the food's contents for if an alternate item was placed into the food.
  * If there is an alternate item, updates the reference to the new item.
  * If there isn't, updates the reference to null.
  *
  * Returns FALSE if the ref is nulled, or TRUE is another item replaced it.
  */
/datum/component/food_storage/proc/update_stored_item()
	var/atom/food = parent
	if(food?.contents.len) //if there's an item in the food
		for(var/obj/item/i in food.contents) //search the food's contents for a replacement item
			if(istype(i, /obj/item/reagent_containers/food/snacks))
				continue
			if(QDELETED(i))
				continue

			stored_item = i //we found something to replace it
			return TRUE

	//if there's nothing else in the food, or we found nothing valid
	stored_item = null
	return FALSE
