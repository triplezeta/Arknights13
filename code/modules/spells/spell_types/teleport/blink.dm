/datum/action/cooldown/spell/teleport/radius_turf/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."
	action_icon_state = "blink"
	sound = 'sound/magic/blink.ogg'

	school = SCHOOL_FORBIDDEN
	charge_max = 2 SECONDS
	cooldown_reduction_per_rank = 0.4 SECONDS

	invocation_type = INVOCATION_NONE

	smoke_spread = SMOKE_HARMLESS
	smoke_amt = 0

	inner_tele_radius = 0
	outer_tele_radius = 6

	post_teleport_sound = 'sound/magic/blink.ogg'
