/// Slow moving mob which attempts to immobilise its target
/mob/living/basic/mining/goliath
	name = "goliath"
	desc = "A hulking, armor-plated beast with long tendrils arching from its back."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_dead = "goliath_dead"
	pixel_x = -12
	base_pixel_x = -12
	gender = MALE // Female ones are the bipedal elites
	basic_mob_flags = IMMUNE_TO_FISTS
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speed = 3
	maxHealth = 300
	health = 300
	friendly_verb_continuous = "wails at"
	friendly_verb_simple = "wail at"
	speak_emote = list("bellows")
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_verb_continuous = "pulverizes"
	attack_verb_simple = "pulverize"
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	butcher_results = list(/obj/item/food/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	/// Icon state to use when tentacles are available
	var/tentacle_warning_state = "goliath_preattack"
	/// Slight cooldown to prevent double-dipping if we use both abilities at once
	COOLDOWN_DECLARE(ability_animation_cooldown)

/mob/living/basic/mining/goliath/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_TENTACLE_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)

	var/datum/action/cooldown/goliath_tentacles/tentacles = new (src)
	tentacles.Grant(src)
	var/datum/action/cooldown/tentacle_burst/melee_tentacles = new (src)
	melee_tentacles.Grant(src)
	var/datum/action/cooldown/tentacle_grasp/ranged_tentacles = new (src)
	ranged_tentacles.Grant(src)

	tentacles_ready()
	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(used_ability))

/// When we use an ability, activate some kind of visual tell
/mob/living/basic/mining/goliath/proc/used_ability(mob/living/source, datum/action/cooldown/ability)
	SIGNAL_HANDLER
	if (stat == DEAD || ability.IsAvailable())
		return // We died or the action failed for some reason like being out of range
	if (istype(ability, /datum/action/cooldown/goliath_tentacles))
		icon_state = icon_living
		addtimer(CALLBACK(src, PROC_REF(tentacles_ready)), ability.cooldown_time - 2 SECONDS, TIMER_DELETE_ME)
		return
	if (!COOLDOWN_FINISHED(src, ability_animation_cooldown))
		return
	COOLDOWN_START(src, ability_animation_cooldown, 2 SECONDS)
	playsound(src, 'sound/magic/demon_attack1.ogg', vol = 50, vary = TRUE)
	Shake(1, 0, 1.5 SECONDS)

/// Called slightly before tentacles ability comes off cooldown, as a warning
/mob/living/basic/mining/goliath/proc/tentacles_ready()
	if (stat == DEAD)
		return
	icon_state = tentacle_warning_state
