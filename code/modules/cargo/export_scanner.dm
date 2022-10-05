
/obj/item/export_scanner
	name = "universal scanner"
	desc = "A device used to check objects against Nanotrasen exports database, assign price tags, or ready an item for a custom vending machine."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	/// Which mode is the scanner currently on?
	var/scanning_mode = SCAN_EXPORTS
	/// A list of all available export scanner modes.
	var/list/scale_mode = list()
	/// The paper currently stored by the export scanner.
	var/paper_count = 10
	/// The maximum paper to be stored by the export scanner.
	var/max_paper_count = 20

	/// The price of the item used by price tagger mode.
	var/price = 1

	/// The account which is receiving the split profits in sales tagger mode.
	var/datum/bank_account/payments_acc = null
	/// The person who tagged this will receive the sale value multiplied by this number in sales tagger mode.
	var/cut_multiplier = 0.5
	/// Maximum value for cut_multiplier in sales tagger mode.
	var/cut_max = 0.5
	/// Minimum value for cut_multiplier in sales tagger mode.
	var/cut_min = 0.01

/obj/item/export_scanner/Initialize(mapload)
	. = ..()
	scale_mode = sort_list(list(
		"export_scanner" = image(icon = src.icon, icon_state = "export_scanner"),
		"pricetagger" = image(icon = src.icon, icon_state = "pricetagger"),
		"salestagger" = image(icon = src.icon, icon_state = "salestagger")
		))

/obj/item/export_scanner/attack_self(mob/user, modifiers)
	. = ..()
	var/choice = show_radial_menu(user, src , scale_mode, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	if(icon_state == "[choice]")
		return FALSE
	switch(choice)
		if("export_scanner")
			scanning_mode = SCAN_EXPORTS
		if("pricetagger")
			scanning_mode = SCAN_PRICE_TAG
		if("salestagger")
			scanning_mode = SCAN_SALES_TAG
	icon_state = "[choice]"
	playsound(src, 'sound/machines/click.ogg', 40, TRUE)



/obj/item/export_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return
	if(scanning_mode == SCAN_EXPORTS)
		export_scan(O, user)
		return
	if(scanning_mode == SCAN_PRICE_TAG)
		price_tag(target = O, user = user)

/obj/item/export_scanner/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(scanning_mode == SCAN_SALES_TAG && isidcard(attacking_item))
		var/obj/item/card/id/potential_acc = attacking_item
		if(potential_acc.registered_account)
			if(payments_acc == potential_acc.registered_account)
				to_chat(user, span_notice("ID card already registered."))
				return
			else
				payments_acc = potential_acc.registered_account
				playsound(src, 'sound/machines/ping.ogg', 40, TRUE)
				to_chat(user, span_notice("[src] registers the ID card. Tag a wrapped item to create a barcode."))
		else if(!potential_acc.registered_account)
			to_chat(user, span_warning("This ID card has no account registered!"))
			return
	if(istype(attacking_item, /obj/item/paper))
		if (!(paper_count >= max_paper_count))
			paper_count += 10
			qdel(attacking_item)
			if (paper_count >= max_paper_count)
				paper_count = max_paper_count
				to_chat(user, span_notice("[src]'s paper supply is now full."))
				return
			to_chat(user, span_notice("You refill [src]'s paper supply, you have [paper_count] left."))
		else
			to_chat(user, span_notice("[src]'s paper supply is full."))

/obj/item/export_scanner/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(paper_count <= 0)
		to_chat(user, span_warning("You're out of paper!'."))
		return
	if(!payments_acc)
		to_chat(user, span_warning("You need to swipe [src] with an ID card first."))
		return
	paper_count -= 1
	playsound(src, 'sound/machines/click.ogg', 40, TRUE)
	to_chat(user, span_notice("You print a new barcode."))
	var/obj/item/barcode/new_barcode = new /obj/item/barcode(src)
	new_barcode.payments_acc = payments_acc		// The sticker gets the scanner's registered account.
	new_barcode.cut_multiplier = cut_multiplier		// Also the registered percent cut.
	user.put_in_hands(new_barcode)

/obj/item/export_scanner/CtrlClick(mob/user)
	. = ..()
	if(scanning_mode == SCAN_SALES_TAG)
		payments_acc = null
		to_chat(user, span_notice("You clear the registered account."))

/obj/item/export_scanner/AltClick(mob/user)
	. = ..()
	if(scanning_mode == SCAN_SALES_TAG)
		var/potential_cut = input("How much would you like to pay out to the registered card?","Percentage Profit ([round(cut_min*100)]% - [round(cut_max*100)]%)") as num|null
		if(!potential_cut)
			cut_multiplier = initial(cut_multiplier)
		cut_multiplier = clamp(round(potential_cut/100, cut_min), cut_min, cut_max)
		to_chat(user, span_notice("[round(cut_multiplier*100)]% profit will be received if a package with a barcode is sold."))

/obj/item/export_scanner/examine(mob/user)
	. = ..()
	. += span_notice("[src] has [paper_count]/[max_paper_count] available barcodes. Refill with paper.")

	if(scanning_mode == SCAN_SALES_TAG)
		. += span_notice("Profit split on sale is currently set to [round(cut_multiplier*100)]%. <b>Alt-click</b> to change.")
		if(payments_acc)
			. += span_notice("<b>Ctrl-click</b> to clear the registered account.")

	if(scanning_mode == SCAN_PRICE_TAG)
		. += span_notice("The current custom price is set to [price] cr.")

/obj/item/export_scanner/proc/export_scan(obj/O, mob/user)
	// Before you fix it:
	// yes, checking manifests is a part of intended functionality.
	var/datum/export_report/ex = export_item_and_contents(O, dry_run = TRUE)
	var/price = 0
	for(var/x in ex.total_amount)
		price += ex.total_value[x]
	if(price)
		to_chat(user, span_notice("Scanned [O], value: <b>[price]</b> credits[O.contents.len ? " (contents included)" : ""]."))
	else
		to_chat(user, span_warning("Scanned [O], no export value."))

	if(ishuman(user))
		var/mob/living/carbon/human/scan_human = user
		if(istype(O, /obj/item/bounty_cube))
			var/obj/item/bounty_cube/cube = O
			var/datum/bank_account/scanner_account = scan_human.get_bank_account()

			if(!istype(get_area(cube), /area/shuttle/supply))
				to_chat(user, span_warning("Shuttle placement not detected. Handling tip not registered."))

			else if(cube.bounty_handler_account)
				to_chat(user, span_warning("Bank account for handling tip already registered!"))

			else if(scanner_account)
				cube.AddComponent(/datum/component/pricetag, scanner_account, cube.handler_tip, FALSE)

				cube.bounty_handler_account = scanner_account
				cube.bounty_handler_account.bank_card_talk("Bank account for [price ? "<b>[price * cube.handler_tip]</b> credit " : ""]handling tip successfully registered.")

				if(cube.bounty_holder_account != cube.bounty_handler_account) //No need to send a tracking update to the person scanning it
					cube.bounty_holder_account.bank_card_talk("<b>[cube]</b> was scanned in \the <b>[get_area(cube)]</b> by <b>[scan_human] ([scan_human.job])</b>.")

			else
				to_chat(user, span_warning("Bank account not detected. Handling tip not registered."))

/obj/item/export_scanner/proc/price_tag(obj/target, mob/user)
	if(isitem(target))
		var/obj/item/I = target
		I.custom_price = price
		to_chat(user, span_notice("You set the price of [I] to [price] cr."))

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/item/export_scanner/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE
