/datum/hud/larva
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/larva/New(mob/owner)
	..()
	var/obj/screen/using

	action_intent = new /obj/screen/combattoggle/flashy()
	action_intent.hud = src
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

	healths = new /obj/screen/healths/alien()
	healths.hud = src
	infodisplay += healths

	alien_queen_finder = new /obj/screen/alien/alien_queen_finder()
	alien_queen_finder.hud = src
	infodisplay += alien_queen_finder

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/hud/screen_alien.dmi'
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_above_movement
	pull_icon.hud = src
	hotkeybuttons += pull_icon

	using = new/obj/screen/language_menu
	using.screen_loc = ui_alien_language_menu
	using.hud = src
	static_inventory += using

	zone_select = new /obj/screen/zone_sel/alien()
	zone_select.hud = src
	zone_select.update_appearance()
	static_inventory += zone_select
