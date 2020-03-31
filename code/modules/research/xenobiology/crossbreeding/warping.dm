
/*
Warping extracts crossbreed
put up a rune with bluespace effects, lots of those runes are fluff or act as a passive buff, others are just griefind tools.

*/

/obj/item/slimecross/warping
	name = "warped extract"
	desc = "It just won't stay in place."
	icon_state = "warping"
	effect = "warping"
	colour = "grey" ///default color of the crossbreed
	var/obj/effect/warped_rune/runepath ///what runes will be drawn depending on the crossbreed color
	var/warp_charge = 1 /// the number of "charge" a bluespace crossbreed start with
	var/max_charge = 1 ///max number of charge, might be different depending on the crossbreed (all crossbreed have 1 max charge for now)
	var/storing_time = 15 ///time it takes to store the rune back into the crossbreed
	var/drawing_time = 15 ///time it takes to draw the rune

/obj/effect/warped_rune
	name = "warped rune"
	desc = "An unstable rune born of the depths of bluespace"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "greyspace_rune"
	var/runepath = /obj/effect/warped_rune  ///serves as a way for some specific runes to identify themselves in the turf.TODO: you can just use src dumbass
	var/storing_time = 5 ///is only used for bluespace crystal erasing as of now
	anchored = TRUE
	layer = MID_TURF_LAYER
	resistance_flags = FIRE_PROOF  //It's only fireproof because of the fire rune and because how do you burn a rune anyway.
	var/turf/T //used on a LOT of runes, so we might as well put it here
	var/cooldown = 0 //cooldown for the rune process() only applies to certain runes
	var/max_cooldown = 100
	move_resist = INFINITY //here to avoid the rune being moved since it only sets it's turf once when it's drawn. doesn't include admin fuckery.

///runes can also be deleted by bluespace crystals if the xenobiologist is fucking everyone up and you need a way to destroy the rune.
/obj/effect/warped_rune/attackby(obj/item/stack/BC, mob/user)
	if(!istype(BC,/obj/item/stack/sheet/bluespace_crystal) && !istype(BC,/obj/item/stack/ore/bluespace_crystal))
		return
	if(do_after(user, storing_time,target = src)) //the time it takes to nullify it depends on the rune too
		to_chat(user, "<span class='notice'>You nullify the effects of the rune with the bluespace crystal!</span>")
		qdel(src)
		BC.amount--
		playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)
		if(BC.amount <= 0)
			qdel(BC)




/obj/effect/warped_rune/acid_act()
	visible_message("<span class='warning'>[src] has been dissolved by the acid</span>")
	playsound(src, 'sound/items/welder.ogg', 150, TRUE)
	qdel(src)

///nearly all runes use their turf in some way so we set T to their turf automatically, the rune also start on cooldown if it uses one.
/obj/effect/warped_rune/Initialize()
	.=..()
	T = get_turf(src)
	RegisterSignal(T, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_rune)
	cooldown = world.time + max_cooldown

/obj/effect/warped_rune/proc/clean_rune()
	qdel(src)

 ///using the extract on the floor will "draw" the rune.
/obj/item/slimecross/warping/afterattack(turf/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target) && locate(/obj/effect/warped_rune) in target) //check if the target is a floor and if there's a rune on said floor
		to_chat(user, "<span class='warning'>There is already a bluespace rune here!</span>")
		return
	if(istype(target, runepath))       //checks if the target is a rune and then if you can store it
		if(warp_charge >= max_charge)
			to_chat(user, "<span class='warning'>Your [src] is already full!</span>")
			return
		if(do_after(user, storing_time,target = target) && warp_charge < max_charge)
			to_chat(user, "<span class='notice'>You store the rune in [src].</span>")
			qdel(target)
			warp_charge++
			desc = "It just won't stay in place. it has [src.warp_charge] charge left"
			return

	if(!istype(target) || isspaceturf(target))
		return

	if(locate(/turf/closed) in target || locate(/obj/structure) in target) // check if there's a wall or a structure in the way
		to_chat(user, "<span class='warning'>something is in the way of the rune!</span>")
		return

	if(warp_charge > 0 && do_after(user, drawing_time,target = target)) //spawns the right rune if you have charge(s) left
		playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)

		if(warp_charge <= 0) //this is only here to fix a bug where the user can draw multiple runes at once if they spam click
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		warp_charge--
		desc = "It just won't stay in place. it has [src.warp_charge] charge left"
		new runepath(target)
		to_chat(user, "<span class='notice'>You carefully draw the rune with [src].</span>")



