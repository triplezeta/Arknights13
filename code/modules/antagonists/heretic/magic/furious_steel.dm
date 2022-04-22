/datum/action/cooldown/spell/pointed/projectile/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "furious_steel0"
	sound = 'sound/weapons/guillotine.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS
	invocation = "F'LSH'NG S'LV'R!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	base_icon_state = "furious_steel"
	active_msg = "You summon forth three blades of furious silver."
	deactive_msg = "You conceal the blades of furious silver."
	cast_range = 20
	projectile_type = /obj/projectile/floating_blade
	projectile_amount = 3

	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return

	if(!isliving(on_who))
		return

	var/mob/living/living_user = on_who
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, null, 3, 25, 0.66 SECONDS)
	RegisterSignal(blade_effect, COMSIG_PARENT_QDELETING, .proc/on_status_effect_deleted)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	QDEL_NULL(blade_effect)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/before_cast(atom/cast_on)
	if(isnull(blade_effect) || !length(blade_effect.blades))
		return FALSE
	if(get_dist(owner, cast_on) <= 1) // Let the caster prioritize melee attacks over blade casts
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/projectile/furious_steel/fire_projectile(mob/living/user, atom/target)
	. = ..()
	qdel(blade_effect.blades[1])

/datum/action/cooldown/spell/pointed/projectile/furious_steel/ready_projectile(obj/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	to_launch.def_zone = check_zone(user.zone_selected)

/// If our blade status effect is deleted, clear our refs and deactivate
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_deleted(datum/source)
	SIGNAL_HANDLER

	blade_effect = null
	on_deactivation()

/obj/projectile/floating_blade
	name = "blade"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	speed = 2
	damage = 25
	armour_penetration = 100
	sharpness = SHARP_EDGED
	wound_bonus = 15
	pass_flags = PASSTABLE | PASSFLAPS

/obj/projectile/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("knife", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))

/obj/projectile/floating_blade/prehit_pierce(atom/hit)
	if(isliving(hit) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/victim = hit
		if(caster == victim)
			return PROJECTILE_PIERCE_PHASE

		if(caster.mind)
			var/datum/antagonist/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
			if(monster?.master == caster.mind)
				return PROJECTILE_PIERCE_PHASE

	return ..()
