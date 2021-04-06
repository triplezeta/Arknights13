#define SCANGATE_NONE "Off"
#define SCANGATE_MINDSHIELD "Mindshield"
#define SCANGATE_NANITES "Nanites"
#define SCANGATE_DISEASE "Disease"
#define SCANGATE_GUNS "Guns"
#define SCANGATE_WANTED "Wanted"
#define SCANGATE_SPECIES "Species"
#define SCANGATE_NUTRITION "Nutrition"

#define SCANGATE_HUMAN "human"
#define SCANGATE_LIZARD "lizard"
#define SCANGATE_FELINID "felinid"
#define SCANGATE_FLY "fly"
#define SCANGATE_PLASMAMAN "plasma"
#define SCANGATE_MOTH "moth"
#define SCANGATE_JELLY "jelly"
#define SCANGATE_POD "pod"
#define SCANGATE_GOLEM "golem"
#define SCANGATE_ZOMBIE "zombie"

/obj/machinery/scanner_gate
	name = "scanner gate"
	desc = "A gate able to perform mid-depth scans on any organisms who pass under it."
	icon = 'icons/obj/machines/scangate.dmi'
	icon_state = "scangate"
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/scanner_gate

	var/scanline_timer
	///Internal timer to prevent audio spam.
	var/next_beep = 0
	///Bool to check if the scanner's controls are locked by an ID.
	var/locked = FALSE
	///Which setting is the scanner checking for? See defines in scan_gate.dm for the list.
	var/scangate_mode = SCANGATE_NONE
	///Is searching for a disease, what severity is enough to trigger the gate?
	var/disease_threshold = DISEASE_SEVERITY_MINOR
	///If scanning for a nanite strain, what cloud is it looking for?
	var/nanite_cloud = 1
	///If scanning for a specific species, what species is it looking for?
	var/detect_species = SCANGATE_HUMAN
	///Flips all scan results for inverse scanning. Signals if scan returns false.
	var/reverse = FALSE
	///If scanning for nutrition, what level of nutrition will trigger the scanner?
	var/detect_nutrition = NUTRITION_LEVEL_FAT
	///Will the assembly on the pass wire activate if the scanner resolves green (Pass) on crossing?
	var/light_pass = FALSE
	///Will the assembly on the pass wire activate if the scanner resolves red (fail) on crossing?
	var/light_fail = FALSE
	///Does the scanner ignore light_pass and light_fail for sending signals?
	var/ignore_signals = FALSE


/obj/machinery/scanner_gate/Initialize()
	. = ..()
	wires = new /datum/wires/scanner_gate(src)
	set_scanline("passive")
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/on_crossed)

/obj/machinery/scanner_gate/Destroy()
	qdel(wires)
	wires = null
	. = ..()

/obj/machinery/scanner_gate/examine(mob/user)
	. = ..()
	if(locked)
		. += "<span class='notice'>The control panel is ID-locked. Swipe a valid ID to unlock it.</span>"
	else
		. += "<span class='notice'>The control panel is unlocked. Swipe an ID to lock it.</span>"

/obj/machinery/scanner_gate/proc/on_crossed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	auto_scan(AM)

/obj/machinery/scanner_gate/proc/auto_scan(atom/movable/AM)
	if(!(machine_stat & (BROKEN|NOPOWER)) && isliving(AM) & (!panel_open))
		perform_scan(AM)

/obj/machinery/scanner_gate/proc/set_scanline(type, duration)
	cut_overlays()
	deltimer(scanline_timer)
	add_overlay(type)
	if(duration)
		scanline_timer = addtimer(CALLBACK(src, .proc/set_scanline, "passive"), duration, TIMER_STOPPABLE)

/obj/machinery/scanner_gate/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/card = W.GetID()
	if(card)
		if(locked)
			if(allowed(user))
				locked = FALSE
				req_access = list()
				to_chat(user, "<span class='notice'>You unlock [src].</span>")
		else if(!(obj_flags & EMAGGED))
			to_chat(user, "<span class='notice'>You lock [src] with [W].</span>")
			var/list/access = W.GetAccess()
			req_access = access
			locked = TRUE
		else
			to_chat(user, "<span class='warning'>You try to lock [src] with [W], but nothing happens.</span>")
	else
		if(!locked && default_deconstruction_screwdriver(user, "scangate_open", "scangate", W))
			return
		if(panel_open && is_wire_tool(W))
			wires.interact(user)
	return ..()

/obj/machinery/scanner_gate/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	locked = FALSE
	req_access = list()
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You fry the ID checking system.</span>")

