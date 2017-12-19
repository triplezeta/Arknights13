//shows a list of clients we could send PMs to, then forwards our choice to cmd_Mentor_pm
/client/proc/cmd_mentor_pm_panel()
	set category = "Mentor"
	set name = "Mentor PM"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Mentor-PM-Panel: Only Mentors may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		targets["[T]"] = T

	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Mentor PM",null) in sorted|null
	cmd_mentor_pm(targets[target],null)


//takes input from cmd_mentor_pm_context, cmd_Mentor_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_mentor_pm(whom, msg)
	var/client/C
	if(ismob(whom))
		var/mob/M = whom
		C = M.client
	else if(istext(whom))
		C = GLOB.directory[whom]
	else if(istype(whom,/client))
		C = whom
	if(!C)
		if(holder)
			to_chat(src, "<font color='red'>Error: Mentor-PM: Client not found.</font>")
		else
			mentorhelp(msg)	//Mentor we are replying to left. Mentorhelp instead
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message") as text|null

		if(!msg)	return
		if(!C)
			if(holder)
				to_chat(src, "<font color='red'>Error: Mentor-PM: Client not found.</font>")
			else
				mentorhelp(msg) //Mentor we are replying to has vanished, Mentorhelp instead
			return

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return

	log_mentor("Mentor PM: [key_name(src)]->[key_name(C)]: [msg]")

	msg = emoji_parse(msg)
	SEND_SOUND(C, 'sound/items/bikehorn.ogg')
	var/show_char = config.mentors_mobname_only
	if(check_mentor_other(C))
		if(check_mentor())	//both are mentors
			to_chat(C, "<font color='#3280ff'>Mentor PM from-<b>[key_name_mentor(src, C, 1, 0, 0)]</b>: [msg]</font>")
			to_chat(src, "<font color='green'>Mentor PM to-<b>[key_name_mentor(C, C, 1, 0, 0)]</b>: [msg]</font>")

		else		//recipient is an mentor but sender is not
			to_chat(C, "<font color='#3280ff'>Reply PM from-<b>[key_name_mentor(src, C, 1, 0, show_char)]</b>: [msg]</font>")
			to_chat(src, "<font color='green'>Mentor PM to-<b>[key_name_mentor(C, C, 1, 0, 0)]</b>: [msg]</font>")

	else
		if(check_mentor())	//sender is an mentor but recipient is not.
			to_chat(C, "<font color='#3280ff'>Mentor PM from-<b>[key_name_mentor(src, C, 1, 0, 0)]</b>: [msg]</font>")
			to_chat(src, "<font color='green'>Mentor PM to-<b>[key_name_mentor(C, C, 1, 0, show_char)]</b>: [msg]</font>")

	//we don't use message_Mentors here because the sender/receiver might get it too
	var/show_char_sender = !check_mentor_other(src) && config.mentors_mobname_only
	var/show_char_recip = !check_mentor_other(C) && config.mentors_mobname_only
	for(var/client/X in mentors_and_admins())
		if(X.key!=key && X.key!=C.key)	//check client/X is an Mentor and isn't the sender or recipient
			to_chat(X, "<B><font color='green'>Mentor PM: [key_name_mentor(src, X, 0, 0, show_char_sender)]-&gt;[key_name_mentor(C, X, 0, 0, show_char_recip)]:</B> \blue [msg]</font>")