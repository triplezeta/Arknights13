/*
Slimecrossing Items
	General items added by the slimecrossing system.
	Collected here for clarity.
*/

//Rewind camera - I'm already Burning Sepia
/obj/item/camera/rewind
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1
	can_customise = FALSE
	default_picture_name = "A nostalgic picture"
	var/used = FALSE

/datum/saved_bodypart
	var/obj/item/bodypart/old_part
	var/bodypart_type
	var/brute_dam
	var/burn_dam
	var/stamina_dam

/datum/saved_bodypart/New(obj/item/bodypart/part)
	old_part = part
	bodypart_type = part.type
	brute_dam = part.brute_dam
	burn_dam = part.burn_dam
	stamina_dam = part.stamina_dam

/mob/living/carbon/proc/apply_saved_bodyparts(list/datum/saved_bodypart/parts)
	var/list/dont_chop = list()
	for(var/zone in parts)
		var/datum/saved_bodypart/saved_part = parts[zone]
		var/obj/item/bodypart/already = get_bodypart(zone)
		if(QDELETED(saved_part.old_part))
			saved_part.old_part = new saved_part.bodypart_type
		if(!already || already != saved_part.old_part)
			saved_part.old_part.replace_limb(src, TRUE)
		saved_part.old_part.heal_damage(INFINITY, INFINITY, INFINITY, null, FALSE)
		saved_part.old_part.receive_damage(saved_part.brute_dam, saved_part.burn_dam, saved_part.stamina_dam, wound_bonus=CANT_WOUND)
		dont_chop[zone] = TRUE
	for(var/_part in bodyparts)
		var/obj/item/bodypart/part = _part
		if(dont_chop[part.body_zone])
			continue
		part.drop_limb(TRUE)

/mob/living/carbon/proc/save_bodyparts()
	var/list/datum/saved_bodypart/ret = list()
	for(var/_part in bodyparts)
		var/obj/item/bodypart/part = _part
		var/datum/saved_bodypart/saved_part = new(part)

		ret[part.body_zone] = saved_part
	return ret

/obj/item/camera/rewind/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return
	if(!used)//selfie time
		if(user == target)
			to_chat(user, "<span class=notice>You take a selfie!</span>")
		else
			to_chat(user, "<span class=notice>You take a photo with [target]!</span>")
			to_chat(target, "<span class=notice>[user] takes a photo with you!</span>")
		to_chat(target, "<span class=notice>You'll remember this moment forever!</span>")

		used = TRUE
		target.AddComponent(/datum/component/dejavu, 2)
	.=..()



//Timefreeze camera - Old Burning Sepia result. Kept in case admins want to spawn it
/obj/item/camera/timefreeze
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1
	var/used = FALSE

/obj/item/camera/timefreeze/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return
	if(!used) //refilling the film does not refill the timestop
		new /obj/effect/timestop(get_turf(target), 2, 50, list(user))
		used = TRUE
		desc = "This camera has seen better days."
	. = ..()


//Hypercharged slime cell - Charged Yellow
/obj/item/stock_parts/cell/high/slime/hypercharged
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with even more plasma. It almost hurts to touch."
	rating = 7 //Roughly 1.5 times the original.
	maxcharge = 20000 //2 times the normal one.
	chargerate = 2250 //1.5 times the normal rate.

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = WEIGHT_CLASS_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(loc))
		to_chat(user, "<span class='warning'>You can't fit more than one barrier in the same space!</span>")
		return
	to_chat(user, "<span class='notice'>You squeeze [src].</span>")
	var/obj/B = new /obj/structure/barricade/slime(get_turf(loc))
	B.visible_message("<span class='warning'>[src] suddenly grows into a large, gelatinous barrier!</span>")
	qdel(src)

//Slime barricade - Chilling Grey
/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier"
	proj_pass_rate = 40
	max_integrity = 60

//Melting Gel Wall - Chilling Metal
/obj/effect/forcefield/slimewall
	name = "solidified gel"
	desc = "A mass of solidified slime gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier_thick"
	CanAtmosPass = ATMOS_PASS_NO
	opacity = TRUE
	timeleft = 100

//Rainbow barrier - Chilling Rainbow
/obj/effect/forcefield/slimewall/rainbow
	name = "rainbow barrier"
	desc = "Despite others' urgings, you probably shouldn't taste this."
	icon_state = "rainbowbarrier"

