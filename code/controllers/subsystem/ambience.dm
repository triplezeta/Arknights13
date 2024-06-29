/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()
	var/list/client_old_areas = list()
	///Cache for sanic speed :D
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()
	var/list/cached_clients = currentrun

	while(cached_clients.len)
		var/client/client_iterator = cached_clients[cached_clients.len]
		cached_clients.len--

		//Check to see if the client exists and isn't held by a new player
		var/mob/client_mob = client_iterator?.mob
		if(isnull(client_iterator) || !client_mob || isnewplayer(client_mob))
			ambience_listening_clients -= client_iterator
			client_old_areas -= client_iterator
			continue

		//Check to see if the client-mob is in a valid area
		var/area/current_area = get_area(client_mob)
		if(!current_area) //Something's gone horribly wrong
			stack_trace("[key_name(client_mob)] has somehow ended up in nullspace. WTF did you do")
			ambience_listening_clients -= client_iterator
			continue

		if(ambience_listening_clients[client_iterator] > world.time)
			if(!(current_area.forced_ambience && (client_old_areas?[client_iterator] != current_area) && prob(5)))
				continue

		//Run play_ambience() on the client-mob and set a cooldown
		ambience_listening_clients[client_iterator] = world.time + current_area.play_ambience(client_mob)

		//We REALLY don't want runtimes in SSambience
		if(client_iterator)
			client_old_areas[client_iterator] = current_area

		if(MC_TICK_CHECK)
			return

///Attempts to play an ambient sound to a mob, returning the cooldown in deciseconds
/area/proc/play_ambience(mob/M, sound/override_sound, volume = 27)
	var/sound/new_sound = override_sound || pick(ambientsounds)
	new_sound = sound(new_sound, repeat = 0, wait = 0, volume = volume, channel = CHANNEL_AMBIENCE)
	SEND_SOUND(M, new_sound)

	return rand(min_ambience_cooldown, max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	client_old_areas -= to_remove
	currentrun -= to_remove

/area/station/maintenance
	min_ambience_cooldown = 20 SECONDS
	max_ambience_cooldown = 35 SECONDS

	///A list of rare sound effects to fuck with players. No, it does not contain actual minecraft sounds anymore.
	var/static/list/minecraft_cave_noises = list(
		'sound/machines/airlock.ogg',
		'sound/effects/snap.ogg',
		'sound/effects/footstep/clownstep1.ogg',
		'sound/effects/footstep/clownstep2.ogg',
		'sound/items/welder.ogg',
		'sound/items/welder2.ogg',
		'sound/items/crowbar.ogg',
		'sound/items/deconstruct.ogg',
		'sound/ambience/source_holehit3.ogg',
		'sound/ambience/cavesound3.ogg',
	)

/area/station/maintenance/play_ambience(mob/M, sound/override_sound, volume)
	if(!M.has_light_nearby() && prob(0.5))
		return ..(M, pick(minecraft_cave_noises))
	return ..()

/mob/proc/update_ambience_area(area/new_area)
	var/old_tracked_area = ambience_tracked_area

	if(old_tracked_area)
		UnregisterSignal(old_tracked_area, COMSIG_AREA_POWER_CHANGE)
		ambience_tracked_area = null

	if(!client)
		playing_ambience = null
		return

	if(new_area)
		ambience_tracked_area = new_area
		RegisterSignal(ambience_tracked_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(refresh_looping_ambience), TRUE)

	refresh_looping_ambience()

/mob/proc/refresh_looping_ambience()
	SIGNAL_HANDLER

	if(!client)
		return

	var/area/my_area = get_area(src)

	if(!(client?.prefs.read_preference(/datum/preference/toggle/sound_ship_ambience)) || !my_area?.ambient_buzz)
		SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = CHANNEL_BUZZ))
		playing_ambience = null
		return

	//Station ambience is dependant on a functioning and charged APC with enviorment power enabled.
	if(!is_mining_level(my_area.z) && ((!my_area.apc || !my_area.apc.operating || !my_area.apc.cell?.charge && my_area.requires_power || !my_area.power_environ)))
		SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = CHANNEL_BUZZ))
		playing_ambience = null
		return
	else
		if(playing_ambience == ambience_tracked_area?.ambient_buzz)
			return

		playing_ambience = my_area.ambient_buzz
		SEND_SOUND(src, sound(my_area.ambient_buzz, repeat = 1, wait = 0, volume = my_area.ambient_buzz_vol, channel = CHANNEL_BUZZ))
