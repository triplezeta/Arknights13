
/obj/item/food/material
	name = "temporary golem material snack item"
	desc = "You shouldn't be able to see this. This is an abstract item which exists to allow you to eat rocks."
	bite_consumption = 2
	food_reagents = list(/datum/reagent/consumable/nutriment/mineral = INFINITY) // Destroyed when stack runs out, not when reagents do
	foodtypes = STONE
	/// A weak reference to the stack which created us
	var/datum/weakref/material
	/// Golem food buff to apply on consumption
	var/datum/golem_food_buff/food_buff

/obj/item/food/material/Initialize(mapload, datum/golem_food_buff/food_buff)
	. = ..()
	src.food_buff = food_buff

/obj/item/food/material/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, after_eat = CALLBACK(src, PROC_REF(took_bite)), volume = INFINITY)

/// Called when someone bites this food, subtract one charge from our material stack
/obj/item/food/material/proc/took_bite(mob/eater)
	var/obj/item/resolved_material = material.resolve()
	if (!resolved_material)
		qdel(src)
		return
	if (isstack(resolved_material))
		var/obj/item/stack/stack_material = resolved_material
		resolved_material.use(used = 1)
	else
		qdel(resolved_material)
	food_buff.on_consumption(eater)
	if (!resolved_material)
		qdel(src)
