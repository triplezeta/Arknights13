
////////////////////////////////////////////OTHER////////////////////////////////////////////
/obj/item/food/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	food_reagents = list(
		/datum/reagent/water = 1,
		/datum/reagent/consumable/nutriment/vitamin = 0.2,
		/datum/reagent/consumable/nutriment = 1,
	)
	tastes = list("watermelon" = 1)
	foodtypes = FRUIT
	food_flags = FOOD_FINGER_FOOD
	juice_typepath = /datum/reagent/consumable/watermelonjuice
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "hugemushroomslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("mushroom" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/hugemushroomslice/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_WALKING_MUSHROOM, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/item/food/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash_type = /obj/item/trash/popcorn
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bite_consumption = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	tastes = list("popcorn" = 3, "butter" = 1)
	foodtypes = JUNKFOOD
	eatverbs = list("bite", "nibble", "gnaw", "gobble", "chomp")
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/popcorn/salty
	name = "salty popcorn"
	icon_state = "salty_popcorn"
	desc = "Salty popcorn, a classic for all time."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/salt = 2,
	)
	tastes = list("salt" = 2, "popcorn" = 1)
	trash_type = /obj/item/trash/popcorn/salty
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/popcorn/caramel
	name = "caramel popcorn"
	icon_state = "сaramel_popcorn"
	desc = "Caramel-covered popcorn. Sweet!"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/caramel = 4,
	)
	tastes = list("caramel" = 2, "popcorn" = 1)
	foodtypes = JUNKFOOD | SUGAR
	trash_type = /obj/item/trash/popcorn/
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/soydope
	name = "soy dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
	)
	tastes = list("soy" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/badrecipe
	name = "burned mess"
	desc = "Someone should be demoted from cook for this."
	icon_state = "badrecipe"
	food_reagents = list(/datum/reagent/toxin/bad_food = 30)
	foodtypes = GROSS
	w_class = WEIGHT_CLASS_SMALL
	preserved_food = TRUE //Can't decompose any more than this
	/// Variable that holds the reference to the stink lines we get when we're moldy, yucky yuck
	var/stink_particles

/obj/item/food/badrecipe/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_GRILL_PROCESS, PROC_REF(OnGrill))
	if(stink_particles)
		particles = new stink_particles

/obj/item/food/badrecipe/moldy
	name = "moldy mess"
	desc = "A rancid, disgusting culture of mold and ants. Somewhere under there, at <i>some point,</i> there was food."
	food_reagents = list(/datum/reagent/consumable/mold = 30)
	preserved_food = FALSE
	ant_attracting = TRUE
	decomp_type = null
	decomposition_time = 30 SECONDS
	stink_particles = /particles/stink

/obj/item/food/badrecipe/moldy/bacteria
	name = "bacteria rich moldy mess"
	desc = "Not only is this rancid lump of disgusting bile crawling with insect life, \
		but it is also teeming with various microscopic cultures. <i>It moves when you're not looking.</i>"

/obj/item/food/badrecipe/moldy/bacteria/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2, 4), 25)

///Prevents grilling burnt shit from well, burning.
/obj/item/food/badrecipe/proc/OnGrill()
	SIGNAL_HANDLER
	return COMPONENT_HANDLED_GRILLING

