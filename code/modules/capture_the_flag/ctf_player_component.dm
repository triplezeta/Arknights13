//Remember to comment
/datum/component/ctf_player
	var/team
	var/mob/living/player_mob
	var/can_respawn = TRUE
	var/datum/ctf_controller/ctf_game

/datum/component/ctf_player/Initialize(team, ctf_game)
	src.team = team
	src.ctf_game = ctf_game
	var/datum/mind/true_parent = parent
	player_mob = true_parent.current
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	setup_dusting()
	
/datum/component/ctf_player/PostTransfer()
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	var/datum/mind/true_parent = parent
	player_mob = true_parent.current
	setup_dusting()

/datum/component/ctf_player/proc/setup_dusting()
	//Todo, check if the victim is actually a ctf participant just incase
	RegisterSignal(player_mob, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(ctf_dust))
	RegisterSignal(player_mob, COMSIG_MOB_GHOSTIZED, PROC_REF(ctf_dust))

/datum/component/ctf_player/proc/ctf_dust()
	SIGNAL_HANDLER

	//Todo, ignore oxy/stam damage as funny as it is for the shotgun class to die from exaustion
	if(HAS_TRAIT(player_mob, TRAIT_CRITICAL_CONDITION) || player_mob.stat == DEAD || !player_mob.client)
		UnregisterSignal(player_mob, list(COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_MOB_GHOSTIZED))
		player_mob.dust()
		player_mob = null
		can_respawn = FALSE
		addtimer(CALLBACK(src, PROC_REF(allow_respawns)), ctf_game.respawn_cooldown ,TIMER_UNIQUE) //Todo link with associated ctf game for respawn cooldown times
	//Todo, dropping ammo pickups

/datum/component/ctf_player/proc/allow_respawns()
	can_respawn = TRUE
	//Insert message to player

/datum/component/ctf_player/proc/send_message(message)
	to_chat(parent, message)

/datum/component/ctf_player/proc/end_game()
	if(player_mob)
		for(var/obj/item/ctf/flag in player_mob)
				player_mob.dropItemToGround(flag)
		player_mob.dust()
	qdel(src)

/datum/component/ctf_player/Destroy(force, silent)
	if(player_mob)
		UnregisterSignal(player_mob, list(COMSIG_MOB_AFTER_APPLY_DAMAGE, COMSIG_MOB_GHOSTIZED))
	return ..()
	