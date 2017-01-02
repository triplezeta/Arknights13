/obj/item/weapon/gun/medbeam
	name = "Medical Beamgun"
	desc = "Don't cross the streams!"
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = WEIGHT_CLASS_NORMAL

	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = 0
	var/datum/beam/current_beam = null
	var/mounted = 0 //Denotes if this is a handheld or mounted version

	weapon_weight = WEAPON_MEDIUM

/obj/item/weapon/gun/medbeam/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/equipped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/proc/LoseTarget()
	if(active)
		qdel(current_beam)
		active = 0
		on_beam_release(current_target)
	current_target = null

/obj/item/weapon/gun/medbeam/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	if(isliving(user))
		add_fingerprint(user)

	if(current_target)
		LoseTarget()
	if(!isliving(target))
		return

	current_target = target
	active = 1
	current_beam = new(user,current_target,time=6000,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)
	addtimer(CALLBACK(current_beam,  /datum/beam.proc/Start), 0)

	feedback_add_details("gun_fired","[src.type]")

/obj/item/weapon/gun/medbeam/process()

	var/source = loc
	if(!mounted && !isliving(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(get_dist(source, current_target)>max_range || !los_check(source, current_target))
		LoseTarget()
		if(isliving(source))
			source << "<span class='warning'>You lose control of the beam!</span>"
		return

	if(current_target)
		on_beam_tick(current_target)

/obj/item/weapon/gun/medbeam/proc/los_check(atom/movable/user, mob/target)
	var/turf/user_turf = user.loc
	if(mounted)
		user_turf = get_turf(user)
	else if(!istype(user_turf))
		return 0
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in getline(user_turf,target))
		if(mounted && turf == user_turf)
			continue //Mechs are dense and thus fail the check
		if(turf.density)
			qdel(dummy)
			return 0
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
		for(var/obj/effect/ebeam/medical/B in turf)// Don't cross the str-beams!
			if(B.owner != current_beam)
				explosion(B.loc,0,3,5,8)
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1

/obj/item/weapon/gun/medbeam/proc/on_beam_hit(var/mob/living/target)
	return

/obj/item/weapon/gun/medbeam/proc/on_beam_tick(var/mob/living/target)
	if(target.health != target.maxHealth)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(get_turf(target), "#80F5FF"))
	target.adjustBruteLoss(-4)
	target.adjustFireLoss(-4)
	return

/obj/item/weapon/gun/medbeam/proc/on_beam_release(var/mob/living/target)
	return

/obj/effect/ebeam/medical
	name = "medical beam"

//////////////////////////////Mech Version///////////////////////////////
/obj/item/weapon/gun/medbeam/mech
	mounted = 1

/obj/item/weapon/gun/medbeam/mech/New()
	..()
	STOP_PROCESSING(SSobj, src) //Mech mediguns do not process until installed, and are controlled by the holder obj
