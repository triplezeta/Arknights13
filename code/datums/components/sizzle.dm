/datum/component/sizzle
	var/mutable_appearance/sizzling
	var/sizzlealpha = 5
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/sizzle/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	setup_sizzle()

/datum/component/sizzle/InheritComponent(datum/component/C, i_am_original)
	sizzlealpha += 5

/datum/component/sizzle/proc/setup_sizzle()
	var/atom/food = parent
	if(!isnull(sizzling))
		food.cut_overlay(sizzling)
	var/icon/grillmarks = mutable_appearance(initial(food.icon), initial(food.icon_state))	//we only want to apply grill marks to the initial icon_state for each object
	grillmarks.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
	grillmarks.Blend(icon('icons/obj/kitchen.dmi', "grillmarks"), ICON_MULTIPLY) //adds grill marks and the remaining white areas become transparent
	sizzling = grillmarks
	sizzling.alpha = sizzlealpha
	food.add_overlay(sizzling)
