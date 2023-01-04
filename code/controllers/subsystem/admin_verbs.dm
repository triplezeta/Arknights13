SUBSYSTEM_DEF(admin_verbs)
	name = "Admin Verbs"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ADMIN_VERBS
	VAR_PRIVATE/list/admin_verb_map
	VAR_PRIVATE/list/holder_map
	VAR_PRIVATE/list/admin_linkup_map

	var/list/waiting_to_assosciate = list()

GENERAL_PROTECT_DATUM(/datum/controller/subsystem/admin_verbs)

/datum/controller/subsystem/admin_verbs/Recover()
	SSadmin_verbs.admin_verb_map = admin_verb_map
	SSadmin_verbs.holder_map = holder_map
	SSadmin_verbs.admin_linkup_map = admin_linkup_map

/datum/controller/subsystem/admin_verbs/Initialize()
	RegisterSignal(src, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(assosciate_with_waiting))
	admin_verb_map = list()
	holder_map = list()
	admin_linkup_map = list()
	populate_verb_map(admin_verb_map)
	generate_holder_map()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/admin_verbs/proc/generate_stat_data(client/target)
	if(!initialized || !target.holder)
		return list()

	var/list/stat_data = list()
	for(var/verb_type in admin_verb_map)
		var/list/verb_information = admin_verb_map[verb_type]
		var/verb_permissions = verb_information[ADMIN_VERB_MAP_PERMISSIONS]
		if(!check_rights_for(target, verb_permissions))
			continue

		var/verb_module = capitalize(verb_information[ADMIN_VERB_MAP_MODULE])
		if(!verb_module || verb_module == "null")
			continue

		var/formatted_name = ""
		var/original_name = verb_information[ADMIN_VERB_MAP_NAME]
		for(var/name_part in splittext(original_name, "_"))
			formatted_name += "[capitalize(name_part)] "
		formatted_name = copytext(formatted_name, 1, -1)

		var/verb_desc = verb_information[ADMIN_VERB_MAP_DESC]
		stat_data[verb_module] += list(list(formatted_name, verb_desc, original_name))
	return stat_data

/datum/controller/subsystem/admin_verbs/proc/populate_verb_map(list/verb_map)
	return

/datum/controller/subsystem/admin_verbs/proc/generate_holder_map()
	for(var/mob/admin_module_holder/holder_type as anything in admin_verb_map)
		holder_map[holder_type] = new holder_type

/datum/controller/subsystem/admin_verbs/proc/get_verb_module(verb_type)
	var/list/verb_information = admin_verb_map[verb_type]
	return verb_information[ADMIN_VERB_MAP_MODULE]

/datum/controller/subsystem/admin_verbs/proc/get_verb_name(verb_type)
	var/list/verb_information = admin_verb_map[verb_type]
	return verb_information[ADMIN_VERB_MAP_NAME]

/datum/controller/subsystem/admin_verbs/proc/get_verb_desc(verb_type)
	var/list/verb_information = admin_verb_map[verb_type]
	return verb_information[ADMIN_VERB_MAP_DESC]

/datum/controller/subsystem/admin_verbs/proc/get_verb_permissions(verb_type)
	var/list/verb_information = admin_verb_map[verb_type]
	return verb_information[ADMIN_VERB_MAP_PERMISSIONS]

/datum/controller/subsystem/admin_verbs/proc/dynamic_invoke_admin_verb(client/target, verb_type, list/arguments = list())
	if(IsAdminAdvancedProcCall())
		return

	var/mob/admin_module_holder/holder = holder_map[verb_type]
	if(!istype(holder))
		to_chat(usr, span_big("Attempted to dynamic invoke an admin verb that didnt exist, this is a really bad problem!"))
		CRASH("Admin Verb Holder '[verb_type]' did not exist when an attempt to access the dynmap occured.")

	usr = target.mob
	holder:invoke(arglist(arguments))

/datum/controller/subsystem/admin_verbs/proc/link_admin(mob/admin)
	for(var/mob/admin_module_holder/holder as anything in holder_map)
		holder = holder_map[holder]
		if(check_rights_for(admin.client, get_verb_permissions(holder.type)))
			admin.group |= holder

/datum/controller/subsystem/admin_verbs/proc/unlink_admin(mob/adwas)
	for(var/mob/admin_module_holder/holder as anything in holder_map)
		holder = holder_map[holder]
		adwas.group -= holder

#define MAP_LOGOUT 1
#define MAP_LOGIN 2

/datum/controller/subsystem/admin_verbs/proc/assosciate_admin(client/admin)
	if(!initialized)
		to_chat_immediate(admin, span_admin("SSadmin_verbs has either not begun or has not finished initialization procedures, please wait!"))
		waiting_to_assosciate |= admin.ckey
		return

	var/list/existing_map = admin_linkup_map[admin.ckey]
	if(existing_map)
		admin.player_details.post_login_callbacks -= existing_map[MAP_LOGIN]

		var/datum/callback/old_logout = existing_map[MAP_LOGOUT]
		admin.player_details.post_logout_callbacks -= old_logout
		old_logout.Invoke(admin.mob)

	var/on_login = CALLBACK(src, PROC_REF(link_admin))
	var/on_logout = CALLBACK(src, PROC_REF(unlink_admin))
	admin_linkup_map[admin.ckey] = list(on_logout, on_login)

	admin.player_details.post_login_callbacks += list(on_login)
	admin.player_details.post_logout_callbacks += list(on_logout)
	link_admin(admin.mob)

/datum/controller/subsystem/admin_verbs/proc/deassosciate_admin(client/adwas)
	var/list/existing_map = admin_linkup_map[adwas.ckey]
	if(existing_map)
		adwas.player_details.post_login_callbacks -= existing_map[MAP_LOGIN]

		var/datum/callback/old_logout = existing_map[MAP_LOGOUT]
		adwas.player_details.post_logout_callbacks -= old_logout
		old_logout.Invoke(adwas.mob)

	unlink_admin(adwas.mob)

/datum/controller/subsystem/admin_verbs/proc/assosciate_with_waiting()
	for(var/waiting in waiting_to_assosciate)
		if(waiting in GLOB.directory)
			assosciate_admin(GLOB.directory[waiting])
	waiting_to_assosciate.Cut()

#undef MAP_LOGOUT
#undef MAP_LOGIN
