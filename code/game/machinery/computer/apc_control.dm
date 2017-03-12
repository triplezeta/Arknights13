/obj/machinery/computer/apc_control
	name = "power flow control console"
	desc = "Used to remotely control the flow of power to different parts of the station."
	icon_screen = "solar"
	icon_keyboard = "power_key"
	circuit = /obj/item/weapon/circuitboard/computer/apc_control
	light_color = LIGHT_COLOR_YELLOW
	var/list/apcs //APCs the computer has access to
	var/mob/living/operator //Who's operating the computer right now
	var/obj/machinery/power/apc/active_apc //The APC we're using right now
	var/list/filters //For sorting the results
	var/checking_logs = 0
	var/list/logs

/obj/machinery/computer/apc_control/Initialize()
	apcs = list() //To avoid BYOND making the list run through a ton of procs
	filters = list("Name" = null, "Charge Above" = null, "Charge Below" = null, "Responsive" = null)
	..()

/obj/machinery/computer/apc_control/process()
	apcs = list() //Clear the list every tick
	for(var/V in apcs_list)
		var/obj/machinery/power/apc/APC = V
		if(check_apc(APC))
			apcs[APC.name] = APC
	if(operator)
		if(!operator.Adjacent(src))
			operator = null
			if(active_apc)
				if(!active_apc.locked)
					active_apc.say("Remote access canceled. Interface locked.")
					playsound(active_apc, 'sound/machines/BoltsDown.ogg', 25, 0)
					playsound(active_apc, 'sound/machines/terminal_alert.ogg', 50, 0)
				active_apc.locked = TRUE
				active_apc.update_icon()
				active_apc = null

/obj/machinery/computer/apc_control/proc/check_apc(obj/machinery/power/apc/APC)
	return APC.z == z && !APC.malfhack && !APC.aidisabled && !APC.emagged && !APC.stat && !istype(APC.area, /area/ai_monitored) && !APC.area.outdoors

