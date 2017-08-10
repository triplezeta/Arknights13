
//Allows the ninja to kidnap people
/obj/item/clothing/suit/space/space_ninja/proc/ninjanet()
	var/mob/living/carbon/human/H = affecting
	var/mob/living/carbon/C = input("Select who to capture:","Capture who?",null) as null|mob in oview(H)

	if(!C||!(C in oview(H)))
		return 0

	if(!C.client)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
		to_chat(H, "<span class='warning'>[C.p_they(TRUE)] will bring no honor to your Clan!</span>")
		return
	if(locate(/obj/structure/energy_net) in C.loc)//Check if they are already being affected by an energy net.
		to_chat(H, "<span class='warning'>[C.p_they(TRUE)] are already trapped inside an energy net!</span>")
		return
	for(var/turf/T in getline(H.loc, C.loc))
		if(T.density)//Don't want them shooting nets through walls. It's kind of cheesy.
			to_chat(H, "<span class='warning'>You may not use an energy net through solid obstacles!</span>")
			return
	if(!ninjacost(200,N_STEALTH_CANCEL))
		H.Beam(C,"n_beam",time=15)
		H.say("Get over here!")
		var/obj/structure/energy_net/E = new /obj/structure/energy_net(C.loc)
		H.visible_message("<span class='danger'>[H] caught [C] with an energy net!</span>","<span class='notice'>You caught [C] with an energy net!</span>")
		E.affecting = C
		E.master = H
		spawn(0)//Parallel processing.
			E.process()
