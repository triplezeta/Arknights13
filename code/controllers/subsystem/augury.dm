var/datum/subsystem/augury/SSaugury

/datum/subsystem/augury
	name = "Augury"
	flags = SS_NO_INIT

	var/list/watchers = list()
	var/list/doombringers = list()

	var/list/observers_given_action = list()

/datum/subsystem/augury/New()
	NEW_SS_GLOBAL(SSaugury)

/datum/subsystem/augury/stat_entry(msg)
	..("W:[watchers.len]|D:[doombringers.len]")

/datum/subsystem/augury/proc/register_doom(atom/A, severity)
	doombringers[A] = severity

/datum/subsystem/augury/fire()
	var/biggest_doom = null
	var/biggest_threat = null

	for(var/d in doombringers)
		if(!d || qdeleted(d))
			doombringers -= d
			continue
		var/threat = doombringers[d]
		if((biggest_threat == null) || (biggest_threat < threat))
			biggest_doom = d
			biggest_threat = threat

	if(doombringers.len)
		for(var/i in player_list)
			if(isobserver(i) && (!(i in observers_given_action)))
				var/datum/action/innate/augury/A = new
				A.Grant(i)
				observers_given_action += i

	for(var/w in watchers)
		if(!w)
			watchers -= w
			continue
		var/mob/dead/observer/O = w
		if(O.orbiting)
			continue
		else if(biggest_doom)
			O.orbit(biggest_doom)

/datum/action/innate/augury
	name = "Auto Follow Debris"
	icon_icon = 'icons/obj/meteor.dmi'
	button_icon_state = "flaming"

/datum/action/innate/augury/Activate()
	SSaugury.watchers |= owner
	active = TRUE

/datum/action/innate/augury/Deactivate()
	SSaugury.watchers -= owner

/datum/action/innate/augury/UpdateButtonIcon()
	..()
	if(active)
		button.icon_state = "bg_default_on"
