/datum/keybinding
	var/list/hotkey_keys
	var/list/classic_keys
	var/name
	var/full_name
	var/description = ""
	var/category = CATEGORY_MISC
	var/weight = WEIGHT_LOWEST
	var/keybind_signal

/datum/keybinding/New()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

	// Default keys to the master "hotkey_keys"
	if(LAZYLEN(hotkey_keys) && !LAZYLEN(classic_keys))
		classic_keys = hotkey_keys.Copy()

/datum/keybinding/proc/down(client/user)
	SHOULD_CALL_PARENT(TRUE)
	user.keybinds_held[type] = src
	return SEND_SIGNAL(user.mob, keybind_signal) & COMSIG_KB_ACTIVATED

/datum/keybinding/proc/up(client/user)
	user.keybinds_held[type] = null
	return FALSE

/datum/keybinding/proc/can_use(client/user)
	return TRUE
