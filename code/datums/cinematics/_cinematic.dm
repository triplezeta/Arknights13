// Use to play cinematics.
// Watcher can be world,mob, or a list of mobs
// Blocks until sequence is done.
/proc/play_cinematic(datum/cinematic/cinematic_type, watchers, datum/callback/special_callback)
	if(!ispath(cinematic_type, /datum/cinematic))
		CRASH("play_cinematic called with a non-cinematic type. (Got: [cinematic_type])")
	var/datum/cinematic/playing = new cinematic_type(watchers, special_callback)

	if(watchers == world)
		watchers = GLOB.mob_list

	playing.start_cinematic(watchers)

/atom/movable/screen/cinematic
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "station_intact"
	plane = SPLASHSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "BOTTOM,LEFT+50%"
	appearance_flags = APPEARANCE_UI | TILE_BOUND

/datum/cinematic
	/// A list of all clients watching the cinematic
	var/list/client/watching = list()
	/// A list of all mobs who have notransform set while watching the cinematic
	var/list/datum/weakref/locked = list()
	/// Whether the cinematic is a global cinematic or not
	var/is_global = FALSE
	/// Refernce to the cinematic screen shown to everyohne
	var/atom/movable/screen/cinematic/screen
	/// Callbacks passed that occur during the animation
	var/datum/callback/special_callback
	/// How long for the final screen remains shown
	var/cleanup_time = 30 SECONDS
	/// Whether the cinematic turns off ooc when played globally.
	var/stop_ooc = TRUE

/datum/cinematic/New(watcher, datum/callback/special_callback)
	screen = new(src)
	if(watcher == world)
		is_global = TRUE

	src.special_callback = special_callback

/datum/cinematic/Destroy()
	QDEL_NULL(screen)
	QDEL_NULL(special_callback)
	watching.Cut()
	locked.Cut()
	return ..()

// /datum/cinematic/proc/play(watchers)
/datum/cinematic/proc/start_cinematic(list/watchers)
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PLAY_CINEMATIC, src) & COMPONENT_GLOB_BLOCK_CINEMATIC)
		return

	// Register a signal to handle what happens when a different cinematic tries to play over us.
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAY_CINEMATIC, .proc/handle_replacement_cinematics)

	// Pause OOC
	var/ooc_toggled = FALSE
	if(is_global && stop_ooc && GLOB.ooc_allowed)
		ooc_toggled = TRUE
		toggle_ooc(FALSE)

	// Place the /atom/movable/screen/cinematic into everyone's screens, prevent them from moving
	for(var/mob/watching_mob in watchers)
		show_to(watching_mob, watching_mob.client)
		RegisterSignal(watching_mob, COMSIG_MOB_CLIENT_LOGIN, .proc/show_to)
		//Close watcher ui's
		SStgui.close_user_uis(watching_mob)

	//Actually play it
	play_cinematic()

	//Cleanup
	sleep(cleanup_time)

	//Restore OOC
	if(ooc_toggled)
		toggle_ooc(TRUE)

	stop_cinematic()

/// Whenever another cinematic starts to play over us, we have the chacne to block it.
/datum/cinematic/proc/handle_replacement_cinematics(datum/source, datum/cinematic/other)
	SIGNAL_HANDLER

	// Stop our's and allow others to play if we're local and it's global
	if(!is_global && other.is_global)
		stop_cinematic()
		return NONE

	return COMPONENT_GLOB_BLOCK_CINEMATIC

/// Whenever a mob watching the cinematic logs in, show them the ongoing cinematic
/datum/cinematic/proc/show_to(mob/watching_mob, client/watching_client)
	SIGNAL_HANDLER

	if(!watching_mob.notransform)
		locked += WEAKREF(watching_mob)
		watching_mob.notransform = TRUE

	if(!watching_client)
		return

	watching += watching_client
	watching_mob.overlay_fullscreen("cinematic", /atom/movable/screen/fullscreen/cinematic_backdrop)
	watching_client.screen += screen

/// Simple helper to sounds from the cinematic
/datum/cinematic/proc/play_cinematic_sound(sound_to_play)
	if(is_global)
		SEND_SOUND(world, sound_to_play)
	else
		for(var/client/watching_client as anything in watching)
			SEND_SOUND(watching_client, sound_to_play)

/// Invoke any special callbacks for actual effects synchronized with animation
/// (Such as a real nuke explosion happening midway)
/datum/cinematic/proc/invoke_special_callback()
	special_callback?.Invoke()

/// The actual cinematic occurs here.
/datum/cinematic/proc/play_cinematic()
	return

/datum/cinematic/proc/stop_cinematic()
	for(var/client/viewing_client as anything in watching)
		viewing_client.mob.clear_fullscreen("cinematic")
		viewing_client.screen -= screen

	for(var/datum/weakref/locked_ref as anything in locked)
		var/mob/locked_mob = locked_ref.resolve()
		if(QDELETED(locked_mob))
			continue
		locked_mob.notransform = FALSE

	qdel(src)
