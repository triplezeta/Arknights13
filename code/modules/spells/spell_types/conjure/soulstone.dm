/datum/action/cooldown/spell/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar'Sie's realm, summoning one of the legendary fragments across time and space."
	background_icon_state = "bg_demon"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "summonsoulstone"

	school = SCHOOL_CONJURATION
	cooldown_time = 4 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/item/soulstone)

/datum/action/cooldown/spell/conjure/soulstone/cult
	cooldown_time = 6 MINUTES
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB

/datum/action/cooldown/spell/conjure/soulstone/noncult
	summon_type = list(/obj/item/soulstone/anybody)

/datum/action/cooldown/spell/conjure/soulstone/purified
	summon_type = list(/obj/item/soulstone/anybody/purified)

/datum/action/cooldown/spell/conjure/soulstone/mystic
	summon_type = list(/obj/item/soulstone/mystic)
