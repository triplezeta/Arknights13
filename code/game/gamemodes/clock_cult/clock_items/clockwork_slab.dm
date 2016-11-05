/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between the Celestial Derelict and the mortal plane. Contains limitless knowledge, fabricates components, and outputs a stream of information that only a trained eye can detect."
	icon_state = "dread_ipad"
	slot_flags = SLOT_BELT
	w_class = 2
	var/list/stored_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GUVAX_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0)
	var/busy //If the slab is currently being used by something
	var/production_time = 0
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks
	var/nonhuman_usable = FALSE //if the slab can be used by nonhumans, defaults to off
	var/produces_components = TRUE //if it produces components at all
	var/list/shown_scripture = list(SCRIPTURE_DRIVER = FALSE, SCRIPTURE_SCRIPT = FALSE, SCRIPTURE_APPLICATION = FALSE, SCRIPTURE_REVENANT = FALSE, SCRIPTURE_JUDGEMENT = FALSE)
	var/text_hidden = FALSE
	var/compact_scripture = FALSE
	var/obj/effect/proc_holder/slab/slab_ability //the slab's current bound ability, for certain scripture
	var/datum/clockwork_scripture/quickbind_slot_one //these are paths, not instances
	var/datum/clockwork_scripture/quickbind_slot_two //accordingly, use initial() for non-list vars
	actions_types = list(/datum/action/item_action/clock/hierophant, /datum/action/item_action/clock/quickbind_one, /datum/action/item_action/clock/quickbind_two)

/obj/item/clockwork/slab/starter
	stored_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 1, GUVAX_CAPACITOR = 1, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)

/obj/item/clockwork/slab/internal //an internal motor for mobs running scripture
	name = "scripture motor"
	no_cost = TRUE
	produces_components = FALSE

/obj/item/clockwork/slab/scarab
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug
	no_cost = TRUE
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	..()
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)

/obj/item/clockwork/slab/New()
	..()
	quickbind_to_one(/datum/clockwork_scripture/ranged_ability/guvax_prep)
	quickbind_to_two(/datum/clockwork_scripture/vanguard)
	START_PROCESSING(SSobj, src)
	production_time = world.time + SLAB_PRODUCTION_TIME

/obj/item/clockwork/slab/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(slab_ability && slab_ability.ranged_ability_user)
		slab_ability.remove_ranged_ability()
	return ..()

/obj/item/clockwork/slab/dropped(mob/user)
	. = ..()
	addtimer(src, "check_on_mob", 1, FALSE, user) //dropped is called before the item is out of the slot, so we need to check slightly later

/obj/item/clockwork/slab/proc/check_on_mob(mob/user)
	if(user && !(src in user.held_items) && slab_ability && slab_ability.ranged_ability_user) //if we happen to check and we AREN'T in user's hands, remove whatever ability we have
		slab_ability.remove_ranged_ability()

//Component Generation
/obj/item/clockwork/slab/process()
	if(!produces_components)
		STOP_PROCESSING(SSobj, src)
		return
	if(production_time > world.time)
		return
	var/servants = 0
	var/production_slowdown = 0
	for(var/mob/living/M in living_mob_list)
		if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
			servants++
	if(servants > 5)
		servants -= 5
		production_slowdown = min(SLAB_SERVANT_SLOWDOWN * servants, SLAB_SLOWDOWN_MAXIMUM) //SLAB_SERVANT_SLOWDOWN additional seconds for each servant above 5, up to SLAB_SLOWDOWN_MAXIMUM
	production_time = world.time + SLAB_PRODUCTION_TIME + production_slowdown
	var/mob/living/L
	if(isliving(loc))
		L = loc
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/W = loc
		if(isliving(W.loc)) //Only goes one level down - otherwise it won't produce components
			L = W.loc
	if(L)
		var/component_to_generate = get_weighted_component_id(src) //more likely to generate components that we have less of
		stored_components[component_to_generate]++
		for(var/obj/item/clockwork/slab/S in L.GetAllContents()) //prevent slab abuse today
			if(L == src)
				continue
			S.production_time = world.time + SLAB_PRODUCTION_TIME
		L << "<span class='warning'>Your slab clunks as it produces a new component.</span>"

/obj/item/clockwork/slab/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "Use the <span class='brass'>Hierophant Network</span> action button to communicate with other servants."
		user << "Clockwork slabs will only generate components if held by a human or if inside a storage item held by a human, and when generating a component will prevent all other slabs held from generating components.<br>"
		user << "Attacking a slab, a fellow Servant with a slab, or a cache with this slab will transfer this slab's components into that slab's components, their slab's components, or the global cache, respectively."
		if(quickbind_slot_one)
			user << "Quickbind slot One bound to: <span class='[get_component_span(initial(quickbind_slot_one.primary_component))]'>[initial(quickbind_slot_one.name)]</span>"
		if(quickbind_slot_two)
			user << "Quickbind slot Two bound to: <span class='[get_component_span(initial(quickbind_slot_two.primary_component))]'>[initial(quickbind_slot_two.name)]</span>"
		if(clockwork_caches)
			user << "<b>Stored components (with global cache):</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[stored_components[i]]</b> \
				(<b>[stored_components[i] + clockwork_component_cache[i]]</b>)</span>"
		else
			user << "<b>Stored components:</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[stored_components[i]]</b></span>"

//Component Transferal
/obj/item/clockwork/slab/attack(mob/living/target, mob/living/carbon/human/user)
	if(is_servant_of_ratvar(user) && is_servant_of_ratvar(target))
		var/obj/item/clockwork/slab/targetslab
		var/highest_component_amount = 0
		for(var/obj/item/clockwork/slab/S in target.GetAllContents())
			if(!istype(S, /obj/item/clockwork/slab/internal))
				var/totalcomponents = 0
				for(var/i in S.stored_components)
					totalcomponents += S.stored_components[i]
				if(!targetslab || totalcomponents > highest_component_amount)
					highest_component_amount = totalcomponents
					targetslab = S
		if(targetslab)
			if(targetslab == src)
				user << "<span class='heavy_brass'>\"You can't transfer components into your own slab, idiot.\"</span>"
			else
				for(var/i in stored_components)
					targetslab.stored_components[i] += stored_components[i]
					stored_components[i] = 0
				user.visible_message("<span class='notice'>[user] empties [src] into [target]'s [targetslab.name].</span>", \
				"<span class='notice'>You transfer your slab's components into [target]'s [targetslab.name].</span>")
		else
			user << "<span class='warning'>[target] has no slabs to transfer components to.</span>"
	else
		return ..()

/obj/item/clockwork/slab/attackby(obj/item/I, mob/user, params)
	var/ratvarian = is_servant_of_ratvar(user)
	if(istype(I, /obj/item/clockwork/component) && ratvarian)
		var/obj/item/clockwork/component/C = I
		if(!C.component_id)
			return 0
		user.visible_message("<span class='notice'>[user] inserts [C] into [src].</span>", "<span class='notice'>You insert [C] into [src], where it is added to the global cache.</span>")
		clockwork_component_cache[C.component_id]++
		user.drop_item()
		qdel(C)
		return 1
	else if(istype(I, /obj/item/clockwork/slab) && ratvarian)
		var/obj/item/clockwork/slab/S = I
		for(var/i in stored_components)
			stored_components[i] += S.stored_components[i]
			S.stored_components[i] = 0
		user.visible_message("<span class='notice'>[user] empties [src] into [S].</span>", "<span class='notice'>You transfer your slab's components into [S].</span>")
	else
		return ..()

//Slab actions; Hierophant, Guvax, Vanguard
/obj/item/clockwork/slab/ui_action_click(mob/user, actiontype)
	switch(actiontype)
		if(/datum/action/item_action/clock/hierophant)
			show_hierophant(user)
		if(/datum/action/item_action/clock/quickbind_one)
			recite_scripture(quickbind_slot_one, user, FALSE)
		if(/datum/action/item_action/clock/quickbind_two)
			recite_scripture(quickbind_slot_two, user, FALSE)

/obj/item/clockwork/slab/proc/show_hierophant(mob/living/user)
	var/message = stripped_input(user, "Enter a message to send to your fellow servants.", "Hierophant")
	if(!message || !user || !user.canUseTopic(src))
		return 0
	clockwork_say(user, text2ratvar("Servants, hear my words. [html_decode(message)]"), TRUE)
	titled_hierophant_message(user, message)
	return 1

//Scripture Recital
/obj/item/clockwork/slab/attack_self(mob/living/user)
	if(iscultist(user))
		user << "<span class='heavy_brass'>\"You reek of blood. You've got a lot of nerve to even look at that slab.\"</span>"
		user.visible_message("<span class='warning'>A sizzling sound comes from [user]'s hands!</span>", "<span class='userdanger'>[src] suddenly grows extremely hot in your hands!</span>")
		playsound(get_turf(user), 'sound/weapons/sear.ogg', 50, 1)
		user.drop_item()
		user.emote("scream")
		user.apply_damage(5, BURN, "l_arm")
		user.apply_damage(5, BURN, "r_arm")
		return 0
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>The information on [src]'s display shifts rapidly. After a moment, your head begins to pound, and you tear your eyes away.</span>"
		user.confused += 5
		user.dizziness += 5
		return 0
	if(busy)
		user << "<span class='warning'>[src] refuses to work, displaying the message: \"[busy]!\"</span>"
		return 0
	if(!nonhuman_usable && !ishuman(user))
		user << "<span class='nezbere'>[src] hums fitfully in your hands, but doesn't seem to do anything...</span>"
		return 0
	access_display(user)

/obj/item/clockwork/slab/proc/access_display(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return 0
	var/action = alert(user, "Among the swathes of information, you see...", "[src]", "Recital", "Recollection", "Cancel")
	if(!action || !user.canUseTopic(src))
		return 0
	switch(action)
		if("Recital")
			try_recite_scripture(user)
		if("Recollection")
			user.set_machine(src)
			interact(user)
		if("Cancel")
			return
	return 1

/obj/item/clockwork/slab/proc/try_recite_scripture(mob/living/user)
	var/list/tiers_of_scripture = scripture_unlock_check()
	for(var/i in tiers_of_scripture)
		if(!tiers_of_scripture[i] && !ratvar_awakens && !no_cost)
			tiers_of_scripture["[i] \[LOCKED\]"] = TRUE
			tiers_of_scripture -= i
	var/scripture_tier = input(user, "Choose a category of scripture to recite.", "[src]") as null|anything in tiers_of_scripture
	if(!scripture_tier || !user.canUseTopic(src))
		return FALSE
	var/list/available_scriptures = list()
	switch(scripture_tier)
		if(SCRIPTURE_DRIVER,SCRIPTURE_SCRIPT,SCRIPTURE_APPLICATION,SCRIPTURE_REVENANT,SCRIPTURE_JUDGEMENT); //; for the empty if
		else
			user << "<span class='warning'>That section of scripture is still locked!</span>"
			return FALSE
	for(var/S in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
		var/datum/clockwork_scripture/C = S
		if(initial(C.tier) == scripture_tier)
			available_scriptures["[initial(C.name)] ([initial(C.descname)])"] = C
	if(!available_scriptures.len)
		return FALSE
	var/chosen_scripture_key = input(user, "Choose a piece of scripture to recite.", "[src]") as null|anything in available_scriptures
	var/datum/clockwork_scripture/chosen_scripture = available_scriptures[chosen_scripture_key]
	return recite_scripture(chosen_scripture, user, TRUE)

/obj/item/clockwork/slab/proc/recite_scripture(datum/clockwork_scripture/scripture, mob/living/user, delayed)
	if(!scripture || !user || !user.canUseTopic(src) || (!nonhuman_usable && !ishuman(user)))
		return FALSE
	if(user.get_active_held_item() != src)
		user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"
		return FALSE
	var/list/tiers_of_scripture = scripture_unlock_check()
	if(!ratvar_awakens && !no_cost && !tiers_of_scripture[initial(scripture.tier)])
		user << "<span class='warning'>That scripture is no[delayed ? " longer":"t"] unlocked, and cannot be recited!</span>"
		return FALSE
	var/datum/clockwork_scripture/scripture_to_recite = new scripture
	scripture_to_recite.slab = src
	scripture_to_recite.invoker = user
	scripture_to_recite.run_scripture()
	return TRUE

//Guide to Serving Ratvar
/obj/item/clockwork/slab/interact(mob/living/user)
	var/text = "If you're seeing this, file a bug report."
	if(ratvar_awakens)
		text = "<font color=#BE8700 size=3><b>"
		for(var/i in 1 to 100)
			text += "HONOR RATVAR "
		text += "</b></font>"
	else

		text = "<font color=#BE8700 size=3><b><center>Chetr nyy hagehguf-naq-ubabe Ratvar.</center></b></font><br>\
		\
		<center><font size=1><A href='?src=\ref[src];hidetext=1'>[text_hidden ? "Show":"Hide"] Information</A></font></center><br>"
		if(!text_hidden)
			var/servants = 0
			var/production_time = SLAB_PRODUCTION_TIME
			for(var/mob/living/M in living_mob_list)
				if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
					servants++
			if(servants > 5)
				servants -= 5
				production_time += min(SLAB_SERVANT_SLOWDOWN * servants, SLAB_SLOWDOWN_MAXIMUM)
			var/production_text_addon = ""
			if(production_time != SLAB_PRODUCTION_TIME+SLAB_SLOWDOWN_MAXIMUM)
				production_text_addon = ", which increases for each human or silicon servant above <b>5</b>"
			production_time = production_time/600
			var/production_text = "<b>[round(production_time)] minute\s"
			if(production_time != round(production_time))
				production_time -= round(production_time)
				production_time *= 60
				production_text += " and [round(production_time, 1)] second\s"
			production_text += "</b>"
			production_text += production_text_addon

			text += "First and foremost, you serve Ratvar, the Clockwork Justicar, in any ways he sees fit. This is with no regard to your personal well-being, and you would do well to think of the larger \
			scale of things than your life. Ratvar wishes retribution upon those that trapped him in Reebe - the Nar-Sian cultists - and you are to help him obtain it.<br><br>\
			\
			Ratvar, being trapped in Reebe, the Celestial Derelict, cannot directly affect the mortal plane. However, links, such as this Clockwork Slab, can be created to draw \
			<b><font color=#BE8700>Components</font></b>, fragments of the Justicar, from Reebe, and those Components can be used to draw power and material from Reebe through arcane chants \
			known as <b><font color=#BE8700>Scripture</font></b>.<br><br>\
			\
			One component of a random type is produced in this slab every [production_text].<br>\
			<font color=#BE8700>Components</font> are stored either within slabs, where they can only be accessed by that slab, or in the Global Cache accessed by Tinkerer's Caches, which all slabs \
			can draw from to recite scripture.<br>\
			There are five types of component, and in general, <font color=#6E001A>Belligerent Eyes</font> are aggressive and judgemental, <font color=#1E8CE1>Vanguard Cogwheels</font> are defensive and \
			repairing, <font color=#AF0AAF>Guvax Capacitors</font> are for conversion and control, <font color=#5A6068>Replicant Alloy</font> is for construction and fuel, and \
			<font color=#DAAA18>Hierophant Ansibles</font> are for transmission and power, though in combination their effects become more nuanced.<br><br>\
			\
			There are also five tiers of <font color=#BE8700>Scripture</font>; <font color=#BE8700>[SCRIPTURE_DRIVER]</font>, <font color=#BE8700>[SCRIPTURE_SCRIPT]</font>, <font color=#BE8700>[SCRIPTURE_APPLICATION]</font>, <font color=#BE8700>[SCRIPTURE_REVENANT]</font>, and <font color=#BE8700>[SCRIPTURE_JUDGEMENT]</font>.<br>\
			Each tier has additional requirements, including Servants, Tinkerer's Caches, and <b>Construction Value</b>(<b>CV</b>). Construction Value is gained by creating structures or converting the \
			station, and everything too large to hold will grant some amount of it.<br><br>\
			\
			This would be a massive amount of information to try and keep track of, but all Servants have the <b><font color=#BE8700>Global Records</font></b> alert, which appears in the top right.<br>\
			Mousing over that alert will display Servants, Caches, CV, and other information, such as the tiers of scripture that are unlocked.<br><br>\
			\
			On that note, <font color=#BE8700>Scripture</font> is recited through <b><font color=#BE8700>Recital</font></b>, the first and most important function of the slab.<br>\
			All scripture requires some amount of <font color=#BE8700>Components</font> to recite, and only the weakest scripture does not consume any components when recited.<br>\
			However, weak is relative when it comes to scripture; even the 'weakest' could be enough to dominate a station in the hands of cunning Servants, and higher tiers of scripture are even \
			stronger in the right hands.<br><br>\
			\
			Some effects of scripture include granting the invoker a temporary complete immunity to stuns, summoning a turret that can attack anything that sets eyes on it, binding a powerful guardian \
			to the invoker, or even, at one of the highest tiers, granting all nearby Servants temporary invulnerability.<br>\
			However, the most important scripture is <font color=#AF0AAF>Guvax</font>, which allows you to convert heathens with relative ease.<br><br>\
			\
			The second function of the clockwork slab is <b><font color=#BE8700>Recollection</font></b>, which will display this guide and allows for the quickbinding of scripture.<br><br>\
			\
			The third to fifth functions are three buttons in the top left while holding the slab.<br>From left to right, they are:<br>\
			<b><font color=#DAAA18>Hierophant Network</font></b>, which allows communication to other Servants.<br>\
			<b>Quickbind slot One, currently set to <font color=[get_component_color_brightalloy(initial(quickbind_slot_one.primary_component))]>[initial(quickbind_slot_one.name)]</font></b>.<br>\
			<b>Quickbind slot Two, currently set to <font color=[get_component_color_brightalloy(initial(quickbind_slot_two.primary_component))]>[initial(quickbind_slot_two.name)]</font></b>.<br><br>\
			\
			Examine the slab to check the number of components it has available.<br><br>\
			\
			<center><font size=1><A href='?src=\ref[src];hidetext=1'>Hide Above Information</A></font></center><br>"

		text += "A complete list of scripture, its effects, and its requirements can be found, and thus <b>Quickbound</b> to this slab, below.<br>\
		Key:<br>"
		for(var/i in clockwork_component_cache)
			text += "<font color=[get_component_color_brightalloy(i)]>[get_component_acronym(i)]</font> = [get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]<br>"
		text += "<br><center><font size=1><A href='?src=\ref[src];compactscripture=1'>Compact Scripture Text: [compact_scripture ? "ON":"OFF"]</A></font></center><br>"
		var/text_to_add = ""
		var/drivers = "<br><font size=3><b><A href='?src=\ref[src];Driver=1'>[SCRIPTURE_DRIVER]</A></b></font><br><i>These scriptures are always unlocked.</i><br>"
		var/scripts = "<br><font size=3><b><A href='?src=\ref[src];Script=1'>[SCRIPTURE_SCRIPT]</A></b></font><br><i>These scriptures require at least <b>5</b> Servants and \
		<b>1</b> Tinkerer's Cache.</i><br>"
		var/applications = "<br><font size=3><b><A href='?src=\ref[src];Application=1'>[SCRIPTURE_APPLICATION]</A></b></font><br><i>These scriptures require at least <b>8</b> Servants, \
		<b>3</b> Tinkerer's Caches, and <b>100CV</b>.</i><br>"
		var/revenant = "<br><font size=3><b><A href='?src=\ref[src];Revenant=1'>[SCRIPTURE_REVENANT]</A></b></font><br><i>These scriptures require at least <b>10</b> Servants, \
		<b>4</b> Tinkerer's Caches, and <b>200CV</b>.</i><br>"
		var/judgement = "<br><font size=3><b><A href='?src=\ref[src];Judgement=1'>[SCRIPTURE_JUDGEMENT]</A></b></font><br><i>This scripture requires at least <b>12</b> Servants, \
		<b>5</b> Tinkerer's Caches, and <b>300CV</b>.<br>In addition, there may not be any active non-Servant AIs.</i><br>"
		for(var/V in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
			var/datum/clockwork_scripture/S = V
			var/initial_tier = initial(S.tier)
			if(initial_tier != SCRIPTURE_PERIPHERAL && shown_scripture[initial_tier])
				var/datum/clockwork_scripture/S2 = new V
				var/list/req_comps = S2.required_components
				var/list/cons_comps = S2.consumed_components
				qdel(S2)
				var/scripture_text = "<br><b><font color=[get_component_color_brightalloy(initial(S.primary_component))]>[initial(S.name)]</font>:</b>"
				if(!compact_scripture)
					scripture_text += "<br>[initial(S.desc)]<br><b>Invocation Time:</b> <b>[initial(S.channel_time) / 10]</b> second\s\
					[initial(S.invokers_required) > 1 ? "<br><b>Invokers Required:</b> <b>[initial(S.invokers_required)]</b>":""]\
					<br><b>Component Requirement:</b>"
				for(var/i in req_comps)
					if(req_comps[i])
						scripture_text += " <font color=[get_component_color_brightalloy(i)]><b>[req_comps[i]]</b> [get_component_acronym(i)]</font>"
				if(!compact_scripture)
					for(var/a in cons_comps)
						if(cons_comps[a])
							scripture_text += "<br><b>Component Cost:</b>"
							for(var/i in cons_comps)
								if(cons_comps[i])
									scripture_text += " <font color=[get_component_color_brightalloy(i)]><b>[cons_comps[i]]</b> [get_component_acronym(i)]</font>"
							break //we want this to only show up if the scripture has a cost of some sort
					scripture_text += "<br><b>Tip:</b> [initial(S.usage_tip)]"
				if(initial(S.quickbind))
					scripture_text += "<br><b><font color=#BE8700 size=1>[S == quickbind_slot_one || S == quickbind_slot_two ? "Currently Quickbound":\
					"<A href='?src=\ref[src];Quickbindone=[S]'>Quickbind to slot one</A>| <A href='?src=\ref[src];Quickbindtwo=[S]'>Quickbind to slot two</A>"]</font></b>"
				scripture_text += "<br><b><A href='?src=\ref[src];Recite=[S]'>Recite</A></b><br>"
				switch(initial_tier)
					if(SCRIPTURE_DRIVER)
						drivers += scripture_text
					if(SCRIPTURE_SCRIPT)
						scripts += scripture_text
					if(SCRIPTURE_APPLICATION)
						applications += scripture_text
					if(SCRIPTURE_REVENANT)
						revenant += scripture_text
					if(SCRIPTURE_JUDGEMENT)
						judgement += scripture_text
		text_to_add += "[drivers]<br>[scripts]<br>[applications]<br>[revenant]<br>[judgement]<br>"
		text_to_add += "<font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
		text += text_to_add
	var/datum/browser/popup = new(user, "slab", "", 600, 500)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/clockwork/slab/Topic(href, href_list)
	. = ..()
	if(.)
		return .

	if(!usr || !src || !(src in usr) || usr.incapacitated())
		if(usr && usr.machine == src)
			usr.unset_machine()
		return 0

	if(href_list["Recite"])
		addtimer(src, "recite_scripture", 0, FALSE, href_list["Recite"], usr, FALSE)

	if(href_list["Quickbindone"])
		quickbind_to_one(href_list["Quickbindone"])

	if(href_list["Quickbindtwo"])
		quickbind_to_two(href_list["Quickbindtwo"])

	if(href_list["hidetext"])
		text_hidden = !text_hidden

	if(href_list["compactscripture"])
		compact_scripture = !compact_scripture

	for(var/i in shown_scripture)
		if(href_list[i])
			shown_scripture[i] = !shown_scripture[i]

	interact(usr)

/obj/item/clockwork/slab/proc/quickbind_to_one(datum/clockwork_scripture/scripture) //takes a typepath(typecast for initial()) and binds it to slot 1
	if(!ispath(scripture) && istext(scripture))
		scripture = text2path(scripture) //if given as a href, the scripture will be a string and not a path. obviously, we need a path and not a string
	if(!scripture || quickbind_slot_two == scripture)
		return
	quickbind_slot_one = scripture
	for(var/datum/action/item_action/clock/quickbind_one/O in actions)
		O.name = initial(quickbind_slot_one.name)
		O.desc = initial(quickbind_slot_one.quickbind_desc)
		O.button_icon_state = initial(quickbind_slot_one.name)
		O.UpdateButtonIcon()

/obj/item/clockwork/slab/proc/quickbind_to_two(datum/clockwork_scripture/scripture) //takes a typepath(typecast for initial()) and binds it to slot 2
	if(!ispath(scripture) && istext(scripture))
		scripture = text2path(scripture) //if given as a href, the scripture will be a string and not a path. obviously, we need a path and not a string
	if(!scripture || quickbind_slot_one == scripture)
		return
	quickbind_slot_two = scripture
	for(var/datum/action/item_action/clock/quickbind_two/O in actions)
		O.name = initial(quickbind_slot_two.name)
		O.desc = initial(quickbind_slot_two.quickbind_desc)
		O.button_icon_state = initial(quickbind_slot_two.name)
		O.UpdateButtonIcon()
