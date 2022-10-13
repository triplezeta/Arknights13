/**
 * Gives you three stacks of Brimdust Coating, when you get hit by anything it will make a short ranged explosion.
 * If this happens on the station it also sets you on fire.
 * If implanted, you can shake off a cloud of brimdust to give this buff to people around you.area
 * I you have this inside you on the station and you catch fire it explodes.
 */
/obj/item/organ/internal/monster_core/reusable/brimdust_sac
	name = "brimdust sac"
	desc = "A strange organ from a brimdemon. You can shake it out to coat yourself in explosive powder."
	desc_preserved = "A strange organ from a brimdemon. It is preserved, allowing you to coat yourself in its explosive contents at your leisure."
	desc_inert = "A decayed brimdemon organ. There's nothing usable left inside it."
	user_status = /datum/status_effect/stacking/brimdust_coating

/obj/item/organ/internal/monster_core/reusable/brimdust_sac/on_life(delta_time, times_fired)
	. = ..()
	if(!owner.on_fire)
		return
	if(lavaland_equipment_pressure_check(get_turf(owner)))
		return
	explode_organ()

/// Your gunpowder organ blows up, uh oh
/obj/item/organ/internal/monster_core/reusable/brimdust_sac/proc/explode_organ()
	owner.visible_message(span_boldwarning("[owner]'s chest bursts open as something inside ignites!"))
	var/turf/origin_turf = get_turf(owner)
	new /obj/effect/temp_visual/explosion/fast(origin_turf)
	owner.Paralyze(5 SECONDS)

	for(var/mob/living/target in range(1, origin_turf))
		var/armor = target.run_armor_check(attack_flag = BOMB)
		target.apply_damage(15, damagetype = BURN, blocked = armor)

	owner.apply_damage(15, damagetype = BRUTE, def_zone = BODY_ZONE_CHEST)
	var/obj/item/bodypart/chest/torso = owner.get_bodypart(BODY_ZONE_CHEST)
	torso.force_wound_upwards(/datum/wound/burn/severe)
	owner.emote("scream")
	qdel(src)

/// Make a cloud which applies brimdust to everyone nearby
/obj/item/organ/internal/monster_core/reusable/brimdust_sac/activate_implanted()
	var/turf/origin_turf = get_turf(owner)
	do_smoke(range = 2, holder = owner, location = origin_turf, smoke_type = /obj/effect/particle_effect/fluid/smoke/bad/brimdust)

/// Smoke which applies brimdust to you, and is also bad for your lungs
/obj/effect/particle_effect/fluid/smoke/bad/brimdust
	lifetime = 5 SECONDS
	color = "#383838"

/obj/effect/particle_effect/fluid/smoke/bad/brimdust/smoke_mob(mob/living/carbon/smoker)
	if(!istype(smoker))
		return FALSE
	if(lifetime < 1)
		return FALSE
	if(smoker.smoke_delay)
		return FALSE
	smoker.apply_status_effect(/datum/status_effect/stacking/brimdust_coating)
	return ..()

/**
 * If you take brute damage with this buff, hurt and push everyone next to you.
 * If you catch fire and or on the space station, detonate all remaining stacks in a way which hurts you.
 * Washes off if you get wet.
 */
/datum/status_effect/stacking/brimdust_coating
	id = "brimdust_coating"
	stacks = 3
	max_stacks = 3
	tick_interval = -1
	consumed_on_threshold = FALSE
	alert_type = /atom/movable/screen/alert/status_effect/brimdust_coating
	/// Damage to deal on explosion
	var/static/blast_damage = 40
	/// Damage reduction when not in a mining pressure area
	var/static/pressure_modifier = 0.25
	/// Time to wait between consuming stacks
	var/delay_between_explosions = 5 SECONDS
	/// Cooldown between explosions
	COOLDOWN_DECLARE(explosion_cooldown)

/atom/movable/screen/alert/status_effect/brimdust_coating
	name = "Brimdust Coating"
	desc = "You are coated with explosive dust, kinetic impacts will cause it to detonate! \
		The explosion will not harm you, as long as you're not under atmospheric pressure."
	icon_state = "highbloodpressure"

/datum/status_effect/stacking/brimdust_coating/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, .proc/on_cleaned)
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, .proc/on_take_damage)

/datum/status_effect/stacking/brimdust_coating/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_COMPONENT_CLEAN_ACT))

/// When you are cleaned, wash off the buff
/datum/status_effect/stacking/brimdust_coating/proc/on_cleaned()
	SIGNAL_HANDLER
	owner.remove_status_effect(/datum/status_effect/stacking/brimdust_coating)
	return COMPONENT_CLEANED

/// When you take brute damage, schedule an explosion
/datum/status_effect/stacking/brimdust_coating/proc/on_take_damage(datum/source, damage, damagetype)
	SIGNAL_HANDLER
	if(damagetype != BRUTE)
		return
	if(!COOLDOWN_FINISHED(src, explosion_cooldown))
		return
	owner.visible_message(span_boldwarning("The brimstone dust surrounding [owner] ignites!"))
	// Ugly method to bypass creating bugs by killing something in the middle of its attack chain
	// Let's pass it off as 'giving skilled player attackers time to dodge the retaliation'
	addtimer(CALLBACK(src, .proc/explode), 0.25 SECONDS)
	COOLDOWN_START(src, explosion_cooldown, delay_between_explosions)

/**
 * Hurts everything in a circle around you. Hurts less if in a pressurised environment.
 */
/datum/status_effect/stacking/brimdust_coating/proc/explode()
	var/turf/origin_turf = get_turf(owner)
	new /obj/effect/temp_visual/explosion/fast(origin_turf)

	var/under_pressure = !lavaland_equipment_pressure_check(origin_turf)
	var/damage_dealt = blast_damage
	if(under_pressure)
		damage_dealt *= pressure_modifier

	var/list/possible_targets = range(1, origin_turf)
	if(!under_pressure)
		possible_targets -= owner
	for(var/mob/living/target in possible_targets)
		var/armor = target.run_armor_check(attack_flag = BOMB)
		target.apply_damage(damage_dealt, damagetype = BURN, blocked = armor)

	if(under_pressure)
		owner.adjust_fire_stacks(5)
		owner.ignite_mob()
	add_stacks(-1)
