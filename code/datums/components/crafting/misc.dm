/datum/crafting_recipe/naturalpaper
	name = "Hand-Pressed Paper"
	time = 3 SECONDS
	reqs = list(/datum/reagent/water = 50, /obj/item/stack/sheet/mineral/wood = 1)
	tool_paths = list(/obj/item/hatchet)
	result = /obj/item/paper_bin/bundlenatural
	category = CAT_MISC

/datum/crafting_recipe/skeleton_key
	name = "Skeleton Key"
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 5)
	result = /obj/item/skeleton_key
	always_available = FALSE
	category = CAT_MISC

/datum/crafting_recipe/coffee_cartridge
	name = "Bootleg Coffee Cartridge"
	result = /obj/item/coffee_cartridge/bootleg
	time = 2 SECONDS
	reqs = list(
		/obj/item/blank_coffee_cartridge = 1,
		/datum/reagent/toxin/coffeepowder = 10,
	)
	category = CAT_MISC

/datum/crafting_recipe/corporate_paper_slip
	name = "Corporate Plastic Card"
	result = /obj/item/paper/paperslip/corporate
	time = 3 SECONDS
	reqs = list(
		/obj/item/paper/paperslip = 1,
		/obj/item/stack/sheet/plastic = 3,
	)
	tool_paths = list(/obj/item/stamp/head/captain)
	category = CAT_MISC

/datum/crafting_recipe/cardboard_id
	name = "Cardboard ID Card"
	tool_behaviors = list(TOOL_WIRECUTTER)
	result = /obj/item/card/cardboard
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
	)
	category = CAT_MISC

/datum/crafting_recipe/syndifultonpack
	name = "Syndicate Fulton Extraction Pack"
	result = /obj/item/extraction_pack/syndicate
	time = 10 SECONDS
	reqs = list(/obj/item/stack/sheet/cloth = 10,
				/obj/item/stock_parts/servo = 5,
				/obj/item/stock_parts/scanning_module = 5)
	category = CAT_MISC
	always_available = FALSE

/datum/crafting_recipe/syndifultonbeacon
	name = "Syndicate Extraction Beacon"
	result = /obj/item/fulton_core/syndicate
	time = 5 SECONDS
	reqs = list(/obj/item/stock_parts/subspace/amplifier = 1,
				/obj/item/stock_parts/servo = 5,
				/obj/item/stock_parts/micro_laser = 3)
	category = CAT_MISC
	always_available = FALSE
	tool_behaviors = list(TOOL_WELDER, TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