/obj/machinery/scanner_gate/proc/perform_scan(mob/living/M)
	var/beep = FALSE
	var/color = null
	switch(scangate_mode)
		if(SCANGATE_NONE)
			return
		if(SCANGATE_WANTED)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/perpname = H.get_face_name(H.get_id_name())
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
				if(!R || (R.fields["criminal"] == "*Arrest*"))
					beep = TRUE
		if(SCANGATE_MINDSHIELD)
			if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
				beep = TRUE
		if(SCANGATE_NANITES)
			if(SEND_SIGNAL(M, COMSIG_HAS_NANITES))
				if(nanite_cloud)
					var/datum/component/nanites/nanites = M.GetComponent(/datum/component/nanites)
					if(nanites && nanites.cloud_id == nanite_cloud)
						beep = TRUE
				else
					beep = TRUE
		if(SCANGATE_DISEASE)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(get_disease_severity_value(C.check_virus()) >= get_disease_severity_value(disease_threshold))
					beep = TRUE
		if(SCANGATE_SPECIES)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/species/scan_species = /datum/species/human
				switch(detect_species)
					if(SCANGATE_LIZARD)
						scan_species = /datum/species/lizard
					if(SCANGATE_FLY)
						scan_species = /datum/species/fly
					if(SCANGATE_FELINID)
						scan_species = /datum/species/human/felinid
					if(SCANGATE_PLASMAMAN)
						scan_species = /datum/species/plasmaman
					if(SCANGATE_MOTH)
						scan_species = /datum/species/moth
					if(SCANGATE_JELLY)
						scan_species = /datum/species/jelly
					if(SCANGATE_POD)
						scan_species = /datum/species/pod
					if(SCANGATE_GOLEM)
						scan_species = /datum/species/golem
					if(SCANGATE_ZOMBIE)
						scan_species = /datum/species/zombie
				if(is_species(H, scan_species))
					beep = TRUE
				if(detect_species == SCANGATE_ZOMBIE) //Can detect dormant zombies
					if(H.getorganslot(ORGAN_SLOT_ZOMBIE))
						beep = TRUE
		if(SCANGATE_GUNS)
			for(var/I in M.get_contents())
				if(istype(I, /obj/item/gun))
					beep = TRUE
					break
		if(SCANGATE_NUTRITION)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.nutrition <= detect_nutrition && detect_nutrition == NUTRITION_LEVEL_STARVING)
					beep = TRUE
				if(H.nutrition >= detect_nutrition && detect_nutrition == NUTRITION_LEVEL_FAT)
					beep = TRUE

	if(reverse)
		beep = !beep
	if(beep)
		alarm_beep()
		if(!ignore_signals)
			color = wires.get_color_of_wire(WIRE_ACCEPT)
			var/obj/item/assembly/assembly = wires.get_attached(color)
			assembly?.activate()
	else
		if(!ignore_signals)
			color = wires.get_color_of_wire(WIRE_DENY)
			var/obj/item/assembly/assembly = wires.get_attached(color)
			assembly?.activate()
		set_scanline("scanning", 10)

/obj/machinery/scanner_gate/proc/alarm_beep()
	if(next_beep <= world.time)
		next_beep = world.time + 20
		playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
	var/image/I = image(icon, src, "alarm_light", layer+1)
	flick_overlay_view(I, src, 20)
	set_scanline("alarm", 20)

/obj/machinery/scanner_gate/can_interact(mob/user)
	if(locked)
		return FALSE
	return ..()

/obj/machinery/scanner_gate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ScannerGate", name)
		ui.open()

/obj/machinery/scanner_gate/ui_data()
	var/list/data = list()
	data["locked"] = locked
	data["scan_mode"] = scangate_mode
	data["reverse"] = reverse
	data["nanite_cloud"] = nanite_cloud
	data["disease_threshold"] = disease_threshold
	data["target_species"] = detect_species
	data["target_nutrition"] = detect_nutrition
	return data

/obj/machinery/scanner_gate/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_mode")
			var/new_mode = params["new_mode"]
			scangate_mode = new_mode
			. = TRUE
		if("toggle_reverse")
			reverse = !reverse
			. = TRUE
		if("toggle_lock")
			if(allowed(usr))
				locked = !locked
			. = TRUE
		if("set_disease_threshold")
			var/new_threshold = params["new_threshold"]
			disease_threshold = new_threshold
			. = TRUE
		if("set_nanite_cloud")
			var/new_cloud = text2num(params["new_cloud"])
			nanite_cloud = clamp(round(new_cloud, 1), 1, 100)
			. = TRUE
		//Some species are not scannable, like abductors (too unknown), androids (too artificial) or skeletons (too magic)
		if("set_target_species")
			var/new_species = params["new_species"]
			detect_species = new_species
			. = TRUE
		if("set_target_nutrition")
			var/new_nutrition = params["new_nutrition"]
			var/nutrition_list = list(
				"Starving",
				"Obese"
			)
			if(new_nutrition && (new_nutrition in nutrition_list))
				switch(new_nutrition)
					if("Starving")
						detect_nutrition = NUTRITION_LEVEL_STARVING
					if("Obese")
						detect_nutrition = NUTRITION_LEVEL_FAT
			. = TRUE

#undef SCANGATE_NONE
#undef SCANGATE_MINDSHIELD
#undef SCANGATE_NANITES
#undef SCANGATE_DISEASE
#undef SCANGATE_GUNS
#undef SCANGATE_WANTED
#undef SCANGATE_SPECIES
#undef SCANGATE_NUTRITION

#undef SCANGATE_HUMAN
#undef SCANGATE_LIZARD
#undef SCANGATE_FELINID
#undef SCANGATE_FLY
#undef SCANGATE_PLASMAMAN
#undef SCANGATE_MOTH
#undef SCANGATE_JELLY
#undef SCANGATE_POD
#undef SCANGATE_GOLEM
#undef SCANGATE_ZOMBIE
