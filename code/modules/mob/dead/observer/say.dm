/mob/dead/observer/check_emote(message, forced)
	if(message == "*spin" || message == "*flip")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE

/mob/dead/observer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if (!message)
		return

	var/message_mode = get_message_mode(message)
	if(client && (message_mode == MODE_ADMIN || message_mode == MODE_DEADMIN))
		message = copytext_char(message, 3)
		message = trim_left(message)

		if(message_mode == MODE_ADMIN)
			client.cmd_admin_say(message)
		else if(message_mode == MODE_DEADMIN)
			client.dsay(message)
		return

	if(check_emote(message, forced))
		return

	. = say_dead(message)

/mob/dead/observer/Hear(datum/spoken_info/info)
	. = ..()
	var/atom/movable/to_follow = info.source
	if(info.radio_freq)
		var/atom/movable/virtualspeaker/V = info.source

		if(isAI(V.source))
			var/mob/living/silicon/ai/S = V.source
			to_follow = S.eyeobj
		else
			to_follow = V.source
	var/link = FOLLOW_LINK(src, to_follow)
	// Recompose the message, because it's scrambled by default
	to_chat(src, "[link] [info.getMsg()]")
