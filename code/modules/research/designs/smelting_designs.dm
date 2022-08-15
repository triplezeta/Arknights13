///////SMELTABLE ALLOYS///////

/datum/design/plasteel_alloy
	name = "Plasma + Iron alloy"
	id = "plasteel"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_STOCK_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	maxstack = 50


/datum/design/plastitanium_alloy
	name = "Plasma + Titanium alloy"
	id = "plastitanium"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/titanium = MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_STOCK_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	maxstack = 50

/datum/design/plaglass_alloy
	name = "Plasma + Glass alloy"
	id = "plasmaglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmaglass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_STOCK_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	maxstack = 50

/datum/design/plasmarglass_alloy
	name = "Plasma + Iron + Glass alloy"
	id = "plasmareinforcedglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/iron = MINERAL_MATERIAL_AMOUNT * 0.5,  /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmarglass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_STOCK_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	maxstack = 50

/datum/design/titaniumglass_alloy
	name = "Titanium + Glass alloy"
	id = "titaniumglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/titanium = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_STOCK_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	maxstack = 50

/datum/design/plastitaniumglass_alloy
	name = "Plasma + Titanium + Glass alloy"
	id = "plastitaniumglass"
	build_type = SMELTER | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_STOCK_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	maxstack = 50

/datum/design/alienalloy
	name = "Alien Alloy"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	build_type = PROTOLATHE | AWAY_LATHE | SMELTER
	materials = list(/datum/material/iron = 4000, /datum/material/plasma = 4000)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list(RND_CATEGORY_STOCK_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
