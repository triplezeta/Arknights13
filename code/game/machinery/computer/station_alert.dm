
/obj/machinery/computer/station_alert
	name = "Station Alert Console"
	desc = "Used to access the station's automated alert system."
	icon_state = "alert:0"
	circuit = "/obj/item/weapon/circuitboard/stationalert"
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())


	attack_ai(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)
		return


	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)
		return


	interact(mob/user)
		usr.set_machine(src)
		var/dat = ""
		for (var/cat in src.alarms)
			dat += text("<h2>[]</h2>", cat)
			var/list/L = src.alarms[cat]
			if (L.len)
				for (var/alarm in L)
					var/list/alm = L[alarm]
					var/area/A = alm[1]
					var/list/sources = alm[3]
					dat += "<NOBR>"
					dat += "&bull; "
					dat += "[format_text(A.name)]"
					if (sources.len > 1)
						dat += text(" - [] sources", sources.len)
					dat += "</NOBR><BR>\n"
			else
				dat += "-- All Systems Nominal<BR>\n"
			dat += "<BR>\n"
		//user << browse(dat, "window=alerts")
		//onclose(user, "alerts")
		var/datum/browser/popup = new(user, "alerts", "Current Station Alerts")
		popup.add_head_content("<META HTTP-EQUIV='Refresh' CONTENT='10'>")
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()


	Topic(href, href_list)
		if(..())
			return
		return


	proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
		if(stat & (BROKEN))
			return
		var/list/L = src.alarms[class]
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/sources = alarm[3]
				if (!(alarmsource in sources))
					sources += alarmsource
				return 1
		var/obj/machinery/camera/C = null
		var/list/CL = null
		if (O && istype(O, /list))
			CL = O
			if (CL.len == 1)
				C = CL[1]
		else if (O && istype(O, /obj/machinery/camera))
			C = O
		L[A.name] = list(A, (C) ? C : O, list(alarmsource))
		return 1


	proc/cancelAlarm(var/class, area/A as area, obj/origin)
		if(stat & (BROKEN))
			return
		var/list/L = src.alarms[class]
		var/cleared = 0
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/srcs  = alarm[3]
				if (origin in srcs)
					srcs -= origin
				if (srcs.len == 0)
					cleared = 1
					L -= I
		return !cleared


	process()
		if(stat & (BROKEN|NOPOWER))
			icon_state = "atmos0"
			return
		var/active_alarms = 0
		for (var/cat in src.alarms)
			var/list/L = src.alarms[cat]
			if(L.len) active_alarms = 1
		if(active_alarms)
			icon_state = "alert:2"
		else
			icon_state = "alert:0"
		..()
		return
