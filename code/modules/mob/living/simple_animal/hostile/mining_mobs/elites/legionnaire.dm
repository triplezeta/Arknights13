/**
  * # Legionnaire
  *
  * A towering skeleton, embodying the power of Legion.
  * As it's health gets lower, the head does more damage.
  * It's attacks are as follows:
  * - Charges at the target after a telegraph, throwing them across the arena should it connect.
  * - Legionnaire's head detaches, attacking as it's own entity.  Has abilities of it's own later into the fight.  Once dead, regenerates after a brief period.  If the skill is used while the head is off, it will be killed.
  * - Leaves a pile of bones at your location.  Upon using this skill again, you'll swap locations with the bone pile.
  * - Spews a cloud of smoke from it's maw, wherever said maw is.  
  * A unique fight incorporating the head mechanic of legion into a whole new beast.  Combatants will need to make sure the tag-team of head and body don't lure them into a deadly trap.
  */

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire
	name = "legionnaire"
	desc = "A towering skeleton, embodying the terrifying power of Legion."
	icon = 'icons/mob/lavaland/legionnaire.dmi'
	icon_state = "legionnaire"
	icon_living = "legionnaire"
	icon_aggro = "legionnaire"
	icon_dead = "legionnaire_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 800
	health = 800
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes its arms at"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	throw_message = "doesn't affect the sturdiness of"
	speed = 1
	move_to_delay = 3
	mouse_opacity = MOUSE_OPACITY_ICON
	deathsound = 'sound/magic/curse.ogg'
	deathmessage = "'s arms reach out before it falls apart onto the floor, lifeless."

	attack_action_types = list(/datum/action/innate/elite_attack/legionnaire_charge,
								/datum/action/innate/elite_attack/head_detach,
								/datum/action/innate/elite_attack/bonfire_teleport,
								/datum/action/innate/elite_attack/spew_smoke)
								
	var/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/myhead = null
	var/obj/structure/legionnaire_bonfire/mypile = null
	var/has_head = TRUE
	
/datum/action/innate/elite_attack/legionnaire_charge
	name = "Legionnaire Charge"
	button_icon_state = "legionnaire_charge"
	chosen_message = "<span class='boldwarning'>You will attempt to grab your opponent and throw them.</span>"
	chosen_attack_num = 1
	
/datum/action/innate/elite_attack/head_detach
	name = "Release Head"
	button_icon_state = "head_detach"
	chosen_message = "<span class='boldwarning'>You will now detach your head or kill it if it is already released.</span>"
	chosen_attack_num = 2
	
/datum/action/innate/elite_attack/bonfire_teleport
	name = "Bonfire Teleport"
	button_icon_state = "bonfire_teleport"
	chosen_message = "<span class='boldwarning'>You will leave a bonfire.  Second use will let you swap positions with it indefintiely.  Using it on the same tile as an active bonfire removes it.</span>"
	chosen_attack_num = 3
	
/datum/action/innate/elite_attack/spew_smoke
	name = "Spew Smoke"
	button_icon_state = "spew_smoke"
	chosen_message = "<span class='boldwarning'>Your head will spew smoke in an area, wherever it may be.</span>"
	chosen_attack_num = 4
	
/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				legionnaire_charge(target)
			if(2)
				head_detach(target)
			if(3)
				bonfire_teleport()
			if(4)
				spew_smoke()
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(1)
			legionnaire_charge(target)
		if(2)
			head_detach(target)
		if(3)
			bonfire_teleport()
		if(4)
			spew_smoke()
		
/obj/effect/temp_visual/dragon_swoop/legionnaire
	duration = 10
	color = rgb(0,0,0)

/obj/effect/temp_visual/dragon_swoop/legionnaire/Initialize()
	. = ..()
	src.transform *= 0.33
	
/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/legionnaire_charge(target)
	ranged_cooldown = world.time + 50
	var/dir_to_target = get_dir(get_turf(src), get_turf(target))
	var/turf/T = get_step(get_turf(src), dir_to_target)
	for(var/i in 1 to 4)
		new /obj/effect/temp_visual/dragon_swoop/legionnaire(T)
		T = get_step(T, dir_to_target)
	playsound(src,'sound/magic/demon_attack1.ogg', 200, 1)
	visible_message("<span class='boldwarning'>[src] prepares to charge!</span>")
	addtimer(CALLBACK(src, .proc/legionnaire_charge_2, dir_to_target, 0), 5)
	return
	
/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/legionnaire_charge_2(var/move_dir, var/times_ran)
	if(times_ran < 4)
		var/turf/T = get_step(get_turf(src), move_dir)
		if(ismineralturf(T))
			var/turf/closed/mineral/M = T
			M.gets_drilled()
		if(!T.density)
			for(var/obj/structure/window/W in T.contents)
				return
			for(var/obj/machinery/door/D in T.contents)
				return
			forceMove(T)
			playsound(src,'sound/effects/bang.ogg', 200, 1)
			var/list/hit_things
			var/throwtarget = get_edge_target_turf(src, move_dir)
			for(var/mob/living/L in T.contents - hit_things - src)
				if(!faction_check_mob(L))
					hit_things += L
					visible_message("<span class='boldwarning'>[src] grasps [L] and throws them with much force!</span>")
					to_chat(L, "<span class='userdanger'>[src] grabs you and throws you with much force!</span>")
					L.safe_throw_at(throwtarget, 10, 1, src)
					L.Paralyze(20)
					L.adjustBruteLoss(50)
			addtimer(CALLBACK(src, .proc/legionnaire_charge_2, move_dir, (times_ran + 1)), 2)
	else
		return
		