/obj/item/slimecross/warping/grey
	name = "greyspace crossbreed"
	colour = "grey"
	effect_desc = "Creates a rune. Extracts that are on the rune are absorbed, 8 extracts produces an adult slime of that color."
	runepath = /obj/effect/warped_rune/greyspace



/obj/effect/warped_rune/greyspace
	name = "greyspace rune"
	desc = "Death is merely a setback, anything can be rebuilt given the right components"
	icon_state = "greyspace_rune"
	var/i = 0 //number of slime extract currently absorbed by the rune
	var/mob/living/simple_animal/slime/S //S stands for the slime that will be spawned
	var/obj/item/slime_extract/extractype = 0 //extractype is used to remember the type of the extract on the rune
	max_cooldown = 50


/obj/effect/warped_rune/greyspace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/greyspace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		slimerevival()

///Makes a slime of the color of extract that were put on the runes.can only take one type of extract between slime spawning.
/obj/effect/warped_rune/greyspace/proc/slimerevival()
	if(i <! 8) // this shouldn't happen and will bring back the count to 7
		i = 7
		return

	for(var/obj/item/slime_extract/extr in T)
		if( extr.color_slime != extractype && extractype != 0) //check if the extract is the first one or of the right color.
			return
		extractype = extr.color_slime  //keep the slime extract color in storage
		qdel(extr)    //vores the slime extract
		playsound(T, 'sound/effects/splat.ogg', 20, TRUE)
		i++
		if (i != 8)
			return

		playsound(T, 'sound/effects/splat.ogg', 20, TRUE)
		S = new(T, extr.color_slime)  //spawn a slime from the extract's color
		S.amount_grown = SLIME_EVOLUTION_THRESHOLD
		S.Evolve() //slime starts as an adult
		i = 0 
		extractype = 0 // reset the type to allow a new extract type



/*The orange rune warp basically ignites whoever walks on it,the fire will teleport you at random as long as you are on fire*/


/obj/item/slimecross/warping/orange
	desc = "Creates a rune "
	colour = "orange"
	runepath = /obj/effect/warped_rune/orangespace
	effect_desc = "Creates a rune burning with bluespace fire, anyone walking into the rune will ignite and teleport randomly as long as they are on fire"
	drawing_time = 150

/obj/effect/warped_rune/orangespace
	desc = "When all is reduced to ash, it shall be reborn from the depth of bluespace."
	icon_state = "bluespace_fire"
	max_cooldown = 50



/obj/effect/warped_rune/orangespace/Initialize()
	.=..()
	RegisterSignal(T,COMSIG_ATOM_ENTERED,.proc/teleport_fire) 

