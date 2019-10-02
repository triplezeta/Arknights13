/**
  * # Goliath Broodmother
  *
  * A stronger, faster variation of the goliath.  Has the ability to spawn baby goliaths, which it can later detonate at will.
  * When it's health is below half, tendrils will spawn randomly around it.  When it is below a quarter of health, this effect is doubled.
  * It's attacks are as follows:
  * - Spawns a 3x3/plus shape of tentacles on the target location
  * - Spawns 2 baby goliaths on its tile, up to a max of 8.  Children blow up when they die.
  * - The broodmother lets out a noise, and is able to move faster for 6.5 seconds.
  * - Summons your children around you.
  * The broodmother is a fight revolving around stage control, as the activator has to manage the baby goliaths, both dead and alive, and the broodmother herself, along with all the tendrils.
  */

/mob/living/simple_animal/hostile/asteroid/elite/broodmother
	name = "goliath broodmother"
	desc = "An example of sexual dimorphism, this female goliath looks much different than the males of her species.  She is, however, just as dangerous, if not more."
	icon_state = "broodmother"
	icon_living = "broodmother"
	icon_aggro = "broodmother"
	icon_dead = "egg_sac"
	icon_gib = "syndicate_gib"
	maxHealth = 800
	health = 800
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration = 30
	attacktext = "beats down on"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	speed = 2
	move_to_delay = 5
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	deathmessage = "explodes into gore!"

	attack_action_types = list(/datum/action/innate/elite_attack/tentacle_patch,
								/datum/action/innate/elite_attack/spawn_children,
								/datum/action/innate/elite_attack/rage,
								/datum/action/innate/elite_attack/call_children)
	
	var/rand_tent = 0
	var/list/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/children_list = list()
	
/datum/action/innate/elite_attack/tentacle_patch
	name = "Tentacle Patch"
	button_icon_state = "tentacle_patch"
	chosen_message = "<span class='boldwarning'>You are now attacking with a patch of tentacles.</span>"
	chosen_attack_num = 1
	
/datum/action/innate/elite_attack/spawn_children
	name = "Spawn Children"
	button_icon_state = "spawn_children"
	chosen_message = "<span class='boldwarning'>You will spawn two children at your location to assist you in combat temporarily.  You can have up to 8.</span>"
	chosen_attack_num = 2
	
/datum/action/innate/elite_attack/rage
	name = "Rage"
	button_icon_state = "rage"
	chosen_message = "<span class='boldwarning'>You will temporarily increase your movement speed.</span>"
	chosen_attack_num = 3
	
/datum/action/innate/elite_attack/call_children
	name = "Call Children"
	button_icon_state = "call_children"
	chosen_message = "<span class='boldwarning'>You will summon your children to your location.</span>"
	chosen_attack_num = 4
	
/mob/living/simple_animal/hostile/asteroid/elite/broodmother/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				tentacle_patch(target)
			if(2)
				spawn_children()
			if(3)
				rage()
			if(4)
				call_children()
		return
	
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(1)
			tentacle_patch(target)
		if(2)
			spawn_children()
		if(3)
			rage()
		if(4)
			call_children()
		
/mob/living/simple_animal/hostile/asteroid/elite/broodmother/Life()
	. = ..()	
	if(health < maxHealth * 0.5 && rand_tent < world.time && stat != DEAD)
		rand_tent = world.time + 30
		var/tentacle_amount = 5
		if(health < maxHealth * 0.25)
			tentacle_amount = 10
		var/tentacle_loc = spiral_range_turfs(5, get_turf(src))
		for(var/i in 1 to tentacle_amount)
			var/turf/t = pick_n_take(tentacle_loc)
			new /obj/effect/temp_visual/goliath_tentacle/broodmother(t, src)
	
//Tentacles have less stun time compared to regular variant, to balance being able to use them much more often.  Also, 10 more damage.
/obj/effect/temp_visual/goliath_tentacle/broodmother/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message("<span class='danger'>[src] grabs hold of [L]!</span>")
		L.Stun(10)
		L.adjustBruteLoss(rand(20,25))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, .proc/retract), 10, TIMER_STOPPABLE)
		
/obj/effect/temp_visual/goliath_tentacle/broodmother/patch/Initialize(mapload, new_spawner)
	. = ..()
	var/tentacle_locs = spiral_range_turfs(1, get_turf(src))
	for(var/T in tentacle_locs)
		if(T)
			new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)
	var/list/directions = GLOB.cardinals.Copy()
	for(var/i in directions)
		var/turf/T = get_step(get_turf(src), i)
		T = get_step(T, i)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)
	
/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/tentacle_patch(var/target)	
	ranged_cooldown = world.time + 15
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so it can't attack people off-screen
		visible_message("<span class='warning'>[src] digs its tentacles under [target]!</span>")
		new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(tturf, src)
		
/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child
	name = "baby goliath"
	desc = "A young goliath recently born from it's mother.  While they hatch from eggs, said eggs are incubated in the mother until they are ready to be born."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_baby"
	icon_living = "goliath_baby"
	icon_aggro = "goliath_baby"
	icon_dead = "goliath_baby_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 30
	health = 30
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "bashes against"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	speed = 2
	move_to_delay = 5
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list()
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	deathmessage = "falls to the ground."
	status_flags = CANPUSH
	var/mob/living/simple_animal/hostile/asteroid/elite/broodmother/mother = null
	
/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/OpenFire(target)
	ranged_cooldown = world.time + 40
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so it can't attack people off-screen
		visible_message("<span class='warning'>[src] digs one of its tentacles under [target]!</span>")
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(tturf, src)
	
/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/death()
	. = ..()
	if(mother != null)
		mother.children_list -= src
	visible_message("<span class='warning'>[src] explodes!</span>")
	explosion(get_turf(loc),0,0,0,flame_range = 3, adminlog = FALSE)
	gib()
		
/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/spawn_children(var/target)	
	ranged_cooldown = world.time + 40
	visible_message("<span class='boldwarning'>The ground churns behind [src]!</span>")
	for(var/i in 1 to 2)
		if(children_list.len < 8)
			var/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/newchild = new /mob/living/simple_animal/hostile/asteroid/elite/broodmother_child(loc)
			newchild.GiveTarget(target)
			newchild.faction = faction.Copy()
			visible_message("<span class='boldwarning'>[newchild] appears below [src]!</span>")
			newchild.mother = src
			children_list += newchild
	return

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/rage()
	ranged_cooldown = world.time + 70
	playsound(src,'sound/spookoween/insane_low_laugh.ogg', 200, 1)
	visible_message("<span class='warning'>[src] starts picking up speed!</span>")
	color = rgb(150,0,0)
	src.set_varspeed(0)
	src.move_to_delay = 3
	addtimer(CALLBACK(src, .proc/reset_rage), 65)
	
/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/reset_rage()
	color = rgb(255, 255, 255)
	src.set_varspeed(2)
	src.move_to_delay = 5
	
/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/call_children()
	ranged_cooldown = world.time + 60
	visible_message("<span class='warning'>The ground shakes near [src]!</span>")
	var/list/directions = GLOB.cardinals.Copy() + GLOB.diagonals.Copy()
	for(var/mob/child in children_list)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			child.forceMove(T)
			playsound(src, 'sound/effects/bamf.ogg', 100, 1)