/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead
	name = "legionnaire head"
	desc = "The legionnaire's head floating by itself.  One shouldn't get too close, though once it sees you, you really don't have a choice."
	icon = 'icons/mob/lavaland/legionnaire.dmi'
	icon_state = "legionnaire_head"
	icon_living = "legionnaire_head"
	icon_aggro = "legionnaire_head"
	icon_dead = "legionnaire_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 60
	health = 60
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "bites at"
	attack_sound = 'sound/effects/curse1.ogg'
	throw_message = "simply misses"
	speed = 0
	move_to_delay = 2
	del_on_death = 1
	deathmessage = "crumbles away!"
	faction = list()
	ranged = 0
	var/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/body = null
	
/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/death()
	. = ..()
	if(body)
		body.onHeadDeath()
	return
		
/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/head_detach(target)
	ranged_cooldown = world.time + 5
	if(has_head)
		has_head = FALSE
		icon_state = "legionnaire_headless"
		icon_living = "legionnaire_headless"
		icon_aggro = "legionnaire_headless"
		visible_message("<span class='boldwarning'>[src]'s head flies off!</span>")
		var/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/newhead = new /mob/living/simple_animal/hostile/asteroid/elite/legionnairehead(loc)
		newhead.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
		newhead.GiveTarget(target)
		newhead.faction = faction.Copy()
		myhead = newhead
		myhead.body = src
		if(health < maxHealth * 0.25)
			myhead.melee_damage_lower = 30
			myhead.melee_damage_upper = 30
		else if(health < maxHealth * 0.5)
			myhead.melee_damage_lower = 20
			myhead.melee_damage_upper = 20
		return
	else if(!has_head && myhead != null)
		myhead.adjustBruteLoss(600)
		return
		
/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/onHeadDeath()
	myhead = null
	addtimer(CALLBACK(src, .proc/regain_head), 50)
	return
	
/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/regain_head()
	has_head = TRUE
	if(stat == DEAD)
		return
	icon_state = "legionnaire"
	icon_living = "legionnaire"
	icon_aggro = "legionnaire"
	visible_message("<span class='boldwarning'>The top of [src]'s spine leaks a black liquid, forming into a skull!</span>")
	return
	
/obj/structure/legionnaire_bonfire
	name = "bone pile"
	desc = "A pile of bones which seems to occasionally move a little.  It's probably a good idea to smash them."
	icon = 'icons/mob/lavaland/legionnaire_bonfire.dmi'
	icon_state = "bonfire"
	max_integrity = 100
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = FALSE
	light_range = 4
	light_color = LIGHT_COLOR_RED
	var/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/myowner = null
	
	
/obj/structure/legionnaire_bonfire/CanPass(atom/movable/mover, turf/target)
	if(isliving(mover))
		var/mob/living/L = mover
		L.adjust_fire_stacks(3)
		L.IgniteMob()
	. = ..()
	
/obj/structure/legionnaire_bonfire/deconstruct(disassembled)
	if(myowner != null)
		myowner.mypile = null
	. = ..()

/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/bonfire_teleport()
	ranged_cooldown = world.time + 5
	if(mypile == null)
		var/obj/structure/legionnaire_bonfire/newpile = new /obj/structure/legionnaire_bonfire(loc)
		mypile = newpile
		mypile.myowner = src
		playsound(get_turf(src),'sound/items/fultext_deploy.ogg', 200, 1)
		visible_message("<span class='boldwarning'>[src] summons a bonfire on [get_turf(src)]!</span>")
		return
	else
		var/turf/legionturf = get_turf(src)
		var/turf/pileturf = get_turf(mypile)
		if(legionturf == pileturf)
			mypile.take_damage(100)
			mypile = null
			return
		playsound(pileturf,'sound/items/fultext_deploy.ogg', 200, 1)
		playsound(legionturf,'sound/items/fultext_deploy.ogg', 200, 1)
		visible_message("<span class='boldwarning'>[src] melts down into a burning pile of bones!</span>")
		forceMove(pileturf)
		visible_message("<span class='boldwarning'>[src] forms from the bonfire!</span>")
		mypile.forceMove(legionturf)
		return
		
/mob/living/simple_animal/hostile/asteroid/elite/legionnaire/proc/spew_smoke()
	ranged_cooldown = world.time + 60
	var/turf/T = null
	if(myhead != null)
		T = get_turf(myhead)
	else
		T = get_turf(src)
	if(myhead != null)
		myhead.visible_message("<span class='boldwarning'>[myhead] spews smoke from its maw!</span>")
	else if(!has_head)
		visible_message("<span class='boldwarning'>[src] spews smoke from the tip of their spine!</span>")
	else
		visible_message("<span class='boldwarning'>[src] spews smoke from its maw!</span>")
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(2, T)
	smoke.start()