///teleport people and put them on fire if they run into the rune.
/obj/effect/warped_rune/orangespace/proc/teleport_fire()
	if(!locate(/obj/effect/hotspot) in T) //doesn't teleport items but put them on fire anyway for good measure.
		new /obj/effect/hotspot(T)

	for(var/mob/living/F in T)
		do_teleport(F, T, 3, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
		F.adjust_fire_stacks(10)
		F.IgniteMob()





/*The purple warp rune makes suture and ointment if you put cloth or plastic on it. */




/obj/item/slimecross/warping/purple
	colour = "purple"
	runepath = /obj/effect/warped_rune/purplespace
	effect_desc = "Draws a rune that transforms plastic into regenerative mesh and cloth into suture"

/obj/effect/warped_rune/purplespace
	desc = "When all that was left were plastic walls and the clothes on their back, they knew what they had to do."
	icon_state = "purplespace"
	var/obj/item/stack/medical/suture/S  
	var/obj/item/stack/medical/mesh/M   
	max_cooldown = 30

/obj/effect/warped_rune/purplespace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/purplespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		transmute_heal()


///""transforms"" cloth and plastic into suture and regenerative mesh
/obj/effect/warped_rune/purplespace/proc/transmute_heal()
	for(var/obj/item/stack/sheet/plastic/P in T)  //transmute Plastic into regenerative mesh
		if(P.amount < 2)
			return

		P.amount -= 2
		M = new (T,1)

		playsound(T, 'sound/effects/splat.ogg', 20, TRUE)
		if(P.amount <= 0)
			qdel(P)

	for(var/obj/item/stack/sheet/cloth/C in T) //transmute cloth into suture
		if(C.amount < 2)
			return
		C.amount -= 2
		S = new(T, 1)


		playsound(T, 'sound/effects/splat.ogg', 20, TRUE)
		if(C.amount <= 0)
			qdel(C)






/* the blue warp rune  keeps a tile slippery CONSTANTLY by adding lube over it. Excellent if you hate standing up.*/



/obj/item/slimecross/warping/blue
	colour = "blue"
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "creates a rune that constantly wet itself with slippery lube as long as the rune is up"

/obj/effect/warped_rune/cyanspace
	icon_state = "slipperyspace"
	desc = "You will crawl like the rest. Standing up is not an option."

/obj/effect/warped_rune/cyanspace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/warped_rune/cyanspace/process()
	slippery_rune(T)

///Spawn lube on the tile the rune is on every process, as horrible as it sounds.
/obj/effect/warped_rune/cyanspace/proc/slippery_rune(turf/open/T)
	T.MakeSlippery(TURF_WET_LUBE,min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)





/*      Metal rune : makes an invisible wall. actually I lied, the rune is the wall.*/


/obj/item/slimecross/warping/metal
	colour = "metal"
	runepath = /obj/effect/warped_rune/metalspace
	effect_desc = "Draws a rune that prevents passage above it, takes longer to store and draw than other runes."
	drawing_time = 100  //Long to draw like most griefing runes
	max_charge = 4 //higher to allow a wider degree of fuckery, still takes a long ass time to draw but you can draw multiple ones at once.
	warp_charge = 4

//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "Words are powerful things, they can stop someone dead in their tracks if used in the right way"
	icon_state = "metal_space"
	density = TRUE
	storing_time = 10 //faster to destroy with the bluespace crystal than with the crossbreed








/*  Yellow rune space acts as an infinite generator, works without power and anywhere, recharges the APC of the room it's in and any battery fueled things. */


/obj/item/slimecross/warping/yellow
	colour = "yellow"
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = "Draws a rune that infinitely recharge cell fueled things that are on it, it will also passively recharge the APC of the room"


/obj/effect/warped_rune/yellowspace
	desc = "Where does all this energy come from? Who knows,the process does not matter, only the result."
	icon_state = "elec_rune"

/obj/effect/warped_rune/yellowspace/Initialize()
	.=..()
	START_PROCESSING(SSmachines, src)


/obj/effect/warped_rune/yellowspace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		apc_charge()
		electrivore()

///recharge the APC every 10 seconds by 10%
/obj/effect/warped_rune/yellowspace/proc/apc_charge()

	var/area/A = get_area(T)
	for(var/obj/machinery/power/apc/P in A)
		if(!P.cell)
			return
		if(P.cell.charge <! (P.cell.maxcharge))
			return
		P.cell.charge += P.cell.maxcharge/10 //will basically recharge 10% of the APC cell every 10 seconds.
		if(P.cell.charge > P.cell.maxcharge)
			P.cell.charge = P.cell.maxcharge //set the cell back to 100% if it goes overboard.


///charge whatever battery is put on the rune, is triggered whenever a battery/baton/energy gun is on the rune
/obj/effect/warped_rune/yellowspace/proc/electrivore()

	for(var/obj/item/I in T) //check if there's even an item on there
		if(istype(I, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = I
			if(B.cell.charge < B.cell.maxcharge)
				B.cell.charge += B.cell.maxcharge/5
				B.update_icon()
				if(B.cell.charge > B.cell.maxcharge)
					B.cell.charge = B.cell.maxcharge
					return

		if(istype(I,/obj/item/gun/energy)) //if they were all in the same subtype I could just use a proc for each of them but instead we got this shit
			var/obj/item/gun/energy/E = I
			if(E.cell.charge < E.cell.maxcharge)
				E.cell.charge += E.cell.maxcharge/5
				E.update_icon()
				if(E.cell.charge > E.cell.maxcharge)
					E.cell.charge = E.cell.maxcharge

		if(istype(I, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/C = I
			if(C.charge < C.maxcharge)
				C.charge += C.maxcharge/5
				C.update_icon()
				if(C.charge > C.maxcharge)
					C.charge = C.maxcharge
					return









/* Dark purple crossbreed, Fill up any beaker like container with 50 unit of plasma dust every 30 seconds  */


/obj/item/slimecross/warping/darkpurple
	colour = "dark purple"
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = "Makes a rune that will periodically create plasma dust,to harvest it simply put a beaker of some kind over the rune."


/obj/effect/warped_rune/darkpurplespace
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "plasma_crystal"
	desc = "The purple ocean would only grow bigger with time."
	runepath = /obj/effect/warped_rune/darkpurplespace
	max_cooldown = 300 //creates 50 unit every minute


/obj/effect/warped_rune/darkpurplespace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)



/obj/effect/warped_rune/darkpurplespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		dust_maker()


/obj/effect/warped_rune/darkpurplespace/proc/dust_maker()
	for(var/obj/item/reagent_containers/glass/RG in T)
		RG.reagents.add_reagent(/datum/reagent/toxin/plasma,25)



/*People who step on the dark blue rune will suddendly get very cold,pretty straight forward.*/


/obj/item/slimecross/warping/darkblue
	colour = "dark blue"
	runepath = /obj/effect/warped_rune/darkbluespace
	effect_desc = "Draws a rune creating an unbearable cold above the rune."


/obj/effect/warped_rune/darkbluespace
	desc = "Cold,so cold, why does the world always feel so cold?"
	icon_state = "cold_rune"


/obj/effect/warped_rune/darkbluespace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(get_turf(src),COMSIG_ATOM_ENTERED,.proc/cold_tile)

/obj/effect/warped_rune/darkbluespace/process() //will keep the person on the tile cold for good measure
	cold_tile()


///it makes people that step on the tile very cold.
/obj/effect/warped_rune/darkbluespace/proc/cold_tile()
	for(var/mob/living/carbon/H in T)
		H.adjust_bodytemperature(-1000) //Not enough to crit anyone not already weak to cold




/* makes a rune that absorb food, whenever someone step on the rune the nutrition come back to them, not all of it of course.
TODO : Improve it so it doesn't steal the spotlight of the chef but instead acts as a direct help to the chef to make his work more convenient
*/


/obj/item/slimecross/warping/silver
	colour = "silver"
	effect_desc = "Draws a rune that will absorb nutriment from foods that are above it and then redistribute it to anyone passing by."
	runepath = /obj/effect/warped_rune/silverspace


/obj/effect/warped_rune/silverspace
	desc = "Feed me and I will feed you back, such is the deal."
	icon_state = "food_rune"
	var/nutriment = 0 //Used to remember how much food/nutriment has been absorbed by the rune

/obj/effect/warped_rune/silverspace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)


///any food put on the rune with nutrients will have said nutrients absorbed by the rune. Then the nutrients will be redirected to the next stepping on the rune
/obj/effect/warped_rune/silverspace/process()
	for(var/obj/item/reagent_containers/food/F in T) //checks if there's snacks on the rune.and then vores the food
		for(var/datum/reagent/consumable/nutriment/N in F.reagents.reagent_list)
			F.reagents.remove_reagent(N.type,1) //take away exactly 1 nutrient from the food each time
			nutriment++
			desc = "Feed me and I will feed you back, I currently hold [nutriment] units of nutrients."
	for(var/mob/living/carbon/human/H in T)
		if((H.nutrition > NUTRITION_LEVEL_WELL_FED) || (nutriment <= 0)) //don't need to feed a perfectly healthy boi
			return
		H.reagents.add_reagent(/datum/reagent/consumable/nutriment,1) //with the time nutriment takes to metabolise it might make them fat oopsie
		nutriment--
		desc = "Feed me and I will feed you back, I currently hold [nutriment] units of nutrients."

/* Bluespace rune,reworked so that the last person that walked on the rune will swap place with the next person stepping on it*/

/obj/item/slimecross/warping/bluespace
	colour = "bluespace"
	runepath = /obj/effect/warped_rune/bluespace
	effect_desc = "Puts up a rune that will swap the next two person that walk on the rune."


obj/effect/warped_rune/bluespace
	desc = "Everyone is everywhere at once, yet so far away from each other"
	icon_state = "bluespace_rune"
	runepath = /obj/effect/warped_rune/bluespace
	var/mob/living/carbon/C // first person to run into the rune
	var/mob/living/carbon/M //second person that run into the rune
	var/count = 0
	max_cooldown = 20 //only here to avoid spam lag


///the first two person that stepped on the rune swap places after the second person stepped on it. TODO: fix the potential lag abyse
obj/effect/warped_rune/bluespace/Crossed(atom/movable/AM)
	..()
	if(cooldown > world.time) //checks if 2 seconds have passed to avoid spam.
		return
	cooldown = max_cooldown + world.time //sorry no constantly running into it with a frend for free lag.
	if(!istype(AM,/mob/living/carbon/human))
		return

	if(count == 0)

		C = AM //remember who stepped in so we can teleport them later.
		count++
		return
	if(AM == C)
		return
	M = AM
	do_teleport(M, C, forceMove = TRUE)//swap both of their place.
	do_teleport(C, T, forceMove = TRUE)
	count--








/* basically a timestop trap, activate when ANYTHING goes over it, that includes projectiles and what not.*/


/obj/item/slimecross/warping/sepia
	colour = "sepia"
	runepath = /obj/effect/warped_rune/sepiaspace
	effect_desc = "Draws a rune that stops time for whatever pass over it."
	drawing_time = 200 //much longer to draw than other runes because it fucking stops time

obj/effect/warped_rune/sepiaspace
	icon_state = "time_space"
	desc = "The clock is ticking, but in what direction?"
	var/TS = /obj/effect/timestop //The timestop path here used during the timewarp() proc



///stops time on a single tile for 5 seconds
obj/effect/warped_rune/sepiaspace/Crossed()
	..()
	if(locate(TS) in T)//checks if there's already a timestop on the rune. here to avoid the effect triggering multiple time at the same time.
		return
	new TS(T, 0, 50) //spawn a timestop for 5 seconds.







/*Cerulean crossbreed : creates a hologram of the last person that stepped on the tile */

/obj/item/slimecross/warping/cerulean
	colour = "cerulean"
	runepath = /obj/effect/warped_rune/ceruleanspace
	effect_desc = "Draws a rune creating a hologram of the last living thing that stepped on the tile. Can draw up to 6 runes."
	max_charge = 6
	warp_charge = 6 //it's not that powerful anyway so we might as well let them do a hologram museum


/obj/effect/warped_rune/ceruleanspace
	desc = "A shadow of what once passed these halls, a memory perhaps?"
	icon_state = "holo_rune"
	var/obj/effect/overlay/holotile
	var/mob/living/L


///makes a hologram of the mob stepping on the tile, any new person stepping in will replace it with a new hologram
/obj/effect/warped_rune/ceruleanspace/Crossed(atom/movable/AM)
	..()
	if(!istype(AM,/mob/living))
		return
	if(locate(holotile) in T)//here to both delete the previous hologram,
		qdel(holotile)
	L = AM
	holotile = new(T) //setting up the hologram to look like the person that just stepped in
	holotile.icon = L.icon
	holotile.icon_state = L.icon_state
	holotile.alpha = 100
	holotile.name = "[L.name] (Hologram)"
	holotile.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	holotile.copy_overlays(L, TRUE)

///destroys the hologram with the rune
/obj/effect/warped_rune/ceruleanspace/Destroy()
	..() //needed so the rune still gets stored by the crossbreed
	qdel(holotile)





/obj/item/slimecross/warping/pyrite
	colour = "pyrite"
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "draws a rune that will randomly color whoever steps on it"

/obj/effect/warped_rune/pyritespace
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "colorune"


///colors whoever steps on the rune randomly
/obj/effect/warped_rune/pyritespace/Crossed(atom/movable/AM)
	..()
	AM.color = rgb(rand(0,255),rand(0,255),rand(0,255))


/* Will make anyone on the rune do much more punch damage. Doesn't boost normal melee weapon damage, may need rebalancing,*/

/obj/item/slimecross/warping/red
	colour = "red"
	runepath = /obj/effect/warped_rune/redspace
	effect_desc = "Draws a rune severely increasing your punch damage as long as you stand on it."
	drawing_time = 100 // slightly longer to draw so you don't draw it in the middle of a fight.

/obj/effect/warped_rune/redspace
	desc = "Progress is made through adversity, power is obtained through violence"
	icon_state = "rage_rune"
	var/mob/living/carbon/human/H


///boost up the unarmed damage of the person currently on the tile.
/obj/effect/warped_rune/redspace/Crossed(atom/movable/AM)
	..()
	if(!istype(AM,/mob/living/carbon/human))
		return
	H = AM
	H.dna.species.punchstunthreshold += 20//we don't want them to insta stun everyone.
	H.dna.species.punchdamagelow += 20
	H.dna.species.punchdamagehigh += 20 //buffed up punch damage
	to_chat(H, "<span class='warning'>You feel the urge to punch something really hard!</span>")


///takes away the punch damage when you leave
/obj/effect/warped_rune/redspace/Uncrossed(atom/movable/AM)
	if(!istype(AM,/mob/living/carbon/human)) //checks if the person that just left is the same as the currently enraged person
		return
	H = AM
	H.dna.species.punchstunthreshold -= 20
	H.dna.species.punchdamagelow -= 20
	H.dna.species.punchdamagehigh -= 20


///destroying the rune will also remove the punch force of the persons on the rune.
/obj/effect/warped_rune/redspace/Destroy()
	..()
	for(var/mob/living/carbon/human/D in T) // takes away people's punch damage that are on the rune anyway.
		H.dna.species.punchstunthreshold -= 20
		H.dna.species.punchdamagelow -= 20
		H.dna.species.punchdamagehigh -= 20.





/* Green rune vores plasma and spews out xeno resin which lets you build xeno structure*/

/obj/item/slimecross/warping/green
	colour = "green"
	runepath = /obj/effect/warped_rune/greenspace
	drawing_time = 100

/obj/effect/warped_rune/greenspace
	icon_state = "xeno_rune"
	desc = "We will build walls out of our fallen foes, they shall fear our very buildings."
	var/obj/item/stack/sheet/xeno_resin/X
	max_cooldown = 100



/obj/item/stack/sheet/xeno_resin
	name = "Resin sheets"
	icon = 'icons/mob/alien.dmi'
	icon_state = "nestoverlay" //literally just the xeno nest icon
	merge_type = /obj/item/stack/sheet/xeno_resin



/obj/effect/warped_rune/greenspace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/greenspace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		transmute_resin()

/obj/effect/warped_rune/greenspace/proc/transmute_resin()
	for(var/obj/item/stack/sheet/mineral/plasma/P in T)
		X = new(T)
		P.amount--
		if(P.amount <= 0)
			qdel(P)

//note : some of these can only be built ON resin weeds such as the resin nest.
GLOBAL_LIST_INIT(resin_recipes, list ( \
	new/datum/stack_recipe("Resin seed", /obj/structure/alien/weeds/node, 10, one_per_turf = 1, on_floor = 1, time = 100), \
	new/datum/stack_recipe("Resin Wall", /obj/structure/alien/resin/wall, 3, one_per_turf = 1, on_floor = 1 , time = 50), \
	new/datum/stack_recipe("Fake hatched egg", /obj/structure/alien/egg/burst, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Resin nest", /obj/structure/bed/nest , 5, one_per_turf = 1, on_floor = 0, time = 50), \
	))

/obj/item/stack/sheet/xeno_resin/get_main_recipes()
	.= ..()
	. += GLOB.resin_recipes







/* pink rune, makes people slightly happier after walking on it*/

/obj/item/slimecross/warping/pink
	colour = "pink"
	effect_desc = "Draws a rune that makes people happier!"
	runepath = /obj/effect/warped_rune/pinkspace



/obj/effect/warped_rune/pinkspace
	desc = "Love is the only reliable source of happiness we have left. But like everything, it comes with a price."
	icon_state = "love_rune"


///adds the jolly mood effect along with hug sound effect.
/obj/effect/warped_rune/pinkspace/Crossed(atom/movable/AM)
	..()
	if(istype(AM,/mob/living/carbon/human))
		playsound(T, "sound/weapons/thudswoosh.ogg", 50, TRUE)
		SEND_SIGNAL(AM, COMSIG_ADD_MOOD_EVENT,"jolly", /datum/mood_event/jolly)
		AM.visible_message(AM, "<span class='notice'>You feel happier.</span>")




/*Gold rune : Turn things over it to gold, completely fucks over economy */

/obj/item/slimecross/warping/gold
	colour = "gold"
	runepath = /obj/effect/warped_rune/goldspace
	effect_desc = "Draws a rune capable of turning nearly anything put on it to gold every 30 seconds"

/obj/effect/warped_rune/goldspace
	icon_state = "midas_rune"
	desc = "When everything is abundant, it becomes easy to forget when one had to work to obtain anything."
	max_cooldown = 300

/obj/effect/warped_rune/goldspace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)

///turn anything on the tile to a golden version of themselves. Sheets of any kind will be directly turned into gold bars.
/obj/effect/warped_rune/goldspace/process()
	if(cooldown > world.time)
		return
	cooldown = world.time + max_cooldown

	for(var/obj/item/stack/sheet/S in T)
		if(istype(S,/obj/item/stack/sheet/mineral/gold)) //can't turn gold into gold
			return
		var/obj/item/stack/sheet/mineral/gold/G = new(T)
		G.amount = S.amount //as broken as it sounds if you mass produce easy stacks.
		qdel(S)
		return //return so it only does one stack at a time

	for(var/obj/item/I in T) //basically copied from the metalgen chem code with a few minor tweaks to make it gold.
		var/gold_amount = 0
		for(var/B in I.custom_materials)
			gold_amount += I.custom_materials[B]

		if(!gold_amount)
			gold_amount = 50 //if the item doesn't have any material it makes the item worth around 0.005 gold bars.

		I.material_flags = MATERIAL_COLOR | MATERIAL_ADD_PREFIX | MATERIAL_AFFECT_STATISTICS
		I.set_custom_materials(list(/datum/material/gold=gold_amount))
		return



/*Adamantine rune, will spawn ores depending on the mineral rocks surrounding it. Here to make miners do their job even less.  */

/obj/item/slimecross/warping/adamantine
	colour = "adamantine"
	runepath = /obj/effect/warped_rune/adamantinespace
	effect_desc = "draws a rune capable of copying the ores of nearby mineral rocks."


/obj/effect/warped_rune/adamantinespace  //doesn't have a rune icon yet please spriters help me I can't sprite for shit I beg you
	desc = "The universe's ressource are nothing but tools for us to use and abuse."
	max_cooldown = 300  //"mines" things every 30 seconds.
	icon_state = "mining_rune"

/obj/effect/warped_rune/adamantinespace/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/warped_rune/adamantinespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		auto_mining()

/obj/effect/warped_rune/adamantinespace/proc/auto_mining()
	for(var/turf/closed/mineral/M in range(7,T)) //the range is pretty big to at least try to rival miners and their plasma cutters.
		if(M.mineralType != null) //here to counter runtimes when the mineral type of the rock is null
			new M.mineralType(T)


/* Lightpink rune. Revive suicided/soulless corpses by yeeting a willing soul into it */

/obj/item/slimecross/warping/lightpink
	colour = "light pink"
	runepath = /obj/effect/warped_rune/lightpinkspace
	effect_desc = "draws a rune that will repair the soul of a human corpse in the hope of bringing them back to life."
	drawing_time = 100

/obj/effect/warped_rune/lightpinkspace
	icon_state = "necro_rune" //use the purple rune icon for now.will really have to change that later
	desc = "Souls are like any other material, You just have to find the right place to manufacture them."
	max_cooldown = 100 


/obj/effect/warped_rune/lightpinkspace/attack_hand(mob/living/U)
	if(cooldown > world.time)
		to_chat(U, "<span class='warning'>The rune is still charging!</span>")
		return

	for(var/mob/living/carbon/human/L in T)
		if(!L.getorgan(/obj/item/organ/brain) || L.key || L.get_ghost(FALSE, TRUE)) //checks if the ghost and brain's there
			to_chat(U, "<span class='warning'>This body can't be fixed by the rune in this state!</span>")
			return
		cooldown = world.time + max_cooldown //only start the cooldown if there's an actual body on there and it can be resurrected.
		to_chat(U, "<span class='warning'>The rune is trying to repair [L.name]'s soul!</span>")
		var/list/candidates = pollCandidatesForMob("Do you want to replace the soul of [L.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, L,POLL_IGNORE_SENTIENCE_POTION)//sentience flags because lightpink. 


		if(LAZYLEN(candidates)) //check if anyone wanted to play as the dead person
			var/mob/dead/observer/C = pick(candidates)
			L.key = C.key
			L.suiciding = 0 //turns off the suicide var just in case
			L.revive(full_heal = TRUE, admin_revive = TRUE) //might as well go all the way
			to_chat(L, "<span class='warning'>You may wear the skin of someone else, but you know who and what you are. Pretend to be the original owner of this body as best as you can.</span>")
			to_chat(U, "<span class='notice'>[L.name] is slowly getting back up with an empty look in [L.p_their()] eyes. It...worked?</span>")
			playsound(L, "sound/magic/castsummon.ogg", 50, TRUE)
			return  
		else
			to_chat(U, "<span class='warning'>The rune failed! Maybe you should try again later.</span>")




/*      black space rune : will swap out the species of the two next person walking on the rune  */

/obj/item/slimecross/warping/black
	colour = "black"
	runepath = /obj/effect/warped_rune/blackspace
	effect_desc = "Will swap the species of the first two humanoids that walk on the rune. Also works on corpses."
	drawing_time = 100

/obj/effect/warped_rune/blackspace
	icon_state = "cursed_rune" 
	desc = "Your body is the problem, limited, so very very limited."
	var/mob/living/carbon/human/H1
	var/mob/living/carbon/human/H2
	var/stepped_on = FALSE //here to check if someone already stepped on the rune

/obj/effect/warped_rune/blackspace/Initialize()
	.=..()
	cooldown = 0 //doesn't start on cooldown like most runes
	
///will swap the species of the first two human or human subset that walk on the rune	
/obj/effect/warped_rune/blackspace/Crossed(atom/movable/AM)
	..()
	if(cooldown > world.time) //here to avoid spam/lag 
		to_chat(AM, "<span class='warning'>The rune needs a little more time before processing your DNA!</span>")
		return
	if(!istype(AM,/mob/living/carbon/human)) 
		return
	if(!stepped_on)
		H1 = AM
		stepped_on = TRUE
		return
	if(AM == H1) 
		return
	H2 = AM 
	var/dna1 = H1.dna.species
	var/dna2 = H2.dna.species
	H2.set_species(dna1)  //swap the species 
	H1.set_species(dna2)
	stepped_on = FALSE
	cooldown = max_cooldown + world.time //the default max cooldown is of 10 seconds



/*
Anything after this is in """progress""" and isn't part of the actual code


/*Any explosion over the rune will convert anything in the range of the explosion to SLIME, not people because even I'm not that evil */

/obj/item/slimecross/warping/oil
	colour = "oil"
	runepath = /obj/effect/warped_rune/oilspace


/obj/effect/warped_rune/oilspace
	desc = "haha bomb machine go boom"

/obj/item/slimecross/warping/rainbow
	colour = "rainbow"
	runepath = /obj/effect/warped_rune/rainbowspace
	*/
