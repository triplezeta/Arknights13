/// Remain in someones view without moving yourself to stun and weaken them for a bit
/datum/action/cooldown/spell/pointed/unsettle
	name = "Unsettle"
	desc = "Stare directly into someone who doesn't see you. Remain in their view for a bit to stun them for 2 seconds and announce your presence to them. "
	button_icon_state = "terrify"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 8 SECONDS
	cast_range = 9
	active_msg = "You prepare to stare down a target..."
	deactive_msg = "You refocus your eyes..."
	/// how long we need to stare at someone to unsettle them (woooooh)
	var/stare_time = 8 SECONDS
	/// how long we stun someone on succesful cast
	var/stun_time = 2 SECONDS
	/// stamina damage we doooo
	var/stamina_damage = 80

/datum/action/cooldown/spell/pointed/unsettle/is_valid_target(atom/cast_on)
	. = ..()

	if(!ishuman(cast_on))
		cast_on.balloon_alert(owner, "cannot be targeted!")
		return FALSE

	if(!check_if_in_view(cast_on))
		owner.balloon_alert(owner, "cannot see you!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(do_after(owner, stare_time, cast_on, IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(check_if_in_view), cast_on), hidden = TRUE))
		spookify(cast_on)
		return
	owner.balloon_alert(owner, "line of sight broken!")
	return SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/unsettle/proc/check_if_in_view(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	if(target.is_blind() || !(owner in oview(9, target)))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/proc/spookify(mob/living/carbon/human/target)
	target.Stun(stun_time)
	target.adjustStaminaLoss(stamina_damage)
	target.apply_status_effect(/datum/status_effect/speech/slurring/generic)
	target.emote("scream")

	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(owner))

/obj/effect/temp_visual/circle_wave/unsettle
	color = COLOR_PURPLE

/datum/action/cooldown/spell/jaunt/space_crawl/voidwalker
	background_icon_state = "bg_spell"
	overlay_icon_state = "bg_spell_border"
	invisible = TRUE

/datum/component/space_kidnap
	/// How long does it take to kidnap them?
	var/kidnap_time = 6 SECONDS
	/// Are we kidnapping right now?
	var/kidnapping = FALSE

/datum/component/space_kidnap/Initialize(...)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_kidnap))

/datum/component/space_kidnap/proc/try_kidnap(mob/living/parent, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return

	var/mob/living/victim = target

	if(!victim.incapacitated() || !isspaceturf(get_turf(target)))
		return

	if(!kidnapping)
		INVOKE_ASYNC(src, PROC_REF(kidnap), parent, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/space_kidnap/proc/kidnap(mob/living/parent, mob/living/victim)
	victim.Stun(kidnap_time) //so they don't get up if we already got em
	var/obj/particles = new /obj/effect/abstract/particle_holder (victim, /particles/smoke)
	kidnapping = TRUE

	if(do_after(parent, kidnap_time, victim, extra_checks = CALLBACK(victim, TYPE_PROC_REF(/mob, incapacitated))))
		take_them(victim)

	qdel(particles)
	kidnapping = FALSE

/datum/component/space_kidnap/proc/take_them(mob/living/victim)
	if(ishuman(victim))
		var/mob/living/carbon/human/hewmon = victim
		hewmon.gain_trauma(/datum/brain_trauma/voided)

	victim.heal_overall_damage(brute = 50, burn = 20)
	victim.adjustOxyLoss(80)
	victim.flash_act(INFINITY, override_blindness_check = TRUE, visual = TRUE, type = /atom/movable/screen/fullscreen/flash/black)
	victim.forceMove(get_random_station_turf())

