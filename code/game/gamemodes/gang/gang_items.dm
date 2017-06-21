/datum/gang_item
	var/name
	var/item_path
	var/cost
	var/spawn_msg
	var/category
	var/id

/datum/gang_item/proc/purchase(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, dominator))
		return FALSE
	var/real_cost = get_cost(user, gang, dominator)
	gang.adjust_influence(user.mind, -real_cost)
	spawn_item(user, gang, dominator)
	return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return gang && (gang.get_influence(user.mind) >= get_cost(user, gang, dominator)) && can_see(user, gang, dominator)

/datum/gang_item/proc/can_see(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return TRUE

/datum/gang_item/proc/get_cost(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return cost

/datum/gang_item/proc/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return "([get_cost(user, gang, dominator)] Influence)"

/datum/gang_item/proc/get_name_display(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return name

/datum/gang_item/proc/isboss(mob/living/carbon/user, datum/gang/gang)
	return user && gang && (user.mind == gang.bosses[1])

/datum/gang_item/proc/get_extra_info(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return

///////////////////
//FUNCTIONS
///////////////////

/datum/gang_item/function
	category = "dominator Functions:"
	cost = 0

/datum/gang_item/function/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return ""


/datum/gang_item/function/gang_ping
	name = "Send Message to Gang"
	id = "gang_ping"

/datum/gang_item/function/gang_ping/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(dominator)
		dominator.ping_gang(user)

/datum/gang_item/function/recall
	name = "Recall Emergency Shuttle"
	id = "recall"

/datum/gang_item/function/recall/can_see(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return isboss(user, gang)

/datum/gang_item/function/recall/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(dominator)
		dominator.recall(user)


///////////////////
//CLOTHING
///////////////////

/datum/gang_item/clothing
	category = "Purchase Influence-Enhancing Clothes:"

/datum/gang_item/clothing/under
	name = "Gang Uniform"
	id = "under"
	cost = 1

/datum/gang_item/clothing/under/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(gang.inner_outfit)
		var/obj/item/O = new gang.inner_outfit(user.loc)
		user.put_in_hands(O)
		to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence")

/datum/gang_item/clothing/suit
	name = "Gang Armored Outerwear"
	id = "suit"
	cost = 1

/datum/gang_item/clothing/suit/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(gang.outer_outfit)
		var/obj/item/O = new gang.outer_outfit(user.loc)
		O.armor = list(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
		O.desc += " Tailored for the [gang.name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
		user.put_in_hands(O)
		to_chat(user, "<span class='notice'> This is your gang's official outerwear, wearing it will increase your influence")


/datum/gang_item/clothing/hat
	name = "Pimp Hat"
	id = "hat"
	cost = 16
	item_path = /obj/item/clothing/head/collectable/petehat/gang

/obj/item/clothing/head/collectable/petehat/gang
	name = "pimpin' hat"
	desc = "The undisputed king of style."

/obj/item/clothing/head/collectable/petehat/gang/gang_contraband_value()
	return 4

/datum/gang_item/clothing/mask
	name = "Golden Death Mask"
	id = "mask"
	cost = 18
	item_path = /obj/item/clothing/mask/gskull

/obj/item/clothing/mask/gskull
	name = "golden death mask"
	icon_state = "gskull"
	desc = "Strike terror, and envy, into the hearts of your enemies."

/obj/item/clothing/mask/gskull/gang_contraband_value()
	return 5

/datum/gang_item/clothing/shoes
	name = "Bling Boots"
	id = "boots"
	cost = 22
	item_path = /obj/item/clothing/shoes/gang

/obj/item/clothing/shoes/gang
	name = "blinged-out boots"
	desc = "Stand aside peasants."
	icon_state = "bling"

/obj/item/clothing/shoes/gang/gang_contraband_value()
	return 6

/datum/gang_item/clothing/neck
	name = "Gold Necklace"
	id = "necklace"
	cost = 9
	item_path = /obj/item/clothing/neck/necklace/dope

/datum/gang_item/clothing/hands
	name = "Decorative Brass Knuckles"
	id = "hand"
	cost = 11
	item_path = /obj/item/clothing/gloves/gang

/obj/item/clothing/gloves/gang
	name = "braggadocio's brass knuckles"
	desc = "Purely decorative, don't find out the hard way."
	icon_state = "knuckles"
	w_class = 3

/obj/item/clothing/gloves/gang/gang_contraband_value()
	return 3

/datum/gang_item/clothing/belt
	name = "Badass Belt"
	id = "belt"
	cost = 13
	item_path = /obj/item/weapon/storage/belt/military/gang

/obj/item/weapon/storage/belt/military/gang
	name = "badass belt"
	icon_state = "gangbelt"
	item_state = "gang"
	desc = "The belt buckle simply reads 'BAMF'."
	storage_slots = 1

/obj/item/weapon/storage/belt/military/gang/gang_contraband_value()
	return 4

///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Purchase Weapons:"

/datum/gang_item/weapon/ammo

/datum/gang_item/weapon/ammo/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	return "&nbsp;&#8627;" + ..() //this is pretty hacky but it looks nice on the popup

/datum/gang_item/weapon/shuriken
	name = "Shuriken"
	id = "shuriken"
	cost = 3
	item_path = /obj/item/weapon/throwing_star

/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	id = "switchblade"
	cost = 5
	item_path = /obj/item/weapon/switchblade

/datum/gang_item/weapon/surplus
	name = "Surplus Rifle"
	id = "surplus"
	cost = 8
	item_path = /obj/item/weapon/gun/ballistic/automatic/surplus

/datum/gang_item/weapon/ammo/surplus_ammo
	name = "Surplus Rifle Ammo"
	id = "surplus_ammo"
	cost = 5
	item_path = /obj/item/ammo_box/magazine/m10mm/rifle

/datum/gang_item/weapon/improvised
	name = "Sawn-Off Improvised Shotgun"
	id = "sawn"
	cost = 6
	item_path = /obj/item/weapon/gun/ballistic/revolver/doublebarrel/improvised/sawn

/datum/gang_item/weapon/ammo/improvised_ammo
	name = "Box of Buckshot"
	id = "buckshot"
	cost = 5
	item_path = /obj/item/weapon/storage/box/lethalshot

/datum/gang_item/weapon/pistol
	name = "10mm Pistol"
	id = "pistol"
	cost = 30
	item_path = /obj/item/weapon/gun/ballistic/automatic/pistol

/datum/gang_item/weapon/ammo/pistol_ammo
	name = "10mm Ammo"
	id = "pistol_ammo"
	cost = 10
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/gang_item/weapon/sniper
	name = "Black Market .50cal Sniper Rifle"
	id = "sniper"
	cost = 40
	item_path = /obj/item/weapon/gun/ballistic/automatic/sniper_rifle/gang

/datum/gang_item/weapon/ammo/sniper_ammo
	name = "Smuggled .50cal Sniper Rounds"
	id = "sniper_ammo"
	cost = 15
	item_path = /obj/item/ammo_box/magazine/sniper_rounds/gang


/datum/gang_item/weapon/ammo/sleeper_ammo
	name = "Illicit Tranquilizer Cartridges"
	id = "sniper_ammo"
	cost = 15
	item_path = /obj/item/ammo_box/magazine/sniper_rounds/gang/sleeper


/datum/gang_item/weapon/machinegun
	name = "Mounted Machine Gun"
	id = "MG"
	cost = 50
	item_path = /obj/machinery/manned_turret
	spawn_msg = "<span class='notice'>The mounted machine gun features enhanced responsiveness. Hold down on the trigger while firing to control where you're shooting.</span>"

/datum/gang_item/weapon/uzi
	name = "Uzi SMG"
	id = "uzi"
	cost = 60
	item_path = /obj/item/weapon/gun/ballistic/automatic/mini_uzi


/datum/gang_item/weapon/ammo/uzi_ammo
	name = "Uzi Ammo"
	id = "uzi_ammo"
	cost = 40
	item_path = /obj/item/ammo_box/magazine/uzim9mm

///////////////////
//EQUIPMENT
///////////////////

/datum/gang_item/equipment
	category = "Purchase Equipment:"


/datum/gang_item/equipment/spraycan
	name = "Territory Spraycan"
	id = "spraycan"
	cost = 5
	item_path = /obj/item/toy/crayon/spraycan/gang

/datum/gang_item/equipment/sharpener
	name = "Sharpener"
	id = "whetstone"
	cost = 3
	item_path = /obj/item/weapon/sharpener


/datum/gang_item/equipment/emp
	name = "EMP Grenade"
	id = "EMP"
	cost = 5
	item_path = /obj/item/weapon/grenade/empgrenade

/datum/gang_item/equipment/c4
	name = "C4 Explosive"
	id = "c4"
	cost = 7
	item_path = /obj/item/weapon/grenade/plastic/c4

/datum/gang_item/equipment/frag
	name = "Fragmentation Grenade"
	id = "frag nade"
	cost = 18
	item_path = /obj/item/weapon/grenade/syndieminibomb/concussion/frag

/datum/gang_item/equipment/stimpack
	name = "Black Market Stimulants"
	id = "stimpack"
	cost = 12
	item_path = /obj/item/weapon/reagent_containers/syringe/stimulants

/datum/gang_item/equipment/implant_breaker
	name = "Implant Breaker"
	id = "implant_breaker"
	cost = 10
	item_path = /obj/item/weapon/implanter/gang
	spawn_msg = "<span class='notice'>The <b>implant breaker</b> is a single-use device that destroys all implants within the target before trying to recruit them to your gang. Also works on enemy gangsters.</span>"

/datum/gang_item/equipment/implant_breaker/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(item_path)
		var/obj/item/O = new item_path(user.loc, gang) //we need to override this whole proc for this one argument
		user.put_in_hands(O)
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/equipment/wetwork_boots
	name = "Wetwork boots"
	id = "wetwork"
	cost = 20
	item_path = /obj/item/clothing/shoes/combat/gang

/obj/item/clothing/shoes/combat/gang
	name = "Wetwork boots"
	desc = "A gang's best hitmen are prepared for anything."
	permeability_coefficient = 0.01
	flags = NOSLIP

/datum/gang_item/equipment/pen
	name = "Recruitment Pen"
	id = "pen"
	cost = 50
	item_path = /obj/item/weapon/pen/gang
	spawn_msg = "<span class='notice'>More <b>recruitment pens</b> will allow you to recruit gangsters faster. Only gang leaders can recruit with pens.</span>"

/datum/gang_item/equipment/pen/purchase(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(..())
		dominator.free_pens--
		return TRUE
	return FALSE

/datum/gang_item/equipment/pen/get_cost(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(dominator && dominator.free_pens)
		return 0
	return ..()

/datum/gang_item/equipment/pen/get_cost_display(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(dominator && dominator.free_pens)
		return "(GET ONE FREE)"
	return ..()

/datum/gang_item/equipment/dominator_spawner
	name = "Dominator Warp Beacon"
	id = "dominator_spawner"
	cost = 30
	item_path = /obj/item/device/dominator_spawner
	spawn_msg = "<span class='notice'>A device that can warp a new dominator configured and ready to go for your gang at your location.</span>"

/datum/gang_item/equipment/dominator/can_buy(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(!gang)
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/get_name_display(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	if(!gang )
		return ..()
	return "<b>[..()]</b>"

/////////////////////////////////////
/datum/gang_item/equipment/dominator/purchase(mob/living/carbon/user, datum/gang/G, obj/machinery/dominator/dominator)
	var/area/usrarea = get_area(user.loc)
	var/usrturf = get_turf(user.loc)
	if(initial(usrarea.name) == "Space" || isspaceturf(usrturf) || usr.z != ZLEVEL_STATION)
		to_chat(user, "<span class='warning'>You can only use this on the station!</span>")
		return FALSE

	for(var/obj/obj in usrturf)
		if(obj.density)
			to_chat(user, "<span class='warning'>There's not enough room here!</span>")
			return FALSE

	if(istype(G.current_dominator) && !(G.current_dominator.stat & BROKEN) && DOMINATOR_FORCEFIELD)
		to_chat(user, "<span class='warning'>Your gang already has an active dominator at [get_area(G.current_dominator)]!</span>")
		return FALSE

	if(dominator_excessive_walls(user))
		to_chat(user, "<span class='warning'>The <b>dominator</b> will not function here! The <b>dominator</b> requires a sizable open space within three standard units so that walls do not interfere with the signal.</span>")
		return FALSE

	if(dominator_interference_check(user))
		to_chat(user, "<span class='warning'>The <b>dominator</b> will not function here! There is an opposing dominator in close proximity, which would be able to override this dominator before it even starts!</span>")
		return FALSE

	if(!(usrarea.type in G.territory|G.territory_new))
		to_chat(user, "<span class='warning'>The <b>dominator</b> can be spawned only on territory controlled by your gang!</span>")
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/spawn_item(mob/living/carbon/user, datum/gang/gang, obj/machinery/dominator/dominator)
	var/obj/machinery/dominator/D = new item_path(user.loc)
	gang.current_dominator = D
	D.gang = gang
