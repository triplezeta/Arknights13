/datum/wires/chembomb
	holder_type = /obj/machinery/chembomb
	randomize = TRUE

/datum/wires/chembomb/New(atom/holder)
	wires = list(
		WIRE_BOOM, WIRE_UNBOLT,
		WIRE_ACTIVATE, WIRE_DELAY, WIRE_PROCEED
	)
	..()

/datum/wires/chembomb/interactable(mob/user)
	var/obj/machinery/chembomb/P = holder
	if(P.open_panel)
		return TRUE

/datum/wires/chembomb/on_pulse(wire)
	var/obj/machinery/chembomb/B = holder
	switch(wire)
		if(WIRE_BOOM)
			if(B.active)
				holder.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-!!</span>")
				B.timer = 0
		if(WIRE_UNBOLT)
			holder.visible_message("<span class='notice'>\icon[B] The bolts spin in place for a moment.</span>")
		if(WIRE_DELAY)
			holder.visible_message("<span class='notice'>\icon[B] The bomb chirps.</span>")
			playsound(B, 'sound/machines/chime.ogg', 30, 1)
			B.timer += 10
		if(WIRE_PROCEED)
			holder.visible_message("<span class='danger'>\icon[B] The bomb buzzes ominously!</span>")
			playsound(B, 'sound/machines/buzz-sigh.ogg', 30, 1)
			if(B.timer >= 61) // Long fuse bombs can suddenly become more dangerous if you tinker with them.
				B.timer = 60
			else if(B.timer >= 21)
				B.timer -= 10
			else if(B.timer >= 11) // Both to prevent negative timers and to have a little mercy.
				B.timer = 10
		if(WIRE_ACTIVATE)
			if(!B.active && !B.defused && B.stage == 3)
				holder.visible_message("<span class='danger'>\icon[B] You hear the bomb start ticking!</span>")
				playsound(B, 'sound/machines/click.ogg', 30, 1)
				B.active = TRUE
				B.update_icon()
			else if (B.stage != 3)
				holder.visible_message("<span class='notice'>\icon[B] The bomb doesn't seem to react in any way.</span>")
			else
				holder.visible_message("<span class='notice'>\icon[B] The bomb seems to hesitate for a moment.</span>")
				B.timer += 5

/datum/wires/chembomb/on_cut(wire, mend)
	var/obj/machinery/chembomb/B = holder
	switch(wire)
		if(WIRE_BOOM)
			if(mend)
				B.defused = FALSE // Cutting and mending all the wires of an inactive bomb will thus cure any sabotage.
			else
				if(B.active)
					holder.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
					B.timer = 0
				else
					B.defused = TRUE
		if(WIRE_UNBOLT)
			if(!mend && B.anchored)
				holder.visible_message("<span class='notice'>\icon[B] The bolts lift out of the ground!</span>")
				playsound(B, 'sound/effects/stealthoff.ogg', 30, 1)
				B.anchored = 0
		if(WIRE_PROCEED)
			if(!mend && B.active)
				holder.visible_message("<span class='danger'>\icon[B] An alarm sounds! It's go-</span>")
				B.timer = 0
		if(WIRE_ACTIVATE)
			if(!mend && B.active)
				holder.visible_message("<span class='notice'>\icon[B] The timer stops! The bomb has been defused!</span>")
				B.active = FALSE
				B.defused = TRUE
				B.update_icon()