/datum/hud/living/blobbernaut/New(mob/living/owner)
	. = ..()

	blobpwrdisplay = new /obj/screen/healths/blob/overmind()
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay
