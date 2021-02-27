/// Makes sure that spawned food has reagents (or else it can't be eaten).
/datum/unit_test/food_reagents_check

/datum/unit_test/food_reagents_check/Run()
	var/list/not_food = list(
	/obj/item/food/grown,
	/obj/item/food/grown/mushroom,
	/obj/item/food/deepfryholder,
	/obj/item/food/clothing,
	/obj/item/food/meat/slab/human/mutant,
	/obj/item/food/grown/shell)

	var/list/food_paths = subtypesof(/obj/item/food) - not_food

	for(var/obj/item/food/food_path as anything in food_paths)
		var/obj/item/food/spawned_food = new food_path

		if(!spawned_food.reagents)
			Fail("[food_path] does not have any reagents, making it inedible!")

		qdel(spawned_food)