/obj/item/food/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spidereggs"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/toxin = 2,
	)
	tastes = list("cobwebs" = 1)
	foodtypes = MEAT | TOXIC | BUGS
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/spidereggs/processed
	name = "processed spider eggs"
	desc = "A cluster of juicy spider eggs. Pops in your mouth without making you sick."
	icon_state = "spidereggs"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 4)
	tastes = list("cobwebs" = 1)
	foodtypes = MEAT | BUGS
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/spiderling
	name = "spiderling"
	desc = "It's slightly twitching in your hand. Ew..."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "spiderling_dead"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/toxin = 4,
	)
	tastes = list("cobwebs" = 1, "guts" = 2)
	foodtypes = MEAT | TOXIC | BUGS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/melonfruitbowl
	name = "melon fruit bowl"
	desc = "For people who wants edible fruit bowls."
	icon_state = "melonfruitbowl"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("melon" = 1)
	foodtypes = FRUIT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/melonkeg
	name = "melon keg"
	desc = "Who knew vodka was a fruit?"
	icon_state = "melonkeg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/ethanol/vodka = 15,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	max_volume = 80
	bite_consumption = 5
	tastes = list("grain alcohol" = 1, "fruit" = 1)
	foodtypes = FRUIT | ALCOHOL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/honeybar
	name = "honey nut bar"
	desc = "Oats and nuts compressed together into a bar, held together with a honey glaze."
	icon_state = "honeybar"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/honey = 5,
	)
	tastes = list("oats" = 3, "nuts" = 2, "honey" = 1)
	foodtypes = GRAIN | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/powercrepe
	name = "Powercrepe"
	desc = "With great power, comes great crepes.  It looks like a pancake filled with jelly but packs quite a punch."
	icon_state = "powercrepe"
	inhand_icon_state = "powercrepe"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/cherryjelly = 5,
	)
	force = 30
	throwforce = 15
	block_chance = 55
	armour_penetration = 80
	block_sound = 'sound/weapons/parry.ogg'
	wound_bonus = -50
	attack_verb_continuous = list("slaps", "slathers")
	attack_verb_simple = list("slap", "slather")
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("cherry" = 1, "crepe" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/branrequests
	name = "Bran Requests Cereal"
	desc = "A dry cereal that satiates your requests for bran. Tastes uniquely like raisins and salt."
	icon_state = "bran_requests"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/salt = 8,
	)
	tastes = list("bran" = 4, "raisins" = 3, "salt" = 1)
	foodtypes = GRAIN | FRUIT | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/butter
	name = "stick of butter"
	desc = "A stick of delicious, golden, fatty goodness."
	icon_state = "butter"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("butter" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/butter/examine(mob/user)
	. = ..()
	. += span_notice("If you had a rod you could make <b>butter on a stick</b>.")

/obj/item/food/butter/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = item
		if(!rods.use(1))//borgs can still fail this if they have no metal
			to_chat(user, span_warning("You do not have enough iron to put [src] on a stick!"))
			return ..()
		to_chat(user, span_notice("You stick the rod into the stick of butter."))
		var/obj/item/food/butter/on_a_stick/new_item = new(usr.loc)
		var/replace = (user.get_inactive_held_item() == rods)
		if(!rods && replace)
			user.put_in_hands(new_item)
		qdel(src)
		return TRUE
	..()

/obj/item/food/butter/on_a_stick //there's something so special about putting it on a stick.
	name = "butter on a stick"
	desc = "delicious, golden, fatty goodness on a stick."
	icon_state = "butteronastick"
	trash_type = /obj/item/stack/rods
	food_flags = FOOD_FINGER_FOOD

/obj/item/food/butter/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/butterslice, 3, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/butterslice
	name = "butter slice"
	desc = "A slice of butter, for your buttering needs."
	icon_state = "butterslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("butter" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/onionrings
	name = "onion rings"
	desc = "Onion slices coated in batter."
	icon_state = "onionrings"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	gender = PLURAL
	tastes = list("batter" = 3, "onion" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/pineappleslice
	name = "pineapple slice"
	desc = "A sliced piece of juicy pineapple."
	icon_state = "pineapple_slice"
	juice_typepath = /datum/reagent/consumable/pineapplejuice
	tastes = list("pineapple" = 1)
	foodtypes = FRUIT | PINEAPPLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/crab_rangoon
	name = "Crab Rangoon"
	desc = "Has many names, like crab puffs, cheese won'tons, crab dumplings? Whatever you call them, they're a fabulous blast of cream cheesy crab."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "crabrangoon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("cream cheese" = 4, "crab" = 3, "crispiness" = 2)
	foodtypes = MEAT | DAIRY | GRAIN
	venue_value = FOOD_PRICE_CHEAP
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pesto
	name = "pesto"
	desc = "A combination of firm cheese, salt, herbs, garlic, oil, and pine nuts. Frequently used as a sauce for pasta or pizza, or eaten on bread."
	icon_state = "pesto"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pesto" = 1)
	foodtypes = VEGETABLES | DAIRY | NUTS
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/tomato_sauce
	name = "tomato sauce"
	desc = "Tomato sauce, perfect for pizza or pasta. Mamma mia!"
	icon_state = "tomato_sauce"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("tomato" = 1, "herbs" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/bechamel_sauce
	name = "béchamel sauce"
	desc = "A classic white sauce common to several European cultures."
	icon_state = "bechamel_sauce"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("cream" = 1)
	foodtypes = DAIRY | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/roasted_bell_pepper
	name = "roasted bell pepper"
	desc = "A blackened, blistered bell pepper. Great for making sauces."
	icon_state = "roasted_bell_pepper"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/char = 1,
	)
	tastes = list("bell pepper" = 1, "char" = 1)
	foodtypes = VEGETABLES
	burns_in_oven = TRUE
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/pierogi
	name = "pierogi"
	desc = "A dumpling made by wrapping unleavened dough around a savoury or sweet filling and cooking in boiling water. This one is filled with a potato and onion mixture."
	icon_state = "pierogi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("potato" = 1, "onions" = 1)
	foodtypes = GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/stuffed_cabbage
	name = "stuffed cabbage"
	desc = "A savoury mixture of ground meat and rice wrapped in cooked cabbage leaves and topped with a tomato sauce. To die for."
	icon_state = "stuffed_cabbage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("juicy meat" = 1, "rice" = 1, "cabbage" = 1)
	foodtypes = MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/seaweedsheet
	name = "seaweed sheet"
	desc = "A dried sheet of seaweed used for making sushi. Use an ingredient on it to start making custom sushi!"
	icon_state = "seaweedsheet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("seaweed" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/seaweedsheet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/sushi/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 6)

/obj/item/food/granola_bar
	name = "granola bar"
	desc = "A dried mixture of oats, nuts, fruits, and chocolate condensed into a chewy bar. Makes a great snack while space-hiking."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "granola_bar"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	tastes = list("granola" = 1, "nuts" = 1, "chocolate" = 1, "raisin" = 1)
	foodtypes = GRAIN | NUTS | FRUIT | SUGAR | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/onigiri
	name = "onigiri"
	desc = "A ball of cooked rice surrounding a filling formed into a triangular shape and wrapped in seaweed. Can be added fillings!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "onigiri"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("rice" = 1, "dried seaweed" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/onigiri/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/onigiri/empty, CUSTOM_INGREDIENT_ICON_NOCHANGE, max_ingredients = 4)

// empty onigiri for custom onigiri
/obj/item/food/onigiri/empty
	name = "onigiri"
	desc = "A ball of cooked rice surrounding a filling formed into a triangular shape and wrapped in seaweed."
	icon_state = "onigiri"
	foodtypes = VEGETABLES
	tastes = list()

/obj/item/food/pacoca
	name = "paçoca"
	desc = "A traditional Brazilian treat made of ground peanuts, sugar, and salt compressed into a cylinder."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "pacoca"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("peanuts" = 1, "sweetness" = 1)
	foodtypes = NUTS | SUGAR
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/pickle
	name = "pickle"
	desc = "Slightly shriveled darkish cucumber. Smelling something sour, but incredibly inviting."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "pickle"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/pickle = 1,
		/datum/reagent/medicine/antihol = 2,
	)
	tastes = list("pickle" = 1, "spices" = 1, "salt water" = 2)
	juice_typepath = /datum/reagent/consumable/pickle
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/pickle/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, check_liked = CALLBACK(src, PROC_REF(check_liked)))