/obj/machinery/computer/apc_control/interact(mob/living/user)
	var/dat
	if(!checking_logs)
		dat += "<i>Filters</i><br>"
		dat += "<b>Name:</b> <a href='?src=\ref[src];name_filter=1'>[filters["Name"] ? filters["Name"] : "None set"]</a><br>"
		dat += "<b>Charge:</b> <a href='?src=\ref[src];above_filter=1'>\>[filters["Charge Above"] ? filters["Charge Above"] : "NaN"]%</a> and <a href='?src=\ref[src];below_filter=1'>\<[filters["Charge Below"] ? filters["Charge Below"] : "NaN"]%</a><br>"
		dat += "<b>Accessible:</b> <a href='?src=\ref[src];access_filter=1'>[filters["Responsive"] ? "Non-Responsive Only" : "All"]</a><br><br>"
		for(var/A in apcs)
			var/obj/machinery/power/apc/APC = apcs[A]
			if(filters["Name"] && !findtext(APC.name, filters["Name"]) && !findtext(APC.area.name, filters["Name"]))
				continue
			if(filters["Charge Above"] && (APC.cell.charge / APC.cell.maxcharge) < filters["Charge Above"] / 100)
				continue
			if(filters["Charge Below"] && (APC.cell.charge / APC.cell.maxcharge) > filters["Charge Below"] / 100)
				continue
			if(filters["Responsive"] && !APC.aidisabled)
				continue
			dat += "<a href='?src=\ref[src];access_apc=\ref[APC]'>[A]</a><br>\
			<b>Charge:</b> [APC.cell.charge] / [APC.cell.maxcharge] W ([round((APC.cell.charge / APC.cell.maxcharge) * 100)]%)<br>\
			<b>Area:</b> [APC.area]<br>\
			[APC.aidisabled || APC.panel_open ? "<font color='#FF0000'>APC does not respond to interface query.</font>" : "<font color='#00FF00'>APC responds to interface query.</font>"]<br><br>"
		dat += "<a href='?src=\ref[src];check_logs=1'>Check Logs</a>"
	else
		if(logs.len)
			for(var/entry in logs)
				dat += "[entry]<br>"
		else
			dat += "<i>No activity has been recorded at this time.</i><br>"
		if(emagged)
			dat += "<a href='?src=\ref[src];clear_logs=1'><font color='#FF0000'>@#%! CLEAR LOGS</a>"
		dat += "<a href='?src=\ref[src];check_apcs=1'>Return</a>"
	operator = user
	var/datum/browser/popup = new(user, "apc_control", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/computer/apc_control/Topic(href, href_list)
	if(..())
		return
	var/image/I = image(src) //For feedback message flavor
	if(href_list["access_apc"])
		playsound(src, "terminal_type", 50, 0)
		var/obj/machinery/power/apc/APC = locate(href_list["access_apc"]) in apcs_list
		if(!APC || APC.aidisabled || APC.panel_open)
			to_chat(usr, "<span class='robot danger'>\icon[I] APC does not return interface request. Remote access may be disabled.</span>")
			return
		if(active_apc)
			to_chat(usr, "<span class='robot danger'>\icon[I] Disconnected from [active_apc].</span>")
			active_apc.locked = TRUE
			active_apc = null
		to_chat(usr, "<span class='robot notice'>\icon[I] Connected to APC in [get_area(APC)]. Interface request sent.</span>")
		log_activity("remotely accessed APC in [get_area(APC)]")
		APC.interact(usr, not_incapacitated_state)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		if(APC.locked)
			APC.say("Remote access detected. Interface unlocked.")
			playsound(APC, 'sound/machines/BoltsUp.ogg', 25, 0)
			playsound(APC, 'sound/machines/terminal_alert.ogg', 50, 0)
		APC.locked = FALSE
		APC.update_icon()
		active_apc = APC
	if(href_list["name_filter"])
		var/new_filter = stripped_input(usr, "What name are you looking for?", name) as null|text
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		log_activity("changed name filter to \"[new_filter]\"")
		if(!src || !usr.Adjacent(src))
			return
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		filters["Name"] = new_filter
	if(href_list["above_filter"])
		var/new_filter = input(usr, "Enter a percentage from 1-100 to sort by (greater than).", name) as null|num
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		log_activity("changed greater than charge filter to \"[new_filter]\"")
		if(!src || !usr.Adjacent(src))
			return
		if(new_filter)
			new_filter = Clamp(new_filter, 0, 100)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		filters["Charge Above"] = new_filter
	if(href_list["below_filter"])
		var/new_filter = input(usr, "Enter a percentage from 1-100 to sort by (lesser than).", name) as null|num
		log_activity("changed lesser than charge filter to \"[new_filter]\"")
		playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		if(!src || !usr.Adjacent(src))
			return
		if(new_filter)
			new_filter = Clamp(new_filter, 0, 100)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		filters["Charge Below"] = new_filter
	if(href_list["access_filter"])
		if(isnull(filters["Responsive"]))
			filters["Responsive"] = 1
			log_activity("sorted by non-responsive APCs only")
		else
			filters["Responsive"] = !filters["Responsive"]
			log_activity("sorted by all APCs")
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	if(href_list["check_logs"])
		checking_logs = TRUE
		log_activity("checked logs")
	if(href_list["check_apcs"])
		checking_logs = FALSE
		log_activity("checked APCs")
	if(href_list["clear_logs"])
		logs = list()
	interact(usr) //Refresh the UI after a filter changes

/obj/machinery/computer/apc_control/emag_act(mob/living/user)
	if(emagged)
		return
	user.visible_message("<span class='warning'>You emag [src], disabling precise logging and allowing you to clear logs.</span>")
	playsound(src, "sparks", 50, 1)
	emagged = 1

/obj/machinery/computer/apc_control/proc/log_activity(log_text)
	var/op_string = operator && !emagged ? operator : "\[NULL OPERATOR\]"
	LAZYADD(logs, "<b>([worldtime2text()])</b> [op_string] [log_text]")

/mob/proc/using_power_flow_console()
	for(var/obj/machinery/computer/apc_control/A in range(1, src))
		if(A.operator && A.operator == src)
			return TRUE
	return
