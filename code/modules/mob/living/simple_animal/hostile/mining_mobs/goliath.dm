//A slow but strong beast that tries to stun using its tentacles
/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensnare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 40
	ranged = 1
	ranged_cooldown_time = 120
	friendly_verb_continuous = "wails at"
	friendly_verb_simple = "wail at"
	speak_emote = list("bellows")
	speed = 3
	maxHealth = 300
	health = 300
	harm_intent_damage = 0
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "pulverizes"
	attack_verb_simple = "pulverize"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	vision_range = 5
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	gender = MALE//lavaland elite goliath says that it s female and i s stronger because of sexual dimorphism, so normal goliaths should be male
	var/pre_attack = 0
	var/pre_attack_icon = "Goliath_preattack"
	var/tentacle_type = /obj/effect/temp_visual/goliath_tentacle
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide)

	footstep_type = FOOTSTEP_MOB_HEAVY

/mob/living/simple_animal/hostile/asteroid/goliath/Life()
	. = ..()
	handle_preattack()

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time*0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return
	icon_state = pre_attack_icon

/mob/living/simple_animal/hostile/asteroid/goliath/revive(full_heal = FALSE, admin_revive = FALSE)//who the fuck anchors mobs
	if(..())
		move_force = MOVE_FORCE_VERY_STRONG
		move_resist = MOVE_FORCE_VERY_STRONG
		pull_force = MOVE_FORCE_VERY_STRONG
		. = 1

/mob/living/simple_animal/hostile/asteroid/goliath/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>[src] digs its tentacles under [target]!</span>")
		new tentacle_type(tturf, src ,TRUE)
		ranged_cooldown = world.time + ranged_cooldown_time
		icon_state = icon_aggro
		pre_attack = 0

/mob/living/simple_animal/hostile/asteroid/goliath/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	ranged_cooldown -= 10
	handle_preattack()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(icon_state != icon_aggro)
		icon_state = icon_aggro

//Lavaland Goliath
/mob/living/simple_animal/hostile/asteroid/goliath/beast
	name = "goliath"
	desc = "A hulking, armor-plated beast with long tendrils arching from its back."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_aggro = "goliath"
	icon_dead = "goliath_dead"
	throw_message = "does nothing to the tough hide of the"
	pre_attack_icon = "goliath2"
	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	loot = list()
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	food_type = list(/obj/item/reagent_containers/food/snacks/customizable/salad/ashsalad, /obj/item/reagent_containers/food/snacks/customizable/soup/ashsoup, /obj/item/reagent_containers/food/snacks/grown/ash_flora)//use lavaland plants to feed the lavaland monster
	tame_chance = 10
	bonus_tame_chance = 5
	var/saddled = FALSE

/mob/living/simple_animal/hostile/asteroid/goliath/beast/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/saddle) && !saddled)
		if(tame && do_after(user,55,target=src))
			user.visible_message("<span class='notice'>You manage to put [O] on [src], you can now ride [p_them()].</span>")
			qdel(O)
			saddled = TRUE
			can_buckle = TRUE
			buckle_lying = FALSE
			add_overlay("goliath_saddled")
			var/datum/component/riding/D = LoadComponent(/datum/component/riding)
			D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(-2, 8), TEXT_WEST = list(2, 8)))
			D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
			D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
			D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
			D.set_vehicle_dir_layer(WEST, OBJ_LAYER)
			D.keytype = /obj/item/key/lasso
			D.drive_verb = "ride"
		else
			user.visible_message("<span class='warning'>[src] is rocking around! You can't put the saddle on!</span>")
		return
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/beast/random/Initialize()
	. = ..()
	if(prob(1))
		new /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient
	name = "ancient goliath"
	desc = "Goliaths are biologically immortal, and rare specimens have survived for centuries. This one is clearly ancient, and its tentacles constantly churn the earth around it."
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	maxHealth = 400
	health = 400
	speed = 4
	pre_attack_icon = "Goliath_preattack"
	throw_message = "does nothing to the rocky hide of the"
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide) //A throwback to the asteroid days
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list()
	crusher_drop_mod = 30
	wander = FALSE
	var/list/cached_tentacle_turfs
	var/turf/last_location
	var/tentacle_recheck_cooldown = 100

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/Life()
	. = ..()
	if(!.) // dead
		return
	if(AIStatus != AI_ON)
		return
	if(isturf(loc))
		if(!LAZYLEN(cached_tentacle_turfs) || loc != last_location || tentacle_recheck_cooldown <= world.time)
			LAZYCLEARLIST(cached_tentacle_turfs)
			last_location = loc
			tentacle_recheck_cooldown = world.time + initial(tentacle_recheck_cooldown)
			for(var/turf/open/T in orange(4, loc))
				LAZYADD(cached_tentacle_turfs, T)
		for(var/t in cached_tentacle_turfs)
			if(isopenturf(t))
				if(prob(10))
					new tentacle_type(t, src)
			else
				cached_tentacle_turfs -= t

/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril
	fromtendril = TRUE

//tentacles
/obj/effect/temp_visual/goliath_tentacle
	name = "goliath tentacle"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle_wiggle"
	layer = BELOW_MOB_LAYER
	var/mob/living/spawner
	var/wiggle = "Goliath_tentacle_spawn"
	var/retract = "Goliath_tentacle_retract"
	var/difficulty = 3

/obj/effect/temp_visual/goliath_tentacle/Initialize(mapload, mob/living/new_spawner,recursive = FALSE)
	. = ..()
	flick(wiggle,src)
	for(var/obj/effect/temp_visual/goliath_tentacle/T in loc)
		if(T != src)
			return INITIALIZE_HINT_QDEL
	if(!QDELETED(new_spawner))
		spawner = new_spawner
	if(ismineralturf(loc))
		var/turf/closed/mineral/M = loc
		M.gets_drilled()
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, .proc/tripanim), 7, TIMER_STOPPABLE)
	if(!recursive)
		return
	var/list/directions = get_directions()
	for(var/i in 1 to difficulty)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			new type(T, spawner)

/obj/effect/temp_visual/goliath_tentacle/proc/get_directions()
	return GLOB.cardinals.Copy()

/obj/effect/temp_visual/goliath_tentacle/proc/tripanim()
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, .proc/trip), 3, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message("<span class='danger'>[src] grabs hold of [L]!</span>")
		on_hit(L)
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, .proc/retract), 10, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/proc/on_hit(mob/living/L)
	L.Stun(100)
	L.adjustBruteLoss(rand(10,15))


/obj/effect/temp_visual/goliath_tentacle/proc/retract()
	icon_state = "marker"
	flick(retract,src)
	deltimer(timerid)
	timerid = QDEL_IN(src, 7)

/obj/item/saddle
	name = "saddle"
	desc = "This saddle will solve all your problems with being killed by lava beasts!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_saddle"

/obj/effect/temp_visual/goliath_tentacle/crystal
	name = "crystalline spire"
	icon = 'icons/effects/32x64.dmi'
	icon_state = "crystal"
	wiggle = "crystal_growth"
	retract = "crystal_reduction"
	difficulty = 5

/obj/effect/temp_visual/goliath_tentacle/crystal/get_directions()
	return GLOB.cardinals.Copy() + GLOB.diagonals.Copy()

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/crystal
	name = "crystal goliath"
	desc = "Deformed, twisted, misshaped. Once it was a goliath now it is an abomination composed of dead goliath flesh and crystals that sprouted throught it's decomposing body."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "crystal_goliath"
	icon_living = "crystal_goliath"
	icon_aggro = "crystal_goliath"
	icon_dead = "crystal_goliath_dead"
	throw_message = "does nothing to the tough hide of the"
	pre_attack_icon = "crystal_goliath2"
	tentacle_type = /obj/effect/temp_visual/goliath_tentacle/crystal
	tentacle_recheck_cooldown = 50
	speed = 2

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/crystal/OpenFire()
	. = ..()
	visible_message("<span class='warning'>[src] Expunges it's matter releasing a spray of crystalline shards!</span>")
	INVOKE_ASYNC(src,.proc/spray_of_crystals)
	shoot_projectile(Get_Angle(src,target) + 10)
	shoot_projectile(Get_Angle(src,target))
	shoot_projectile(Get_Angle(src,target) - 10)

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/crystal/proc/spray_of_crystals()
	for(var/i in 0 to 9)
		shoot_projectile(i*(180/NUM_E))
		sleep(3)

/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/crystal/proc/shoot_projectile(angle)
	var/obj/projectile/P = new /obj/projectile/goliath(get_turf(src))
	P.preparePixelProjectile(get_step(src, pick(GLOB.alldirs)), get_turf(src))
	P.firer = src
	P.fire(angle)

/obj/projectile/goliath
	name = "Crystalline Shard"
	icon_state = "crystal_shard"
	damage = 25
	damage_type = BRUTE
	speed = 3

/obj/projectile/goliath/on_hit(atom/target, blocked)
	. = ..()
	var/turf/turf_hit = get_turf(target)
	new /obj/effect/temp_visual/goliath_tentacle/crystal(turf_hit,firer)

/obj/projectile/goliath/can_hit_target(atom/target, list/passthrough, direct_target, ignore_loc)
	if(istype(target,/mob/living/simple_animal/hostile/asteroid))
		return FALSE
	return ..()