/obj/item/food/pickle/proc/check_liked(fraction, mob/living/carbon/human/consumer)
	var/obj/item/organ/internal/liver/liver = consumer.get_organ_slot(ORGAN_SLOT_LIVER)
	if(!HAS_TRAIT(consumer, TRAIT_AGEUSIA) && liver && HAS_TRAIT(liver, TRAIT_CORONER_METABOLISM))
		return FOOD_LIKED

/obj/item/food/springroll
	name = "spring roll"
	desc = "A plate of translucent rice wrappers filled with fresh vegetables, served with sweet chili sauce. You either love them or hate them."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "springroll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/capsaicin = 2,
	)
	tastes = list("rice wrappers" = 1, "spice" = 1, "crunchy veggies" = 1)
	foodtypes = GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cheese_pierogi
	name = "cheese pierogi"
	desc = "A dumpling made by wrapping unleavened dough around a savoury or sweet filling and cooking in boiling water. This one is filled with a potato and cheese mixture."
	icon_state = "cheese_pierogi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("potato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/meat_pierogi
	name = "meat pierogi"
	desc = "A dumpling made by wrapping unleavened dough around a savoury or sweet filling and cooking in boiling water. This one is filled with a potato and meat mixture."
	icon_state = "meat_pierogi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("potato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
