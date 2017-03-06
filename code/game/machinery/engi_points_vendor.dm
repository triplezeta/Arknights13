
/obj/machinery/engi_points_manager
	name = "Engineering Points Manager"
	desc = "Who's a good boy?"
	icon = 'icons/obj/machines/engi_points.dmi'
	icon_state = "store"
	verb_say = "states"
	density = 1
	anchored = 1
	var/obj/item/device/radio/radio
	var/GBP = 0
	var/GBPearned = 0
	var/power_export_bonus = 0
	var/air_alarm_bonus = 0
	var/power_alarm_bonus = 0
	var/fire_alarm_bonus = 0
	var/alarm_rating = ""
	var/prior_bonus = 2500
	var/total_bonus = 0
	var/GBP_alarm_cooldown = 4500
	var/list/prize_list = list(
		new /datum/GBP_equipment("Tendie",				/obj/item/weapon/reagent_containers/food/snacks/nugget,				50,		1),
		new /datum/GBP_equipment("Cigar",				/obj/item/clothing/mask/cigarette/cigar/havana,						50,		1),
		new /datum/GBP_equipment("Soap",				/obj/item/weapon/soap/nanotrasen,									100,	1),
		new /datum/GBP_equipment("Fulton Beacon",		/obj/item/fulton_core,												50,		1),
		new /datum/GBP_equipment("Fulton Pack",			/obj/item/weapon/extraction_pack,									200,	1),
		new /datum/GBP_equipment("Space Cash",			/obj/item/stack/spacecash/c1000,									250,	1),
		new /datum/GBP_equipment("Insulated Gloves",				/obj/item/clothing/gloves/color/yellow,					400,	1),
		new /datum/GBP_equipment("50 metal sheets",			/obj/item/stack/sheet/metal/fifty,								500,	1),
		new /datum/GBP_equipment("50 glass sheets",			/obj/item/stack/sheet/glass/fifty,								500,	1),
		new /datum/GBP_equipment("50 cardboard sheets",			/obj/item/stack/sheet/cardboard/fifty,						500,	1),
		new /datum/GBP_equipment("Hardsuit x3",			/obj/item/clothing/suit/space/hardsuit,								750,	3),
		new /datum/GBP_equipment("Jetpack Upgrade x5",		/obj/item/weapon/tank/jetpack/suit,								1000,	5),
		new /datum/GBP_equipment("Powertools x3",			/obj/item/weapon/storage/belt/utility/chief/full,				2000,	3),
		new /datum/GBP_equipment("Advanced Magboot x3",			/obj/item/clothing/shoes/magboots/advance,					3000,	3),
		new /datum/GBP_equipment("Reflector Box x3",			/obj/structure/reflector/box,								3500,	3),
		new /datum/GBP_equipment("Radiation Collector x3",			/obj/machinery/power/rad_collector,						4000,	3),
		new /datum/GBP_equipment("Ranged RCD x3",			/obj/item/weapon/rcd/arcd,										5000,	3),
		new /datum/GBP_equipment("ERT Hardsuit x5",		/obj/item/clothing/suit/space/hardsuit/ert/engi,					6000,	5),
		new /datum/GBP_equipment("Portal Gun x5",			/obj/item/weapon/gun/energy/wormhole_projector,					8000,	5),
		new /datum/GBP_equipment("Reactive Decoy Armor x5",		/obj/item/clothing/suit/armor/reactive/stealth,				10000,	5),
		new /datum/GBP_equipment("Chrono Suit x5",		/obj/item/clothing/suit/space/chronos,								20000,	5),
		new /datum/GBP_equipment("WHAT HAVE YOU DONE... x5",		/obj/vehicle/space/speedbike/memewagon,				30000,	5),
		)

/datum/GBP_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0
	var/amount = 0

/datum/GBP_equipment/New(name, path, cost, amount)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost
	src.amount = amount

/obj/machinery/engi_points_manager/Initialize()
	radio = new(src)
	radio.listening = 0
	radio.frequency = 1357
	..()

/obj/machinery/engi_points_manager/Destroy()
	if(radio)
		qdel(radio)
		radio = null
	return ..()


/obj/machinery/engi_points_manager/power_change()
	..()
	update_icon()

/obj/machinery/engi_points_manager/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/engi_points_manager/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/engi_points_manager/interact(mob/user)
	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "You currently have <td>[round(GBP)]</td> engineering voucher points<br>"
	dat += "You have earned a total of <td>[round(GBPearned)]</td> this shift<br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='300'>"
	for(var/datum/GBP_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "vending", "Engineering Point Redemption", 400, 350)
	popup.set_content(dat)
	popup.open()

/obj/machinery/engi_points_manager/Topic(href, href_list)
	if(..())
		return
	if(href_list["purchase"])
		var/datum/GBP_equipment/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			return
		if(prize.cost > GBP)
			return
		else if(prize.cost <= GBP) // Placeholder spaghetti calm your shit
			GBP -= prize.cost
			for(var/i in 1 to prize.amount)
				for(var/obj/machinery/engi_points_delivery/D in machines)
					D.icon_state = "geardist-load"
					playsound(D, 'sound/machines/Ding.ogg', 100, 1)
					spawn(20)
						new prize.equipment_path(get_turf(D))
						D.icon_state = "geardist"
					if(prize.cost == 20000) // Still a placeholder
						new /obj/item/clothing/head/helmet/space/chronos(get_turf(src))
					feedback_add_details("Engi_equipment_bought",
					"[src.type]|[prize.equipment_path]")
		else
			GBP -= prize.cost
			new prize.equipment_path(src.loc)
			feedback_add_details("Engi_equipment_bought",
				"[src.type]|[prize.equipment_path]")
	updateUsrDialog()

/obj/machinery/engi_points_manager/attackby(obj/item/I, mob/user, params)
	return ..()

/obj/machinery/engi_points_manager/process()
	power_export_bonus = 0
	for(var/obj/machinery/power/exporter/PE in machines)
		power_export_bonus = PE.drain_rate/200
	if(GBP_alarm_cooldown <= world.time)
		var/limit = 0 // ugh, to stop it from checking the Centcom Computer
		for(var/obj/machinery/computer/station_alert/SA in machines)
			if(!limit)
				air_alarm_bonus = max(0,(1000 - (SA.air_alarm_count * 200)))
				power_alarm_bonus = max(0,(1000 - (SA.power_alarm_count * 200)))
				fire_alarm_bonus = max(0,(500 - (SA.fire_alarm_count * 100)))
				total_bonus = air_alarm_bonus + power_alarm_bonus + fire_alarm_bonus
				limit++
		switch(total_bonus)
			if(0)
				alarm_rating = "NOT WORTH THE AIR YOU'RE BREATHING, CONSIDER SUICIDE"
				playsound(src, 'sound/misc/compiler-failure.ogg', 100, 1)
			if(100 to 900)
				alarm_rating = "COMPLICIT IN THE STATION'S DOWNFALL"
				playsound(src, 'sound/misc/compiler-failure.ogg', 100, 1)
			if(1000 to 1500)
				alarm_rating = "HALF-ASSED"
				playsound(src, 'sound/misc/compiler-stage1.ogg', 100, 1)
			if(1600 to 2000)
				alarm_rating = "ADEQUATE AND UNREMARKABLE"
				playsound(src, 'sound/misc/compiler-stage1.ogg', 100, 1)
			if(2100 to 2400)
				alarm_rating = "IMPRESSIVE"
				playsound(src, 'sound/misc/compiler-stage2.ogg', 100, 1)
			if(2500)
				alarm_rating = "ABSOLUTELY FLAWLESS"
				playsound(src, 'sound/misc/compiler-stage2.ogg', 100, 1)
		radio.talk_into(src,"UPDATE: The engineering department has been awarded [air_alarm_bonus] points for the state of the station's air, [power_alarm_bonus] points for the state of the station's power, and [fire_alarm_bonus] points for the state of the station's fire alarms.")
		radio.talk_into(src,"This bonus represents [((total_bonus)/2500)*100]% of the total possible bonus. Your rating is: [alarm_rating]. Consult the station alert console for details.")
		if((total_bonus - prior_bonus) >= 1600)
			radio.talk_into(src,"Congratulations! Due to the significant repairs made by the engineering team, your bonus has been doubled this cycle!")
			total_bonus = total_bonus*2
		prior_bonus = total_bonus
		GBP_alarm_cooldown = world.time + 3000
		power_export_bonus += (air_alarm_bonus + power_alarm_bonus + fire_alarm_bonus)
	GBP += power_export_bonus
	GBPearned += power_export_bonus

/obj/machinery/engi_points_delivery
	name = "Engineering Reward Fabricator"
	desc = "Like a christmas tree for engineers"
	icon = 'icons/obj/machines/engi_points.dmi'
	icon_state = "geardist"
	density = 1
	anchored = 1
