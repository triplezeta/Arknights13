/datum/mafia_role/hos
	name = "Head of Security"
	desc = "You can decide to execute during the night, visiting someone killing, and revealing them. If they are innocent, you will die at the start of the next night."
	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL | ROLE_UNIQUE
	revealed_outfit = /datum/outfit/mafia/hos
	revealed_icon = "headofsecurity"
	hud_icon = "hudheadofsecurity"
	winner_award = /datum/award/achievement/mafia/hos

	role_unique_actions = list(/datum/mafia_ability/attack_player/honorable)

/datum/mafia_role/warden
	name = "Warden"
	desc = "You can lockdown during the night once, killing any visitors. WARNING: This kills fellow town members, too!"

	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL
	revealed_outfit = /datum/outfit/mafia/warden
	revealed_icon = "warden"
	hud_icon = "hudwarden"
	winner_award = /datum/award/achievement/mafia/warden

	role_unique_actions = list(/datum/mafia_ability/attack_visitors)