//Ration pack - Chilling Silver
/obj/item/reagent_containers/food/snacks/rationpack
	name = "ration pack"
	desc = "A square bar that sadly <i>looks</i> like chocolate, packaged in a nondescript grey wrapper. Has saved soldiers' lives before - usually by stopping bullets."
	icon_state = "rationpack"
	bitesize = 3
	junkiness = 15
	filling_color = "#964B00"
	tastes = list("cardboard" = 3, "sadness" = 3)
	foodtype = null //Don't ask what went into them. You're better off not knowing.
	list_reagents = list(/datum/reagent/consumable/nutriment/stabilized = 10, /datum/reagent/consumable/nutriment = 2) //Won't make you fat. Will make you question your sanity.

/obj/item/reagent_containers/food/snacks/rationpack/checkLiked(fraction, mob/M)	//Nobody likes rationpacks. Nobody.
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.mind && !HAS_TRAIT(H, TRAIT_AGEUSIA))
				to_chat(H,"<span class='notice'>That didn't taste very good...</span>") //No disgust, though. It's just not good tasting.
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
				last_check_time = world.time
				return
	..()

//Ice stasis block - Chilling Dark Blue
/obj/structure/ice_stasis
	name = "ice block"
	desc = "A massive block of ice. You can see something vaguely humanoid inside."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	max_integrity = 100
	armor = list("melee" = 30, "bullet" = 50, "laser" = -50, "energy" = -50, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = -80, "acid" = 30)

/obj/structure/ice_stasis/Initialize()
	. = ..()
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, TRUE)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, TRUE)
	return ..()

//Gold capture device - Chilling Gold
/obj/item/capturedevice
	name = "gold capture device"
	desc = "Bluespace technology packed into a roughly egg-shaped device, used to store nonhuman creatures. Can't catch them all, though - it only fits one."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "capturedevice"

/obj/item/capturedevice/attack(mob/living/M, mob/user)
	if(length(contents))
		to_chat(user, "<span class='warning'>The device already has something inside.</span>")
		return
	if(!isanimal(M))
		to_chat(user, "<span class='warning'>The capture device only works on simple creatures.</span>")
		return
	if(M.mind)
		to_chat(user, "<span class='notice'>You offer the device to [M].</span>")
		if(alert(M, "Would you like to enter [user]'s capture device?", "Gold Capture Device", "Yes", "No") == "Yes")
			if(user.canUseTopic(src, BE_CLOSE) && user.canUseTopic(M, BE_CLOSE))
				to_chat(user, "<span class='notice'>You store [M] in the capture device.</span>")
				to_chat(M, "<span class='notice'>The world warps around you, and you're suddenly in an endless void, with a window to the outside floating in front of you.</span>")
				store(M, user)
			else
				to_chat(user, "<span class='warning'>You were too far away from [M].</span>")
				to_chat(M, "<span class='warning'>You were too far away from [user].</span>")
		else
			to_chat(user, "<span class='warning'>[M] refused to enter the device.</span>")
			return
	else
		if(istype(M, /mob/living/simple_animal/hostile) && !("neutral" in M.faction))
			to_chat(user, "<span class='warning'>This creature is too aggressive to capture.</span>")
			return
	to_chat(user, "<span class='notice'>You store [M] in the capture device.</span>")
	store(M)

/obj/item/capturedevice/attack_self(mob/user)
	if(contents.len)
		to_chat(user, "<span class='notice'>You open the capture device!</span>")
		release()
	else
		to_chat(user, "<span class='warning'>The device is empty...</span>")

/obj/item/capturedevice/proc/store(var/mob/living/M)
	M.forceMove(src)

/obj/item/capturedevice/proc/release()
	for(var/atom/movable/M in contents)
		M.forceMove(get_turf(loc))

/obj/item/slimeball
	name = "Slimeball"
	desc = "Allows you to hold a single slime inside of it, just throw it into a slime, and throw again to release him!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimeball"
	var/mob/living/simple_animal/slime/held_slime

/obj/item/slimeball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!isslime(hit_atom))
		if(!held_slime)
			return

		held_slime.forceMove(get_turf(src))
		playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
		held_slime = null
		return
	playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
	held_slime = hit_atom
	held_slime.forceMove(src)

/obj/item/spear/slime
	name = "Slimespear"
	desc = "Gelatinous spear, hardens on touch, glossy like glass with zaps of electricity going around it."
	color = "#00ff15"

/obj/item/spear/slime/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		playsound(hit_atom, 'sound/effects/glassbr3.ogg', 100)
		qdel(src)

/obj/item/storage/photo_album/slime
	name = "slimey photo album"
	color = "#00ff15"

/obj/item/reagent_containers/food/snacks/pie/plain/slime
	name = "slime pie"
	desc = "A slime pie, still delicious."
	color = "#00ff15"

