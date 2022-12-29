#define COUPON_OMEN "omen"

/obj/item/coupon
	name = "coupon"
	desc = "It doesn't matter if you didn't want it before, what matters now is that you've got a coupon for it!"
	icon_state = "data_1"
	icon = 'icons/obj/card.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	var/datum/supply_pack/discounted_pack
	var/discount_pct_off = 0.05
	var/obj/machinery/computer/cargo/inserted_console

/// Choose what our prize is :D
/obj/item/coupon/proc/generate(rig_omen=FALSE)
	discounted_pack = pick(subtypesof(/datum/supply_pack/goody))
	var/list/chances = list("0.10" = 4, "0.15" = 8, "0.20" = 10, "0.25" = 8, "0.50" = 4, COUPON_OMEN = 1)

	if(rig_omen)
		discount_pct_off = COUPON_OMEN
	else
		discount_pct_off = pick_weight(chances)

	if(discount_pct_off != COUPON_OMEN)
		discount_pct_off = text2num(discount_pct_off)
		name = "coupon - [round(discount_pct_off * 100)]% off [initial(discounted_pack.name)]"
		return

	name = "coupon - fuck you"
	desc = "The small text reads, 'You will be slaughtered'... That doesn't sound right, does it?"
	if(!ismob(loc))
		return FALSE

	var/mob/cursed = loc
	to_chat(cursed, span_warning("The coupon reads '<b>fuck you</b>' in large, bold text... is- is that a prize, or?"))

	if(!cursed.GetComponent(/datum/component/omen))
		cursed.AddComponent(/datum/component/omen, silent = TRUE)
		return TRUE
	if(HAS_TRAIT(cursed, TRAIT_UNFORTUNATE))
		to_chat(cursed, span_warning("What a horrible night... To have a curse!"))
	addtimer(CALLBACK(src, PROC_REF(curse_heart), cursed), 5 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

/// Play stupid games, win stupid prizes
/obj/item/coupon/proc/curse_heart(mob/living/cursed)
	if(!iscarbon(cursed))
		cursed.gib()
		return TRUE

	var/mob/living/carbon/player = cursed
	INVOKE_ASYNC(player, TYPE_PROC_REF(/mob, emote), "scream")
	to_chat(player, span_mind_control("What could that coupon mean?"))
	to_chat(player, span_userdanger("...The suspense is killing you!"))
	player.set_heartattack(status = TRUE)

/obj/item/coupon/attack_atom(obj/O, mob/living/user, params)
	if(!istype(O, /obj/machinery/computer/cargo))
		return ..()
	if(discount_pct_off == COUPON_OMEN)
		to_chat(user, span_warning("\The [O] validates the coupon as authentic, but refuses to accept it..."))
		O.say("Coupon fulfillment already in progress...")
		return

	inserted_console = O
	LAZYADD(inserted_console.loaded_coupons, src)
	inserted_console.say("Coupon for [initial(discounted_pack.name)] applied!")
	forceMove(inserted_console)

/obj/item/coupon/Destroy()
	if(inserted_console)
		LAZYREMOVE(inserted_console.loaded_coupons, src)
		inserted_console = null
	. = ..()

#undef COUPON_OMEN
