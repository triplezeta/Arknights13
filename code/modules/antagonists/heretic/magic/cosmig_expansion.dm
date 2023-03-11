/datum/action/cooldown/spell/conjure/cosmig_expansion
	name = "Cosmig Expansion"
	desc = "This spell generates a 3x3 domain of cosmig fields, neaby mobs from 7 tiles away will also get a star mark status effect."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmig_domain"

	sound = 'sound/magic/cosmig_expansion.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 80 SECONDS

	invocation = "C'SM'S 'XP'ND"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_amount = 9
	summon_radius = 1
	summon_type = list(/obj/effect/cosmig_field)
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 7
	/// Effect for when the spell triggers
	var/obj/effect/expansion_effect = /obj/effect/temp_visual/cosmig_domain

/datum/action/cooldown/spell/conjure/cosmig_expansion/cast(atom/cast_on)
	new expansion_effect(get_turf(cast_on))
	for(var/mob/living/nearby_mob in range(star_mark_range, cast_on))
		if(!(owner == nearby_mob))
			if(!(FACTION_HERETIC in nearby_mob.faction))
				nearby_mob.apply_status_effect(/datum/status_effect/star_mark)
	return ..()