/obj/item/reagent_containers/food/snacks/pie/plain/slime/On_Consume(mob/living/eater)
	. = ..()
	if(isslimeperson(eater))
		var/mob/living/carbon/human/human_eater = eater
		human_eater.blood_volume += 50

/obj/machinery/photocopier/slime
	name = "Slime photocopier"
	desc = "Used to copy important documents and anatomy studies, it can run on slime jelly!"
	anchored = FALSE
	color = "#00ff15"

/obj/machinery/photocopier/slime/attackby(obj/item/O, mob/user, params)
	. = ..()
	var/datum/reagents/reggies = O.reagents
	if(!reggies)
		return
	var/datum/reagent/toxin/slimejelly/SJ =  reggies.has_reagent(/datum/reagent/toxin/slimejelly)
	if(!SJ)
		return
	toner += round(SJ.volume/10)
	reggies.remove_reagent(/datum/reagent/toxin/slimejelly,SJ.volume)


/obj/item/slime_iv
	name = "Slime IV"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimeiv"
	var/mob/living/carbon/attached

/obj/item/slime_iv/Initialize()
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/item/slime_iv/MouseDrop(mob/living/target)
	. = ..()
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE) || !isliving(target))
		return

	if(attached == target)
		visible_message("<span class='warning'>[attached] is detached from [src].</span>")
		attached = null
		return

	if(!target.has_dna())
		to_chat(usr, "<span class='danger'>The drip beeps: Warning, incompatible creature!</span>")
		return

	if(Adjacent(target) && usr.Adjacent(target))
		usr.visible_message("<span class='warning'>[usr] attaches [src] to [target].</span>", "<span class='notice'>You attach [src] to [target].</span>")
		add_fingerprint(usr)
		attached = target
		START_PROCESSING(SSprocessing, src)

/obj/item/slime_iv/process()
	if(!attached)
		return PROCESS_KILL

	if(!(get_dist(src, attached) <= 1 && isturf(attached.loc)))
		to_chat(attached, "<span class='userdanger'>The IV drip needle is ripped out of you!</span>")
		attached.apply_damage(3, BRUTE, pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
		attached = null
		return PROCESS_KILL

	if(reagents.total_volume)
		reagents.trans_to(attached, 5, method = INJECT, show_message = FALSE) //make reagents reacts, but don't spam messages
		return

/obj/item/slime_letter
	name = "Slime letter"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slime_letter"

/obj/item/slime_letter/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing,src)

/obj/item/slime_letter/process()
	var/humanfound = null
	if(ishuman(loc))
		humanfound = loc
	if(!humanfound)
		return
	var/mob/living/carbon/human/human = humanfound
	human.apply_status_effect(/datum/status_effect/lovers_hug)

/obj/item/slime_veil
	name = "Slime veil"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slime_veil"
	///who holds us
	var/mob/wielder

/obj/item/slime_veil/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/slime_veil/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=8, force_wielded=12)

/obj/item/slime_veil/process()
	if(!wielder)
		return PROCESS_KILL
	///you will always be barely visible
	wielder.alpha = max(10, wielder.alpha - 25)


/obj/item/slime_veil/proc/on_wield(datum/source,mob/user)
	START_PROCESSING(SSprocessing,src)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED ,.proc/moved)
	wielder = user

/obj/item/slime_veil/proc/moved(datum/source)
	var/atom/movable/moved = source
	moved.alpha = 255

/obj/item/slime_veil/proc/on_unwield(datum/source,mob/user)
	STOP_PROCESSING(SSprocessing,src)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	wielder = null

/obj/item/kitchen/knife/slime
	name = "slime knife"
	color = "#00ff15"
	force = 0

/obj/item/claymore/slime
	name = "slime claymore"
	force = 18
	color = "#00ff15"
	block_chance = 10

obj/item/tank/internals/emergency_oxygen/slime
	name = "slime oxygen tank"
	volume = 6
	color = "#00ff15"

/obj/item/stack/cable_coil/slime
	name = "slime compressed cable"
	desc = "A flexible, super-compressible, superconducting insulated cable for heavy-duty power transfer. Slime goo compresses the wire inside of it maximizing it's volume."
	max_amount = 300
	amount = 300
	color = "#00ff15"

/obj/item/wormhole_jaunter/slime
	name = "slime jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to bluespace for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter can be worn on the belt to provide protection from chasms. This one is made out of glossy green slime, with a small note saying that it no longer causes vomiting."
	unpleasant = FALSE
	color = "#00ff15"

/obj/item/clothing/under/suit/blacktwopiece/slime
	name = "slime suit"
	color = "#00ff15"
