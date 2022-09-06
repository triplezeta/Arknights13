//Canister Frames
/obj/structure/canister_frame
	name = "canister frame"
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "frame_0"
	density = TRUE

/obj/structure/canister_frame/examine(user)
	. = ..()

/obj/structure/canister_frame/machine
	name = "canister frame"
	desc = "A frame used to build different kinds of canisters."

	/// The previous canister frame tier path
	var/obj/structure/canister_frame/machine/prev_tier
	/// The next canister frame tier path
	var/obj/structure/canister_frame/machine/next_tier
	/// The required item for going to next tier. Must be set if next_tier is set.
	var/obj/item/stack/next_tier_reqitem
	/// The amount of items required in the stack of the required item. Must be set if next_tier is set.
	var/next_tier_reqitem_am
	/// The finished usable canister path
	var/atom/finished_obj

/obj/structure/canister_frame/machine/deconstruct(disassembled = TRUE)
	if (!(atom_flags & NODECONSTRUCT))
		// Spawn 5 sheets for the tier 0 frame
		new /obj/item/stack/sheet/iron(loc, 5)

		// Loop backwards in the tiers and spawn the requirement for each tier
		var/obj/structure/canister_frame/machine/i_prev = prev_tier
		while(ispath(i_prev))
			var/obj/item/stack/prev_tier_reqitem = initial(i_prev.next_tier_reqitem)
			var/prev_tier_reqitem_am = initial(i_prev.next_tier_reqitem_am)
			new prev_tier_reqitem(loc, prev_tier_reqitem_am)
			i_prev = initial(i_prev.prev_tier)
	qdel(src)

/obj/structure/canister_frame/machine/unfinished_canister_frame
	name = "unfinished canister frame"
	icon_state = "frame_0"

	next_tier = /obj/structure/canister_frame/machine/finished_canister_frame
	next_tier_reqitem = /obj/item/stack/sheet/iron
	next_tier_reqitem_am = 5

/obj/structure/canister_frame/machine/finished_canister_frame
	name = "finished canister frame"
	icon_state = "frame_1"

	prev_tier = /obj/structure/canister_frame/machine/unfinished_canister_frame
	finished_obj = /obj/machinery/portable_atmospherics/canister

/obj/structure/canister_frame/machine/examine(user)
	. = ..()
	. += span_notice("It can be dismantled by removing the <b>bolts</b>.")

	if(ispath(next_tier))
		var/item_name = initial(next_tier_reqitem.singular_name)
		if(!item_name)
			item_name = initial(next_tier_reqitem.name)
		if(next_tier_reqitem_am > 1)
			. += span_notice("It can be improved using [next_tier_reqitem_am] [item_name]\s.")
		else
			. += span_notice("It can be improved using \a [item_name].")

	if(ispath(finished_obj))
		. += span_notice("It can be finished off by <b>screwing</b> it together.")

/obj/structure/canister_frame/machine/attackby(obj/item/S, mob/user, params)
	if (ispath(next_tier) && istype(S, next_tier_reqitem))
		var/obj/item/stack/ST = S
		var/reqitem_name = ST.singular_name ? ST.singular_name : ST.name
		to_chat(user, span_notice("You start adding [next_tier_reqitem_am] [reqitem_name]\s to the frame..."))
		if (ST.use_tool(src, user, 2 SECONDS, amount=next_tier_reqitem_am, volume=50))
			to_chat(user, span_notice("You added [next_tier_reqitem_am] [reqitem_name]\s to the frame, turning it into \a [initial(next_tier.name)]."))
			new next_tier(drop_location())
			qdel(src)
		return
	return ..()

/obj/structure/canister_frame/machine/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(ispath(finished_obj))
		to_chat(user, span_notice("You start tightening the screws on \the [src]."))
		if (I.use_tool(src, user, 2 SECONDS, volume=50))
			to_chat(user, span_notice("You tighten the last screws on \the [src]."))
			new finished_obj(drop_location())
			qdel(src)
		return
	return FALSE

/obj/structure/canister_frame/machine/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	to_chat(user, span_notice("You start to dismantle \the [src]..."))
	if (I.use_tool(src, user, 2 SECONDS, volume=50))
		to_chat(user, span_notice("You dismantle \the [src]."))
		deconstruct()
