/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over || !initialized)
		return
	if(over == src)
		return usr.client.Click(src, src_location, src_control, params)
	if(!Adjacent(usr) || !over.Adjacent(usr))
		return // should stop you from dragging through windows
	if(user.client && user.client.SendSignal(COMSIG_CLIENT_MOUSEDROP, over, src_location, over_location, src_control, over_control, params))
		return

	over.MouseDrop_T(src,usr)
	return

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	return
