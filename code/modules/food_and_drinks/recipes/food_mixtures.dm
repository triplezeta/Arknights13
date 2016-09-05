/datum/crafting_recipe/food/New()
	parts |= reqs

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	id = "tofu"
	required_reagents = list("soymilk" = 10, "enzyme" = 0)
	no_mob_react=1

/datum/chemical_reaction/tofu/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	id = "chocolate_bar"
	required_reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return


/datum/chemical_reaction/chocolate_bar2
	id = "chocolate_bar"
	required_reagents = list("milk" = 2, "cocoa" = 2, "sugar" = 2)
	no_mob_react = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	id = "hot_coco"
	results = list("hot_coco" = 5)
	required_reagents = list("water" = 5, "cocoa" = 1)

/datum/chemical_reaction/coffee
	id = "coffee"
	results = list("coffee" = 5)
	required_reagents = list("coffeepowder" = 1, "water" = 5)

/datum/chemical_reaction/tea
	id = "tea"
	results = list("tea" = 5)
	required_reagents = list("teapowder" = 1, "water" = 5)

/datum/chemical_reaction/soysauce
	id = "soysauce"
	results = list("soysauce" = 5)
	required_reagents = list("soymilk" = 4, "sacid" = 1)

/datum/chemical_reaction/corn_syrup
	id = "corn_syrup"
	results = list("corn_syrup" = 5)
	required_reagents = list("corn_starch" = 1, "sacid" = 1)
	required_temp = 374

/datum/chemical_reaction/cheesewheel
	id = "cheesewheel"
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/cheesewheel/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/store/cheesewheel(location)

/datum/chemical_reaction/synthmeat
	id = "synthmeat"
	required_reagents = list("blood" = 5, "cryoxadone" = 1)
	no_mob_react = 1

/datum/chemical_reaction/synthmeat/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/synthmeat(location)

/datum/chemical_reaction/hot_ramen
	id = "hot_ramen"
	results = list("hot_ramen" = 3)
	required_reagents = list("water" = 1, "dry_ramen" = 3)

/datum/chemical_reaction/hell_ramen
	id = "hell_ramen"
	results = list("hell_ramen" = 6)
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)

/datum/chemical_reaction/imitationcarpmeat
	id = "imitationcarpmeat"
	required_reagents = list("carpotoxin" = 5)
	required_container = /obj/item/weapon/reagent_containers/food/snacks/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/imitationcarpmeat/on_reaction(datum/chem_holder/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/carpmeat/imitation(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/dough
	id = "dough"
	required_reagents = list("water" = 10, "flour" = 15)
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/dough(location)

/datum/chemical_reaction/cakebatter
	id = "cakebatter"
	required_reagents = list("eggyolk" = 15, "flour" = 15, "sugar" = 5)
	mix_message = "The ingredients form a cake batter."

/datum/chemical_reaction/cakebatter/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/cakebatter(location)

/datum/chemical_reaction/cakebatter/vegan
	id = "vegancakebatter"
	required_reagents = list("soymilk" = 15, "flour" = 15, "sugar" = 5)

/datum/chemical_reaction/ricebowl
	id = "ricebowl"
	required_reagents = list("rice" = 10, "water" = 10)
	required_container = /obj/item/weapon/reagent_containers/glass/bowl
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/ricebowl/on_reaction(datum/chem_holder/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/salad/ricebowl(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)
