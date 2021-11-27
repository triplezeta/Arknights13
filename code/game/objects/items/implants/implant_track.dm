/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	activated = FALSE
	///for how many seconds after user death will the implant work?
	var/lifespan_postmortem = 600 SECONDS
	///will people implanted with this act as teleporter beacons?
	var/allow_teleport = TRUE
	///The id of the timer that's qdeleting us
	var/timerid

/obj/item/implant/tracking/c38
	name = "TRAC implant"
	desc = "A smaller tracking implant that supplies power for only a few minutes."
	allow_teleport = FALSE
	var/lifespan = 300 SECONDS //how many seconds does the implant last?

/obj/item/implant/tracking/c38/Initialize(mapload)
	. = ..()
	timerid = QDEL_IN(src, lifespan)

/obj/item/implant/tracking/c38/Destroy()
	deltimer(timerid)
	return ..()

/obj/item/implant/tracking/Initialize(mapload)
	. = ..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	GLOB.tracked_implants -= src
	return ..()

/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host.<BR>
				<b>Important Notes:</b> Implant [allow_teleport ? "also works" : "does not work"] as a teleporter beacon.<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage."}
	return dat
