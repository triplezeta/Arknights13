/obj/item/mecha_parts/mecha_equipment/hammer
	name = "exosuit hammer"
	desc = "Equipment for combat exosuits. This is the hammer that'll break the CRANIUM!"
	icon_state = "mecha_hammer"
	equip_cooldown = 15
	energy_drain = 0.02 * STANDARD_CELL_CHARGE
	force = 15
	harmful = TRUE
	range = MECHA_MELEE
	mech_flags = EXOSUIT_MODULE_WORKING | EXOSUIT_MODULE_COMBAT
	var/equipped_damage = 25

/obj/item/mecha_parts/mecha_equipment/hammer/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_MOVABLE_BUMP)
	return ..()

/obj/item/mecha_parts/mecha_equipment/hammer/Destroy()
	if(chassis)
		UnregisterSignal(chassis, COMSIG_MOVABLE_BUMP)
	return ..()

/obj/item/mecha_parts/mecha_equipment/hammer/action(mob/source, atom/target, list/modifiers, bumped)


	if(DOING_INTERACTION_WITH_TARGET(source, target) && do_after_cooldown(target, source, DOAFTER_SOURCE_MECHADRILL))
		return

	target.visible_message(span_warning("[chassis] smashes [target]."), \
				span_userdanger("[chassis] smashes [target]..."), \
				span_hear("You hear smashing."))

	log_message("Slashed [target]", LOG_MECHA)

	if(isliving(target))
		if(!action_checks(target))
			return
		hammer_mob(target, source)
		return ..()
	if(isobj(target))
		var/obj/O = target
		playsound(O, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		O.take_damage(15, BRUTE, 0, FALSE, get_dir(chassis, target))


/obj/item/mecha_parts/mecha_equipment/hammer/proc/hammer_mob(mob/living/target, mob/living/user)
	target.visible_message(span_danger("[chassis] smashes [target] with [src]!"), \
						span_userdanger("[chassis] smashes you with [src]!"))
	log_combat(user, target, "smashes", "[name]", "Combat mode: [user.combat_mode ? "On" : "Off"])(DAMTYPE: [uppertext(damtype)])")

	var/obj/item/bodypart/target_part = target.get_bodypart(target.get_random_valid_zone(user.zone_selected))
	target.apply_damage(25, BRUTE, target_part, target.run_armor_check(target_part, MELEE))
	playsound(src, SFX_SWING_HIT, 50, TRUE)
	do_attack_animation(target, ATTACK_EFFECT_SMASH)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(user, get_step_away(target, user)))
	target.throw_at(throw_target, 4, 4)

	var/splatter_dir = get_dir(chassis, target)
	if(isalien(target))
		new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target.drop_location(), splatter_dir)
	else
		new /obj/effect/temp_visual/dir_setting/bloodsplatter(target.drop_location(), splatter_dir)

	if(target_part && prob(10))
		target_part.dismember(BRUTE)

