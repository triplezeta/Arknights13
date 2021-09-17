/obj/screen/swarmer
	icon = 'icons/hud/swarmer.dmi'

/obj/screen/swarmer/MouseEntered(location, control, params)
	. = ..()
	openToolTip(usr, src, params, title = name, content = desc)

/obj/screen/swarmer/MouseExited(location, control, params)
	closeToolTip(usr)

/obj/screen/swarmer/fabricate_trap
	icon_state = "ui_trap"
	name = "Create Trap (Costs 4 Resources)"
	desc = "Creates a trap that will nonlethally shock any non-swarmer that attempts to cross it."

/obj/screen/swarmer/fabricate_trap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/our_swarmer = usr
		our_swarmer.create_trap()

/obj/screen/swarmer/barricade
	icon_state = "ui_barricade"
	name = "Create Barricade (Costs 4 Resources)"
	desc = "Creates a destructible barricade that will stop any non-swarmer from passing it. Also allows disabler beams to pass through."

/obj/screen/swarmer/barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/our_swarmer = usr
		our_swarmer.create_barricade()

/obj/screen/swarmer/replicate
	icon_state = "ui_replicate"
	name = "Replicate (Costs 20 Resources)"
	desc = "Creates an autonomous melee drone that will follow you and attack all non-swamers entities in sight. They can be ordered to move to a target location by a middle-click."

/obj/screen/swarmer/replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/our_swarmer = usr
		our_swarmer.create_swarmer()

/obj/screen/swarmer/repair_self
	icon_state = "ui_self_repair"
	name = "Repair Self"
	desc = "Fully repairs damage done to our body after a moderate delay."

/obj/screen/swarmer/repair_self/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/our_swarmer = usr
		our_swarmer.repair_self()

/obj/screen/swarmer/toggle_light
	icon_state = "ui_light"
	name = "Toggle Light"
	desc = "Toggles our inbuilt light on or off. Follower drones will also synchronize their lights with a master unit."

/obj/screen/swarmer/toggle_light/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/our_swarmer = usr
		our_swarmer.toggle_light()

/obj/screen/swarmer/contact_swarmers
	icon_state = "ui_contact_swarmers"
	name = "Contact Swarmers"
	desc = "Sends a message to all other swarmers, should they exist."

/obj/screen/swarmer/contact_swarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/our_swarmer = usr
		our_swarmer.contact_swarmers()

/datum/hud/living/swarmer/New(mob/living/owner)
	. = ..()
	var/obj/screen/using

	using = new /obj/screen/swarmer/fabricate_trap()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/barricade()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/replicate()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/repair_self()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/toggle_light()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/contact_swarmers()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using
