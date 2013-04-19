proc/getbrain(mob/living/carbon/M)
	if(istype(M))
		for(var/obj/item/I in M.internal_organs)
			if(istype(I, /obj/item/medical/organ/brain))
				return I


proc/getappendix(mob/living/carbon/M)
	if(istype(M))
		for(var/obj/item/I in M.internal_organs)
			if(istype(I, /obj/item/medical/organ/appendix))
				return I