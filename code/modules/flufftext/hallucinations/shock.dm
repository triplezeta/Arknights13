/// Causes a fake "zap" to the hallucinator.
/datum/hallucination/shock
	var/image/shock_image
	var/image/electrocution_skeleton_anim

/datum/hallucination/shock/Destroy()
	if(shock_image)
		hallucinator.client?.images -= shock_image
		shock_image = null
	if(electrocution_skeleton_anim)
		hallucinator.client?.images -= electrocution_skeleton_anim
		electrocution_skeleton_anim = null

	return ..()

/datum/hallucination/shock/start()
	shock_image = image(hallucinator, hallucinator, dir = hallucinator.dir)
	shock_image.appearance_flags |= KEEP_APART
	shock_image.color = rgb(0, 0, 0)
	shock_image.override = TRUE

	electrocution_skeleton_anim = image('icons/mob/human.dmi', hallucinator, icon_state = "electrocuted_base", layer = ABOVE_MOB_LAYER)
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART

	to_chat(hallucinator, span_userdanger("You feel a powerful shock course through your body!"))
	hallucinator.client?.images |= shock_image
	hallucinator.client?.images |= electrocution_skeleton_anim

	hallucinator.playsound_local(get_turf(src), SFX_SPARKS, 100, TRUE)
	hallucinator.adjustStaminaLoss(50)
	hallucinator.Stun(4 SECONDS)
	hallucinator.do_jitter_animation(300) // Maximum jitter
	hallucinator.adjust_timed_status_effect(20 SECONDS, /datum/status_effect/jitter)

	addtimer(CALLBACK(src, .proc/reset_shock_animation), 4 SECONDS)
	addtimer(CALLBACK(src, .proc/shock_drop), 2 SECONDS)
	QDEL_IN(src, 4 SECONDS)
	return TRUE

/datum/hallucination/shock/proc/reset_shock_animation()
	if(QDELETED(hallucinator))
		return

	hallucinator.client?.images -= shock_image
	shock_image = null

	hallucinator.client?.images -= electrocution_skeleton_anim
	electrocution_skeleton_anim = null

/datum/hallucination/shock/proc/shock_drop()
	if(QDELETED(hallucinator))
		return

	hallucinator.Paralyze(6 SECONDS)
